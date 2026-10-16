import 'screens/plant_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU');
  runApp(const PlantOrganizerApp());
}

DateTime day(DateTime date) =>
    DateTime(date.year, date.month, date.day);

class Plant {
  final int id;
  final String name;
  final String species;
  final String emoji;
  final String location;
  final DateTime wateringDate;
  final String light;
  final int wateringInterval;
  final String humidity;
  final String careAdvice;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.emoji,
    required this.location,
    required this.wateringDate,
    required this.light,
    required this.wateringInterval,
    required this.humidity,
    required this.careAdvice
  });
}

class CareEvent {
  final String plantName;
  final String type;
  final DateTime date;
  final String? note;

  const CareEvent({
    required this.plantName,
    required this.type,
    required this.date,
    this.note,
  });
}

class PlantOrganizerApp extends StatelessWidget {
  const PlantOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мои растения',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF477653),
          primary: const Color(0xFF477653),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F7F0),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const CatalogScreen(),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final DateTime today;
  late final List<Plant> plants;
  late final List<CareEvent> events;

  DateTime focusedDay = day(DateTime.now());
  DateTime selectedDay = day(DateTime.now());

  String searchQuery = '';
  String filter = 'Все';

  @override
  void initState() {
    super.initState();

    today = day(DateTime.now());

    plants = [
      Plant(
        id: 1,
        name: 'Монстера',
        species: 'Monstera deliciosa',
        emoji: '🌿',
        location: 'Гостиная',
        wateringDate: today.subtract(const Duration(days: 2)),
        light: 'Рассеянный свет',
        wateringInterval: 7,
        humidity: '60-70%',
        careAdvice: 'Предпочитает яркий рассеянный свет. Протирайте листья от пыли и избегайте переувлажнения почвы.',
      ),
      Plant(
        id: 2,
        name: 'Сансевиерия',
        species: 'Dracaena trifasciata',
        emoji: '🪴',
        location: 'Спальня',
        wateringDate: today.add(const Duration(days: 3)),
        light: 'Свет или полутень',
        wateringInterval: 14,
        humidity: '30-50%',
        careAdvice: 'Поливайте после просыхания почвы. Не допускайте застоя воды.',
      ),
      Plant(
        id: 3,
        name: 'Спатифиллум',
        species: 'Spathiphyllum',
        emoji: '🌱',
        location: 'Кухня',
        wateringDate: today,
        light: 'Рассеянный свет',
        wateringInterval: 5,
        humidity: '50-70%',
        careAdvice: 'Не допускайте полного пересыхания земляного кома',
      ),
      Plant(
        id: 4,
        name: 'Фикус',
        species: 'Ficus elastica',
        emoji: '🌳',
        location: 'Кабинет',
        wateringDate: today.add(const Duration(days: 1)),
        light: 'Яркий рассеянный свет',
        wateringInterval: 7,
        humidity: '40-60%',
        careAdvice: 'Предпочитает яркий рассеянный свет. Защищайте растение от холодных сквозняков и перепадов температуры.',     ),
    ];

    events = [
      CareEvent(
        plantName: 'Монстера',
        type: 'Полив',
        date: day(today.subtract(const Duration(days: 2))),
        note: 'Почва подсохла, растение полито.',
      ),
      CareEvent(
        plantName: 'Монстера',
        type: 'Подкормка',
        date: day(today.subtract(const Duration(days: 10))),
        note: 'Удобрение для декоративно-лиственных растений.',
      ),
      CareEvent(
        plantName: 'Монстера',
        type: 'Пересадка',
        date: day(today.subtract(const Duration(days: 30))),
        note: 'Пересажена в новый горшок.',
      ),
      CareEvent(
        plantName: 'Спатифиллум',
        type: 'Полив',
        date: day(today),
        note: 'Плановый полив.',
      ),
      CareEvent(
        plantName: 'Спатифиллум',
        type: 'Подкормка',
        date: day(today.subtract(const Duration(days: 7))),
        note: 'Добавлено жидкое удобрение.',
      ),
      CareEvent(
        plantName: 'Фикус',
        type: 'Полив',
        date: day(today.subtract(const Duration(days: 3))),
        note: 'Полив умеренным количеством воды.',
      ),
      CareEvent(
        plantName: 'Фикус',
        type: 'Пересадка',
        date: day(today.subtract(const Duration(days: 60))),
        note: 'Плановая пересадка.',
      ),
      CareEvent(
        plantName: 'Сансевиерия',
        type: 'Полив',
        date: day(today.subtract(const Duration(days: 5))),
        note: 'Полив после просыхания почвы.',
      ),
    ];
  }

  Color statusColor(Plant plant) {
    final difference = day(plant.wateringDate).difference(today).inDays;

    if (difference < 0) return const Color(0xFFC84C43);
    if (difference <= 1) return const Color(0xFFE4A13A);
    return const Color(0xFF477653);
  }

  String statusText(Plant plant) {
    final difference = day(plant.wateringDate).difference(today).inDays;

    if (difference < 0) {
      return 'Просрочено на ${-difference} дн.';
    }
    if (difference == 0) return 'Полить сегодня';
    if (difference == 1) return 'Полить завтра';
    return 'Полив через $difference дн.';
  }

  List<Plant> get filteredPlants {
    return plants.where((plant) {
      final matchesSearch =
      '${plant.name} ${plant.species} ${plant.location}'
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesFilter = switch (filter) {
        'Требуют ухода' =>
        day(plant.wateringDate).isBefore(today) ||
            day(plant.wateringDate) == today,
        'Всё в порядке' => day(plant.wateringDate).isAfter(today),
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<CareEvent> eventsForDay(DateTime date) {
    return events.where((event) => day(event.date) == day(date)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final overdueCount = plants
        .where((plant) => day(plant.wateringDate).isBefore(today))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Зелёный уголок',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
            Text(
              'Забота о растениях каждый день',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Сканировать название растения',
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () async {
              final String? plantName = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => const PlantScannerScreen(),
                ),
              );

              if (!mounted || plantName == null) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Распознано название: $plantName'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDDF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ваш домашний сад',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text('Следите за состоянием своих растений'),
                    ],
                  ),
                ),
                const Text('🪴', style: TextStyle(fontSize: 42)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Растений',
                  '${plants.length}',
                  Icons.eco_outlined,
                  const Color(0xFF477653),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  'Просрочено',
                  '$overdueCount',
                  Icons.water_drop_outlined,
                  const Color(0xFFC84C43),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'Календарь ухода',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar<CareEvent>(
                locale: 'ru_RU',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (date) =>
                    isSameDay(selectedDay, date),
                eventLoader: eventsForDay,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFB8CFB1),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF477653),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Color(0xFFE4A13A),
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = day(selected);
                    focusedDay = focused;
                  });
                },
                onPageChanged: (focused) {
                  focusedDay = focused;
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Процедуры на ${DateFormat('d MMMM', 'ru_RU').format(selectedDay)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._buildEventsForSelectedDay(),
          const SizedBox(height: 24),
          const Text(
            'Мои растения',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Поиск растения...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('Все'),
              _filterChip('Требуют ухода'),
              _filterChip('Всё в порядке'),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredPlants.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Растения не найдены')),
            )
          else
            ...filteredPlants.map(_plantCard),
        ],
      ),
    );
  }

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: filter == label,
      onSelected: (_) => setState(() => filter = label),
      selectedColor: const Color(0xFFDCE8D7),
      checkmarkColor: const Color(0xFF477653),
    );
  }

  Widget _plantCard(Plant plant) {
    final color = statusColor(plant);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.65), width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPlantDetails(plant),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 85,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  plant.emoji,
                  style: const TextStyle(fontSize: 39),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plant.species,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📍 ${plant.location}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(Icons.water_drop, size: 16, color: color),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            statusText(plant),
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEventsForSelectedDay() {
    final selectedEvents = eventsForDay(selectedDay);

    if (selectedEvents.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'На этот день процедур нет',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ];
    }

    return selectedEvents.map((event) {
      final isWatering = event.type == 'Полив';

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              isWatering ? Icons.water_drop : Icons.spa_outlined,
              color: const Color(0xFF477653),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('${event.type} — ${event.plantName}')),
          ],
        ),
      );
    }).toList();
  }


  void _showPlantDetails(Plant plant) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  plant.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  plant.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  plant.species,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Основная информация
              const Text(
                'Информация о растении',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _detailRow(
                Icons.place_outlined,
                'Место',
                plant.location,
              ),
              _detailRow(
                Icons.wb_sunny_outlined,
                'Освещение',
                plant.light,
              ),
              _detailRow(
                Icons.water_drop_outlined,
                'Влажность воздуха',
                plant.humidity,
              ),
              _detailRow(
                Icons.calendar_month_outlined,
                'Следующий полив',
                DateFormat('d MMMM yyyy', 'ru_RU')
                    .format(plant.wateringDate),
              ),
              _detailRow(
                Icons.repeat,
                'Интервал полива',
                'Примерно раз в ${plant.wateringInterval} дн.',
              ),

              const SizedBox(height: 20),

              // Ботаническая справка
              const Text(
                'Ботаническая справка',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EDDF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          color: Color(0xFF477653),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Рекомендации по уходу',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      plant.careAdvice,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Журнал ухода',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ..._buildCareHistory(plant),

              const SizedBox(height: 16),
              const Text(
                'Справочные данные демонстрационные. '
                    'Режим ухода зависит от условий содержания растения.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCareHistory(Plant plant) {
    final plantEvents = events
        .where((event) => event.plantName == plant.name)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (plantEvents.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Записей пока нет. История ухода появится здесь.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ];
    }

    return plantEvents.map((event) {
      final IconData eventIcon;

      switch (event.type) {
        case 'Полив':
          eventIcon = Icons.water_drop_outlined;
          break;
        case 'Подкормка':
          eventIcon = Icons.eco_outlined;
          break;
        case 'Пересадка':
          eventIcon = Icons.yard_outlined;
          break;
        default:
          eventIcon = Icons.event_note_outlined;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE0EBDD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                eventIcon,
                color: const Color(0xFF477653),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'd MMMM yyyy',
                      'ru_RU',
                    ).format(event.date),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  if (event.note != null &&
                      event.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      event.note!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }


  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF477653)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}