import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Clés définies dans la console Firebase
  static const String _keyMinVersion = 'min_required_version';
  static const String _keyStoreUrl = 'store_url';

  String get storeUrl => _remoteConfig.getString(_keyStoreUrl);

  /// Initialiser et récupérer les configs
  Future<void> initialize() async {
    try {
      // Paramètres par défaut si pas d'internet
      await _remoteConfig.setDefaults({
        _keyMinVersion: '1.0.0',
        _keyStoreUrl: 'https://play.google.com/store/apps/details?id=com.heyhappy.smartspend',
      });

      // Configurer le cache (0 en dev pour voir les changements de suite, 1h en prod)
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 0) : const Duration(hours: 1),
      ));

      // Récupérer et activer les valeurs
      await _remoteConfig.fetchAndActivate();

      if (kDebugMode) {
        print('Remote Config: Min Version: ${_remoteConfig.getString(_keyMinVersion)}');
      }
    } catch (e) {
      print('Erreur Remote Config: $e');
    }
  }

  /// Vérifier si une mise à jour est requise
  Future<bool> isUpdateRequired() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersionStr = packageInfo.version; // ex: "1.0.0"
      final String minVersionStr = _remoteConfig.getString(_keyMinVersion);

      if (kDebugMode) {
        print('Version actuelle: $currentVersionStr, Version min requise: $minVersionStr');
      }

      return _compareVersions(currentVersionStr, minVersionStr) < 0;
    } catch (e) {
      print('Erreur lors de la comparaison de version: $e');
      return false; // En cas d'erreur, on ne bloque pas l'utilisateur
    }
  }

  /// Compare deux versions (ex: "1.2.0" vs "1.2.1")
  /// Retourne -1 si v1 < v2 (Mise à jour requise)
  /// Retourne 0 si v1 == v2
  /// Retourne 1 si v1 > v2
  int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      int part1 = (i < v1Parts.length) ? v1Parts[i] : 0;
      int part2 = (i < v2Parts.length) ? v2Parts[i] : 0;

      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }
    return 0;
  }
}
