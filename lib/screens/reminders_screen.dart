import 'package:flutter/material.dart';

import '../data/plant_repository.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() =>
      _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final PlantRepository _repository = PlantRepository();

  List<Map<String, Object?>> _reminders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      // Синхронизируем активные напоминания с датами полива.
      final plants = await _repository.getPlants();
      final existing = await _repository.getReminders();

      for (final plant in plants) {
        final plantId = plant['id'] as int;
        final wateringDate =
        DateTime.parse(plant['watering_date'] as String);

        final plantReminders = existing.where(
              (reminder) =>
          reminder['plant_id'] == plantId &&
              reminder['type'] == 'Полив',
        );

        // Удаляем активные напоминания, дата которых
        // больше не соответствует дате полива растения.
        for (final reminder in plantReminders) {
          final scheduledDate = DateTime.parse(
            reminder['scheduled_date'] as String,
          );

          final completed = reminder['is_completed'] == 1;

          if (!completed &&
              !DateUtils.isSameDay(
                scheduledDate,
                wateringDate,
              )) {
            await _repository.deleteReminder(
              reminder['id'] as int,
            );
          }
        }

        // Не создаём повторное напоминание на ту же дату,
        // даже если оно уже было выполнено.
        final hasReminder = plantReminders.any((reminder) {
          final scheduledDate = DateTime.parse(
            reminder['scheduled_date'] as String,
          );

          return DateUtils.isSameDay(
            scheduledDate,
            wateringDate,
          );
        });

        if (!hasReminder) {
          await _repository.addReminder(
            plantId: plantId,
            type: 'Полив',
            scheduledDate: wateringDate,
          );
        }
      }

      final reminders = await _repository.getReminders();

      if (!mounted) return;

      setState(() {
        _reminders = reminders;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Не удалось загрузить напоминания: $e';
      });
    }
  }

  Future<void> _completeReminder(
      Map<String, Object?> reminder,
      ) async {
    try {
      await _repository.completeReminder(
        reminder['id'] as int,
      );

      await _loadReminders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Напоминание выполнено'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _deleteReminder(
      Map<String, Object?> reminder,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить напоминание?'),
        content: const Text(
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _repository.deleteReminder(
        reminder['id'] as int,
      );

      await _loadReminders();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pending = _reminders
        .where((r) => r['is_completed'] == 0)
        .toList();

    final completed = _reminders
        .where((r) => r['is_completed'] == 1)
        .toList();

    pending.sort((a, b) {
      final dateA = DateTime.parse(
        a['scheduled_date'] as String,
      );
      final dateB = DateTime.parse(
        b['scheduled_date'] as String,
      );
      return dateA.compareTo(dateB);
    });

    final now = DateUtils.dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Напоминания',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: _loadReminders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadReminders,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadReminders,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummary(pending, now),
            const SizedBox(height: 24),
            const Text(
              'Предстоящие задачи',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              const Text(
                'Активных напоминаний нет.',
              )
            else
              ...pending.map(
                    (reminder) => _buildReminderCard(
                  reminder,
                  now,
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Выполненные',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (completed.isEmpty)
              const Text(
                'Выполненных напоминаний пока нет.',
              )
            else
              ...completed.map(
                    (reminder) => _buildReminderCard(
                  reminder,
                  now,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
      List<Map<String, Object?>> pending,
      DateTime today,
      ) {
    final overdue = pending.where((reminder) {
      final date = DateUtils.dateOnly(
        DateTime.parse(
          reminder['scheduled_date'] as String,
        ),
      );

      return date.isBefore(today);
    }).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDDF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            size: 38,
            color: Color(0xFF477653),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Активных задач: ${pending.length}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Просрочено: $overdue'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
      Map<String, Object?> reminder,
      DateTime today,
      ) {
    final date = DateTime.parse(
      reminder['scheduled_date'] as String,
    );
    final completed = reminder['is_completed'] == 1;

    final dateOnly = DateUtils.dateOnly(date);
    final overdue = !completed && dateOnly.isBefore(today);
    final isToday = DateUtils.isSameDay(date, today);

    final color = completed
        ? Colors.grey
        : overdue
        ? const Color(0xFFC84C43)
        : const Color(0xFF477653);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: overdue
              ? const Color(0xFFE8B8B4)
              : const Color(0xFFE7E9E2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              completed
                  ? Icons.check_circle_outline
                  : Icons.water_drop_outlined,
              size: 30,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['plant_name'] as String? ??
                        'Растение',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reminder['type']} · ${_formatDate(date)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completed
                        ? 'Выполнено'
                        : overdue
                        ? 'Просрочено'
                        : isToday
                        ? 'Сегодня'
                        : 'Предстоит',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Действия',
              onSelected: (value) {
                if (value == 'complete' && !completed) {
                  _completeReminder(reminder);
                } else if (value == 'delete') {
                  _deleteReminder(reminder);
                }
              },
              itemBuilder: (_) => [
                if (!completed)
                  const PopupMenuItem(
                    value: 'complete',
                    child: Text('Выполнено'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Удалить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}