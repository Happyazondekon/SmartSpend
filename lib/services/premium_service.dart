import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'in_app_purchase_service.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final InAppPurchaseService _iapService = InAppPurchaseService();

  // Constantes
  static const int maxFreeExports = 3;
  static const int maxFreeChatbotUses = 3;
  static const double premiumPrice = 4.99; // Prix en USD

  String? get currentUserId => _auth.currentUser?.uid;

  // ===================================================================
  // =================== INITIALISATION ===============================
  // ===================================================================

  Future<void> initialize() async {
    await _iapService.initialize();
  }

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
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('chatbot_uses_used') ?? 0;
    }
  }

  Future<bool> isPremiumUser() async {
    return await _iapService.checkPremiumStatus();
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
    if (isPremium) return -1;

    final exportsUsed = await getPDFExportsUsed();
    return (maxFreeExports - exportsUsed).clamp(0, maxFreeExports);
  }

  Future<int> getRemainingChatbotUses() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return -1;

    final usesUsed = await getChatbotUsesUsed();
    return (maxFreeChatbotUses - usesUsed).clamp(0, maxFreeChatbotUses);
  }

  // ===================================================================
  // =================== UPGRADE VERS PREMIUM ========================
  // ===================================================================

  Future<void> upgradeToPremium() async {
    if (currentUserId == null) return;

    try {
      final expiryDate = DateTime.now().add(const Duration(days: 365));

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'isPremium': true,
        'premiumExpiryDate': Timestamp.fromDate(expiryDate),
        'premiumUpgradeDate': Timestamp.now(),
      });

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

  // ===================================================================
  // =================== DIALOGUE PREMIUM =============================
  // ===================================================================

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
                _showPurchaseDialog(context);
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
                _showPurchaseDialog(context);
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

  // ===================================================================
  // =================== DIALOGUE D'ACHAT =============================
  // ===================================================================

  void _showPurchaseDialog(BuildContext context) async {
    final products = _iapService.products;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement des produits. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
            Expanded(
              child: Text(
                'Choisir votre abonnement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: products.map((product) {
              final isYearly = product.id == InAppPurchaseService.premiumYearlyProductId;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: isYearly
                      ? LinearGradient(
                    colors: [
                      Color(0xFFFFD700).withOpacity(0.2),
                      Color(0xFFFFA500).withOpacity(0.1)
                    ],
                  )
                      : null,
                  color: isYearly ? null : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isYearly ? Color(0xFFFFD700) : Colors.grey,
                    width: isYearly ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _purchaseProduct(context, product.id);
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isYearly
                          ? Color(0xFFFFD700).withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isYearly ? Icons.star : Icons.schedule,
                      color: isYearly ? Color(0xFFFFA500) : Colors.grey[700],
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        product.title.split(' (').first,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ÉCONOMISEZ',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    product.description,
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    product.price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isYearly ? Color(0xFFFFA500) : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _iapService.restorePurchases();

              // Vérifier le statut après la restauration
              final isPremium = await isPremiumUser();
              if (isPremium && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Achats restaurés avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Aucun achat à restaurer'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text('Restaurer les achats'),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // =================== ACHAT DE PRODUIT =============================
  // ===================================================================

  Future<void> _purchaseProduct(BuildContext context, String productId) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Traitement de votre achat...'),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await _iapService.purchaseProduct(productId);

      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement

        if (success) {
          // Attendre quelques secondes pour que l'achat soit traité
          await Future.delayed(const Duration(seconds: 3));

          // Vérifier le statut Premium
          final isPremium = await isPremiumUser();

          if (isPremium && context.mounted) {
            _showSuccessDialog(context);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer l'indicateur de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'achat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
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
              child: Icon(Icons.star, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Bienvenue Premium !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Color(0xFFFFD700),
            ),
            const SizedBox(height: 16),
            Text(
              'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium de SmartSpend.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Profitez de toutes les fonctionnalités sans limite !',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD700),
              foregroundColor: Colors.white,
            ),
            child: Text('Commencer'),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // =================== MÉTHODE SIMULATEPURCHASE =====================
  // ===================================================================

  /// Cette méthode est conservée pour la compatibilité avec l'ancien code
  /// Elle appelle maintenant le vrai système d'achat in-app
  Future<bool> simulatePurchase(BuildContext context) async {
    // Appeler le dialogue d'achat réel
    _showPurchaseDialog(context);

    // Retourner false car l'achat réel est asynchrone et géré par le dialogue
    return false;
  }
}