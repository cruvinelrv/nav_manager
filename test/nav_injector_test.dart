import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_manager/src/navigation/nav_injector.dart';

void main() {
  group('NavInjector', () {
    late NavInjector navInjector;

    setUp(() {
      navInjector = NavInjector();
    });

    test('resolveRoute returns the correct page builder for a registered route',
        () {
      // Arrange
      navInjector.registerRoute('/home', () => const Text('Home Page'));

      // Act
      final pageBuilder = navInjector.resolveRoute('/home');

      // Assert
      expect(pageBuilder, isNotNull);
      expect(pageBuilder!(), isA<Text>());
      expect((pageBuilder() as Text).data, 'Home Page');
    });

    test('resolveRoute returns null for an unregistered route', () {
      // Act
      final pageBuilder = navInjector.resolveRoute('/unknown');

      // Assert
      expect(pageBuilder, isNull);
    });

    test('registerRoute allows multiple routes to be registered', () {
      // Arrange
      navInjector.registerRoute('/home', () => const Text('Home Page'));
      navInjector.registerRoute('/about', () => const Text('About Page'));

      // Act
      final homePageBuilder = navInjector.resolveRoute('/home');
      final aboutPageBuilder = navInjector.resolveRoute('/about');

      // Assert
      expect(homePageBuilder, isNotNull);
      expect(homePageBuilder!(), isA<Text>());
      expect((homePageBuilder() as Text).data, 'Home Page');

      expect(aboutPageBuilder, isNotNull);
      expect(aboutPageBuilder!(), isA<Text>());
      expect((aboutPageBuilder() as Text).data, 'About Page');
    });

    test('multiple routes can be in the list at the same time', () {
      // Arrange
      navInjector.registerRoute('/home', () => const Text('Home Page'));
      navInjector.registerRoute('/about', () => const Text('About Page'));

      // Act
      final homePageBuilder = navInjector.resolveRoute('/home');
      final aboutPageBuilder = navInjector.resolveRoute('/about');

      // Assert
      expect(homePageBuilder, isNotNull);
      expect(homePageBuilder!(), isA<Text>());
      expect((homePageBuilder() as Text).data, 'Home Page');

      expect(aboutPageBuilder, isNotNull);
      expect(aboutPageBuilder!(), isA<Text>());
      expect((aboutPageBuilder() as Text).data, 'About Page');

      expect(navInjector.resolveRoute('/home'), isNotNull);
      expect(navInjector.resolveRoute('/about'), isNotNull);

      navInjector.printRegisteredRoutes();
    });
  });
}
