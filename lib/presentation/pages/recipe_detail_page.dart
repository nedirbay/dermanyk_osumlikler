import 'package:flutter/material.dart';
import 'package:plant/data/models/recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2E7D32), const Color(0xFF81C784)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection('Gysgaça düşündiriş', recipe.description, Icons.info_outline),
                _buildSection('Gerekli zatlar (Ingrediyentler)', recipe.ingredients, Icons.list),
                _buildSection('Taýýarlanyş usuly', recipe.instructions, Icons.restaurant_menu),
                const SizedBox(height: 30),
                _buildCategoryChip(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
            ],
          ),
          const Divider(height: 16),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Center(
      child: Chip(
        label: Text(recipe.category),
        backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
        labelStyle: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
      ),
    );
  }
}
