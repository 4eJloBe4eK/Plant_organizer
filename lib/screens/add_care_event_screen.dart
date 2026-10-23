
import 'package:flutter/material.dart';

class AddCareEventScreen extends StatefulWidget {
  const AddCareEventScreen({super.key});

  @override
  State<AddCareEventScreen> createState() =>
      _AddCareEventScreenState();
}

class _AddCareEventScreenState
    extends State<AddCareEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  String _type = 'Полив';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected != null && mounted) {
      setState(() {
        _date = selected;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      <String, Object?>{
        'type': _type,
        'date': _date,
        'note': _noteController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${_date.day.toString().padLeft(2, '0')}.'
        '${_date.month.toString().padLeft(2, '0')}.'
        '${_date.year}';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Записать уход',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Тип ухода',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Полив',
                      child: Text('💧 Полив'),
                    ),
                    DropdownMenuItem(
                      value: 'Подкормка',
                      child: Text('🌱 Подкормка'),
                    ),
                    DropdownMenuItem(
                      value: 'Пересадка',
                      child: Text('🪴 Пересадка'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text('Дата: $dateText'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Комментарий',
                    hintText: 'Например, почва подсохла',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Сохранить запись'),
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