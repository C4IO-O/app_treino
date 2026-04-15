class Sets {
  double weight;
  int reps;
  String tipo;
  bool isCompleted;

  Sets({required this.weight, required this.reps, this.tipo = '1', this.isCompleted = false});

  // guardar dados em json
  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps': reps,
    'tipo': tipo,
    'isCompleted': isCompleted,
  };

  factory Sets.fromJson(Map<String, dynamic> json) => Sets(
    weight: json['weight'],
    reps: json['reps'],
    tipo: json['tipo'] ?? '1', // se tipo não existir, atribui '1' por padrão
    isCompleted: json['isCompleted'] ?? false, // se isCompleted não existir, atribui false por padrão
  );
}
