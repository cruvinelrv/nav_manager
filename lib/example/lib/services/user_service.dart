class UserService {
  final String configValue;
  UserService(this.configValue);
  void doSomething() {
    print('MyService doing something with config: $configValue');
  }

  String getConfigValue() {
    return configValue;
  }
}
