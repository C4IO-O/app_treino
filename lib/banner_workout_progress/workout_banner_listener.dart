import 'package:flutter/material.dart';
import 'package:app_treino/workout_state.dart';
import 'package:app_treino/workout.dart';
import 'package:app_treino/banner_workout_progress/active_workout_banner.dart';

class WorkoutBannerListener extends StatelessWidget {
  const WorkoutBannerListener({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Workout?>(
      valueListenable: WorkoutState.activeWorkout,
      builder: (context, activeWorkout, _) {
        if (activeWorkout != null) {
          return ActiveWorkoutBanner(activeWorkout: activeWorkout);
        }
        return const SizedBox.shrink();
      },
    );
  }
}