import 'package:flutter/material.dart';
import 'package:app_treino/program.dart';
import 'workout.dart';
import 'package:app_treino/workout_screen.dart';

// tela exibida ao clicar em um programa, mostra os treinos daquele programa e permite criar novos
class ProgramScreen extends StatefulWidget {
  final Program program;

  const ProgramScreen({super.key, required this.program});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.program.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Novo Treino'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Ex: Full Body 1'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        widget.program.workouts.add(Workout(name: controller.text));
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Criar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: widget.program.workouts.isEmpty
          ? const Center(child: Text('Nenhum treino criado'))
          : ListView.builder(
              itemCount: widget.program.workouts.length,
              itemBuilder: (context, index) {
                final workout = widget.program.workouts[index];
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(workout.name),
                  subtitle: Text('${workout.exercise.length} exercícios'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutScreen(workout: workout),
                      ),
                    );
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}