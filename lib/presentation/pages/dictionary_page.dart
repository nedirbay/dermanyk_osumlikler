import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../data/models/compound.dart';
import 'dart:collection';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<Compound>> _groupedCompounds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompounds();
  }

  Future<void> _loadCompounds([String query = '']) async {
    setState(() => _isLoading = true);
    final data = await DatabaseService.instance.searchCompounds(query);
    
    // Group by first letter
    final groups = SplayTreeMap<String, List<Compound>>();
    for (var item in data) {
      final letter = item.name.isNotEmpty 
          ? item.name[0].toUpperCase() 
          : '#';
      if (!groups.containsKey(letter)) {
        groups[letter] = [];
      }
      groups[letter]!.add(item);
    }

    setState(() {
      _groupedCompounds = groups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_groupedCompounds.isEmpty)
            const SliverFillRemaining(child: Center(child: Text('Madda tapylmady')))
          else
            ..._groupedCompounds.entries.map((entry) => _buildLetterSegment(entry.key, entry.value)).toList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF8FAF8),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Himiki sözlük',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 20),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _loadCompounds,
          decoration: InputDecoration(
            hintText: "Maddany gözle...",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: 24),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLetterSegment(String letter, List<Compound> compounds) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _LetterHeaderDelegate(letter: letter),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _CompoundListItem(compound: compounds[index]),
              childCount: compounds.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _LetterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String letter;

  _LetterHeaderDelegate({required this.letter});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bool isPinned = shrinkOffset > 0 || overlapsContent;
    return Container(
      color: isPinned ? Colors.white.withOpacity(0.9) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          letter,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant _LetterHeaderDelegate oldDelegate) => oldDelegate.letter != letter;
}

class _CompoundListItem extends StatelessWidget {
  final Compound compound;

  const _CompoundListItem({required this.compound});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.science_rounded, size: 20, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          compound.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 16),
                Text(
                  compound.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                if (compound.sourcePlants != 'Sözlük') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.eco_rounded, size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Çeşmesi: ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            compound.sourcePlants,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
