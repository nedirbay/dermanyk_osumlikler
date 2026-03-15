class Recipe {
  final int? id;
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final String category;
  final String imageUrl;

  Recipe({
    this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.category,
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      ingredients: map['ingredients'],
      instructions: map['instructions'],
      category: map['category'],
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
