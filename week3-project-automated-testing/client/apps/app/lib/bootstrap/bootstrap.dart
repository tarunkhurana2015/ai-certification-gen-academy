import 'package:flutter/widgets.dart';
import '../app.dart';
import 'app_config.dart';
import 'dependency_bindings.dart';

Widget bootstrap(AppConfig config, AppDependencies dependencies) =>
    MoviesApp(config: config, dependencies: dependencies);
