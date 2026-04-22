import 'package:flutter/material.dart';
import 'workout.dart';
import 'workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cabeçalho
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.workout.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.workout.lastPerformed != null
                      ? 'Último treino: ${_formatDate(widget.workout.lastPerformed!)}'
                      : 'Nunca realizado',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          // lista de exercícios
          Expanded(
            child: ListView.builder(
              itemCount: widget.workout.exercises.length,
              itemBuilder: (context, index) {
                final exercises = widget.workout.exercises[index];
                final sets = exercises.sets.length;
                final minReps = exercises.sets
                    .map((sets) => sets.reps)
                    .reduce((a, b) => a < b ? a : b);
                final maxReps = exercises.sets
                    .map((sets) => sets.reps)
                    .reduce((a, b) => a > b ? a : b);
                final hasWeight = exercises.sets.any((sets) => sets.weight > 0);
                final minWeight = hasWeight
                    ? exercises.sets
                          .map((sets) => sets.weight)
                          .reduce((a, b) => a < b ? a : b)
                    : 0.0;
                final maxWeight = hasWeight
                    ? exercises.sets
                          .map((sets) => sets.weight)
                          .reduce((a, b) => a > b ? a : b)
                    : 0.0;

                return ListTile(
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fitness_center),
                  ),
                  title: Text(
                    exercises.exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    hasWeight
                        ? '$sets set • $minReps - $maxReps reps • ${minWeight.toStringAsFixed(1)} - ${maxWeight.toStringAsFixed(1)}kg'
                        : '$sets set • $minReps - $maxReps reps',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          // botão começar treino
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutScreen(
                        workout: widget.workout,
                        isActive: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Começar Treino',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar Treino'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutScreen(workout: widget.workout),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // excluir implementar depois
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_month(date.month)} ${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _month(int month) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return months[month - 1];
  }
}
