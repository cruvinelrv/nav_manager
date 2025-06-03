import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/domains/domain_screen.dart';

/// Define as rotas relacionadas a Usuário e Configurações.
Map<String, Widget Function()> userRoutes() {
  return {
    '/profile': () => DomainScreen(
          title: 'Profile',
          domain: 'User',
          icon: Icons.person,
          color: Colors.green,
        ),
    '/settings': () => DomainScreen(
          title: 'Settings',
          domain: 'User',
          icon: Icons.settings,
          color: Colors.green,
        ),
  };
}
