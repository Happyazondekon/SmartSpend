import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constantes
  static const int maxFreeExports = 3;
  static const int maxFreeChatbotUses = 3;
  static const double premiumPrice = 20.0; // 2 dollars

  String? get currentUserId => _auth.currentUser?.uid;

  // ===================================================================
  // =================== GESTION DES COMPTES GRATUITS ================
  // ===================================================================

  Future<int> getPDFExportsUsed() async {
    if (currentUserId == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['pdfExportsUsed'] ?? 0;
      }
      return 0;
    } catch (e) {
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('pdf_exports_used') ?? 0;
    }
  }

  Future<int> getChatbotUsesUsed() async {
    if (currentUserId == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['chatbotUsesUsed'] ?? 0;
      }
      return 0;
    } catch (e) {
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('chatbot_uses_used') ?? 0;
    }
  }

  Future<bool> isPremiumUser() async {
    if (currentUserId == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        final isPremium = doc.data()!['isPremium'] ?? false;
        final premiumExpiryDate = doc.data()!['premiumExpiryDate'] as Timestamp?;

        if (isPremium && premiumExpiryDate != null) {
          return premiumExpiryDate.toDate().isAfter(DateTime.now());
        }
        return isPremium;
      }
      return false;
    } catch (e) {
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_premium') ?? false;
    }
  }

  Future<void> incrementPDFExports() async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'pdfExportsUsed': FieldValue.increment(1),
      });
    } catch (e) {
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('pdf_exports_used') ?? 0;
      await prefs.setInt('pdf_exports_used', current + 1);
    }
  }

  Future<void> incrementChatbotUses() async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'chatbotUsesUsed': FieldValue.increment(1),
      });
    } catch (e) {
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('chatbot_uses_used') ?? 0;
      await prefs.setInt('chatbot_uses_used', current + 1);
    }
  }

  // ===================================================================
  // =================== VÉRIFICATIONS ===============================
  // ===================================================================

  Future<bool> canExportPDF() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return true;

    final exportsUsed = await getPDFExportsUsed();
    return exportsUsed < maxFreeExports;
  }

  Future<bool> canUseChatbot() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return true;

    final usesUsed = await getChatbotUsesUsed();
    return usesUsed < maxFreeChatbotUses;
  }

  Future<int> getRemainingPDFExports() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return -1; // Illimité

    final exportsUsed = await getPDFExportsUsed();
    return (maxFreeExports - exportsUsed).clamp(0, maxFreeExports);
  }

  Future<int> getRemainingChatbotUses() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return -1; // Illimité

    final usesUsed = await getChatbotUsesUsed();
    return (maxFreeChatbotUses - usesUsed).clamp(0, maxFreeChatbotUses);
  }

  // ===================================================================
  // =================== UPGRADE VERS PREMIUM ========================
  // ===================================================================

  Future<void> upgradeToPremium() async {
    if (currentUserId == null) return;

    try {
      // Dans un vrai système, ici vous intégreriez un système de paiement
      // comme Stripe, PayPal, etc.

      final expiryDate = DateTime.now().add(const Duration(days: 365)); // 1 an

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'isPremium': true,
        'premiumExpiryDate': Timestamp.fromDate(expiryDate),
        'premiumUpgradeDate': Timestamp.now(),
      });

      // Sauvegarder aussi localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', true);

    } catch (e) {
      throw 'Erreur lors de la mise à niveau Premium';
    }
  }

  // ===================================================================
  // =================== WIDGETS UTILITAIRES =========================
  // ===================================================================

  Widget buildPremiumBadge({Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color ?? const Color(0xFFFFD700),
            color?.withOpacity(0.8) ?? const Color(0xFFFFA500),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (color ?? const Color(0xFFFFD700)).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            'PREMIUM',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void showPremiumDialog(
      BuildContext context, {
        required String feature,
        required VoidCallback onUpgrade,
        int? remainingUses,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.star, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Premium requis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (remainingUses != null && remainingUses > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Il vous reste $remainingUses essais gratuits pour $feature',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (remainingUses == null || remainingUses <= 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vous avez épuisé vos essais gratuits pour $feature',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'Passez à SmartSpend Premium pour :',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),

            ...[
              '✨ Exports PDF illimités',
              '🤖 Assistant financier illimité',
              '📊 Analyses avancées',
              '☁️ Synchronisation cloud prioritaire',
              '🎯 Objectifs financiers avancés',
              '📱 Support prioritaire',
            ].map((benefit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(benefit, style: TextStyle(fontSize: 14)),
            )).toList(),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700).withOpacity(0.2), Color(0xFFFFA500).withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money, color: Color(0xFFFFA500)),
                  Text(
                    'Seulement \$${premiumPrice.toStringAsFixed(0)} pour 1 an',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFA500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Plus tard'),
          ),
          if (remainingUses != null && remainingUses > 0)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Permettre l'utilisation gratuite
              },
              child: Text('Essayer gratuitement'),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onUpgrade();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Passer à Premium',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simuler un achat (dans un vrai projet, utilisez un vrai système de paiement)
  Future<bool> simulatePurchase(BuildContext context) async {
    // Afficher un dialogue de confirmation de paiement
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation d\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text('Confirmez-vous l\'achat de SmartSpend Premium ?'),
            const SizedBox(height: 8),
            Text(
              '\$${premiumPrice.toStringAsFixed(2)} pour 1 an',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirmer l\'achat'),
          ),
        ],
      ),
    ) ?? false;
  }
}