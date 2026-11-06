
import 'package:flutter/material.dart';
import '../services/plant_api_service.dart';

class AddPlantScreen extends StatefulWidget {
  final Map<String, Object?>? initialData;

  const AddPlantScreen({
    super.key,
    this.initialData,
  });

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = PlantApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _locationController;
  late final TextEditingController _intervalController;
  late final TextEditingController _humidityController;
  late final TextEditingController _adviceController;

  late String _light;

  bool _isLoading = false;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    _nameController = TextEditingController(
      text: data?['name'] as String? ?? '',
    );
    _speciesController = TextEditingController(
      text: data?['species'] as String? ?? '',
    );
    _locationController = TextEditingController(
      text: data?['location'] as String? ?? '',
    );
    _intervalController = TextEditingController(
      text: (data?['watering_interval'] as int? ?? 7).toString(),
    );
    _humidityController = TextEditingController(
      text: data?['humidity'] as String? ?? '50-60%',
    );
    _adviceController = TextEditingController(
      text: data?['care_advice'] as String? ?? '',
    );

    const lightOptions = [
      'Яркий свет',
      'Яркий рассеянный свет',
      'Рассеянный свет',
      'Свет или полутень',
      'Полутень',
    ];

    final savedLight = data?['light'] as String?;
    _light = lightOptions.contains(savedLight)
        ? savedLight!
        : 'Рассеянный свет';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _locationController.dispose();
    _intervalController.dispose();
    _humidityController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    final plantName = _nameController.text.trim();

    if (plantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала введите название растения'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.getPlantCare(plantName);

      if (!mounted) return;

      _nameController.text = data['name']?.toString() ?? plantName;
      _speciesController.text =
          data['species']?.toString() ?? '';
      _intervalController.text =
          data['watering_interval']?.toString() ?? '7';
      _adviceController.text =
          data['care_advice']?.toString() ?? '';

      // Преобразуем освещение API в значения нашего списка.
      final apiLight = data['light']?.toString().toLowerCase() ?? '';

      if (apiLight.contains('прямой') ||
          apiLight.contains('full sun')) {
        _light = 'Яркий свет';
      } else if (apiLight.contains('тень') ||
          apiLight.contains('shade')) {
        _light = 'Полутень';
      } else {
        _light = 'Рассеянный свет';
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Рекомендации успешно загружены!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось загрузить рекомендации: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = widget.initialData;
    final interval = int.parse(_intervalController.text.trim());

    final previousInterval = data?['watering_interval'] as int?;
    final previousDate = data?['watering_date'] as String?;

    final String wateringDate;

    if (data != null &&
        interval == previousInterval &&
        previousDate != null) {
      wateringDate = previousDate;
    } else {
      wateringDate = DateTime.now()
          .add(Duration(days: interval))
          .toIso8601String();
    }

    Navigator.pop<Map<String, Object?>>(
      context,
      {
        'name': _nameController.text.trim(),
        'species': _speciesController.text.trim().isEmpty
            ? 'Не указан'
            : _speciesController.text.trim(),
        'emoji': data?['emoji'] as String? ?? '🌱',
        'location': _locationController.text.trim(),
        'watering_date': wateringDate,
        'light': _light,
        'watering_interval': interval,
        'humidity': _humidityController.text.trim(),
        'care_advice': _adviceController.text.trim().isEmpty
            ? 'Следите за состоянием почвы и листьев.'
            : _adviceController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Редактирование растения' : 'Новое растение',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название растения *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_florist_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название растения';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loadRecommendations,
              icon: _isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(
                _isLoading
                    ? 'Загрузка рекомендаций...'
                    : 'Загрузить рекомендации из API',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: 'Ботаническое название',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Местоположение *',
                hintText: 'Например, спальня',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Укажите местоположение';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _light,
              decoration: const InputDecoration(
                labelText: 'Освещение',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Яркий свет',
                  child: Text('Яркий свет'),
                ),
                DropdownMenuItem(
                  value: 'Яркий рассеянный свет',
                  child: Text('Яркий рассеянный свет'),
                ),
                DropdownMenuItem(
                  value: 'Рассеянный свет',
                  child: Text('Рассеянный свет'),
                ),
                DropdownMenuItem(
                  value: 'Свет или полутень',
                  child: Text('Свет или полутень'),
                ),
                DropdownMenuItem(
                  value: 'Полутень',
                  child: Text('Полутень'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _light = value);
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _humidityController,
              decoration: const InputDecoration(
                labelText: 'Влажность',
                hintText: 'Например, 50-60%',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Укажите влажность';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Интервал полива (дней) *',
                border: OutlineInputBorder(),
                suffixText: 'дн.',
              ),
              validator: (value) {
                final interval =
                int.tryParse(value?.trim() ?? '');

                if (interval == null ||
                    interval < 1 ||
                    interval > 365) {
                  return 'Введите число от 1 до 365';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adviceController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Советы по уходу',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                _isEditing
                    ? 'Сохранить изменения'
                    : 'Сохранить растение',
              ),
            ),
          ],
        ),
      ),
    );
  }
}