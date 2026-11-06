import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Загружаем базу часовых поясов.
    tz_data.initializeTimeZones();

    // Получаем часовой пояс устройства.
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings: initializationSettings);

    // Запрашиваем разрешение на Android 13 и новее.
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();

    // Запрашиваем разрешение на iOS.
    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;

    debugPrint('NotificationService initialized');
  }

  /// Планирует уведомление о поливе.
  Future<void> scheduleWateringReminder({
    required int id,
    required String plantName,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) {
      throw StateError('NotificationService ещё не инициализирован');
    }

    // Все уведомления будут приходить в 09:00.
    final notificationDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9,
    );

    // Не планируем уведомления на прошедшее время.
    if (!notificationDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'plant_watering_channel',
        'Уход за растениями',
        channelDescription: 'Напоминания о поливе растений',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Пора полить растение!',
      body: 'Не забудьте полить $plantName 🌱',
      scheduledDate: notificationDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'reminder:$id',
    );
  }

  /// Отменяет уведомление по его идентификатору.
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }
}