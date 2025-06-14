import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/config/application_config.dart';
import 'package:nav_manager/example/lib/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final navConfig = ApplicationConfig.configure();
  runApp(MyApp(config: navConfig));
}
