
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'plant_organizer.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE plants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            species TEXT NOT NULL,
            emoji TEXT NOT NULL DEFAULT '🌱',
            location TEXT NOT NULL,
            watering_date TEXT NOT NULL,
            light TEXT NOT NULL,
            watering_interval INTEGER NOT NULL,
            humidity TEXT NOT NULL,
            care_advice TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE care_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plant_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (plant_id)
              REFERENCES plants(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plant_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            scheduled_date TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (plant_id)
              REFERENCES plants(id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ---------- РАСТЕНИЯ ----------

  Future<int> insertPlant(Map<String, Object?> plant) async {
    final db = await database;
    return db.insert('plants', plant);
  }

  Future<List<Map<String, Object?>>> getPlants() async {
    final db = await database;
    return db.query('plants', orderBy: 'name COLLATE NOCASE');
  }

  Future<Map<String, Object?>?> getPlantById(int id) async {
    final db = await database;
    final result = await db.query(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<int> updatePlant(
      int id,
      Map<String, Object?> plant,
      ) async {
    final db = await database;
    return db.update(
      'plants',
      plant,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await database;
    return db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- ИСТОРИЯ УХОДА ----------

  Future<int> insertCareEvent(
      Map<String, Object?> event,
      ) async {
    final db = await database;
    return db.insert('care_events', event);
  }

  Future<List<Map<String, Object?>>> getCareEvents(
      int plantId,
      ) async {
    final db = await database;
    return db.query(
      'care_events',
      where: 'plant_id = ?',
      whereArgs: [plantId],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteCareEvent(int id) async {
    final db = await database;
    return db.delete(
      'care_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- НАПОМИНАНИЯ ----------

  Future<int> insertReminder(
      Map<String, Object?> reminder,
      ) async {
    final db = await database;
    return db.insert('reminders', reminder);
  }

  Future<List<Map<String, Object?>>> getReminders({
    int? plantId,
    bool? completed,
  }) async {
    final db = await database;

    final conditions = <String>[];
    final arguments = <Object?>[];

    if (plantId != null) {
      conditions.add('plant_id = ?');
      arguments.add(plantId);
    }

    if (completed != null) {
      conditions.add('is_completed = ?');
      arguments.add(completed ? 1 : 0);
    }

    return db.query(
      'reminders',
      where: conditions.isEmpty
          ? null
          : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'scheduled_date ASC',
    );
  }

  Future<int> completeReminder(int id) async {
    final db = await database;

    return db.update(
      'reminders',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}