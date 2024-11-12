import 'package:get_it/get_it.dart';

class GetItNavInject {
  static final GetIt _getIt = GetIt.instance;

  static void registerSingleton<T extends Object>(T instance) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerSingleton<T>(instance);
    } else {
      print('Dependency of type $T is already registered as Singleton');
    }
  }

  static void registerLazySingleton<T extends Object>(
      T Function() factoryFunc) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerLazySingleton<T>(factoryFunc);
    } else {
      print('Dependency of type $T is already registered as Lazy Singleton');
    }
  }

  static void registerFactory<T extends Object>(T Function() factoryFunc) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerFactory<T>(factoryFunc);
    } else {
      print('Dependency of type $T is already registered as Factory');
    }
  }

  static T resolve<T extends Object>() {
    if (_getIt.isRegistered<T>()) {
      return _getIt<T>();
    } else {
      throw Exception('Dependency of type $T is not registered');
    }
  }

  static void reset() {
    _getIt.reset();
  }

  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}
