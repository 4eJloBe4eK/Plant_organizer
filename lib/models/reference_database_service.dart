import 'package:realm/realm.dart';

import '../models/reference_models.dart';

class ReferenceDatabaseService {
  late final Realm _realm;

  ReferenceDatabaseService() {
    final configuration = Configuration.local([
      PlantFamily.schema,
      Fertilizer.schema,
    ]);

    _realm = Realm(configuration);

    _initializeData();
  }

  /// Заполнение справочников начальными данными.
  void _initializeData() {
    if (_realm.all<PlantFamily>().isEmpty) {
      _realm.write(() {
        _realm.addAll([
          PlantFamily(
            'family_1',
            'Кактусовые',
            'Семейство суккулентных растений, приспособленных к засушливым условиям.',
            'Кактус, маммиллярия, опунция',
          ),
          PlantFamily(
            'family_2',
            'Ароидные',
            'Семейство растений, многие представители которого выращиваются в помещениях.',
            'Монстера, спатифиллум, антуриум',
          ),
          PlantFamily(
            'family_3',
            'Аралиевые',
            'Семейство растений, включающее декоративные комнатные виды.',
            'Шеффлера, фатсия',
          ),
          PlantFamily(
            'family_4',
            'Орхидные',
            'Семейство многолетних растений с разнообразными цветками.',
            'Фаленопсис, дендробиум',
          ),
        ]);
      });
    }

    if (_realm.all<Fertilizer>().isEmpty) {
      _realm.write(() {
        _realm.addAll([
          Fertilizer(
            'fertilizer_1',
            'Комплексное удобрение',
            'Обеспечение растений основными питательными элементами.',
            'Применять согласно инструкции производителя.',
          ),
          Fertilizer(
            'fertilizer_2',
            'Удобрение для цветущих растений',
            'Поддержка роста и цветения декоративных растений.',
            'Использовать в период активного роста согласно инструкции.',
          ),
          Fertilizer(
            'fertilizer_3',
            'Удобрение для кактусов',
            'Подкормка кактусов и других суккулентов.',
            'Использовать в период роста в рекомендованной дозировке.',
          ),
        ]);
      });
    }
  }

  /// Получение списка семейств растений.
  List<PlantFamily> getPlantFamilies() {
    final families = _realm.all<PlantFamily>().toList();

    families.sort((a, b) => a.name.compareTo(b.name));

    return families;
  }

  /// Получение списка удобрений.
  List<Fertilizer> getFertilizers() {
    final fertilizers = _realm.all<Fertilizer>().toList();

    fertilizers.sort((a, b) => a.name.compareTo(b.name));

    return fertilizers;
  }

  /// Закрытие соединения с базой данных.
  void dispose() {
    _realm.close();
  }
}