import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to the Home Screen!'),
              ElevatedButton(
                onPressed: () {
                  // Aqui você pode navegar para outra tela, por exemplo:
                  // Navigator.pushNamed(context, '/detail');
                },
                child: const Text('Go to Detail Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
