
import 'package:flutter/material.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  final _intervalController = TextEditingController(text: '7');
  final _humidityController = TextEditingController(text: '50-60%');
  final _adviceController = TextEditingController();

  String _light = 'Рассеянный свет';

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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final interval = int.parse(_intervalController.text.trim());

    Navigator.pop<Map<String, Object?>>(
      context,
      {
        'name': _nameController.text.trim(),
        'species': _speciesController.text.trim().isEmpty
            ? 'Не указан'
            : _speciesController.text.trim(),
        'emoji': '🌱',
        'location': _locationController.text.trim(),
        'watering_date': DateTime.now()
            .add(Duration(days: interval))
            .toIso8601String(),
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
        title: const Text('Новое растение'),
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
              value: _light,
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
                final interval = int.tryParse(value?.trim() ?? '');
                if (interval == null || interval < 1 || interval > 365) {
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
              label: const Text('Сохранить растение'),
            ),
          ],
        ),
      ),
    );
  }
}