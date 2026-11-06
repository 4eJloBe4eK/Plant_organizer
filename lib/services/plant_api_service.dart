import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantApiService {
  static const String _apiKey =
  String.fromEnvironment('PERENUAL_API_KEY');

  static const String _baseUrl = 'perenual.com';

  Future<Map<String, dynamic>> getPlantCare(String plantName) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Не указан API-ключ Perenual. '
            'Запустите приложение с PERENUAL_API_KEY.',
      );
    }

    // 1. Поиск растения
    final searchUri = Uri.https(
      _baseUrl,
      '/api/v2/species-list',
      {
        'key': _apiKey,
        'q': plantName,
      },
    );

    final searchResponse = await http.get(searchUri);

    if (searchResponse.statusCode != 200) {
      throw Exception(
        'Ошибка поиска растения: ${searchResponse.statusCode}',
      );
    }

    final searchData = jsonDecode(searchResponse.body)
    as Map<String, dynamic>;

    final plants = searchData['data'] as List<dynamic>?;

    if (plants == null || plants.isEmpty) {
      throw Exception('Растение "$plantName" не найдено.');
    }

    final plant = plants.first as Map<String, dynamic>;
    final plantId = plant['id'];

    // 2. Получение подробной информации
    final detailsUri = Uri.https(
      _baseUrl,
      '/api/v2/species/details/$plantId',
      {'key': _apiKey},
    );

    final detailsResponse = await http.get(detailsUri);

    if (detailsResponse.statusCode != 200) {
      throw Exception(
        'Ошибка получения информации: ${detailsResponse.statusCode}',
      );
    }

    final details = jsonDecode(detailsResponse.body)
    as Map<String, dynamic>;

    // 3. Получение базовых параметров ухода
    final watering = details['watering']?.toString() ?? 'Average';

    final benchmark =
    details['watering_general_benchmark']
    as Map<String, dynamic>?;

    final wateringValue = benchmark?['value']?.toString();

    final interval = _getWateringInterval(
      watering,
      wateringValue,
    );

    final sunlight = details['sunlight'];
    final light = _getLight(sunlight);

    final description =
        details['description']?.toString() ??
            'Информация об уходе отсутствует.';

    return {
      'name': details['common_name'] ??
          plant['common_name'] ??
          plantName,
      'species': _getScientificName(details),
      'watering_interval': interval,
      'light': light,
      'care_advice': description,
      'humidity': '50-60%',
    };
  }

  int _getWateringInterval(
      String watering,
      String? benchmark,
      ) {
    if (benchmark != null) {
      final numbers = RegExp(r'\d+')
          .allMatches(benchmark)
          .map((match) => int.parse(match.group(0)!))
          .toList();

      if (numbers.isNotEmpty) {
        if (numbers.length >= 2) {
          return ((numbers[0] + numbers[1]) / 2).round();
        }

        return numbers.first;
      }
    }

    switch (watering.toLowerCase()) {
      case 'frequent':
        return 3;
      case 'minimum':
        return 14;
      case 'none':
        return 30;
      default:
        return 7;
    }
  }

  String _getLight(dynamic sunlight) {
    final values = sunlight is List
        ? sunlight.map((value) => value.toString()).join(' ').toLowerCase()
        : sunlight?.toString().toLowerCase() ?? '';

    if (values.contains('full sun')) {
      return 'Прямой солнечный свет';
    }

    if (values.contains('shade')) {
      return 'Тень';
    }

    return 'Рассеянный свет';
  }

  String _getScientificName(Map<String, dynamic> details) {
    final scientificName = details['scientific_name'];

    if (scientificName is List && scientificName.isNotEmpty) {
      return scientificName.first.toString();
    }

    return scientificName?.toString() ?? 'Не указан';
  }
}