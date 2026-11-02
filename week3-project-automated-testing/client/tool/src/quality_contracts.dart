import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

class QualityFailure implements Exception {
  const QualityFailure(this.message, {this.code = 1});
  final String message;
  final int code;
  @override
  String toString() => message;
}

typedef LineCoverage = Map<String, Map<int, int>>;

class CoverageCount {
  const CoverageCount(this.hit, this.total);
  final int hit, total;
  double get percent => total == 0 ? 0 : hit * 100 / total;
  Map<String, Object> toJson() => {
    'hit': hit,
    'total': total,
    'percent': percent,
  };
}

bool isGenerated(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.contains('/l10n/generated/');
String normalizeCoveragePath(
  String source, {
  required String workspace,
  required String member,
  Map<String, String> packages = const {},
}) {
  final root = Directory(workspace).absolute.uri.normalizePath();
  Uri absolute;
  if (source.startsWith('package:')) {
    final value = source.substring(8);
    final slash = value.indexOf('/');
    final package = slash < 0 ? value : value.substring(0, slash);
    final owner = packages[package];
    if (owner == null)
      throw QualityFailure('Unknown coverage package: $package');
    absolute = root.resolve('$owner/lib/${value.substring(slash + 1)}');
  } else if (source.startsWith('file:')) {
    absolute = Uri.parse(source);
  } else {
    absolute = root.resolve('$member/').resolve(source);
  }
  final path = absolute.normalizePath().toFilePath();
  final prefix = root.toFilePath();
  if (!path.startsWith(prefix))
    throw QualityFailure('Coverage source escapes workspace: $source');
  return path.substring(prefix.length).replaceAll('\\', '/');
}

LineCoverage parseLcov(
  String input, {
  required String workspace,
  required String member,
  Map<String, String> packages = const {},
}) {
  final output = <String, Map<int, int>>{};
  String? source;
  for (final line in const LineSplitter().convert(input)) {
    if (line.startsWith('SF:')) {
      source = normalizeCoveragePath(
        line.substring(3),
        workspace: workspace,
        member: member,
        packages: packages,
      );
      output.putIfAbsent(source, () => {});
    } else if (line.startsWith('DA:')) {
      if (source == null) throw const QualityFailure('LCOV line has no source');
      final parts = line.substring(3).split(',');
      final number = int.tryParse(parts.first);
      final hits = parts.length < 2 ? null : int.tryParse(parts[1]);
      if (number == null || number <= 0 || hits == null || hits < 0)
        throw const QualityFailure('Malformed LCOV line');
      output[source]![number] = math.max(output[source]![number] ?? 0, hits);
    } else if (line == 'end_of_record') {
      source = null;
    }
  }
  return output;
}

LineCoverage mergeCoverage(Iterable<LineCoverage> reports) {
  final merged = <String, Map<int, int>>{};
  for (final report in reports) {
    for (final file in report.entries) {
      final lines = merged.putIfAbsent(file.key, () => {});
      for (final line in file.value.entries) {
        lines[line.key] = math.max(lines[line.key] ?? 0, line.value);
      }
    }
  }
  return merged;
}

CoverageCount countCoverage(LineCoverage report, Set<String> required) {
  var total = 0, hit = 0;
  for (final file in required) {
    final lines = report[file];
    if (lines == null || lines.isEmpty)
      throw QualityFailure(
        'Missing/unusable coverage for executable source: $file',
      );
    total += lines.length;
    hit += lines.values.where((value) => value > 0).length;
  }
  return CoverageCount(hit, total);
}

CoverageCount checkCoverage(
  LineCoverage report,
  Set<String> required, {
  int thresholdBasisPoints = 8500,
}) {
  if (required.isEmpty)
    throw const QualityFailure('Executable coverage scope cannot be empty');
  final count = countCoverage(report, required);
  if (count.hit * 10000 < count.total * thresholdBasisPoints)
    throw QualityFailure(
      'Coverage ${count.percent.toStringAsFixed(2)}% is below ${thresholdBasisPoints / 100}%',
    );
  return count;
}

void validateScope(Set<String> actual, Set<String> classified) {
  final missing = actual.difference(classified);
  final stale = classified.difference(actual);
  if (missing.isNotEmpty || stale.isNotEmpty)
    throw QualityFailure(
      'Coverage scope mismatch. Unclassified: $missing; missing files: $stale',
    );
}

Set<String> parseAcceptedExamples(String input) {
  final result = <String>{};
  String? id;
  bool outline = false, examples = false;
  List<String>? headings;
  for (final line in const LineSplitter().convert(input)) {
    final tag = RegExp(r'^\s*@(MOV-[A-Z0-9]+-[0-9]{3})\s*$').firstMatch(line);
    if (tag != null) {
      id = tag.group(1);
      outline = false;
      examples = false;
      headings = null;
      continue;
    }
    final value = line.trim();
    if (value.startsWith('Scenario:')) {
      if (id != null) result.add(id);
      outline = false;
    }
    if (value.startsWith('Scenario Outline:')) outline = true;
    if (outline && value == 'Examples:') {
      examples = true;
      headings = null;
      continue;
    }
    if (examples && value.startsWith('|') && value.endsWith('|')) {
      final cells = value
          .substring(1, value.length - 1)
          .split('|')
          .map((cell) => cell.trim())
          .toList();
      if (headings == null) {
        headings = cells;
        continue;
      }
      if (cells.length != headings.length || id == null)
        throw const QualityFailure('Malformed scenario examples');
      result.add(
        '$id|${[for (var i = 0; i < cells.length; i++) '${headings[i]}=${cells[i]}'].join('|')}',
      );
    }
  }
  return result;
}

class TestEvidence {
  const TestEvidence({required this.passed, this.skipped = false});
  final bool passed, skipped;
}

void checkAcceptance(
  Set<String> expected,
  Map<String, List<String>> manifest,
  Map<String, TestEvidence> executed,
) {
  final missing = expected.difference(manifest.keys.toSet());
  final unknown = manifest.keys.toSet().difference(expected);
  if (missing.isNotEmpty || unknown.isNotEmpty)
    throw QualityFailure(
      'Acceptance manifest mismatch. Missing: $missing; unknown: $unknown',
    );
  final failures = <String>[];
  for (final entry in manifest.entries) {
    if (entry.value.isEmpty) {
      failures.add('${entry.key}: no tests');
      continue;
    }
    for (final test in entry.value) {
      final evidence = executed[test];
      if (evidence == null || !evidence.passed || evidence.skipped)
        failures.add('${entry.key}: $test was not executed successfully');
    }
  }
  if (failures.isNotEmpty) throw QualityFailure(failures.join('\n'));
}

bool hasSoloTest(String source) =>
    RegExp(r'\b(?:test|testWidgets|group)\s*\.\s*only\s*\(').hasMatch(source);
void validateNativeEvidence(Map<String, dynamic> evidence) {
  const kinds = {
    'N1': 'simulatorProcess',
    'N2': 'simulatorLifecycle',
    'N3': 'nativeBrowser',
    'N4': 'nativeAccessibility',
  };
  for (final entry in evidence.entries) {
    final row = Map<String, dynamic>.from(entry.value as Map);
    if (!kinds.containsKey(entry.key))
      throw QualityFailure('Unknown native check: ${entry.key}');
    if (row['status'] == 'notRun') continue;
    if (row['status'] != 'passed' && row['status'] != 'failed')
      throw QualityFailure('Invalid native status: ${entry.key}');
    if (row['kind'] != kinds[entry.key] ||
        row['simulatorId'] is! String ||
        row['revision'] is! String ||
        row['artifacts'] is! List ||
        (row['artifacts'] as List).isEmpty ||
        entry.key == 'N3' && row['mode'] != 'live') {
      throw QualityFailure('${entry.key} lacks genuine native evidence');
    }
  }
}

Future<void> requireSuccessfulStep(
  String name,
  Future<int> Function() run,
) async {
  final code = await run();
  if (code != 0)
    throw QualityFailure('$name failed with exit code $code', code: code);
}

/// Converts the machine reporter into exact test-name evidence; suite hooks and
/// loading events cannot satisfy an acceptance obligation.
Map<String, TestEvidence> machineTestEvidence(
  String contents, {
  required String member,
  String? workspace,
}) {
  final root = workspace ?? Directory.current.path;
  final suites = <int, String>{};
  final tests = <int, ({String name, String file})>{};
  final results = <String, TestEvidence>{};
  for (final line in const LineSplitter().convert(contents)) {
    dynamic event;
    try {
      event = jsonDecode(line);
    } catch (_) {
      continue;
    }
    if (event is! Map<String, dynamic>) continue;
    if (event['type'] == 'suite') {
      final suite = event['suite'] as Map<String, dynamic>;
      suites[suite['id'] as int] = suite['path'] as String;
    } else if (event['type'] == 'testStart') {
      final test = event['test'] as Map<String, dynamic>;
      final source = suites[test['suiteID']] ?? test['url'] as String?;
      if (source == null) continue;
      tests[test['id'] as int] = (
        name: test['name'] as String,
        file: normalizeCoveragePath(source, workspace: root, member: member),
      );
    } else if (event['type'] == 'testDone') {
      final test = tests[event['testID']];
      if (test == null || event['hidden'] == true) continue;
      final key = '${test.file}|${test.name}';
      final value = TestEvidence(
        passed: event['result'] == 'success',
        skipped: event['skipped'] == true,
      );
      final previous = results[key];
      results[key] = TestEvidence(
        passed: value.passed && (previous?.passed ?? true),
        skipped: value.skipped || (previous?.skipped ?? false),
      );
    }
  }
  return results;
}
