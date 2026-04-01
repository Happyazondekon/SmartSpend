import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service de notifications locales pour SmartSpend
/// Gère tous les rappels en local sans Firebase
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Clés SharedPreferences
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _lastNotificationTimeKey = 'last_notification_time';
  static const String _newMonthReminderShownKey = 'new_month_reminder_shown';

  // IDs des notifications
  static const int _morningReminderId = 1001;
  static const int _eveningReminderId = 1002;
  static const int _newMonthReminderId = 1003;
  static const int _goalReminderId = 1004;
  static const int _budgetWarningId = 1005;
  static const int _testNotificationId = 9999;

  // Messages motivationnels variés pour les rappels de transactions
  static const List<String> _morningMessages = [
    "Bonjour ! 🌅 Avez-vous des dépenses à enregistrer ?",
    "Nouvelle journée, nouvelles finances ! 💼 Pensez à noter vos dépenses.",
    "Un petit check financier ce matin ? ☕",
    "Commencez bien la journée en gérant vos finances ! 📊",
    "Bonjour ! Vos objectifs financiers vous attendent 🎯",
  ];

  static const List<String> _eveningMessages = [
    "Bonsoir ! 🌙 N'oubliez pas de saisir vos dépenses du jour.",
    "Fin de journée = bilan financier ! 💰 Avez-vous tout noté ?",
    "Avant de dormir, un petit tour sur vos finances ? 📱",
    "Bilan du jour : avez-vous enregistré toutes vos transactions ? ✅",
    "Bonne soirée ! Pensez à mettre à jour vos dépenses 🌟",
    "Votre portefeuille vous remercie de le tenir à jour ! 💳",
  ];

  static const List<String> _newMonthMessages = [
    "🎉 Nouveau mois, nouvelles opportunités ! Entrez vos revenus du mois.",
    "C'est le début du mois ! 📅 Définissez vos revenus pour bien démarrer.",
    "Nouveau mois = nouveau budget ! 💪 Commencez par entrer vos revenus.",
    "Le mois précédent est clôturé ! Entrez vos revenus pour ce mois 📊",
  ];

  static const List<String> _goalReminderMessages = [
    "Vos objectifs financiers vous attendent ! 🎯",
    "N'oubliez pas vos rêves financiers ! Continuez à épargner 💎",
    "Un pas de plus vers vos objectifs ! 🚀",
  ];

  // ===================================================================
  // ===================== INITIALISATION =============================
  // ===================================================================

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
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _isInitialized = true;
        await _createNotificationChannels();
        debugPrint('✅ Service de notification initialisé avec succès');
      }
    } catch (e) {
      debugPrint('❌ Erreur initialisation notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification cliquée: ${response.payload}');
    // Navigation possible selon le payload
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Canal pour les rappels quotidiens
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'smartspend_daily',
        'Rappels quotidiens',
        description: 'Rappels pour saisir vos transactions',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Canal pour les rappels de nouveau mois
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'smartspend_monthly',
        'Rappels mensuels',
        description: 'Rappels pour entrer vos revenus mensuels',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Canal pour les objectifs
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'smartspend_goals',
        'Objectifs financiers',
        description: 'Notifications liées à vos objectifs',
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Canal pour les alertes budget
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'smartspend_budget',
        'Alertes budget',
        description: 'Alertes de dépassement de budget',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    debugPrint('📢 Canaux de notification créés');
  }

  // ===================================================================
  // ===================== GESTION DES PERMISSIONS ====================
  // ===================================================================

  Future<bool> requestPermissions() async {
    try {
      final notificationStatus = await Permission.notification.request();
      if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
        return false;
      }

      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      if (exactAlarmStatus.isDenied) {
        debugPrint('⚠️ Permission alarme exacte refusée');
      }

      return notificationStatus.isGranted;
    } catch (e) {
      debugPrint('❌ Erreur demande permissions: $e');
      return false;
    }
  }

  Future<bool> hasRequiredPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    return notificationStatus.isGranted && exactAlarmStatus.isGranted;
  }

  // ===================================================================
  // ===================== ÉTAT DES NOTIFICATIONS =====================
  // ===================================================================

  /// Activer/désactiver les notifications (stocké en local)
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      await scheduleAllReminders();
    } else {
      await cancelAllNotifications();
    }
  }

  /// Vérifier si les notifications sont activées (stocké en local)
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  /// Vérifier si les notifications système sont activées
  Future<bool> areSystemNotificationsEnabled() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ===================================================================
  // ===================== PROGRAMMATION DES RAPPELS ==================
  // ===================================================================

  /// Programmer tous les rappels automatiques
  Future<Map<String, bool>> scheduleAllReminders() async {
    if (!await areNotificationsEnabled() || !await hasRequiredPermissions()) {
      return {'morning': false, 'evening': false};
    }

    final results = <String, bool>{};

    // Rappel du matin (8h30)
    results['morning'] = await _scheduleDailyReminder(
      id: _morningReminderId,
      hour: 8,
      minute: 30,
      messages: _morningMessages,
      title: '💰 SmartSpend - Bonjour !',
    );

    // Rappel du soir (20h00)
    results['evening'] = await _scheduleDailyReminder(
      id: _eveningReminderId,
      hour: 20,
      minute: 0,
      messages: _eveningMessages,
      title: '💰 SmartSpend - Rappel du soir',
    );

    debugPrint('📅 Rappels programmés: $results');
    return results;
  }

  Future<bool> _scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required List<String> messages,
    required String title,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final scheduledTime = _nextInstanceOfTime(hour, minute);
      final message = messages[Random().nextInt(messages.length)];

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        message,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_daily',
            'Rappels quotidiens',
            channelDescription: 'Rappels pour saisir vos transactions',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF00A9A9),
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: const DarwinNotificationDetails(
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

      return true;
    } catch (e) {
      debugPrint('❌ Erreur programmation rappel ($id): $e');
      return false;
    }
  }

  /// Programmer un rappel pour le début du nouveau mois
  Future<bool> scheduleNewMonthReminder() async {
    try {
      if (!_isInitialized) await initialize();
      if (!await areNotificationsEnabled()) return false;

      // Programmer pour le 1er du mois prochain à 9h00
      final now = DateTime.now();
      var nextMonth = DateTime(now.year, now.month + 1, 1, 9, 0);
      
      // Si on est déjà le 1er et avant 9h, programmer pour aujourd'hui
      if (now.day == 1 && now.hour < 9) {
        nextMonth = DateTime(now.year, now.month, 1, 9, 0);
      }

      final scheduledTime = tz.TZDateTime.from(nextMonth, tz.local);
      final message = _newMonthMessages[Random().nextInt(_newMonthMessages.length)];

      await _notificationsPlugin.zonedSchedule(
        _newMonthReminderId,
        '📅 Nouveau mois !',
        message,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_monthly',
            'Rappels mensuels',
            channelDescription: 'Rappels pour entrer vos revenus mensuels',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF4CAF50),
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
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );

      debugPrint('📅 Rappel nouveau mois programmé pour: $scheduledTime');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur programmation rappel nouveau mois: $e');
      return false;
    }
  }

  // ===================================================================
  // ===================== NOTIFICATIONS IMMÉDIATES ===================
  // ===================================================================

  /// Afficher une notification immédiate pour le nouveau mois
  Future<void> showNewMonthNotification() async {
    try {
      if (!_isInitialized) await initialize();

      final prefs = await SharedPreferences.getInstance();
      final currentMonth = '${DateTime.now().year}-${DateTime.now().month}';
      final lastShown = prefs.getString(_newMonthReminderShownKey);

      // Ne pas afficher si déjà montré ce mois
      if (lastShown == currentMonth) return;

      await _notificationsPlugin.show(
        _newMonthReminderId + 100,
        '🎉 Nouveau mois !',
        _newMonthMessages[Random().nextInt(_newMonthMessages.length)],
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_monthly',
            'Rappels mensuels',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF4CAF50),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'new_month',
      );

      await prefs.setString(_newMonthReminderShownKey, currentMonth);
    } catch (e) {
      debugPrint('❌ Erreur notification nouveau mois: $e');
    }
  }

  /// Afficher une notification d'alerte budget dépassé
  Future<void> showBudgetWarningNotification(String category, double percentUsed) async {
    try {
      if (!_isInitialized) await initialize();

      String message;
      if (percentUsed >= 100) {
        message = '🚨 Budget "$category" dépassé ! Attention aux dépenses.';
      } else if (percentUsed >= 90) {
        message = '⚠️ Budget "$category" presque épuisé (${percentUsed.toStringAsFixed(0)}%)';
      } else {
        message = '📊 Vous avez utilisé ${percentUsed.toStringAsFixed(0)}% du budget "$category"';
      }

      await _notificationsPlugin.show(
        _budgetWarningId + category.hashCode % 1000,
        '💰 Alerte Budget',
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_budget',
            'Alertes budget',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFFFF9800),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur notification budget: $e');
    }
  }

  /// Afficher une notification d'objectif atteint
  Future<void> showGoalAchievedNotification(String goalName) async {
    try {
      if (!_isInitialized) await initialize();

      await _notificationsPlugin.show(
        _goalReminderId,
        '🎉 Objectif atteint !',
        'Félicitations ! Vous avez atteint votre objectif "$goalName" 🏆',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_goals',
            'Objectifs financiers',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF4CAF50),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur notification objectif: $e');
    }
  }

  /// Afficher un avertissement d'échéance d'objectif
  Future<void> showGoalDeadlineWarning(String goalName, int daysRemaining) async {
    try {
      if (!_isInitialized) await initialize();

      await _notificationsPlugin.show(
        _goalReminderId + 1,
        '⏰ Objectif bientôt échéant',
        'Plus que $daysRemaining jours pour atteindre "$goalName"',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_goals',
            'Objectifs financiers',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFFFF9800),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur notification deadline: $e');
    }
  }

  // ===================================================================
  // ===================== NOTIFICATIONS DE TEST ======================
  // ===================================================================

  /// Afficher une notification de test immédiate
  Future<void> showTestNotification() async {
    try {
      if (!_isInitialized) await initialize();

      await _notificationsPlugin.show(
        _testNotificationId,
        '✅ Test SmartSpend',
        'Les notifications fonctionnent correctement ! 🎉',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_daily',
            'Rappels quotidiens',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF00A9A9),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur notification test: $e');
    }
  }

  /// Programmer une notification de test dans quelques secondes
  Future<void> scheduleTestNotification({int delaySeconds = 3}) async {
    try {
      if (!_isInitialized) await initialize();

      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));

      await _notificationsPlugin.zonedSchedule(
        _testNotificationId + 1,
        '⏰ Test programmé',
        'Cette notification était programmée pour dans $delaySeconds secondes !',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartspend_daily',
            'Rappels quotidiens',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF00A9A9),
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

      debugPrint('⏰ Notification test programmée pour dans $delaySeconds secondes');
    } catch (e) {
      debugPrint('❌ Erreur programmation test: $e');
    }
  }

  // ===================================================================
  // ===================== UTILITAIRES ================================
  // ===================================================================

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('🗑️ Toutes les notifications annulées');
    } catch (e) {
      debugPrint('❌ Erreur annulation notifications: $e');
    }
  }

  /// Annuler une notification spécifique
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Obtenir la liste des notifications en attente
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Obtenir des statistiques sur les notifications
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final pending = await getPendingNotifications();
      final enabled = await areNotificationsEnabled();
      final hasPermissions = await hasRequiredPermissions();
      final systemEnabled = await areSystemNotificationsEnabled();

      return {
        'pendingCount': pending.length,
        'enabled': enabled,
        'hasPermissions': hasPermissions,
        'systemEnabled': systemEnabled,
        'pendingIds': pending.map((n) => n.id).toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Sauvegarder le timestamp de la dernière notification
  Future<void> _saveLastNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastNotificationTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Récupérer le timestamp de la dernière notification
  Future<DateTime?> getLastNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastNotificationTimeKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
}
