import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late List<Page> _pages;

  static NavRouter? _instance;

  NavRouter(this._injector) {
    _pages = [];
    _initializeRoutes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printPages();
    });
    _instance = this;
  }

  static NavRouter get instance {
    if (_instance == null) {
      throw Exception('NavRouter has not been initialized.');
    }
    return _instance!;
  }

  static Future<void> navigateTo(String route) async {
    await instance.to(route);
  }

  List<Page> get pages => List.of(_pages);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onDidRemovePage: (route) {},
    );
  }

  Future<void> to(String route) async {
    _recoverRoutes();
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _navigateToPage(route);
      notifyListeners();
      _printPages();
    } else {
      debugPrint('Route not found: $route');
      _navigateToPage('escape');
      notifyListeners();
    }
  }

  void _navigateToPage(String route) {
    final existingPageIndex =
        _pages.indexWhere((page) => (page.key as ValueKey).value == route);
    if (existingPageIndex != -1) {
      _pages = _pages.sublist(0, existingPageIndex + 1);
    } else {
      final pageBuilder = _injector.resolveRoute(route);
      if (pageBuilder != null) {
        _pages.add(MaterialPage(
          key: ValueKey(route),
          child: pageBuilder(),
        ));
      }
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    _recoverRoutes();
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    debugPrint('\n🔄 Defining new route: $route');
    _navigateToPage(route);

    notifyListeners();
    _printPages();
  }

  void _initializeRoutes() {
    const initialRoute = '/';
    final initialPageBuilder = _injector.resolveRoute(initialRoute);

    if (initialPageBuilder != null) {
      _pages.add(MaterialPage(
        key: const ValueKey(initialRoute),
        child: initialPageBuilder(),
      ));
    } else {
      _pages.add(_buildEscapePage());
    }

    _injectRoutesFromModule();
  }

  MaterialPage _buildEscapePage() {
    return MaterialPage(
      key: const ValueKey('escape'),
      child: Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: const Center(child: Text('The requested route was not found.')),
      ),
    );
  }

  void _injectRoutesFromModule() {
    final routes = _injector.getRoutes();
    debugPrint('📋 Routes obtained from NavInjector:');
    for (var route in routes) {
      debugPrint('🔄 Processing route: $route');
      if (route != '/') {
        final pageBuilder = _injector.resolveRoute(route);
        if (pageBuilder != null) {
          debugPrint('✅ Injecting route: $route');
          _pages.add(MaterialPage(
            key: ValueKey(route),
            child: pageBuilder(),
          ));
        }
      }
    }
  }

  void _recoverRoutes() {
    final routes = _injector.getRoutes();
    debugPrint('📋 Recover routes of NavInjector:');
    for (var route in routes) {
      debugPrint('🔄 Route: $route');
      if (route != '/' &&
          !_pages.any((page) => (page.key as ValueKey).value == route)) {
        final pageBuilder = _injector.resolveRoute(route);
        if (pageBuilder != null) {
          debugPrint('✅ Injecting route: $route');
          _pages.add(MaterialPage(
            key: ValueKey(route),
            child: pageBuilder(),
          ));
        }
      }
    }
  }

  void _printPages() {
    debugPrint('Current routes in the navigation stack:');
    for (var page in _pages) {
      debugPrint((page.key as ValueKey).value);
    }
  }

  @override
  RouteInformation? get currentConfiguration {
    if (_pages.isEmpty) {
      return null;
    }
    final route = _pages.last.key as ValueKey<String>;
    return RouteInformation(uri: Uri.parse(route.value));
  }
}
