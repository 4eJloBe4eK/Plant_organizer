
import 'package:realm/realm.dart';

part 'reference_models.realm.dart';

@RealmModel()
class _PlantFamily {
  @PrimaryKey()
  late String id;

  late String name;
  late String description;
  late String examples;
}

@RealmModel()
class _Fertilizer {
  @PrimaryKey()
  late String id;

  late String name;
  late String purpose;
  late String application;
}