import 'package:flutter/material.dart';
import 'package:app_treino/program.dart';
import 'workout.dart';
import 'package:app_treino/workout_screen.dart';
import 'workout_detail_screen.dart';

// tela exibida ao clicar em um programa, mostra os treinos daquele programa e permite criar novos
// precisa colocar save e load para guardar os treinos
class ProgramScreen extends StatefulWidget {
  final Program program;
  final List<Program>
  allPrograms; // vai servir para mover treinos entre programas

  const ProgramScreen({
    super.key,
    required this.program,
    required this.allPrograms,
  });

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  void _showWorkoutOptions(BuildContext context, Workout workout, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Renomear'),
            onTap: () {
              Navigator.pop(context);
              _renameWorkout(workout);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicar'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                final copy = Workout(name: '${workout.name} (cópia)');
                copy.exercises.addAll(workout.exercises);
                widget.program.workouts.add(copy);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_move_outline),
            title: const Text('Mover para outro programa'),
            onTap: () {
              Navigator.pop(context);
              _moveWorkout(workout, index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excluir treino'),
                  content: Text(
                    'Tens a certeza que queres excluir "${workout.name}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => widget.program.workouts.removeAt(index));
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _moveWorkout(Workout workout, int index) {
    final otherPrograms = widget.allPrograms
        .where(
          (p) => p != widget.program,
        ) // filtra para não mostrar o programa atual
        .toList(); // converte para lista para usar no dropdown

    if (otherPrograms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há outros programas para mover este treino.'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Mover para...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...otherPrograms.map(
            (p) => ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(p.name),
              onTap: () {
                setState(() {
                  p.workouts.add(workout);
                  widget.program.workouts.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _renameWorkout(Workout workout) {
    final controller = TextEditingController(text: workout.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => workout.name = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

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
                        widget.program.workouts.add(
                          Workout(name: controller.text),
                        );
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
                  subtitle: Text('${workout.exercises.length} exercícios'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkoutDetailScreen(workout: workout),
                      ),
                    );
                    setState(() {});
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutScreen(
                                workout: workout,
                                isActive: true,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () =>
                            _showWorkoutOptions(context, workout, index),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
