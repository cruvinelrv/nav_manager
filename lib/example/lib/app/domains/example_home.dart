import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';
import '../config/application_config.dart';

class ExampleHome extends StatefulWidget {
  @override
  _ExampleHomeState createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  String _appVersion = 'Loading...';
  String _currentTime = 'Loading...';
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      // ✅ Agora funciona corretamente
      final injector = ApplicationConfig.getDependencyInjector();

      setState(() {
        _appVersion = injector.resolve<String>();
        _counter = injector.resolve<int>();
        _currentTime = injector.resolve<DateTime>().toString().substring(0, 19);
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _appVersion = 'Error loading';
        _currentTime = DateTime.now().toString().substring(0, 19);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NavManager Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 📊 Info Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('📱 $_appVersion',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('🕐 $_currentTime'),
                    Text('🔢 Counter: $_counter'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🔐 Auth Section
            Text('🔐 Authentication', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () => NavRouter.navigateTo('/login'),
                  child: Text('Login'),
                )),
                SizedBox(width: 8),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text('Register'),
                )),
              ],
            ),

            SizedBox(height: 16),

            // 👤 User Section
            Text('👤 User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: Text('Profile'),
                )),
                SizedBox(width: 8),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  child: Text('Settings'),
                )),
              ],
            ),

            SizedBox(height: 16),

            // 🛍️ Shop Section
            Text('🛍️ Shop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/products'),
                  child: Text('Products'),
                )),
                SizedBox(width: 8),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  child: Text('Cart'),
                )),
              ],
            ),

            SizedBox(height: 20),

            // 🔄 Actions
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh),
              label: Text('Refresh Data'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
