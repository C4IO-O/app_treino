import "package:flutter/material.dart";
import 'exercise.dart';

// usa a classe Exercise do exercise.dart para criar uma lista de exercícios
// é mais seguro pois são dados que serão verificados pelo Dart, e não apenas strings soltas
const List<Exercise> exercises = [
  Exercise(nome: 'Agachamento', musculo: 'Pernas', descricao: 'Exercício para fortalecer as pernas.'),
  Exercise(nome: 'Supino Reto', musculo: 'Peito', descricao: 'Exercício para fortalecer o peito.'),
  Exercise(nome: 'Puxada Alta', musculo: 'Costas', descricao: 'Exercício para fortalecer as costas.'),
  Exercise(nome: 'Desenvolvimento c/ Halteres', musculo: 'Ombros', descricao: 'Exercício para fortalecer os ombros.'),
  Exercise(nome: 'Rosca Direta', musculo: 'Bíceps', descricao: 'Exercício para fortalecer os bíceps.'),
  Exercise(nome: 'Triceps Testa', musculo: 'Triceps', descricao: 'Exercício para fortalecer os tríceps.'),
  Exercise(nome: 'Remada Curvada', musculo: 'Costas', descricao: 'Exercício para fortalecer as costas.')
];

class ExercisesListScreen extends StatelessWidget {
  const ExercisesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('Exercícios'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: () {})
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ExerciseCard(
            nome: exercise.nome,
            musculo: exercise.musculo,
            descricao: exercise.descricao,
          );
        },
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String nome;
  final String musculo;
  final String descricao;
  
  const ExerciseCard({super.key, required this.nome, required this.musculo, required this.descricao});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color:const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12.0)
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon( Icons.fitness_center, color: Colors.white),
          const SizedBox(height: 8.0),
          Text(nome, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          Text(musculo, style: const TextStyle(fontSize: 16.0, color: Colors.grey)),
          Text(descricao, style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
        ],
      ),
    );
  }
}