import 'package:app_treino/sets.dart';
import 'package:flutter/material.dart';
import 'exercise_list_screen.dart';
import 'routine.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final Routine routine = Routine(name: 'Novo Treino');

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
              routine.exercises.add(ExerciseInRoutine(exercise: exercise));
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: Text(routine.name)),
      body: routine.exercises.isEmpty
          // ? -> se a condição for verdadeira (rotina estiver vazia) mostra a mensagem
          // : -> se a condição for falsa mostra a lista de exercícios
          ? const Center(child: Text('Nenhum exercício adicionado'))
          : ListView.builder(
              itemCount: routine.exercises.length,
              itemBuilder: (context, index) {
                final exerciseInRoutine = routine.exercises[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Cabeçalho do exercício
                      ListTile(
                        title: Text(exerciseInRoutine.exercise.name),
                        subtitle: Text(exerciseInRoutine.exercise.muscle),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              exerciseInRoutine.sets.add(
                                Sets(weight: 0, reps: 10),
                              );
                            });
                          },
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
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'kg',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      set.weight =
                                          double.tryParse(value) ??
                                          set.weight; // converte texto em número, se falhar mantém o valor atual
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'reps',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      set.reps =
                                          int.tryParse(value) ??
                                          set.reps; // converte texto em número, se falhar mantém o valor atual
                                    });
                                  },
                                ),
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
