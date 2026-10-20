import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _kDailyReminderId = 1;
const _kChannelId = 'daily_reminder';
const _kChannelName = 'Daily reminder';

final reminderServiceProvider =
    Provider<ReminderService>((ref) => LocalReminderService());

/// Schedules the daily review reminder.
abstract interface class ReminderService {
  /// Asks for notification permission. Returns whether it was granted.
  Future<bool> requestPermission();

  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  });

  Future<void> cancelDaily();
}

class LocalReminderService implements ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  Future<void> _ensureInitialized() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final granted = switch (defaultTargetPlatform) {
      TargetPlatform.android => await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission(),
      TargetPlatform.iOS => await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true),
      TargetPlatform.macOS => await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true),
      _ => true,
    };
    return granted ?? false;
  }

  @override
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    await _plugin.zonedSchedule(
      id: _kDailyReminderId,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(_kChannelId, _kChannelName),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelDaily() async {
    await _ensureInitialized();
    await _plugin.cancel(id: _kDailyReminderId);
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
