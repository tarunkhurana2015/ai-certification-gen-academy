import 'dart:convert';
import 'dart:io';
import 'quality_contracts.dart';

const members = [
  'packages/movies_core',
  'packages/movies_data',
  'packages/movies_ui',
  'packages/catalog_feature',
  'packages/home_feature',
  'packages/browse_feature',
  'packages/search_feature',
  'packages/library_feature',
  'apps/app',
];
const workspacePackages =
    r'^(movies|movies_core|movies_data|movies_ui|catalog_feature|home_feature|browse_feature|search_feature|library_feature)$';
const _encoder = JsonEncoder.withIndent('  ');

class WorkspaceQuality {
  WorkspaceQuality(this.root) {
    output = Directory('$root/artifacts/quality')..createSync(recursive: true);
  }
  final String root;
  late final Directory output;
  final commands = <Map<String, Object>>[];
  String get dart => Platform.resolvedExecutable;
  String get flutter =>
      Platform.environment['MOVIES_FLUTTER_BIN'] ??
      '${File(dart).parent.parent.parent.parent.path}/flutter';
  void write(String filename, Object value) => File(
    '${output.path}/$filename',
  ).writeAsStringSync(_encoder.convert(value));
  Future<void> step(
    String label,
    String executable,
    List<String> args, {
    String member = '',
    String? logName,
  }) async {
    stdout.writeln(label);
    await requireSuccessfulStep(label, () async {
      final result = await Process.run(
        executable,
        args,
        workingDirectory: member.isEmpty ? root : '$root/$member',
      );
      final name =
          logName ?? label.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');
      File(
        '${output.path}/$name.log',
      ).writeAsStringSync('${result.stdout}${result.stderr}');
      commands.add({
        'label': label,
        'member': member,
        'exitCode': result.exitCode,
        'log': '$name.log',
      });
      write('commands.json', commands);
      return result.exitCode;
    });
  }

  Map<String, String> generatedSnapshot() {
    final result = <String, String>{};
    for (final member in members) {
      for (final file in Directory(
        '$root/$member/lib',
      ).listSync(recursive: true, followLinks: false).whereType<File>()) {
        if (isGenerated(file.path))
          result[file.path] = base64Encode(file.readAsBytesSync());
      }
    }
    result['$root/pubspec.lock'] = File(
      '$root/pubspec.lock',
    ).readAsStringSync();
    return result;
  }

  Future<void> fast() async {
    write('result.json', {
      'status': 'running',
      'native': {
        for (final id in ['N1', 'N2', 'N3', 'N4']) id: 'notRun',
      },
    });
    try {
      final lockBefore = File('$root/pubspec.lock').readAsStringSync();
      await step('Resolve workspace', flutter, ['pub', 'get']);
      if (File('$root/pubspec.lock').readAsStringSync() != lockBefore)
        throw const QualityFailure(
          'Dependency lock changed; review and commit the resolved lock before running the gate.',
        );
      final before = generatedSnapshot();
      for (final member in [
        'packages/movies_core',
        'packages/movies_data',
        'packages/catalog_feature',
      ]) {
        await step('Generate $member', dart, [
          'run',
          'build_runner',
          'build',
        ], member: member);
      }
      for (final member in members.where(
        (m) => m != 'packages/movies_core' && m != 'packages/movies_data',
      )) {
        await step('Localize $member', flutter, ['gen-l10n'], member: member);
      }
      final after = generatedSnapshot();
      final changed = {
        ...before.keys,
        ...after.keys,
      }.where((key) => before[key] != after[key]).toList();
      if (changed.isNotEmpty)
        throw QualityFailure(
          'Generated files/lock changed. Regenerate and review: $changed',
        );
      final formatPaths = [
        'tool',
        for (final member in members) ...['$member/lib', '$member/test'],
        'apps/app/integration_test',
        'apps/app/test_driver',
      ];
      await step('Check formatting', dart, [
        'format',
        '--output=none',
        '--set-exit-if-changed',
        ...formatPaths,
      ]);
      await step('Analyze tooling', dart, ['analyze', '--fatal-infos', 'tool']);
      await step('Test tooling', dart, ['test', 'tool/test']);
      for (final member in members) {
        await step(
          'Analyze $member',
          member == 'packages/movies_core' ? dart : flutter,
          member == 'packages/movies_core'
              ? ['analyze', '--fatal-infos']
              : ['analyze', '--no-pub', '--fatal-infos'],
          member: member,
        );
        for (final source
            in Directory('$root/$member/test')
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart'))) {
          if (hasSoloTest(source.readAsStringSync()))
            throw QualityFailure('Focused test is prohibited: ${source.path}');
        }
        final name = member.replaceAll('/', '-');
        await step(
          'Test $member',
          member == 'packages/movies_core' ? dart : flutter,
          member == 'packages/movies_core'
              ? [
                  'test',
                  'test',
                  '--reporter=json',
                  '--coverage-path=coverage/lcov.info',
                  '--coverage-package=^movies_core\$',
                ]
              : [
                  'test',
                  'test',
                  '--no-pub',
                  '--machine',
                  '--coverage',
                  '--coverage-package=$workspacePackages',
                  '--coverage-path=coverage/lcov.info',
                ],
          member: member,
          logName: 'test-$name',
        );
      }
      Map<String, dynamic>? coverage, acceptance;
      final gateFailures = <String>[];
      try {
        coverage = checkCoverageReports();
      } on QualityFailure catch (error) {
        gateFailures.add(error.message);
      }
      try {
        acceptance = checkAcceptanceReports();
      } on QualityFailure catch (error) {
        gateFailures.add(error.message);
      }
      if (gateFailures.isNotEmpty)
        throw QualityFailure(gateFailures.join('\n'));
      write('result.json', {
        'status': 'passed',
        'coverage': coverage,
        'deterministicAcceptance': acceptance,
        'native': {
          for (final id in ['N1', 'N2', 'N3', 'N4']) id: 'notRun',
        },
        'note':
            'Fast checks do not establish Simulator, lifecycle, browser or authenticated live results.',
      });
      stdout.writeln(
        'Fast quality gate passed. Native/live evidence remains separate.',
      );
    } catch (error) {
      write('result.json', {
        'status': 'failed',
        'error': '$error',
        'native': {
          for (final id in ['N1', 'N2', 'N3', 'N4']) id: 'notRun',
        },
      });
      rethrow;
    }
  }

  Map<String, dynamic> checkCoverageReports() {
    final scope =
        jsonDecode(File('$root/tool/coverage_scope.json').readAsStringSync())
            as Map<String, dynamic>;
    final files = Map<String, dynamic>.from(scope['files'] as Map);
    final actual = <String>{};
    for (final member in members) {
      for (final file in Directory(
        '$root/$member/lib',
      ).listSync(recursive: true, followLinks: false).whereType<File>()) {
        if (file.path.endsWith('.dart') && !isGenerated(file.path))
          actual.add(file.path.substring(root.length + 1));
      }
    }
    validateScope(actual, files.keys.toSet());
    final reports = <LineCoverage>[];
    for (final member in members) {
      final file = File('$root/$member/coverage/lcov.info');
      if (!file.existsSync())
        throw QualityFailure('Missing member coverage: $member');
      reports.add(
        parseLcov(file.readAsStringSync(), workspace: root, member: member),
      );
    }
    final merged = mergeCoverage(reports);
    final included = <String>{};
    final result = <String, dynamic>{};
    final failures = <String>[];
    for (final member in members) {
      final selected = files.entries
          .where((entry) {
            final row = entry.value as Map;
            return row['member'] == member && row['included'] == true;
          })
          .map((entry) => entry.key)
          .toSet();
      for (final path in selected) {
        if (isGenerated(path))
          throw QualityFailure('Generated file in business scope: $path');
      }
      if (selected.isEmpty) {
        result[member] = {
          'status': 'notApplicable',
          'reason': 'No handwritten business logic in this member.',
        };
        continue;
      }
      final count = countCoverage(merged, selected);
      included.addAll(selected);
      result[member] = count.toJson();
      if (count.hit * 10000 < count.total * 8500)
        failures.add('$member: ${count.percent.toStringAsFixed(2)}%');
    }
    final combined = countCoverage(merged, included);
    result['combined'] = combined.toJson();
    write('coverage.json', result);
    final filtered = StringBuffer();
    for (final file in included.toList()..sort()) {
      filtered.writeln('SF:$file');
      for (final line in merged[file]!.keys.toList()..sort()) {
        filtered.writeln('DA:$line,${merged[file]![line]}');
      }
      filtered.writeln('end_of_record');
    }
    File(
      '${output.path}/business-logic.lcov.info',
    ).writeAsStringSync(filtered.toString());
    if (combined.hit * 10000 < combined.total * 8500)
      failures.add('combined: ${combined.percent.toStringAsFixed(2)}%');
    if (failures.isNotEmpty)
      throw QualityFailure('Coverage below 85%: ${failures.join(', ')}');
    return result;
  }

  Map<String, dynamic> checkAcceptanceReports() {
    final expected = parseAcceptedExamples(
      File('$root/specs/02_user_journeys_and_features.md').readAsStringSync(),
    );
    final manifest =
        jsonDecode(
              File('$root/tool/acceptance_manifest.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final executed = <String, TestEvidence>{};
    for (final member in members) {
      final file = File(
        '${output.path}/test-${member.replaceAll('/', '-')}.log',
      );
      if (!file.existsSync())
        throw QualityFailure('Missing executed test report: $member');
      executed.addAll(
        machineTestEvidence(
          file.readAsStringSync(),
          member: member,
          workspace: root,
        ),
      );
    }
    write('test-index.json', {
      for (final entry in executed.entries)
        entry.key: {
          'passed': entry.value.passed,
          'skipped': entry.value.skipped,
        },
    });
    final rows = List<Map<String, dynamic>>.from(
      (manifest['cases'] as List).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
    final mapping = <String, List<String>>{};
    for (final row in rows) {
      final example = row['case'] as String;
      if (mapping.containsKey(example))
        throw QualityFailure('Duplicate acceptance case: $example');
      final references = <String>[];
      for (final raw in row['tests'] as List) {
        final reference = raw as Map;
        final file = reference['file'] as String;
        final name = reference['name'] as String;
        if (!File('$root/$file').existsSync() ||
            !name.contains(example.split('|').first))
          throw QualityFailure('Invalid test reference: $example');
        references.add('$file|$name');
      }
      mapping[example] = references;
    }
    final acceptedIds = expected
        .map((example) => example.split('|').first)
        .toSet();
    for (final name in executed.keys) {
      for (final id in RegExp(r'MOV-[A-Z0-9]+-[0-9]{3}').allMatches(name)) {
        if (!acceptedIds.contains(id.group(0)))
          throw QualityFailure(
            'Unknown acceptance ID in executed test: ${id.group(0)}',
          );
      }
    }
    checkAcceptance(expected, mapping, executed);
    return {
      'scenarioIds': acceptedIds.length,
      'expandedExamples': expected.length,
      'status': 'passed',
      'evidenceType': 'deterministicTests',
      'nativeStatus': 'notRun',
    };
  }
}
