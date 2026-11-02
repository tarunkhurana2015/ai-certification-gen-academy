import 'dart:io';
import 'src/quality_contracts.dart';
import 'src/workspace_quality.dart';

Future<void> main(List<String> args) async {
  final root = File.fromUri(Platform.script).parent.parent.absolute.path;
  try {
    final quality = WorkspaceQuality(root);
    switch (args.isEmpty ? 'fast' : args.first) {
      case 'fast':
        await quality.fast();
      case 'coverage':
        quality.checkCoverageReports();
      case 'acceptance':
        quality.checkAcceptanceReports();
      default:
        throw const QualityFailure(
          'Usage: dart run tool/quality.dart fast|coverage|acceptance',
          code: 64,
        );
    }
  } on QualityFailure catch (error) {
    stderr.writeln(error);
    exitCode = error.code;
  } catch (error) {
    stderr.writeln('Quality gate failed: $error');
    exitCode = 1;
  }
}
