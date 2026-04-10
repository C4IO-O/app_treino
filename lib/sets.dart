class Sets {
  double weight;
  int reps;

  Sets({required this.weight, required this.reps});

  // guardar dados em json
  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps};

  factory Sets.fromJson(Map<String, dynamic> json) =>
      Sets(weight: json['weight'], reps: json['reps']);
}
