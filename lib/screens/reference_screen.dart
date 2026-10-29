import 'package:flutter/material.dart';

import '../models/reference_database_service.dart';
import '../models/reference_models.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  late final ReferenceDatabaseService _databaseService;

  List<PlantFamily> _families = [];
  List<Fertilizer> _fertilizers = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  void _loadReferences() {
    try {
      _databaseService = ReferenceDatabaseService();

      _families = _databaseService.getPlantFamilies();
      _fertilizers = _databaseService.getFertilizers();

      _isLoading = false;
    } catch (e) {
      _error = 'Не удалось загрузить справочники: $e';
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    if (!_isLoading && _error == null) {
      _databaseService.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Справочники',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.eco_outlined),
                text: 'Семейства',
              ),
              Tab(
                icon: Icon(Icons.grass_outlined),
                text: 'Удобрения',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
            ),
          ),
        )
            : TabBarView(
          children: [
            _buildFamiliesTab(),
            _buildFertilizersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFamiliesTab() {
    if (_families.isEmpty) {
      return const Center(
        child: Text('Семейства растений не найдены'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _families.length,
      itemBuilder: (context, index) {
        final family = _families[index];

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ExpansionTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE5EDDF),
              child: Icon(
                Icons.local_florist_outlined,
                color: Color(0xFF477653),
              ),
            ),
            title: Text(
              family.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              family.examples,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Описание',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(family.description),
              const SizedBox(height: 12),
              const Text(
                'Примеры растений',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(family.examples),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFertilizersTab() {
    if (_fertilizers.isEmpty) {
      return const Center(
        child: Text('Удобрения не найдены'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fertilizers.length,
      itemBuilder: (context, index) {
        final fertilizer = _fertilizers[index];

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ExpansionTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE5EDDF),
              child: Icon(
                Icons.compost_outlined,
                color: Color(0xFF477653),
              ),
            ),
            title: Text(
              fertilizer.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              fertilizer.purpose,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Назначение',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(fertilizer.purpose),
              const SizedBox(height: 12),
              const Text(
                'Применение',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(fertilizer.application),
            ],
          ),
        );
      },
    );
  }
}