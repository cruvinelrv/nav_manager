import 'package:nav_manager/example/lib/app/domains/detail_screen.dart';
import 'package:nav_manager/example/lib/app/domains/error_screen.dart';
import 'package:nav_manager/example/lib/app/domains/home_screen.dart';
import 'package:nav_manager/nav_manager.dart';

class ApplicationConfig {
  static NavInjector configureApp() {
    final injector = NavInjector();

    // Registre suas rotas aqui
    injector.registerRoute('/', () => const HomeScreen());
    injector.registerRoute('/detail', () => const DetailScreen());
    injector.registerRoute('/escape', () => const ErrorScreen());

    // Registre seus serviços aqui
    // injector.registerService<MyApiService>(() => MyApiService());

    return injector;
  }
}
