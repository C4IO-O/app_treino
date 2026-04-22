import 'exercise.dart';
import 'sets.dart';

class ExerciseInWorkout {
  final Exercise exercise;
  List<Sets> sets;

  ExerciseInWorkout({required this.exercise})
    : sets = [Sets(weight: 0, reps: 0)];

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseInWorkout.fromJson(Map<String, dynamic> json) =>
      ExerciseInWorkout(exercise: Exercise.fromJson(json['exercise']))
        ..sets = (json['sets'] as List).map((s) => Sets.fromJson(s)).toList();
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

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    name: json['name'],
  )
    ..exercises = (json['exercises'] as List).map((e) => ExerciseInWorkout.fromJson(e)).toList()
    ..lastPerformed = json['lastPerformed'] != null ? DateTime.parse(json['lastPerformed']) : null;
}
