import 'package:flutter/material.dart';

class FolkMedicinePage extends StatelessWidget {
  const FolkMedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
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
    final plants = [
      {'name': 'Üzerlik', 'desc': 'Ruhy tämizlik', 'icon': Icons.flare},
      {'name': 'Ýandak', 'desc': 'Sowuklama', 'icon': Icons.ac_unit},
      {'name': 'Buyan', 'desc': 'Üsgülewük', 'icon': Icons.air},
      {'name': 'Çopantelpek', 'desc': 'Immunitet', 'icon': Icons.verified_user},
    ];

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
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plants.length,
            itemBuilder: (context, index) {
              return Container(
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
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(plants[index]['icon'] as IconData, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      plants[index]['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      plants[index]['desc'] as String,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesSection(BuildContext context) {
    final recipes = [
      {
        'title': 'Sowuklama üçin çaý',
        'recipe': 'Üzerlik, narpyz we melissa garyndysy.',
        'icon': Icons.local_cafe
      },
      {
        'title': 'Aşgazan üçin gaýnatma',
        'recipe': 'Buyan köki we çopantelpek.',
        'icon': Icons.medical_services
      },
      {
        'title': 'Immunitet üçin',
        'recipe': 'Ýandak baly we lök köki.',
        'icon': Icons.shield
      },
    ];

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
        ...recipes.map((r) => Container(
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(r['icon'] as IconData, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  r['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(r['recipe'] as String),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            )),
      ],
    );
  }
}
