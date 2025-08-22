import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final bool? initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification cliquée: ${details.payload}');
        },
      );

      if (initialized == true) {
        _isInitialized = true;
        debugPrint('Service de notification initialisé avec succès');
        await _createNotificationChannel();
      } else {
        debugPrint('Erreur: Impossible d\'initialiser les notifications');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'smartspend_reminders',
      'Rappels SmartSpend',
      description: 'Notifications de rappel pour enregistrer les transactions',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('Canal de notification créé: ${channel.id}');
  }

  Future<void> scheduleInstantReminder() async {
    try {
      if (!_isInitialized) await initialize();

      debugPrint('Programmation d\'une notification dans 3 secondes...');

      await _notificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Test SmartSpend ✅',
        'Cette notification de test a été envoyée avec succès! 🎉',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_reminders',
            'Rappels SmartSpend',
            channelDescription:
            'Notifications de rappel pour enregistrer les transactions',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Notification test programmée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la programmation de la notification test: $e');
    }
  }

  Future<void> showImmediateNotification() async {
    try {
      if (!_isInitialized) await initialize();

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
        'SmartSpend - Test Immédiat',
        'Cette notification s\'affiche immédiatement!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_reminders',
            'Rappels SmartSpend',
            channelDescription:
            'Notifications de rappel pour enregistrer les transactions',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
      );

      debugPrint('Notification immédiate affichée');
    } catch (e) {
      debugPrint('Erreur notification immédiate: $e');
    }
  }

  /// ✅ Version finale et unique
  Future<void> scheduleDailyReminder() async {
    try {
      if (!_isInitialized) await initialize();

      const int dailyReminderId = 999;

      final tz.TZDateTime scheduledTime = _nextInstanceOfTime(20, 0);
      debugPrint('Programmation rappel quotidien pour: $scheduledTime');

      await _notificationsPlugin.zonedSchedule(
        dailyReminderId,
        '💰 SmartSpend - Rappel du soir',
        'N\'oubliez pas de saisir vos dépenses du jour et de vérifier vos objectifs !',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Rappels Quotidiens',
            channelDescription:
            'Rappel quotidien pour saisir vos dépenses et vérifier vos objectifs',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            color: Color(0xFF00A9A9),
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Rappel quotidien programmé à 20h00');
    } catch (e) {
      debugPrint('Erreur programmation rappel quotidien: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> showGoalAchievedNotification(String goalName) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'goals_channel',
      'Objectifs Financiers',
      channelDescription: 'Notifications pour les objectifs financiers',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: Color(0xFF4CAF50),
      playSound: true,
      sound: RawResourceAndroidNotificationSound('success_sound'),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      2,
      '🎉 Objectif atteint !',
      'Félicitations ! Vous avez atteint votre objectif "$goalName"',
      notificationDetails,
    );
  }

  Future<void> showGoalDeadlineWarning(
      String goalName, int daysRemaining) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'goals_channel',
      'Objectifs Financiers',
      channelDescription: 'Notifications pour les objectifs financiers',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: Color(0xFFFF9800),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      3,
      '⏰ Objectif bientôt échéant',
      'Plus que $daysRemaining jours pour atteindre "$goalName"',
      notificationDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Toutes les notifications ont été annulées');
    } catch (e) {
      debugPrint('Erreur lors de l\'annulation des notifications: $e');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur vérification notifications: $e');
      return false;
    }
  }
}
