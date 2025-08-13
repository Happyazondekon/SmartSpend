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
          print('Notification cliquée: ${details.payload}');
        },
      );

      if (initialized == true) {
        _isInitialized = true;
        print('Service de notification initialisé avec succès');
        await _createNotificationChannel();
      } else {
        print('Erreur: Impossible d\'initialiser les notifications');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('Canal de notification créé: ${channel.id}');
  }

  Future<void> scheduleInstantReminder() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      print('Programmation d\'une notification dans 3 secondes...');

      await _notificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique basé sur le timestamp
        'Test SmartSpend ✅',
        'Cette notification de test a été envoyée avec succès! 🎉',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_reminders',
            'Rappels SmartSpend',
            channelDescription: 'Notifications de rappel pour enregistrer les transactions',
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

      print('Notification test programmée avec succès');
    } catch (e) {
      print('Erreur lors de la programmation de la notification test: $e');
      rethrow;
    }
  }

  Future<void> showImmediateNotification() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1, // ID unique
        'SmartSpend - Test Immédiat',
        'Cette notification s\'affiche immédiatement!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_reminders',
            'Rappels SmartSpend',
            channelDescription: 'Notifications de rappel pour enregistrer les transactions',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
      );

      print('Notification immédiate affichée');
    } catch (e) {
      print('Erreur notification immédiate: $e');
      rethrow;
    }
  }

  // CORRECTION PRINCIPALE : Éviter cancel() qui pose problème
  Future<void> scheduleDailyReminder() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final scheduledTime = _nextInstanceOfTime(21, 0);
      print('Programmation rappel quotidien pour: $scheduledTime');

      // IMPORTANT: Ne pas utiliser cancel() avant, utiliser un ID fixe
      const int dailyReminderId = 999; // ID fixe pour les rappels quotidiens

      await _notificationsPlugin.zonedSchedule(
        dailyReminderId,
        'SmartSpend - Rappel quotidien 💰',
        'N\'oubliez pas d\'enregistrer vos transactions aujourd\'hui!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_reminders',
            'Rappels SmartSpend',
            channelDescription: 'Notifications de rappel pour enregistrer les transactions',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
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

      print('Rappel quotidien programmé avec succès');
    } catch (e) {
      print('Erreur programmation rappel quotidien: $e');

      // En cas d'erreur, essayer une approche alternative
      await _scheduleSimpleReminder();
    }
  }

  // Méthode alternative plus simple
  Future<void> _scheduleSimpleReminder() async {
    try {
      await _notificationsPlugin.periodicallyShow(
        998, // ID différent
        'SmartSpend - Rappel 💰',
        'Pensez à vos transactions!',
        RepeatInterval.daily,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_reminders',
            'Rappels SmartSpend',
            channelDescription: 'Notifications de rappel pour enregistrer les transactions',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      print('Rappel périodique simple activé');
    } catch (e) {
      print('Erreur rappel périodique: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> debugNotifications() async {
    print('=== DEBUG NOTIFICATIONS SMARTSPEND ===');
    print('Service initialisé: $_isInitialized');

    var scheduleStatus = await Permission.scheduleExactAlarm.status;
    var notificationStatus = await Permission.notification.status;
    print('Permission alarme exacte: $scheduleStatus');
    print('Permission notification: $notificationStatus');

    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    print('Permission optimisation batterie: $batteryStatus');

    // ÉVITER pendingNotificationRequests() qui peut causer des crashes
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      print('Notifications en attente: ${pending.length}');
    } catch (e) {
      print('Impossible de lister les notifications en attente: $e');
    }

    print('--- Tests de notifications ---');

    try {
      await showImmediateNotification();
      print('✅ Test notification immédiate envoyé');
    } catch (e) {
      print('❌ Erreur notification immédiate: $e');
    }

    try {
      await scheduleInstantReminder();
      print('✅ Test notification programmée envoyé (dans 3s)');
    } catch (e) {
      print('❌ Erreur notification programmée: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('Toutes les notifications ont été annulées');
    } catch (e) {
      print('Erreur lors de l\'annulation des notifications: $e');
      // En cas d'erreur, on ignore silencieusement
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      }
      return false;
    } catch (e) {
      print('Erreur vérification notifications: $e');
      return false;
    }
  }
}