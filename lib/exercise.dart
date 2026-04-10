// armazenar dados
class Exercise {
  final String name;
  final String muscle;
  final String description;

  const Exercise({
    required this.name,
    required this.muscle,
    required this.description,
  });
  // guardar dados em json
  Map<String, dynamic> toJson() => {
    'name': name,
    'muscle': muscle,
    'description': description,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    name: json['name'],
    muscle: json['muscle'],
    description: json['description'],
  );
}
