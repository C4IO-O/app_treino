import 'package:flutter/material.dart';
import 'routine_screen.dart';
import 'routine.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Routine> routines = [];

  Future<void> _saveRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final data = routines.map((r) => r.toJson()).toList();
    prefs.setString('routines', jsonEncode(data));
  }

  Future<void> _loadRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('routines');
    if (data != null) {
      setState(() {
        routines.addAll(
          (jsonDecode(data) as List).map((r) => Routine.fromJson(r)),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  // Exibe opções para renomear, duplicar ou excluir a rotina
  void _showOptions(BuildContext context, Routine routine, int index) {
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
              _renameRoutine(routine);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicar'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                routines.add(Routine(name: '${routine.name} (cópia)'));
              });
              _saveRoutines();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excluir rotina'),
                  content: Text(
                    'Tens a certeza que queres excluir "${routine.name}"?', // Mensagem de confirmação para excluir a rotina
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          routines.removeAt(index);
                        });
                        _saveRoutines();
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

  // Exibe um diálogo para renomear a rotina
  void _renameRoutine(Routine routine) {
    final controller = TextEditingController(text: routine.name);
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
              setState(() {
                routine.name = controller.text;
              });
              _saveRoutines();
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
      appBar: AppBar(title: const Text('Biblioteca de Rotinas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nova Rotina'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Nome da rotina'),
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
                        routines.add(Routine(name: controller.text));
                      });
                      _saveRoutines();
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
      body: routines.isEmpty
          ? const Center(child: Text('Nenhuma rotina adicionada'))
          : ListView.builder(
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return ListTile(
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context, routine, index),
                  ),
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
