import 'package:flutter/material.dart';
import 'package:app_treino/workout.dart';

class WorkoutState {
  static final ValueNotifier<Workout?> activeWorkout = ValueNotifier(null);
}
