import 'package:flutter/material.dart';

abstract class NavRoutesConfig {
  void registerRoute(String route, Widget Function() pageBuilder);

  Map<String, Widget Function()> getAllRoutes();
}
