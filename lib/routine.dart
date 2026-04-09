import 'exercise.dart';
import 'sets.dart';

class ExerciseInRoutine {
  final Exercise exercise;
  List<Sets> sets;

  ExerciseInRoutine({required this.exercise}) : sets = [Sets(weight: 0, reps: 10)];
}

class Routine {
  String name;
  List<ExerciseInRoutine> exercises;

  Routine({required this.name}) : exercises = [];
}