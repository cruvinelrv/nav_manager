import 'package:flutter/material.dart'; // Para Widget Function()

abstract class INavRoutesInjector {
  void registerRoute(String path, Widget Function() builder);
  Widget Function() getRouteOrThrow(String path);
  Map<String, Widget Function()> getAllRegisteredRoutes();
  bool hasRoute(String path);
  void clearAllRoutes(); // Adicionei para consistência, se necessário
}
