import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../data/models/plant.dart';
import '../widgets/plant_image.dart';
import 'plant_form_page.dart';

class PlantDetailPage extends StatefulWidget {
  final Plant plant;

  const PlantDetailPage({super.key, required this.plant});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  late Plant _currentPlant;

  @override
  void initState() {
    super.initState();
    _currentPlant = widget.plant;
  }

  Future<void> _editPlant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantFormPage(plant: _currentPlant),
      ),
    );

    if (result == true) {
      // Refresh current plant data (simple way: search by ID)
      final updatedPlants = await DatabaseService.instance.searchPlants(_currentPlant.name);
      final updated = updatedPlants.firstWhere((p) => p.id == _currentPlant.id, orElse: () => _currentPlant);
      setState(() {
        _currentPlant = updated;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öçürmek'),
        content: const Text('Siz hakykatdan hem bu ösümligi öçürmek isleýärsiňizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ýatyrmak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Öçürmek'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.deletePlant(_currentPlant.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(onPressed: _editPlant, icon: const Icon(Icons.edit)),
              IconButton(onPressed: _confirmDelete, icon: const Icon(Icons.delete)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'plant_${_currentPlant.id}',
                child: PlantImage(
                  imageUrl: _currentPlant.imageUrl,
                  borderRadius: 30, // Using borderRadius logic in widget
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Gysga düşündiriş',
                  content: _currentPlant.description,
                  icon: Icons.info_outline,
                ),
                _buildCard(
                  title: 'Peýdaly aýratynlyklary',
                  content: _currentPlant.medicalUses,
                  icon: Icons.eco,
                ),
                _buildCard(
                  title: 'Ulanylýan bölegi',
                  content: _currentPlant.usedPart,
                  icon: Icons.list_alt,
                ),
                _buildCard(
                  title: 'Taýýarlanyş usuly',
                  content: _currentPlant.preparationMethod,
                  icon: Icons.local_cafe_outlined,
                ),
                _buildCard(
                  title: 'Himiki düzümi',
                  content: _currentPlant.chemicalComposition,
                  icon: Icons.science_outlined,
                ),
                _buildCard(
                  title: 'Garşy görkezmeler',
                  content: _currentPlant.contraindications,
                  icon: Icons.warning_amber_rounded,
                  isWarning: true,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPlant.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    _currentPlant.scientificName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF4E6E50),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Dermanlyk',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    bool isWarning = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isWarning ? Colors.orange : const Color(0xFF2E7D32), size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isWarning ? Colors.orange.shade800 : const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFF1F8E9)),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
