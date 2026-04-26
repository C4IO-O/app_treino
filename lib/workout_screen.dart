import 'package:app_treino/sets.dart';
import 'package:flutter/material.dart';
import 'exercise_list_screen.dart';
import 'workout.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'rest_timer_screen.dart';

// editar treinos e realizar treinos (tela ativa)
class WorkoutScreen extends StatefulWidget {
  final Workout workout;
  final bool
  isActive; // indica se o treino está sendo realizado ou apenas editado

  const WorkoutScreen({
    super.key,
    required this.workout,
    this.isActive = false,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  //timer de descanso
  late ValueNotifier<int> _restNotifier;
  int _restTotal = 0;
  Timer? _restTimer;

  // timer do treino
  late Timer _timer;
  int _seconds = 0;

  // função para renumerar as séries normais (tipo numérico ou '__normal__')
  // sempre que uma série é marcada como normal ou quando uma série normal é removida, garantindo que os números fiquem sequenciais
  void _renumberNormalSets(ExerciseInWorkout exerciseInWorkout) {
    int counter = 1;
    for (final set in exerciseInWorkout.sets) {
      // Consideramos "normal" se o tipo for um número inteiro ou a string especial '__normal__'
      if (int.tryParse(set.tipo) != null || set.tipo == '__normal__') {
        set.tipo = '$counter';
        counter++;
      }
    }
  }

  // função de começar o timer de descanso
  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    _restTotal = seconds;
    _restNotifier.value = seconds;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restNotifier.value <= 0) {
        timer.cancel();
        setState(() => _restTotal = 0);
      } else {
        _restNotifier.value--;
      }
    });
  }

  // função para mostrar as opções de descanso ao clicar no tipo da série
  void _showRestSettings(ExerciseInWorkout exerciseInWorkout) {
    int activeTab = 0; // 0 = Ativas, 1 = Aquecimento

    late FixedExtentScrollController minutesController;
    late FixedExtentScrollController secondsController;

    void initControllers(int seconds) {
      minutesController = FixedExtentScrollController(
        initialItem: seconds ~/ 60,
      );
      secondsController = FixedExtentScrollController(
        initialItem: seconds % 60,
      );
    }

    initControllers(exerciseInWorkout.restSecondsActive);

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final seconds = activeTab == 0
              // se a aba ativa for "0", usa restSecondsActive, caso contrário ("1") usa restSecondsWarmup
              ? exerciseInWorkout.restSecondsActive
              : exerciseInWorkout.restSecondsWarmup;

          final minutes = seconds ~/ 60;
          final secs = seconds % 60;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // cor e tamanho do fundo do menu que é usado para definir o descanso
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // cabeçalho
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseInWorkout.exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Descanso entre séries',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: exerciseInWorkout.restEnabled,
                      onChanged: (val) {
                        setModalState(
                          () => exerciseInWorkout.restEnabled = val,
                        );
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        // aquecimento
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              activeTab = 1;
                              minutesController.jumpToItem(
                                exerciseInWorkout.restSecondsWarmup ~/ 60,
                              );
                              secondsController.jumpToItem(
                                exerciseInWorkout.restSecondsWarmup % 60,
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: activeTab == 1
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Séries de Aquecimento',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              activeTab = 0;
                              minutesController.jumpToItem(
                                exerciseInWorkout.restSecondsActive ~/ 60,
                              );
                              secondsController.jumpToItem(
                                exerciseInWorkout.restSecondsActive % 60,
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: activeTab == 0
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Séries ativas',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // scroll picker
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // minutos
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView(
                        itemExtent: 40,
                        perspective: 0.003,
                        onSelectedItemChanged: (val) {
                          setModalState(() {
                            final newSeconds = val * 60 + secs;
                            if (activeTab == 0) {
                              exerciseInWorkout.restSecondsActive = newSeconds;
                            } else {
                              exerciseInWorkout.restSecondsWarmup = newSeconds;
                            }
                          });
                          setState(() {});
                        },
                        controller: minutesController,
                        children: List.generate(
                          60,
                          (i) => Center(
                            child: Text(
                              '$i',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(':', style: TextStyle(fontSize: 24)),
                    // segundos
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView(
                        itemExtent: 40,
                        perspective: 0.003,
                        onSelectedItemChanged: (val) {
                          setModalState(() {
                            final newSeconds = minutes * 60 + val;
                            if (activeTab == 0) {
                              exerciseInWorkout.restSecondsActive = newSeconds;
                            } else {
                              exerciseInWorkout.restSecondsWarmup = newSeconds;
                            }
                          });
                          setState(() {});
                        },
                        controller: secondsController,
                        children: List.generate(
                          60,
                          (i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // botão concluído
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Concluído',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _restNotifier = ValueNotifier(0);
    if (widget.isActive) {
      // resetar as séries
      for (final exercise in widget.workout.exercises) {
        for (final set in exercise.sets) {
          set.isCompleted = false;
        }
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // timer do treino
        setState(() {
          _seconds++;
        });
      });
    }
  }

  @override
  void dispose() {
    if (widget.isActive) {
      _timer.cancel(); // cancelar timer do treino
      _restNotifier.dispose();
      _restTimer?.cancel(); // cancelar timer de descanso
    }
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  int get _totalVolume {
    return widget.workout.exercises.fold(0, (total, exercise) {
      return total +
          exercise.sets.fold(0, (sum, s) {
            return sum + (s.isCompleted ? (s.weight * s.reps).toInt() : 0);
          });
    });
  }

  Future<void> _saveWorkout() async {
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
              widget.workout.exercises.add(
                ExerciseInWorkout(exercise: exercise),
              );
            });
            _saveWorkout();
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          if (widget.isActive)
            ValueListenableBuilder<int>(
              valueListenable: _restNotifier,
              builder: (context, remainingcountdown, _) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestTimerScreen(
                          restNotifier: _restNotifier,
                          totalSeconds: _restTotal,
                          onTimeSelected: (seconds) => _startRestTimer(seconds),
                          onStop: () {
                            _restTimer?.cancel();
                            _restTotal = 0;
                            _restNotifier.value = 0;
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: remainingcountdown > 0 && _restTotal > 0
                        ? SizedBox(
                            width: 64,
                            height: 32,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: LinearProgressIndicator(
                                    value: remainingcountdown / _restTotal,
                                    backgroundColor: const Color(0xFF2C2C2C),
                                    color: Colors.blue,
                                    minHeight: 32,
                                  ),
                                ),
                                Text(
                                  '${remainingcountdown ~/ 60}:${(remainingcountdown % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Icon(Icons.timer_outlined, color: Colors.grey),
                  ),
                );
              },
            ),
  if (widget.isActive)
    Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(_formattedTime, style: const TextStyle(fontSize: 18)),
      ),
    ),
            if (widget.isActive)
              TextButton(
                onPressed: () {
                  _timer.cancel();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Terminar',
                  style: TextStyle(color: Colors.green),
                ),
              )
            else
              TextButton(
                onPressed: () async {
                  await _saveWorkout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Treino guardado!')),
                    );
                  }
                },
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
        ],
      ),
      
      // quando o treino tá ativo, mostra o progresso (volume total e séries completas) e permite marcar as séries como completas.
      body: Column(
        children: [
          if (widget.isActive)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Volume',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '$_totalVolume kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Séries',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${widget.workout.exercises.fold(0, (t, e) => t + e.sets.where((s) => s.isCompleted).length)} / ${widget.workout.exercises.fold(0, (t, e) => t + e.sets.length)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Expanded(
            child: widget.workout.exercises.isEmpty
                // ? -> se a condição for verdadeira (rotina estiver vazia) mostra a mensagem
                // : -> se a condição for falsa mostra a lista de exercícios
                ? const Center(child: Text('Nenhum exercício adicionado'))
                : ListView.builder(
                    itemCount: widget.workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exerciseInWorkout = widget.workout.exercises[index];
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Cabeçalho do exercício
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exerciseInWorkout.exercise.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          exerciseInWorkout.exercise.muscle,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        final nextNumber =
                                            exerciseInWorkout.sets
                                                .where(
                                                  (s) =>
                                                      int.tryParse(s.tipo) !=
                                                      null,
                                                )
                                                .length +
                                            1;
                                        exerciseInWorkout.sets.add(
                                          Sets(
                                            weight: 0,
                                            reps: 0,
                                            tipo: '$nextNumber',
                                          ),
                                        );
                                      });
                                      _saveWorkout();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => widget.workout.exercises.removeAt(
                                          index,
                                        ),
                                      );
                                      _saveWorkout();
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        _showRestSettings(exerciseInWorkout),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.timer_outlined,
                                            size: 14,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            exerciseInWorkout.restEnabled
                                                ? 'Descanso: ${exerciseInWorkout.restSecondsActive ~/ 60}m ${exerciseInWorkout.restSecondsActive % 60 == 0 ? '' : '${exerciseInWorkout.restSecondsActive % 60}s'}'
                                                : 'Sem descanso',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 2. Lista de séries
                            ...exerciseInWorkout.sets.asMap().entries.map((
                              entry,
                            ) {
                              // inicio de cada série
                              final i = entry.key;
                              final set = entry.value;

                              return Dismissible(
                                key: ValueKey(
                                  set.id,
                                ), // ID único gerado para cada série
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  // retorna true para confirmar a exclusão, false para cancelar
                                  return true;
                                },
                                onDismissed: (direction) {
                                  if (i < exerciseInWorkout.sets.length) {
                                    setState(() {
                                      exerciseInWorkout.sets.removeAt(i);
                                      _renumberNormalSets(
                                        exerciseInWorkout,
                                      ); // reordena as séries normais após a remoção
                                    });
                                  }
                                  _saveWorkout();
                                },
                                // widget que aparece por trás da série quando o usuário desliza para excluir
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Padding(
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            set.tipo =
                                                                '__normal__';
                                                            int counter = 1;
                                                            for (final s
                                                                in exerciseInWorkout
                                                                    .sets) {
                                                              if (int.tryParse(
                                                                        s.tipo,
                                                                      ) !=
                                                                      null ||
                                                                  s.tipo ==
                                                                      '__normal__') {
                                                                s.tipo =
                                                                    '$counter';
                                                                counter++;
                                                              }
                                                            }
                                                          });
                                                          Navigator.pop(
                                                            context,
                                                          );
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
                                                                  FontWeight
                                                                      .bold,
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
                                                              () => set.tipo =
                                                                  tipo,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
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
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                // opção para remover a série
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                  title: const Text(
                                                    'Remover série',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      exerciseInWorkout.sets
                                                          .removeAt(i);
                                                      _renumberNormalSets(
                                                        exerciseInWorkout,
                                                      );
                                                    });
                                                    _saveWorkout();
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
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                            'weight-${exerciseInWorkout.exercise.name}-$i',
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
                                            _saveWorkout();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 60,
                                        child: TextFormField(
                                          key: ValueKey(
                                            'reps-${exerciseInWorkout.exercise.name}-$i',
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
                                            _saveWorkout();
                                          },
                                        ),
                                      ),
                                      // função de marcar série como concluída
                                      if (widget.isActive)
                                        GestureDetector(
                                          onTap: () {
                                            setState(
                                              () => set.isCompleted =
                                                  !set.isCompleted,
                                            );
                                            // abrir o timer automáticamente quando conclui uma série
                                            if (set.isCompleted &&
                                                exerciseInWorkout.restEnabled) {
                                              final isWarmup = set.tipo == 'A';
                                              final seconds = isWarmup
                                                  ? exerciseInWorkout
                                                        .restSecondsWarmup
                                                  : exerciseInWorkout
                                                        .restSecondsActive;
                                              _startRestTimer(seconds);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RestTimerScreen(
                                                        restNotifier:
                                                            _restNotifier,
                                                        totalSeconds: seconds,
                                                        onTimeSelected:
                                                            (seconds) =>
                                                                _startRestTimer(
                                                                  seconds,
                                                                ),
                                                        onStop: () {
                                                          _restTimer?.cancel();
                                                          _restTotal = 0;
                                                          _restNotifier.value =
                                                              0;
                                                        },
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: set.isCompleted
                                                  ? Colors.green
                                                  : const Color(0xFF2C2C2C),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: set.isCompleted
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 20,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
