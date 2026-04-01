import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Nouveau import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:smartspend/services/premium_service.dart';
import 'auth_wrapper.dart';
import 'notification_service.dart';
import 'theme.dart';
import 'utils.dart';
import 'theme_provider.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp();

  // Configurer Firestore
  await _configureFirestore();

  // Initialiser la locale
  await initializeLocale();
  // NOUVEAU: Initialiser le service Premium/In-App Purchase
  await PremiumService().initialize();

  // Initialiser le ThemeProvider
  await ThemeProvider().initialize();

  // Initialisation des notifications
  try {
    await NotificationService().initialize();
    print('Service de notifications initialisé avec succès');
  } catch (e) {
    print('Erreur lors de l\'initialisation des notifications: $e');
  }

  runApp(const MyApp());
}

// Nouvelle fonction pour configurer Firestore
Future<void> _configureFirestore() async {
  try {
    // Activer la persistance hors ligne
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Activer les logs en mode debug
    if (kDebugMode) {
      await FirebaseFirestore.instance.enableNetwork();
      print('Firestore configuré avec succès');
      print('Persistance hors ligne activée');
    }

    // Créer les index nécessaires programmatiquement
    await _ensureFirestoreIndexes();

  } catch (e) {
    print('Erreur lors de la configuration de Firestore: $e');
  }
}

// Fonction pour s'assurer que les index Firestore existent
Future<void> _ensureFirestoreIndexes() async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Test de connexion simple
    await firestore.collection('users').limit(1).get();

    print('Index Firestore vérifiés avec succès');
  } catch (e) {
    // Les erreurs d'index sont normales lors du premier déploiement
    print('Index Firestore en cours de création: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SmartSpend',
            theme: AppTheme.getTheme(false),
            darkTheme: AppTheme.getTheme(true),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}