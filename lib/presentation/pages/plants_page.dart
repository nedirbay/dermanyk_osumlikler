import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../data/models/plant.dart';
import '../widgets/plant_image.dart';
import 'plant_detail_page.dart';
import 'plant_form_page.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Plant> _plants = [];
  bool _isLoading = true;
  String _selectedFilter = 'Ählisi';

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants([String query = '']) async {
    setState(() => _isLoading = true);
    final data = await DatabaseService.instance.searchPlants(query);
    setState(() {
      _plants = data;
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    _loadPlants(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlantFormPage()),
          );
          if (result == true) {
            _loadPlants(_searchController.text);
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Ösümlikler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFilters(),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _isLoading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : _plants.isEmpty
                    ? const SliverFillRemaining(child: Center(child: Text('Ösümlik tapylmady')))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _PlantCard(
                            plant: _plants[index],
                            onRefresh: () => _loadPlants(_searchController.text),
                          ),
                          childCount: _plants.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: "Ösümlik ady boýunça gözleg...",
            prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Ählisi', 'Sowuklama', 'Aşgazan', 'Nerw', 'Böwrek'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                  _onSearch(filter == 'Ählisi' ? '' : filter);
                },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onRefresh;

  const _PlantCard({required this.plant, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlantDetailPage(plant: plant)),
            );
            if (result == true) {
              onRefresh();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Hero(
                  tag: 'plant_${plant.id}',
                  child: PlantImage(
                    imageUrl: plant.imageUrl,
                    width: 100,
                    height: 100,
                    borderRadius: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: plant.medicalUses.split(',').map((use) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              use.trim(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
