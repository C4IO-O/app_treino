import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Treino',
      theme: ThemeData.dark(),
      home: const MainNavigationScreen(),
    );
  }
}
