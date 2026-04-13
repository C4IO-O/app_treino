class Sets {
  double weight;
  int reps;
  String tipo;

  Sets({required this.weight, required this.reps, this.tipo = '1'});

  // guardar dados em json
  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps': reps,
    'tipo': tipo,
  };

  factory Sets.fromJson(Map<String, dynamic> json) => Sets(
    weight: json['weight'],
    reps: json['reps'],
    tipo: json['tipo'] ?? '1', // se tipo não existir, atribui '1' por padrão
  );
}
