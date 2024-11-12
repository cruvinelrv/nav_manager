# NavManager

NavManager is a package that simplifies **dependency injection** and **route management** in Flutter applications, with support for **multiple repositories** (multirepo) or **single repositories** (monorepo). It allows flexible and modular configuration, providing a more organized and efficient navigation and dependency management flow.

## Features

- **Dependency Injection**: Registers and resolves dependencies in a simple and efficient way.
- **Route Management**: Registers and configures routes centrally.
- **Support for Multiple Repositories**: Configures local and remote modules with support for multirepo.
- **Easy Configuration**: Provides simple configuration with the `NavManagerConfig` class to integrate your modules and dependencies.

## Getting Started

## main.dart

Adicione o seguinte trecho de código ao seu projeto para inicializar a navegação:

```dart

void main() async {
  final navManagerConfig = ApplicationConfig.configureNavManager();

  runApp(AppWidget(navManagerConfig: navManagerConfig));
}

## Configuração do NavManager

Abaixo está um exemplo de como configurar o `NavManager` em seu projeto:

```dart

class ApplicationConfig {
  static NavManagerConfig configureNavManager() {
    WidgetsFlutterBinding.ensureInitialized();
    final routes = Routes();
    routes.defineRoutes();
    final navInjector = NavInjector();

    final navManagerConfig = NavManagerConfig(
      navInjector: navInjector,
      routes: routes.getAllRoutes(),
      dependencyScope: DependencyScopeEnum.singleton,
      isMultRepo: false,
    );
    navManagerConfig.configureRoutes();

    return navManagerConfig;
  }
}

## Definição de Rotas

Abaixo está um exemplo de como definir rotas usando a classe `Routes`:

```dart
class Routes extends NavRoutesConfig {
  final Map<String, Widget Function()> _routes = {};
  
  @override
  void defineRoutes() {
    registerRoute('/', () {
      return const FirstPage();
    });
    registerRoute('/first', () {
      return const FirstPage();
    });
    registerRoute('/second', () {
      return const SecondPage();
    });
    registerRoute('/details', () {
      return const DetailsPage();
    });
  }

  @override
  Map<String, Widget Function()> get routes => _routes;
}

## Estrutura do AppWidget

Veja abaixo como a classe `AppWidget` é implementada para usar a configuração do `NavManager`:

```dart
class AppWidget extends StatelessWidget {
  final NavManagerConfig navManagerConfig;
  const AppWidget({super.key, required this.navManagerConfig});

  @override
  Widget build(BuildContext context) {
    navManagerConfig.navInjector.printRegisteredRoutes();
    return MaterialApp.router(
      routeInformationParser: NavRouteInformationParser(),
      routerDelegate: NavRouter((navManagerConfig.navInjector)),
      title: 'App Title',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

## Exemplo de Implementação de uma Página

Abaixo está a implementação de uma página de exemplo chamada `FirstPage`:

```dart
class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Page')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                NavRouter.navigateTo('/second');
              },
              child: const Text('Go to Second Page'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NavRouter.navigateTo('/details');
              },
              child: const Text('Go to Details Page'),
            ),
          ],
        ),
      ),
    );
  }
}

### Prerequisites

To use the NavManager package in your Flutter project, you need to have the latest version of Dart and Flutter installed.

1. Add the `nav_manager` package to your `pubspec.yaml` file:

```yaml
dependencies:
  nav_manager: ^0.0.1