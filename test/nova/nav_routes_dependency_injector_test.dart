// import 'package:flutter_test/flutter_test.dart';
// import 'package:nav_manager/src/config/nav_manager_exception.dart';
// import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart'; // Ajuste o caminho
// import 'package:nav_manager/src/dependency_injection/nav_dependency_injector.dart'; // Ajuste o caminho
// import 'package:nav_manager/src/nova/disposable.dart';
// import 'package:nav_manager/src/nova/inav_dependency_injector.dart'; // Ajuste o caminho

// // --- Classes de Teste ---
// class ServiceA {
//   final String id = DateTime.now().microsecondsSinceEpoch.toString();
// }

// class ServiceB {
//   final ServiceA serviceA;
//   final String id = DateTime.now().microsecondsSinceEpoch.toString();
//   ServiceB(this.serviceA);
// }

// class DisposableService implements Disposable {
//   bool isDisposed = false;
//   final String id = DateTime.now().microsecondsSinceEpoch.toString();

//   @override
//   void dispose() {
//     isDisposed = true;
//     // print('DisposableService $id disposed');
//   }
// }

// class AnotherDisposableService implements Disposable {
//   bool isDisposed = false;
//   @override
//   void dispose() {
//     isDisposed = true;
//   }
// }
// // --- Fim das Classes de Teste ---

// void main() {
//   group('NavDependencyInjector Tests', () {
//     late INavDependencyInjector injector;

//     setUp(() {
//       injector = INavDependencyInjector;
//     });

//     tearDown(() {
//       // Garante que o injetor seja limpo entre os testes, especialmente para singletons
//       injector.unregisterAll(
//           autoDispose: false); // Não queremos que o dispose falhe se já foi testado
//     });

//     group('Registration and Retrieval', () {
//       test('should register and get a singleton (eager) dependency', () {
//         int factoryCallCount = 0;
//         injector.register<ServiceA>(
//           (i) {
//             factoryCallCount++;
//             return ServiceA();
//           },
//           scope: DependencyScopeEnum.singleton,
//         );
//         // Eager singleton: factory é chamada no registro
//         expect(factoryCallCount, 1);

//         final instance1 = injector.get<ServiceA>();
//         // Factory não deve ser chamada novamente
//         expect(factoryCallCount, 1);
//         final instance2 = injector.get<ServiceA>();
//         expect(factoryCallCount, 1);

//         expect(instance1, isA<ServiceA>());
//         expect(instance1, same(instance2)); // Verifica se é a mesma instância
//       });

//       test('should register and get a lazy singleton dependency', () {
//         int factoryCallCount = 0;
//         injector.register<ServiceA>(
//           (i) {
//             factoryCallCount++;
//             return ServiceA();
//           },
//           scope: DependencyScopeEnum.lazySingleton,
//         );
//         // Lazy singleton: factory não é chamada no registro
//         expect(factoryCallCount, 0);

//         final instance1 = injector.get<ServiceA>();
//         // Factory é chamada no primeiro get
//         expect(factoryCallCount, 1);
//         final instance2 = injector.get<ServiceA>();
//         // Factory não deve ser chamada novamente
//         expect(factoryCallCount, 1);

//         expect(instance1, isA<ServiceA>());
//         expect(instance1, same(instance2));
//       });

//       test('should register and get a factory dependency', () {
//         int factoryCallCount = 0;
//         injector.register<ServiceA>(
//           (i) {
//             factoryCallCount++;
//             return ServiceA();
//           },
//           scope: DependencyScopeEnum.factory,
//         );
//         // Factory não é chamada no registro
//         expect(factoryCallCount, 0);

//         final instance1 = injector.get<ServiceA>();
//         expect(factoryCallCount, 1);
//         final instance2 = injector.get<ServiceA>();
//         expect(factoryCallCount, 2);

//         expect(instance1, isA<ServiceA>());
//         expect(instance2, isA<ServiceA>());
//         expect(instance1, isNot(same(instance2))); // Verifica se são instâncias diferentes
//       });

//       test('should register and get an instance dependency', () {
//         final preExistingInstance = ServiceA();
//         injector.registerInstance<ServiceA>(preExistingInstance);

//         final instance1 = injector.get<ServiceA>();
//         final instance2 = injector.get<ServiceA>();

//         expect(instance1, same(preExistingInstance));
//         expect(instance2, same(preExistingInstance));
//       });

//       test('should throw when using register for instance scope', () {
//         expect(
//           () => injector.register<ServiceA>((i) => ServiceA(), scope: DependencyScopeEnum.instance),
//           throwsA(isA<NavManagerException>().having(
//             (e) => e.message,
//             'message',
//             "Para registrar uma instância pré-existente, use o método 'registerInstance'.",
//           )),
//         );
//       });
//     });

//     group('Tags', () {
//       test('should register and get dependencies with tags', () {
//         injector.register<ServiceA>((i) => ServiceA(),
//             scope: DependencyScopeEnum.lazySingleton, tag: 'tag1');
//         injector.register<ServiceA>((i) => ServiceA(),
//             scope: DependencyScopeEnum.lazySingleton, tag: 'tag2');

//         final instance1 = injector.get<ServiceA>(tag: 'tag1');
//         final instance2 = injector.get<ServiceA>(tag: 'tag2');
//         final instance1Again = injector.get<ServiceA>(tag: 'tag1');

//         expect(instance1, isA<ServiceA>());
//         expect(instance2, isA<ServiceA>());
//         expect(instance1, isNot(same(instance2)));
//         expect(instance1, same(instance1Again)); // lazySingletons com mesma tag são os mesmos
//       });

//       test('should distinguish between tagged and untagged dependencies of the same type', () {
//         injector.register<ServiceA>((i) => ServiceA(),
//             scope: DependencyScopeEnum.lazySingleton); // Untagged
//         injector.register<ServiceA>((i) => ServiceA(),
//             scope: DependencyScopeEnum.lazySingleton, tag: 'tagged');

//         final untaggedInstance = injector.get<ServiceA>();
//         final taggedInstance = injector.get<ServiceA>(tag: 'tagged');

//         expect(untaggedInstance, isA<ServiceA>());
//         expect(taggedInstance, isA<ServiceA>());
//         expect(untaggedInstance, isNot(same(taggedInstance)));
//       });
//     });

//     group('isRegistered', () {
//       test('should return true for registered dependencies and false otherwise', () {
//         injector.register<ServiceA>((i) => ServiceA(), scope: DependencyScopeEnum.lazySingleton);
//         injector.register<ServiceB>((i) => ServiceB(i.get<ServiceA>()),
//             scope: DependencyScopeEnum.lazySingleton, tag: 'serviceB');

//         expect(injector.isRegistered<ServiceA>(), isTrue);
//         expect(injector.isRegistered<ServiceB>(tag: 'serviceB'), isTrue);
//         expect(injector.isRegistered<ServiceB>(), isFalse); // Untagged ServiceB não registrado
//         expect(injector.isRegistered<DisposableService>(), isFalse);
//       });
//     });

//     group('Unregistration and Disposal', () {
//       test('should unregister a dependency', () {
//         injector.register<ServiceA>((i) => ServiceA(), scope: DependencyScopeEnum.lazySingleton);
//         expect(injector.isRegistered<ServiceA>(), isTrue);

//         final unregisterResult = injector.unregister<ServiceA>();
//         expect(unregisterResult, isTrue);
//         expect(injector.isRegistered<ServiceA>(), isFalse);
//         expect(() => injector.get<ServiceA>(), throwsA(isA<NavManagerException>()));
//       });

//       test('unregister should return false for non-existent dependency', () {
//         expect(injector.unregister<ServiceA>(), isFalse);
//         expect(injector.unregister<ServiceA>(tag: 'nonExistent'), isFalse);
//       });

//       test('should call dispose on Disposable singleton when unregistered with autoDispose true',
//           () {
//         final disposable = DisposableService();
//         injector
//             .registerInstance<DisposableService>(disposable); // Usa instance para fácil verificação

//         expect(disposable.isDisposed, isFalse);
//         injector.unregister<DisposableService>(autoDispose: true);
//         expect(disposable.isDisposed, isTrue);
//       });

//       test(
//           'should call dispose on Disposable lazySingleton when unregistered with autoDispose true',
//           () {
//         injector.register<DisposableService>((i) => DisposableService(),
//             scope: DependencyScopeEnum.lazySingleton);
//         final instance =
//             injector.get<DisposableService>(); // Precisa ser resolvido para ser disposto
//         expect(instance.isDisposed, isFalse);

//         injector.unregister<DisposableService>(autoDispose: true);
//         expect(instance.isDisposed, isTrue);
//       });

//       test('should not call dispose on Disposable when autoDispose is false', () {
//         final disposable = DisposableService();
//         injector.registerInstance<DisposableService>(disposable);

//         injector.unregister<DisposableService>(autoDispose: false);
//         expect(disposable.isDisposed, isFalse);
//       });

//       test('unregisterAll should remove all dependencies', () {
//         injector.register<ServiceA>((i) => ServiceA(), scope: DependencyScopeEnum.lazySingleton);
//         injector.register<ServiceB>((i) => ServiceB(i.get<ServiceA>()),
//             scope: DependencyScopeEnum.lazySingleton, tag: 'b');
//         injector.registerInstance<DisposableService>(DisposableService());

//         injector.unregisterAll(autoDispose: false);

//         expect(injector.isRegistered<ServiceA>(), isFalse);
//         expect(injector.isRegistered<ServiceB>(tag: 'b'), isFalse);
//         expect(injector.isRegistered<DisposableService>(), isFalse);
//       });

//       test('unregisterAll should call dispose on all Disposable instances when autoDispose is true',
//           () {
//         final disposable1 = DisposableService();
//         final disposable2 = AnotherDisposableService();
//         injector.registerInstance<DisposableService>(disposable1);
//         injector.register<AnotherDisposableService>((i) => disposable2,
//             scope: DependencyScopeEnum.lazySingleton);

//         // Resolve lazy singleton para que a instância exista
//         injector.get<AnotherDisposableService>();

//         expect(disposable1.isDisposed, isFalse);
//         expect(disposable2.isDisposed, isFalse);

//         injector.unregisterAll(autoDispose: true);

//         expect(disposable1.isDisposed, isTrue);
//         expect(disposable2.isDisposed, isTrue);
//       });
//     });

//     group('Exception Handling', () {
//       test('should throw NavManagerException if dependency is already registered', () {
//         injector.register<ServiceA>((i) => ServiceA(), scope: DependencyScopeEnum.lazySingleton);
//         expect(
//           () => injector.register<ServiceA>((i) => ServiceA(),
//               scope: DependencyScopeEnum.lazySingleton),
//           throwsA(isA<NavManagerException>().having((e) => e.message, 'message',
//               "Dependency for type 'ServiceA' with tag 'default' is already registered.")),
//         );
//       });

//       test('should throw NavManagerException if instance dependency is already registered', () {
//         injector.registerInstance<ServiceA>(ServiceA());
//         expect(
//           () => injector.registerInstance<ServiceA>(ServiceA()),
//           throwsA(isA<NavManagerException>().having((e) => e.message, 'message',
//               "Dependency for type 'ServiceA' with tag 'default' (as instance) is already registered.")),
//         );
//       });

//       test('should throw NavManagerException if dependency is not found', () {
//         expect(
//           () => injector.get<ServiceA>(),
//           throwsA(isA<NavManagerException>().having((e) => e.message, 'message',
//               "No bindings found for type 'ServiceA'. Ensure it's registered.")),
//         );
//       });

//       test(
//           'should throw NavManagerException with tag suggestion if untagged not found but tagged exists',
//           () {
//         injector.register<ServiceA>((i) => ServiceA(),
//             scope: DependencyScopeEnum.lazySingleton, tag: 'myTag');
//         expect(
//           () => injector.get<ServiceA>(), // Tenta pegar sem tag
//           throwsA(isA<NavManagerException>().having((e) => e.message, 'message',
//               "No untagged binding found for type 'ServiceA'. Available tags: ['myTag']. Did you mean to provide a tag?")),
//         );
//       });

//       test(
//           'should throw NavManagerException with untagged suggestion if tagged not found but untagged exists',
//           () {
//         injector.register<ServiceA>((i) => ServiceA(),
//             scope: DependencyScopeEnum.lazySingleton); // Untagged
//         expect(
//           () => injector.get<ServiceA>(tag: 'nonExistentTag'),
//           throwsA(isA<NavManagerException>().having((e) => e.message, 'message',
//               "No binding found for type 'ServiceA' with tag 'nonExistentTag'. An untagged version exists. Did you mean to get the untagged version?")),
//         );
//       });

//       test('should throw NavManagerException if factory throws during resolution', () {
//         injector.register<ServiceA>(
//           (i) => throw Exception('Factory error!'),
//           scope: DependencyScopeEnum.lazySingleton,
//         );
//         expect(
//           () => injector.get<ServiceA>(),
//           throwsA(isA<NavManagerException>()
//               .having(
//                 (e) => e.message,
//                 'message',
//                 "Error resolving dependency for type 'ServiceA' with tag 'default'. Scope: DependencyScopeEnum.lazySingleton",
//               )
//               .having((e) => e.originalException, 'originalException', isA<Exception>())),
//         );
//       });
//     });

//     group('Dependency Resolution within Factories', () {
//       test('factory should be able to resolve other dependencies', () {
//         injector.register<ServiceA>((i) => ServiceA(), scope: DependencyScopeEnum.lazySingleton);
//         injector.register<ServiceB>(
//           (i) => ServiceB(i.get<ServiceA>()), // ServiceB depende de ServiceA
//           scope: DependencyScopeEnum.lazySingleton,
//         );

//         final serviceBInstance = injector.get<ServiceB>();
//         expect(serviceBInstance, isA<ServiceB>());
//         expect(serviceBInstance.serviceA, isA<ServiceA>());

//         // Verifica se o ServiceA injetado é o mesmo que obteríamos diretamente (para singletons)
//         final serviceAFromInjector = injector.get<ServiceA>();
//         expect(serviceBInstance.serviceA, same(serviceAFromInjector));
//       });
//     });
//   });
// }
