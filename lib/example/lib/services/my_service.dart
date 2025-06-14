class MyService {
  final String configValue;
  MyService(this.configValue);
  void doSomething() {
    print('MyService doing something with config: $configValue');
  }
}
