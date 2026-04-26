import 'exercise.dart';
import 'sets.dart';

class ExerciseInWorkout {
  final Exercise exercise;
  List<Sets> sets; // séries do exercício
  int restSecondsActive; // séries normais/falha
  int restSecondsWarmup; // séries de aquecimento
  bool restEnabled; // descanso habilidado ou não

  ExerciseInWorkout({
    required this.exercise,
    this.restSecondsActive = 60,
    this.restSecondsWarmup = 30,
    this.restEnabled = true,
  })
    // valor padrão de descanso = 60s para normais e 30s para aquecimento
    : sets = [Sets(weight: 0, reps: 0)];

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'sets': sets.map((s) => s.toJson()).toList(),
    'restSecondsActive': restSecondsActive,
    'restSecondsWarmup': restSecondsWarmup,
    'restEnabled': restEnabled,
  };

  factory ExerciseInWorkout.fromJson(Map<String, dynamic> json) =>
      ExerciseInWorkout(
        exercise: Exercise.fromJson(json['exercise']),
        restSecondsActive: json['restSecondsActive'] ?? 60,
        restSecondsWarmup: json['restSecondsWarmup'] ?? 30,
        restEnabled: json['restEnabled'] ?? true,
      );
}

class Workout {
  String name;
  List<ExerciseInWorkout> exercises;
  DateTime? lastPerformed;

  Workout({required this.name}) : exercises = [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'lastPerformed': lastPerformed?.toIso8601String(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) =>
      Workout(name: json['name'])
        ..exercises = (json['exercises'] as List)
            .map((e) => ExerciseInWorkout.fromJson(e))
            .toList()
        ..lastPerformed = json['lastPerformed'] != null
            ? DateTime.parse(json['lastPerformed'])
            : null;
}
