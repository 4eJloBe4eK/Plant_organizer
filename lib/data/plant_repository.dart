import 'database_helper.dart';

class PlantRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> addReminder({
    required int plantId,
    required String type,
    required DateTime scheduledDate,
  }) async {
    return _databaseHelper.insertReminder({
      'plant_id': plantId,
      'type': type,
      'scheduled_date': scheduledDate.toIso8601String(),
      'is_completed': 0,
    });
  }

  Future<List<Map<String, Object?>>> getReminders({
    int? plantId,
    bool? completed,
  }) async {
    final reminders = await _databaseHelper.getReminders(
      plantId: plantId,
      completed: completed,
    );

    final plants = await getPlants();
    final plantNames = <int, String>{
      for (final plant in plants)
        plant['id'] as int: plant['name'] as String,
    };

    return reminders.map((reminder) {
      final id = reminder['plant_id'] as int;

      return {
        ...reminder,
        'plant_name': plantNames[id] ?? 'Неизвестное растение',
      };
    }).toList();
  }

  Future<int> completeReminder(int id) async {
    return _databaseHelper.completeReminder(id);
  }

  Future<int> deleteReminder(int id) async {
    return _databaseHelper.deleteReminder(id);
  }

  Future<void> addCareEvent({
    required int plantId,
    required String type,
    required DateTime date,
    String? note,
  }) async {
    final db = await _databaseHelper.database;

    await db.insert('care_events', {
      'plant_id': plantId,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
    });

    // После полива пересчитываем дату следующего полива.
    if (type == 'Полив') {
      final plants = await db.query(
        'plants',
        columns: ['watering_interval'],
        where: 'id = ?',
        whereArgs: [plantId],
        limit: 1,
      );

      if (plants.isNotEmpty) {
        final interval = plants.first['watering_interval'] as int;
        final nextWatering = date.add(Duration(days: interval));

        await db.update(
          'plants',
          {'watering_date': nextWatering.toIso8601String()},
          where: 'id = ?',
          whereArgs: [plantId],
        );
      }
    }
  }

  /// Заполняет базу демонстрационными данными,
  /// только если в ней ещё нет растений.
  Future<void> seedDemoDataIfNeeded(DateTime today) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM plants',
    );

    final count = result.first['count'] as int;

    if (count > 0) return;

    await db.transaction((txn) async {
      final demoPlants = <Map<String, Object?>>[
        {
          'name': 'Монстера',
          'species': 'Monstera deliciosa',
          'emoji': '🌿',
          'location': 'Гостиная',
          'watering_date':
          today.subtract(const Duration(days: 2)).toIso8601String(),
          'light': 'Рассеянный свет',
          'watering_interval': 7,
          'humidity': '60-70%',
          'care_advice':
          'Предпочитает яркий рассеянный свет. '
              'Протирайте листья от пыли и избегайте переувлажнения почвы.',
        },
        {
          'name': 'Сансевиерия',
          'species': 'Dracaena trifasciata',
          'emoji': '🪴',
          'location': 'Спальня',
          'watering_date':
          today.add(const Duration(days: 3)).toIso8601String(),
          'light': 'Свет или полутень',
          'watering_interval': 14,
          'humidity': '30-50%',
          'care_advice':
          'Поливайте после просыхания почвы. '
              'Не допускайте застоя воды.',
        },
        {
          'name': 'Спатифиллум',
          'species': 'Spathiphyllum',
          'emoji': '🌱',
          'location': 'Кухня',
          'watering_date': today.toIso8601String(),
          'light': 'Рассеянный свет',
          'watering_interval': 5,
          'humidity': '50-70%',
          'care_advice':
          'Не допускайте полного пересыхания земляного кома.',
        },
        {
          'name': 'Фикус',
          'species': 'Ficus elastica',
          'emoji': '🌳',
          'location': 'Кабинет',
          'watering_date':
          today.add(const Duration(days: 1)).toIso8601String(),
          'light': 'Яркий рассеянный свет',
          'watering_interval': 7,
          'humidity': '40-60%',
          'care_advice':
          'Предпочитает яркий рассеянный свет. '
              'Защищайте растение от холодных сквозняков '
              'и перепадов температуры.',
        },
      ];

      // Запоминаем идентификаторы растений,
      // чтобы связать с ними записи истории ухода.
      final plantIds = <String, int>{};

      for (final plant in demoPlants) {
        final id = await txn.insert('plants', plant);
        plantIds[plant['name'] as String] = id;
      }

      final demoEvents = <Map<String, Object?>>[
        {
          'plant': 'Монстера',
          'type': 'Полив',
          'date': today.subtract(const Duration(days: 2)),
          'note': 'Почва подсохла, растение полито.',
        },
        {
          'plant': 'Монстера',
          'type': 'Подкормка',
          'date': today.subtract(const Duration(days: 10)),
          'note': 'Удобрение для декоративно-лиственных растений.',
        },
        {
          'plant': 'Монстера',
          'type': 'Пересадка',
          'date': today.subtract(const Duration(days: 30)),
          'note': 'Пересажена в новый горшок.',
        },
        {
          'plant': 'Спатифиллум',
          'type': 'Полив',
          'date': today,
          'note': 'Плановый полив.',
        },
        {
          'plant': 'Спатифиллум',
          'type': 'Подкормка',
          'date': today.subtract(const Duration(days: 7)),
          'note': 'Добавлено жидкое удобрение.',
        },
        {
          'plant': 'Фикус',
          'type': 'Полив',
          'date': today.subtract(const Duration(days: 3)),
          'note': 'Полив умеренным количеством воды.',
        },
        {
          'plant': 'Фикус',
          'type': 'Пересадка',
          'date': today.subtract(const Duration(days: 60)),
          'note': 'Плановая пересадка.',
        },
        {
          'plant': 'Сансевиерия',
          'type': 'Полив',
          'date': today.subtract(const Duration(days: 5)),
          'note': 'Полив после просыхания почвы.',
        },
      ];

      for (final event in demoEvents) {
        await txn.insert('care_events', {
          'plant_id': plantIds[event['plant']]!,
          'type': event['type'],
          'date': (event['date'] as DateTime).toIso8601String(),
          'note': event['note'],
        });
      }
    });
  }

  /// Загружает растения из SQLite.
  Future<List<Map<String, Object?>>> getPlants() async {
    final db = await _databaseHelper.database;

    return db.query(
      'plants',
      orderBy: 'id ASC',
    );
  }

  Future<int> insertPlant(Map<String, Object?> plant) async {
    final db = await _databaseHelper.database;
    return db.insert('plants', plant);
  }

  Future<int> updatePlant(int id, Map<String, Object?> plant) async {
    final db = await _databaseHelper.database;

    return db.update(
      'plants',
      plant,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await _databaseHelper.database;

    return db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Загружает историю ухода с названиями растений.
  Future<List<Map<String, Object?>>> getCareEvents() async {
    final db = await _databaseHelper.database;

    return db.rawQuery('''
      SELECT
        care_events.id,
        care_events.plant_id,
        care_events.type,
        care_events.date,
        care_events.note,
        plants.name AS plant_name
      FROM care_events
      INNER JOIN plants
        ON plants.id = care_events.plant_id
      ORDER BY care_events.date DESC
    ''');
  }
}