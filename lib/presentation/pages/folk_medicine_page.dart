import 'package:flutter/material.dart';
import 'package:plant/core/services/database_service.dart';
import 'package:plant/data/models/recipe.dart';
import 'package:plant/data/models/plant.dart';
import 'package:plant/presentation/pages/recipe_detail_page.dart';
import 'package:plant/presentation/pages/plant_detail_page.dart';

class FolkMedicinePage extends StatefulWidget {
  const FolkMedicinePage({super.key});

  @override
  State<FolkMedicinePage> createState() => _FolkMedicinePageState();
}

class _FolkMedicinePageState extends State<FolkMedicinePage> {
  List<Recipe> _recipes = [];
  List<Plant> _popularPlants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final recipes = await DatabaseService.instance.getAllRecipes();
    // For popular plants, we'll pick some common ones from the database
    final plants = await DatabaseService.instance.searchPlants('');
    
    // Pick specific ones for the popular section if they exist
    final popularNames = ['Üzerlik', 'Ýandak', 'Buyan', 'Çopantelpek'];
    final popular = plants.where((p) => popularNames.any((name) => p.name.contains(name))).toList();

    setState(() {
      _recipes = recipes;
      _popularPlants = popular.isNotEmpty ? popular : (plants.length > 4 ? plants.sublist(0, 4) : plants);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Halk lukmançylygy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHistorySection(context),
                    const SizedBox(height: 24),
                    _buildPopularPlantsSection(context),
                    const SizedBox(height: 24),
                    _buildRecipesSection(context),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFF81C784),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history_edu, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Taryhy maglumat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Türkmen halkynyň lukmançylyk medeniýeti müňýyllyklaryň dowamynda kemala gelipdir. '
              'Tebigy dermanlyk ösümlikleri ulanmak, keselleriň öňüni almak we bejermek boýunça baý tejribe toplanandyr.',
              style: TextStyle(fontSize: 15, height: 1.6, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularPlantsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Meşhur ösümlikler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularPlants.length,
            itemBuilder: (context, index) {
              final plant = _popularPlants[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlantDetailPage(plant: plant)),
                ),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
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
                    border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco, color: Color(0xFF2E7D32)),
                      const SizedBox(height: 8),
                      Text(
                        plant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          plant.scientificName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Meşhur reseptler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ..._recipes.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: r)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  child: const Icon(Icons.local_cafe, color: Color(0xFF2E7D32)),
                ),
                title: Text(
                  r.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            )),
      ],
    );
  }
}
