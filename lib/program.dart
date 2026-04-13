import 'workout.dart';

class Program {
  String name;
  List<Workout> workouts;

  Program({required this.name}) : workouts = [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'workouts': workouts.map((w) => w.toJson()).toList(),
  };

  factory Program.fromJson(Map<String, dynamic> json) =>
      Program(name: json['name'])
        ..workouts = (json['workouts'] as List)
            .map((w) => Workout.fromJson(w))
            .toList();
}
