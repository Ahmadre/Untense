import 'package:flutter/material.dart';
import 'package:untense/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // oder .light / .dark
      home: Scaffold(
        appBar: AppBar(title: Text('Untense')),
        body: Center(
          child: Card(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text('Hello World ☀️'),
            ),
          ),
        ),
      ),
    );
  }
}
