import 'package:flutter/material.dart';
import 'workout_state.dart';

Future<bool> canStartNewWorkout(BuildContext context) async {
  if (WorkoutState.activeWorkout.value != null) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Treino em andamento'),
        content: const Text(
          'Termine a sessão atual para começar um novo treino.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return false;
  }
  return true;
}