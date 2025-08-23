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
  // Simuler un achat avec paiement par carte (dans un vrai projet, utilisez un vrai système de paiement)
  Future<bool> simulatePurchase(BuildContext context) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    bool isProcessing = false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                child: Icon(Icons.credit_card, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement Premium',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${premiumPrice.toStringAsFixed(2)} / an',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFA500),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Numéro de carte
                  TextFormField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    decoration: InputDecoration(
                      labelText: 'Numéro de carte',
                      hintText: '1234 5678 9012 3456',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                    ),
                    onChanged: (value) {
                      // Formatage automatique du numéro de carte
                      String formatted = value.replaceAll(' ', '');
                      if (formatted.length <= 16) {
                        formatted = formatted.replaceAllMapped(
                          RegExp(r'(.{4})'),
                              (match) => '${match.group(1)} ',
                        );
                        if (formatted.endsWith(' ')) {
                          formatted = formatted.substring(0, formatted.length - 1);
                        }
                        cardNumberController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir le numéro de carte';
                      }
                      String cleanValue = value.replaceAll(' ', '');
                      if (cleanValue.length != 16) {
                        return 'Le numéro doit contenir 16 chiffres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nom sur la carte
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Nom sur la carte',
                      hintText: 'JOHN SMITH',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez saisir le nom sur la carte';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date d'expiration et CVV
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: expiryController,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          decoration: InputDecoration(
                            labelText: 'MM/AA',
                            hintText: '12/25',
                            prefixIcon: Icon(Icons.calendar_month),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            counterText: '',
                          ),
                          onChanged: (value) {
                            if (value.length == 2 && !value.contains('/')) {
                              expiryController.value = TextEditingValue(
                                text: '$value/',
                                selection: TextSelection.collapsed(offset: 3),
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Date requise';
                            }
                            if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                              return 'Format: MM/AA';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: cvvController,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            prefixIcon: Icon(Icons.security),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'CVV requis';
                            }
                            if (value.length != 3) {
                              return '3 chiffres';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Informations de sécurité
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Paiement sécurisé - Vos données sont protégées',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: isProcessing ? null : () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      isProcessing = true;
                    });

                    // Simuler le traitement du paiement
                    await Future.delayed(Duration(seconds: 2));

                    // Simuler une réponse aléatoire (90% de succès)
                    bool paymentSuccess = DateTime.now().millisecond % 10 != 0;

                    if (paymentSuccess) {
                      // Afficher un message de succès
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Paiement effectué avec succès !'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    } else {
                      setState(() {
                        isProcessing = false;
                      });
                      // Afficher un message d'erreur
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Erreur de paiement. Veuillez réessayer.'),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: isProcessing
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Traitement...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_card, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Payer \$${premiumPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ) ?? false;
  }
}