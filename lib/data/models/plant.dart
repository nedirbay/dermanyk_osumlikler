class Plant {
  final int? id;
  final String name;
  final String scientificName;
  final String description;
  final String medicalUses;
  final String preparationMethod;
  final String relatedDiseases;
  final String usedPart;
  final String chemicalComposition;
  final String contraindications;
  final String imageUrl;

  Plant({
    this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.medicalUses,
    required this.preparationMethod,
    required this.relatedDiseases,
    required this.usedPart,
    required this.chemicalComposition,
    required this.contraindications,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'medicalUses': medicalUses,
      'preparationMethod': preparationMethod,
      'relatedDiseases': relatedDiseases,
      'usedPart': usedPart,
      'chemicalComposition': chemicalComposition,
      'contraindications': contraindications,
      'imageUrl': imageUrl,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as int?,
      name: map['name'] as String,
      scientificName: map['scientificName'] as String,
      description: map['description'] as String,
      medicalUses: map['medicalUses'] as String,
      preparationMethod: map['preparationMethod'] as String,
      relatedDiseases: map['relatedDiseases'] as String,
      usedPart: map['usedPart'] as String,
      chemicalComposition: map['chemicalComposition'] as String,
      contraindications: map['contraindications'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }
}
