import 'package:flutter/material.dart';

// Importe outras classes do seu package se necessário
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Home Page')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to the Example App!'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Exemplo de navegação (usando Navigator 1.0 por enquanto)
                  // Eventualmente, você usará seu package para navegar
                  Navigator.pushNamed(context, '/products/123');
                },
                child: const Text('Go to Detail (ID: 123)'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Exemplo de como obter uma dependência (via placeholder)
                  // Eventualmente, você usará seu package para injetar/obter dependências
                  try {
                    // Isso falhará sem a implementação do DI no package, é apenas um placeholder
                    // final myService = NavManager.instance.get();
                    // myService.doSomething();
                    print('Dependency injection not yet implemented in the package.');
                  } catch (e) {
                    print('Error getting dependency: $e');
                  }
                },
                child: const Text('Use MyService (Placeholder)'),
              ),
            ],
          ),
        ),
      );
}
