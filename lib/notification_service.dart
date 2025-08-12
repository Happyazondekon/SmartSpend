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
      // Initialiser les fuseaux horaires
      tz.initializeTimeZones();

      // Configuration Android plus complète
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuration iOS
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

        // Créer le canal de notification pour Android
        await _createNotificationChannel();
      } else {
        print('Erreur: Impossible d\'initialiser les notifications');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  // Créer le canal de notification (requis pour Android 8+)
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'smartspend_reminders', // ID du canal
      'Rappels SmartSpend', // Nom du canal
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

  // Test de notification immédiate (plus simple)
  Future<void> scheduleInstantReminder() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      print('Programmation d\'une notification dans 3 secondes...');

      await _notificationsPlugin.zonedSchedule(
        1, // ID différent de 0
        'Test SmartSpend ✅',
        'Cette notification de test a été envoyée avec succès! 🎉',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_reminders', // Utiliser le même ID de canal
            'Rappels SmartSpend',
            channelDescription: 'Notifications de rappel pour enregistrer les transactions',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            // Forcer l'affichage même si l'app est ouverte
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

      print('Notification test programmée avec succès pour ${tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3))}');
    } catch (e) {
      print('Erreur lors de la programmation de la notification test: $e');
      rethrow;
    }
  }

  // Notification immédiate (sans délai) pour test
  Future<void> showImmediateNotification() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _notificationsPlugin.show(
        2, // ID différent
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

  // Fonction de rappel quotidien améliorée
  Future<void> scheduleDailyReminder() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Annuler d'abord toute notification existante avec cet ID
      await _notificationsPlugin.cancel(0);

      final scheduledTime = _nextInstanceOfTime(21, 0);
      print('Programmation rappel quotidien pour: $scheduledTime');

      await _notificationsPlugin.zonedSchedule(
        0, // ID pour les rappels quotidiens
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
        matchDateTimeComponents: DateTimeComponents.time, // Répéter quotidiennement
      );

      print('Rappel quotidien programmé avec succès');
    } catch (e) {
      print('Erreur programmation rappel quotidien: $e');
      rethrow;
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

  // Fonction de debug améliorée
  Future<void> debugNotifications() async {
    print('=== DEBUG NOTIFICATIONS SMARTSPEND ===');

    // Vérifier l'initialisation
    print('Service initialisé: $_isInitialized');

    // Vérifier les permissions détaillées
    var scheduleStatus = await Permission.scheduleExactAlarm.status;
    var notificationStatus = await Permission.notification.status;
    print('Permission alarme exacte: $scheduleStatus');
    print('Permission notification: $notificationStatus');

    // Vérifier les paramètres système
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    print('Permission optimisation batterie: $batteryStatus');

    // Lister toutes les notifications en attente
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    print('Notifications en attente: ${pending.length}');
    for (var notif in pending) {
      print('  - ID: ${notif.id}, Titre: "${notif.title}", Body: "${notif.body}"');
    }

    // Test avec les trois méthodes
    print('--- Tests de notifications ---');

    // 1. Notification immédiate
    try {
      await showImmediateNotification();
      print('✅ Test notification immédiate envoyé');
    } catch (e) {
      print('❌ Erreur notification immédiate: $e');
    }

    // 2. Notification programmée
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
    }
  }

  // Nouvelle fonction pour vérifier si les notifications sont vraiment activées
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