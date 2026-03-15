class Compound {
  final int? id;
  final String name;
  final String description;
  final String sourcePlants;

  Compound({
    this.id,
    required this.name,
    required this.description,
    required this.sourcePlants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sourcePlants': sourcePlants,
    };
  }

  factory Compound.fromMap(Map<String, dynamic> map) {
    return Compound(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      sourcePlants: map['sourcePlants'] as String,
    );
  }
}
