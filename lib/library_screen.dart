import 'package:flutter/material.dart';
import 'routine_screen.dart';
import 'routine.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Routine> routines = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Rotinas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            routines.add(Routine(name: 'Novo Treino ${routines.length + 1}'));
          });
        },
        child: const Icon(Icons.add),
      ),
      body: routines.isEmpty
          ? const Center(child: Text('Nenhuma rotina adicionada'))
          : ListView.builder(
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(routine.name),
                  subtitle: Text('${routine.exercises.length} exercícios'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutineScreen(routine: routine),
                      ),
                    );
                    // Atualiza a tela para refletir as mudanças na rotina
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}
