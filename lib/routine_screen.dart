import 'package:app_treino/sets.dart';
import 'package:flutter/material.dart';
import 'exercise_list_screen.dart';
import 'routine.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// AKA editar rotinas
class RoutineScreen extends StatefulWidget {
  final Routine routine;
  const RoutineScreen({super.key, required this.routine});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  Future<void> _saveRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('routines');
    final routines = data != null
        // Se houver dados salvos, decodifica e converte para lista de rotinas, caso contrário retorna uma lista vazia
        ? (jsonDecode(data) as List).map((r) => Routine.fromJson(r)).toList()
        : <Routine>[];
    // encontra a rotina atual e atualiza, se não encontrar adiciona à lista
    final index = routines.indexWhere((r) => r.name == widget.routine.name);
    if (index != -1) {
      routines[index] = widget.routine;
    } else {
      routines.add(widget.routine);
    }

    await prefs.setString(
      'routines',
      jsonEncode(routines.map((r) => r.toJson()).toList()),
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
              widget.routine.exercises.add(
                ExerciseInRoutine(exercise: exercise),
              );
            });
            _saveRoutines();
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(widget.routine.name),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveRoutines();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rotina guardada!')),
                );
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: widget.routine.exercises.isEmpty
          // ? -> se a condição for verdadeira (rotina estiver vazia) mostra a mensagem
          // : -> se a condição for falsa mostra a lista de exercícios
          ? const Center(child: Text('Nenhum exercício adicionado'))
          : ListView.builder(
              itemCount: widget.routine.exercises.length,
              itemBuilder: (context, index) {
                final exerciseInRoutine = widget.routine.exercises[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Cabeçalho do exercício
                      ListTile(
                        title: Text(exerciseInRoutine.exercise.name),
                        subtitle: Text(exerciseInRoutine.exercise.muscle),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  exerciseInRoutine.sets.add(
                                    Sets(weight: 0, reps: 0),
                                  );
                                });
                                _saveRoutines();
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.routine.exercises.removeAt(index);
                                });
                                _saveRoutines();
                              },
                            ),
                          ],
                        ),
                      ),
                      // 2. Lista de séries
                      ...exerciseInRoutine.sets.asMap().entries.map((entry) {
                        final i = entry.key;
                        final set = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Text('Série ${i + 1}'),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  key: ValueKey(
                                    'weight-${exerciseInRoutine.exercise.name}-$i',
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
                                    _saveRoutines();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  key: ValueKey(
                                    'reps-${exerciseInRoutine.exercise.name}-$i',
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
                                    _saveRoutines();
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
                                    exerciseInRoutine.sets.removeAt(i);
                                  });
                                  _saveRoutines();
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
