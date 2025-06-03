// dependency_injector_factory.dart
import 'package:nav_manager/nav_manager.dart';

enum InjectorTypeEnum {
  nav, // 🔧 Implementação padrão do NavManager (DISPONÍVEL)
  getIt, // 📦 Adapter para GetIt (FUTURO)
  flecha, // 🏹 Adapter para FlechaInjector (FUTURO)
}

class DependencyInjectorFactory {
  /// 🏭 Cria uma instância do injetor baseado no tipo
  static NavDependencyInjector create(InjectorTypeEnum type) {
    switch (type) {
      case InjectorTypeEnum.nav:
        return NavDependencyInjectorImpl(); // 🔧 DISPONÍVEL

      case InjectorTypeEnum.getIt:
        throw UnsupportedError('GetIt adapter não implementado ainda. Use InjectorTypeEnum.nav');

      case InjectorTypeEnum.flecha:
        throw UnsupportedError('Flecha adapter não implementado ainda. Use InjectorType.nav');
    }
  }

  /// 🎯 Factory padrão (sempre NavDependencyImpl)
  static NavDependencyInjector createDefault() {
    return NavDependencyInjectorImpl();
  }

  /// 🔧 Factory com configuração (só nav por enquanto)
  static NavDependencyInjector createWithConfig({
    InjectorTypeEnum type = InjectorTypeEnum.nav,
    Map<String, dynamic>? config,
  }) {
    if (type != InjectorTypeEnum.nav) {
      throw UnsupportedError(
          'Apenas InjectorType.nav está disponível. Outros adapters em desenvolvimento.');
    }

    final injector = create(type);

    // Configurações específicas se necessário
    if (config != null) {
      // Aplicar configurações futuras...
    }

    return injector;
  }

  /// 📊 Lista tipos disponíveis AGORA
  static List<InjectorTypeEnum> get availableTypes => [InjectorTypeEnum.nav];

  /// 📊 Lista todos os tipos (incluindo futuros)
  static List<InjectorTypeEnum> get allTypes => InjectorTypeEnum.values;

  /// ✅ Verifica se tipo está disponível
  static bool isTypeAvailable(InjectorTypeEnum type) {
    return availableTypes.contains(type);
  }

  /// 📋 Informações sobre cada tipo
  static String getTypeDescription(InjectorTypeEnum type) {
    switch (type) {
      case InjectorTypeEnum.nav:
        return '🔧 Implementação padrão do NavManager - completa e otimizada (DISPONÍVEL)';
      case InjectorTypeEnum.getIt:
        return '📦 Adapter para GetIt - em desenvolvimento';
      case InjectorTypeEnum.flecha:
        return '🏹 Adapter para FlechaInjector - em desenvolvimento';
    }
  }

  /// 🚀 Status da implementação
  static String getImplementationStatus(InjectorTypeEnum type) {
    switch (type) {
      case InjectorTypeEnum.nav:
        return 'DISPONÍVEL ✅';
      case InjectorTypeEnum.getIt:
      case InjectorTypeEnum.flecha:
        return 'EM DESENVOLVIMENTO 🚧';
    }
  }
}
