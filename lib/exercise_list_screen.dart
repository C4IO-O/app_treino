import "package:flutter/material.dart";
import 'exercise.dart';
import 'exercise_detail_screen.dart';

// usa a classe Exercise do exercise.dart para criar uma lista de exercícios
// é mais seguro pois são dados que serão verificados pelo Dart, e não apenas strings soltas
const List<Exercise> exercises = [
  Exercise(name: 'Agachamento', muscle: 'Pernas', description: 'Exercício para fortalecer as pernas.'),
  Exercise(name: 'Supino Reto', muscle: 'Peito', description: 'Exercício para fortalecer o peito.'),
  Exercise(name: 'Puxada Alta', muscle: 'Costas', description: 'Exercício para fortalecer as costas.'),
  Exercise(name: 'Desenvolvimento c/ Halteres', muscle: 'Ombros', description: 'Exercício para fortalecer os ombros.'),
  Exercise(name: 'Rosca Direta', muscle: 'Bíceps', description: 'Exercício para fortalecer os bíceps.'),
  Exercise(name: 'Triceps Testa', muscle: 'Triceps', description: 'Exercício para fortalecer os tríceps.'),
  Exercise(name: 'Remada Curvada', muscle: 'Costas', description: 'Exercício para fortalecer as costas.')
];

class ExercisesListScreen extends StatelessWidget {
  final bool selectionMode;

  const ExercisesListScreen({super.key, this.selectionMode = false});

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
          return GestureDetector(
            onTap: () {
              if (selectionMode) {
                Navigator.pop(context, exercise); // volta para a tela anterior passando o exercício selecionado
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: exercise)));
              }
            },
            child: ExerciseCard(
              nome: exercise.name,
              musculo: exercise.muscle,
              descricao: exercise.description,
            ),
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