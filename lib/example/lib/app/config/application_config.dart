import 'package:flutter/widgets.dart';
import 'package:nav_manager/example/lib/app/pages/detail_page.dart';
import 'package:nav_manager/example/lib/app/pages/home_page.dart';
import 'package:nav_manager/example/lib/app/pages/settings_page.dart';
import 'package:nav_manager/nav_manager.dart';

class ApplicationConfig {
  static NavManagerConfig configure() {
    final navConfig = NavManagerConfig(
      routes: {
        'products': NavRoutesInjector(
          routes: {
            '/': NavRoute(builder: (context) => const HomePage()),
            '/products/:id': NavRoute(builder: (context) {
              final id = ModalRoute.of(context)!.settings.arguments as String?;
              return DetailPage(id: id ?? 'Unknown');
            }),
          },
        ),
        'settings': NavRoutesInjector(routes: {
          '/settings': NavRoute(builder: (context) => const SettingsPage()),
        }),
      },
      dependencies: {},
    );
    return navConfig;
  }
}
