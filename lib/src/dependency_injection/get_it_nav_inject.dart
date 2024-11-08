import 'package:get_it/get_it.dart';

class GetItNavInject {
  static final GetIt _getIt = GetIt.instance;

  /// Registra uma dependência como Singleton com GetIt.
  static void registerSingleton<T extends Object>(T instance) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerSingleton<T>(instance);
    } else {
      print('Dependency of type $T is already registered as Singleton');
    }
  }

  /// Registra uma dependência como Lazy Singleton com GetIt.
  static void registerLazySingleton<T extends Object>(
      T Function() factoryFunc) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerLazySingleton<T>(factoryFunc);
    } else {
      print('Dependency of type $T is already registered as Lazy Singleton');
    }
  }

  /// Registra uma dependência como Factory com GetIt.
  static void registerFactory<T extends Object>(T Function() factoryFunc) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerFactory<T>(factoryFunc);
    } else {
      print('Dependency of type $T is already registered as Factory');
    }
  }

  /// Resolve a dependência registrada do tipo `T`.
  static T resolve<T extends Object>() {
    if (_getIt.isRegistered<T>()) {
      return _getIt<T>();
    } else {
      throw Exception('Dependency of type $T is not registered');
    }
  }

  /// Limpa todas as dependências registradas.
  static void reset() {
    _getIt.reset();
  }

  /// Verifica se uma dependência foi registrada.
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}
