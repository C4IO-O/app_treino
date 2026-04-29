import 'package:flutter/material.dart';
import 'package:app_treino/banner_workout_progress/workout_banner_listener.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          // Conteúdo principal centrado
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, size: 80, color: Color(0xFF6200EE)),
                  const SizedBox(height: 16),
                  const Text(
                    'App Treino',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Acesse seus exercícios na aba abaixo',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const WorkoutBannerListener(),
        ],
      ),
    );
  }
}