// lib/services/notification_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
// Conditional import: web gets dart:js bridge, other platforms get a stub
import 'js_notification_bridge_stub.dart'
    if (dart.library.js) 'js_notification_bridge_web.dart';

/// Cross-platform notification service.
///   - Web   → Dart Timer countdown + browser Notification API via JS
///   - Mobile → flutter_local_notifications with timezone-aware exact alarms
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  final Map<int, Timer> _webTimers = {};

  // ────────────────────────────────────────────────────────────
  // Initialization
  // ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    if (!kIsWeb) {
      tz_data.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
      await androidImpl?.requestExactAlarmsPermission();
    }

    _initialized = true;
    debugPrint('[NotificationService] Initialized (${kIsWeb ? "web" : "mobile"})');
  }

  // ────────────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────────────

  Future<void> scheduleTaskReminder(Task task) async {
    if (!_initialized) await initialize();

    final due = task.fullDueDateTime;
    if (due == null) return;

    final now = DateTime.now();

    // Pre-reminder
    final reminder = task.reminderDateTime;
    if (reminder != null && reminder.isAfter(now)) {
      await _schedule(
        id: _preId(task.id),
        title: '⏰ Upcoming Task',
        body: '"${task.title}" is due in ${task.notifyBeforeMinutes} min',
        at: reminder,
      );
    }

    // Due-time notification — fires at the exact due datetime
    if (due.isAfter(now)) {
      await _schedule(
        id: _dueId(task.id),
        title: '⏳ Last Chance — Time\'s Up!',
        body: '🚨 "${task.title}" is due right now! Complete it before it\'s too late.',
        at: due,
      );
    }
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    if (kIsWeb) {
      _webTimers[_preId(taskId)]?.cancel();
      _webTimers.remove(_preId(taskId));
      _webTimers[_dueId(taskId)]?.cancel();
      _webTimers.remove(_dueId(taskId));
    } else {
      await _plugin.cancel(_preId(taskId));
      await _plugin.cancel(_dueId(taskId));
    }
  }

  // ────────────────────────────────────────────────────────────
  // Internal
  // ────────────────────────────────────────────────────────────

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    if (kIsWeb) {
      _scheduleWebTimer(id: id, title: title, body: body, at: at);
      return;
    }
    try {
      final tzAt = tz.TZDateTime.from(at, tz.local);
      const androidDetails = AndroidNotificationDetails(
        'nova_tasks',
        'Nova Tasks Reminders',
        channelDescription: 'Task due-date and reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzAt,
        const NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[NotificationService] Schedule error: $e');
    }
  }

  void _scheduleWebTimer({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) {
    _webTimers[id]?.cancel();
    final delay = at.difference(DateTime.now());
    if (delay.isNegative) return;
    _webTimers[id] = Timer(delay, () {
      // callJsNotification is resolved via conditional import
      callJsNotification(title, body);
      _webTimers.remove(id);
    });
  }

  int _preId(String taskId) => taskId.hashCode.abs() % 100000;
  int _dueId(String taskId) => (taskId.hashCode.abs() % 100000) + 100000;
}
