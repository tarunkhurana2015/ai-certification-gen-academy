import 'package:flutter/material.dart';
import 'bootstrap/app_config.dart';
import 'bootstrap/bootstrap.dart';
import 'bootstrap/dependency_bindings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  runApp(bootstrap(config, createDependencies(config)));
}
