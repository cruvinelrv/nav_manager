/// Mock services para demonstração do NavManager
class MockAuthService {
  final String _status = 'Mock Authentication Service - Connected ✅';
  final bool _isAuthenticated = true;

  String get status => _status;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }

  void logout() {
    // Mock logout
  }

  @override
  String toString() => _status;
}

class MockUserService {
  final String id = DateTime.now().millisecondsSinceEpoch.toString();
  final String name = 'Usuário Exemplo';
  final String email = 'usuario@exemplo.com';

  Map<String, dynamic> getUserProfile() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() => 'MockUserService(id: $id, name: $name)';
}

class MockProductService {
  final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': 'Produto A', 'price': 29.99},
    {'id': 2, 'name': 'Produto B', 'price': 49.99},
    {'id': 3, 'name': 'Produto C', 'price': 19.99},
  ];

  List<Map<String, dynamic>> getProducts() => _products;

  Map<String, dynamic>? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => 'MockProductService(${_products.length} products)';
}

class MockConfigService {
  final Map<String, dynamic> _config = {
    'appName': 'NavManager Example',
    'version': '1.0.0',
    'environment': 'development',
    'apiUrl': 'https://api.exemplo.com',
  };

  T getConfig<T>(String key) {
    if (!_config.containsKey(key)) {
      throw Exception('Config key "$key" not found');
    }
    return _config[key] as T;
  }

  @override
  String toString() => 'MockConfigService($_config)';
}

/// Factory para criar timestamps únicos
class TimestampFactory {
  static DateTime create() => DateTime.now();

  @override
  String toString() => 'TimestampFactory';
}

/// Contador simples para demonstrar instance
class SimpleCounter {
  static int _globalValue = 42;

  static int get value => _globalValue;
  static void increment() => _globalValue++;
  static void reset() => _globalValue = 42;

  @override
  String toString() => 'SimpleCounter(value: $_globalValue)';
}
