import 'exercise.dart';
import 'sets.dart';

class ExerciseInRoutine {
  final Exercise exercise;
  List<Sets> sets;

  ExerciseInRoutine({required this.exercise}) : sets = [Sets(weight: 0, reps: 10)];

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseInRoutine.fromJson(Map<String, dynamic> json) =>
      ExerciseInRoutine(exercise: Exercise.fromJson(json['exercise']))
        ..sets = (json['sets'] as List).map((s) => Sets.fromJson(s)).toList();
}

class Routine {
  String name;
  List<ExerciseInRoutine> exercises;

  Routine({required this.name}) : exercises = [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory Routine.fromJson(Map<String, dynamic> json) =>
      Routine(name: json['name'])
        ..exercises = (json['exercises'] as List)
            .map((e) => ExerciseInRoutine.fromJson(e))
            .toList();
}
