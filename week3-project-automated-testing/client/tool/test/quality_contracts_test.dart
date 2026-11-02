import 'dart:io';
import 'package:test/test.dart';
import '../src/quality_contracts.dart';

void main() {
  const workspace = '/workspace/client';
  test(
    'LCOV normalizes member-relative and cross-package paths without duplicate lines',
    () {
      final first = parseLcov(
        'SF:lib/a.dart\nDA:4,0\nDA:5,1\nend_of_record\n',
        workspace: workspace,
        member: 'packages/a',
      );
      final second = parseLcov(
        'SF:../../packages/a/lib/a.dart\nDA:4,1\nDA:5,1\nend_of_record\n',
        workspace: workspace,
        member: 'apps/app',
      );
      final result = checkCoverage(mergeCoverage([first, second]), {
        'packages/a/lib/a.dart',
      });
      expect(result.total, 2);
      expect(result.hit, 2);
      expect(
        () => normalizeCoveragePath(
          '../../../outside.dart',
          workspace: workspace,
          member: 'apps/app',
        ),
        throwsA(isA<QualityFailure>()),
      );
    },
  );
  test('missing executable sources and empty reports cannot disappear', () {
    expect(
      () => checkCoverage({}, {'packages/a/lib/missing.dart'}),
      throwsA(isA<QualityFailure>()),
    );
    expect(
      () => checkCoverage({'lib/a.dart': {}}, {'lib/a.dart'}),
      throwsA(isA<QualityFailure>()),
    );
    expect(
      () => validateScope({'lib/new.dart'}, {'lib/old.dart'}),
      throwsA(isA<QualityFailure>()),
    );
  });
  test(
    '85 percent boundary includes zero-hit lines and excludes generated sources',
    () {
      final lines = {for (var i = 1; i <= 10000; i++) i: i <= 8499 ? 1 : 0};
      expect(
        () => checkCoverage(
          {
            'lib/a.dart': lines,
            'lib/a.g.dart': {1: 1},
          },
          {'lib/a.dart'},
        ),
        throwsA(isA<QualityFailure>()),
      );
      lines[8500] = 1;
      final result = checkCoverage(
        {
          'lib/a.dart': lines,
          'lib/a.g.dart': {1: 1},
        },
        {'lib/a.dart'},
      );
      expect(result.total, 10000);
      expect(result.hit, 8500);
      expect(isGenerated('lib/a.freezed.dart'), true);
      expect(
        isGenerated('lib/l10n/generated/generated_localizations.dart'),
        true,
      );
      expect(isGenerated('lib/domain/a.dart'), false);
    },
  );
  test('approved specification has 62 IDs and 64 expanded examples', () {
    final cases = parseAcceptedExamples(
      File('specs/02_user_journeys_and_features.md').readAsStringSync(),
    );
    expect(cases.length, 64);
    expect(cases.map((e) => e.split('|').first).toSet().length, 62);
    expect(cases, contains('MOV-SEARCH-004|outcome=success'));
    expect(cases, contains('MOV-DEEP-004|relationship=filmography'));
  });
  test(
    'acceptance rejects unknown/missing cases, unexecuted and skipped tests',
    () {
      const expected = {'MOV-X-001', 'MOV-X-002|outcome=failure'};
      final manifest = {
        'MOV-X-001': ['one'],
        'MOV-X-002|outcome=failure': ['two'],
      };
      expect(
        () => checkAcceptance(expected, manifest, {
          'one': const TestEvidence(passed: true),
          'two': const TestEvidence(passed: true),
        }),
        returnsNormally,
      );
      expect(
        () => checkAcceptance(expected, {
          'MOV-X-001': ['one'],
        }, {}),
        throwsA(isA<QualityFailure>()),
      );
      expect(
        () => checkAcceptance(expected, {
          ...manifest,
          'MOV-X-999': ['three'],
        }, {}),
        throwsA(isA<QualityFailure>()),
      );
      expect(
        () => checkAcceptance(expected, manifest, {
          'one': const TestEvidence(passed: true),
          'two': const TestEvidence(passed: true, skipped: true),
        }),
        throwsA(isA<QualityFailure>()),
      );
      expect(
        () => checkAcceptance(expected, manifest, {
          'one': const TestEvidence(passed: true),
        }),
        throwsA(isA<QualityFailure>()),
      );
      expect(hasSoloTest("test.only('example', () {});"), true);
      expect(hasSoloTest("test('ordinary', () {});"), false);
    },
  );
  test('fixture/CI reports never establish passed native/live checks', () {
    expect(
      () => validateNativeEvidence({
        'N1': {'status': 'passed', 'kind': 'fixtureWidget'},
      }),
      throwsA(isA<QualityFailure>()),
    );
    expect(
      () => validateNativeEvidence({
        'N3': {'status': 'passed', 'kind': 'nativeBrowser', 'mode': 'fixture'},
      }),
      throwsA(isA<QualityFailure>()),
    );
    expect(
      () => validateNativeEvidence({
        'N1': {'status': 'notRun'},
        'N3': {'status': 'notRun'},
      }),
      returnsNormally,
    );
  });
  test('command failure preserves its exit code', () async {
    try {
      await requireSuccessfulStep('example', () async => 7);
      fail('Expected failure');
    } on QualityFailure catch (error) {
      expect(error.code, 7);
    }
  });
}
