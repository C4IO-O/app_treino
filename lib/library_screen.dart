import 'package:app_treino/program.dart';
import 'package:flutter/material.dart';
import 'program_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Program> programs = [];

  Future<void> _savePrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = programs.map((r) => r.toJson()).toList();
    prefs.setString('programs', jsonEncode(data));
  }

  Future<void> _loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('programs');
    if (data != null) {
      setState(() {
        programs.addAll(
          (jsonDecode(data) as List).map((r) => Program.fromJson(r)),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  // Exibe opções para renomear, duplicar ou excluir a rotina
  void _showOptions(BuildContext context, Program program, int index) {
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
              _renameProgram(program);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicar'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                programs.add(Program(name: '${program.name} (cópia)'));
              });
              _savePrograms();
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
                  title: const Text('Excluir Programa'),
                  content: Text(
                    'Tens a certeza que queres excluir "${program.name}"?', // Mensagem de confirmação para excluir a rotina
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          programs.removeAt(index);
                        });
                        _savePrograms();
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
  void _renameProgram(Program program) {
    final controller = TextEditingController(text: program.name);
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
                program.name = controller.text;
              });
              _savePrograms();
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
      appBar: AppBar(title: const Text('Biblioteca')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Novo Programa'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Nome do Programa'),
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
                        programs.add(Program(name: controller.text));
                      });
                      _savePrograms();
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
      body: programs.isEmpty
          ? const Center(child: Text('Nenhum programa adicionado'))
          : ListView.builder(
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];
                return ListTile(
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context, program, index),
                  ),
                  leading: const Icon(Icons.fitness_center),
                  title: Text(program.name),
                  subtitle: Text('${program.workouts.length} treinos'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgramScreen(program: program),
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
