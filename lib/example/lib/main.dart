import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/config/application_config.dart';
import 'package:nav_manager/example/lib/app/config/routes/auth_routes.dart';
import 'package:nav_manager/example/lib/app/domains/domain_screen.dart';

void main() {
  final navManagerConfig = ApplicationConfig.configureApp();

  runApp(DomainScreen(
    title: '',
    domain: AuthRoutes.domain,
    icon: Icons.home,
    color: Colors.purple,
  ));
}
