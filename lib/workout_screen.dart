import 'package:app_treino/sets.dart';
import 'package:flutter/material.dart';
import 'exercise_list_screen.dart';
import 'workout.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// AKA editar rotinas
class WorkoutScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutScreen({super.key, required this.workout});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Future<void> _savePrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('workout');
    final programs = data != null
        // Se houver dados salvos, decodifica e converte para lista de programas, caso contrário retorna uma lista vazia
        ? (jsonDecode(data) as List).map((p) => Workout.fromJson(p)).toList()
        : <Workout>[];
    // Verifica se o treino atual já existe na lista de programas. Se existir, atualiza o treino, caso contrário adiciona como um novo treino
    final index = programs.indexWhere((p) => p.name == widget.workout.name);
    if (index != -1) {
      programs[index] = widget.workout;
    } else {
      programs.add(widget.workout);
    }

    await prefs.setString(
      'workout',
      jsonEncode(programs.map((p) => p.toJson()).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Lógica para adicionar um exercício à rotina
          final exercise = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ExercisesListScreen(selectionMode: true),
            ),
          );
          if (exercise != null) {
            setState(() {
              widget.workout.exercise.add(
                ExerciseInWorkout(exercise: exercise),
              );
            });
            _savePrograms();
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          TextButton(
            onPressed: () async {
              await _savePrograms();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Programa guardado!')),
                );
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: widget.workout.exercise.isEmpty
          // ? -> se a condição for verdadeira (rotina estiver vazia) mostra a mensagem
          // : -> se a condição for falsa mostra a lista de exercícios
          ? const Center(child: Text('Nenhum exercício adicionado'))
          : ListView.builder(
              itemCount: widget.workout.exercise.length,
              itemBuilder: (context, index) {
                final exerciseInProgram = widget.workout.exercise[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Cabeçalho do exercício
                      ListTile(
                        title: Text(exerciseInProgram.exercise.name),
                        subtitle: Text(exerciseInProgram.exercise.muscle),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  final nextNumber =
                                      exerciseInProgram.sets
                                          .where(
                                            (s) => int.tryParse(s.tipo) != null,
                                          )
                                          .length +
                                      1;
                                  exerciseInProgram.sets.add(
                                    Sets(
                                      weight: 0,
                                      reps: 0,
                                      tipo: '$nextNumber',
                                    ),
                                  );
                                });
                                _savePrograms();
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.workout.exercise.removeAt(index);
                                });
                                _savePrograms();
                              },
                            ),
                          ],
                        ),
                      ),
                      // 2. Lista de séries
                      ...exerciseInProgram.sets.asMap().entries.map((entry) {
                        final i = entry.key;
                        final set = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text(
                                            'Tipo de Série',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    set.tipo = '__normal__';
                                                    int counter = 1;
                                                    for (final s
                                                        in exerciseInProgram
                                                            .sets) {
                                                      if (int.tryParse(
                                                                s.tipo,
                                                              ) !=
                                                              null ||
                                                          s.tipo ==
                                                              '__normal__') {
                                                        s.tipo = '$counter';
                                                        counter++;
                                                      }
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF2C2C2C,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Normal',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              for (final tipo in [
                                                'A',
                                                'F',
                                                'DS',
                                              ])
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(
                                                      () => set.tipo = tipo,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF2C2C2C,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      tipo,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          title: const Text(
                                            'Remover série',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            setState(
                                              () => exerciseInProgram.sets
                                                  .removeAt(i),
                                            );
                                            Navigator.pop(context);
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2C2C),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    set.tipo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              // Espaço entre o tipo e os campos de peso/reps
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  key: ValueKey(
                                    'weight-${exerciseInProgram.exercise.name}-$i',
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: set.weight.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'kg',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      set.weight =
                                          double.tryParse(value) ??
                                          set.weight; // converte texto em número, se falhar mantém o valor atual
                                    });
                                    _savePrograms();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  key: ValueKey(
                                    'reps-${exerciseInProgram.exercise.name}-$i',
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: set.reps.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'reps',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      set.reps =
                                          int.tryParse(value) ??
                                          set.reps; // converte texto em número, se falhar mantém o valor atual
                                    });
                                    _savePrograms();
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    exerciseInProgram.sets.removeAt(i);
                                  });
                                  _savePrograms();
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
