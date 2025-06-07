import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/config/application_config.dart';
import 'package:nav_manager/example/lib/app_widget.dart';

void main() {
  // 1. Configura o injector usando o método estático
  final injector = ApplicationConfig.configureApp();
  // 2. Constrói o widget raiz, passando o injector

  // 3. Executa o aplicativo
  runApp(AppWidget(injector: injector));
}
