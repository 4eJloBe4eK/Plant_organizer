// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_models.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class PlantFamily extends _PlantFamily
    with RealmEntity, RealmObjectBase, RealmObject {
  PlantFamily(String id, String name, String description, String examples) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'examples', examples);
  }

  PlantFamily._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String get examples =>
      RealmObjectBase.get<String>(this, 'examples') as String;
  @override
  set examples(String value) => RealmObjectBase.set(this, 'examples', value);

  @override
  Stream<RealmObjectChanges<PlantFamily>> get changes =>
      RealmObjectBase.getChanges<PlantFamily>(this);

  @override
  Stream<RealmObjectChanges<PlantFamily>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PlantFamily>(this, keyPaths);

  @override
  PlantFamily freeze() => RealmObjectBase.freezeObject<PlantFamily>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'description': description.toEJson(),
      'examples': examples.toEJson(),
    };
  }

  static EJsonValue _toEJson(PlantFamily value) => value.toEJson();
  static PlantFamily _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'description': EJsonValue description,
        'examples': EJsonValue examples,
      } =>
        PlantFamily(
          fromEJson(id),
          fromEJson(name),
          fromEJson(description),
          fromEJson(examples),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PlantFamily._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PlantFamily,
      'PlantFamily',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('description', RealmPropertyType.string),
        SchemaProperty('examples', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Fertilizer extends _Fertilizer
    with RealmEntity, RealmObjectBase, RealmObject {
  Fertilizer(String id, String name, String purpose, String application) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'purpose', purpose);
    RealmObjectBase.set(this, 'application', application);
  }

  Fertilizer._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get purpose => RealmObjectBase.get<String>(this, 'purpose') as String;
  @override
  set purpose(String value) => RealmObjectBase.set(this, 'purpose', value);

  @override
  String get application =>
      RealmObjectBase.get<String>(this, 'application') as String;
  @override
  set application(String value) =>
      RealmObjectBase.set(this, 'application', value);

  @override
  Stream<RealmObjectChanges<Fertilizer>> get changes =>
      RealmObjectBase.getChanges<Fertilizer>(this);

  @override
  Stream<RealmObjectChanges<Fertilizer>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Fertilizer>(this, keyPaths);

  @override
  Fertilizer freeze() => RealmObjectBase.freezeObject<Fertilizer>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'purpose': purpose.toEJson(),
      'application': application.toEJson(),
    };
  }

  static EJsonValue _toEJson(Fertilizer value) => value.toEJson();
  static Fertilizer _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'purpose': EJsonValue purpose,
        'application': EJsonValue application,
      } =>
        Fertilizer(
          fromEJson(id),
          fromEJson(name),
          fromEJson(purpose),
          fromEJson(application),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Fertilizer._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Fertilizer,
      'Fertilizer',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('purpose', RealmPropertyType.string),
        SchemaProperty('application', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
