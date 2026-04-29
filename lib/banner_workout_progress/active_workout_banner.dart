import 'package:flutter/material.dart';
import '../workout_state.dart';
import '../workout.dart';
import '../workout_screen.dart';

class ActiveWorkoutBanner extends StatelessWidget {
  final Workout activeWorkout;
  
  const ActiveWorkoutBanner({required this.activeWorkout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutScreen(
              workout: activeWorkout,
              isActive: true,
            ),
          ),
        );
      },
      child: Container(
        color: const Color(0xFF1E1E1E),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Treino em Andamento',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(activeWorkout.name,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancelar Treino'),
                    content: const Text('Tens a certeza que queres cancelar o treino em andamento?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Continuar Treino'),
                      ),
                      TextButton(
                        onPressed: () {
                          activeWorkout.resetProgress();
                          WorkoutState.activeWorkout.value = null;
                          Navigator.pop(ctx);
                        },
                        child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}