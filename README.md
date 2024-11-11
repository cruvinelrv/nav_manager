# NavManager

NavManager is a package that simplifies **dependency injection** and **route management** in Flutter applications, with support for **multiple repositories** (multirepo) or **single repositories** (monorepo). It allows flexible and modular configuration, providing a more organized and efficient navigation and dependency management flow.

## Features

- **Dependency Injection**: Registers and resolves dependencies in a simple and efficient way.
- **Route Management**: Registers and configures routes centrally.
- **Support for Multiple Repositories**: Configures local and remote modules with support for multirepo.
- **Easy Configuration**: Provides simple configuration with the `NavManagerConfig` class to integrate your modules and dependencies.

## Getting Started

### Prerequisites

To use the NavManager package in your Flutter project, you need to have the latest version of Dart and Flutter installed.

1. Add the `nav_manager` package to your `pubspec.yaml` file:

```yaml
dependencies:
  nav_manager: ^0.1.0