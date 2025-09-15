import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constantes
  static const int maxFreeExports = 3;
  static const int maxFreeChatbotUses = 3;
  static const double premiumPrice = 0.2;

  // Constantes FedaPay

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
                showPaymentOptionsDialog(context);
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
                showPaymentOptionsDialog(context);
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
  // =================== INTÉGRATION PAYPAL ===========================
  // ===================================================================

  // PayPal Service intégré

  static const String _sandboxUrl = 'https://api.sandbox.paypal.com';
  static const bool _isProduction = true; // Changez à true pour la production

  static String get _baseUrl => _isProduction ? 'https://api.paypal.com' : _sandboxUrl;

  Future<String?> _getAccessToken() async {
    try {
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/oauth2/token'),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en_US',
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      print('Erreur lors de l\'obtention du token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _createPayment({
    required double amount,
    required String currency,
    required String description,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return null;

      final paymentData = {
        'intent': 'sale',
        'payer': {
          'payment_method': 'paypal'
        },
        'transactions': [
          {
            'amount': {
              'total': amount.toStringAsFixed(2),
              'currency': currency,
            },
            'description': description,
          }
        ],
        'redirect_urls': {
          'return_url': returnUrl,
          'cancel_url': cancelUrl,
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la création du paiement: $e');
      return null;
    }
  }

  Future<bool> _executePayment({
    required String paymentId,
    required String payerId,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return false;

      final executeData = {
        'payer_id': payerId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments/payment/$paymentId/execute'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(executeData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de l\'exécution du paiement: $e');
      return false;
    }
  }

  // Méthode simulatePurchase avec PayPal
  Future<bool> simulatePurchase(BuildContext context) async {
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
                child: Icon(Icons.star, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade Premium',
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo PayPal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0070BA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF0070BA).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF0070BA),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PayPal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0070BA),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Avantages Premium
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFD700).withOpacity(0.1),
                        Color(0xFFFFA500).withOpacity(0.1)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartSpend Premium inclut :',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...['✨ Exports PDF illimités', '🤖 Assistant financier illimité', '📊 Analyses avancées']
                          .map((benefit) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          benefit,
                          style: TextStyle(fontSize: 12),
                        ),
                      ))
                          .toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Informations de sécurité PayPal
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
                          'Paiement sécurisé avec PayPal - Vos données financières ne sont pas partagées',
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
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF0070BA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: isProcessing ? null : () async {
                  setState(() {
                    isProcessing = true;
                  });

                  try {
                    // Créer le paiement PayPal
                    final payment = await _createPayment(
                      amount: premiumPrice,
                      currency: 'USD',
                      description: 'SmartSpend Premium - Abonnement annuel',
                      returnUrl: 'https://smartspend.app/success',
                      cancelUrl: 'https://smartspend.app/cancel',
                    );

                    if (payment != null) {
                      // Trouver l'URL d'approbation
                      String? approvalUrl;
                      final links = payment['links'] as List;
                      for (var link in links) {
                        if (link['rel'] == 'approval_url') {
                          approvalUrl = link['href'];
                          break;
                        }
                      }

                      if (approvalUrl != null) {
                        setState(() {
                          isProcessing = false;
                        });

                        // Fermer le dialog actuel et ouvrir PayPal WebView
                        Navigator.of(context).pop();

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _PayPalWebView(
                              checkoutUrl: approvalUrl!,
                              onSuccess: (String paymentData) async {
                                Navigator.pop(context);

                                final parts = paymentData.split('|');
                                final paymentId = parts[0];
                                final payerId = parts[1];

                                final success = await _executePayment(
                                  paymentId: paymentId,
                                  payerId: payerId,
                                );

                                if (success) {
                                  // Mise à niveau vers Premium après paiement réussi
                                  await upgradeToPremium();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('Paiement PayPal effectué avec succès !'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return true;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('Erreur lors de l\'exécution du paiement.'),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return false;
                                }
                              },
                              onError: (String error) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur PayPal: $error'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              onCancel: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Paiement annulé'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                          ),
                        );

                        return result ?? false;
                      } else {
                        throw Exception('URL d\'approbation PayPal non trouvée');
                      }
                    } else {
                      throw Exception('Impossible de créer le paiement PayPal');
                    }
                  } catch (e) {
                    setState(() {
                      isProcessing = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(context, false);
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
                      'Préparation...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Payer avec PayPal',
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

  // ===================================================================
  // =================== INTÉGRATION FEDAPAY ===========================
  // ===================================================================

  // Méthode pour initier un paiement FedaPay avec Checkout.js
  Future<bool> purchaseWithFedaPay(BuildContext context) async {
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
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.star, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade Premium',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(premiumPrice * 655).toStringAsFixed(0)} XOF / an',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4CAF50),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo FedaPay
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'FedaPay',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Avantages Premium
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFD700).withOpacity(0.1),
                        Color(0xFFFFA500).withOpacity(0.1)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartSpend Premium inclut :',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...['✨ Exports PDF illimités', '🤖 Assistant financier illimité', '📊 Analyses avancées']
                          .map((benefit) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          benefit,
                          style: TextStyle(fontSize: 12),
                        ),
                      ))
                          .toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Informations de sécurité FedaPay
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
                          'Paiement sécurisé avec FedaPay - Mobile Money, Cartes bancaires',
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
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: isProcessing ? null : () async {
                  setState(() {
                    isProcessing = true;
                  });

                  // Fermer le dialogue actuel et ouvrir la WebView
                  Navigator.of(context).pop();

                  // Convertir le prix en centimes pour FedaPay (XOF)
                  final amountInCents = (premiumPrice * 655).toInt();

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _FedaPayWebView(
                        amountInCents: amountInCents,
                        description: 'SmartSpend Premium - Abonnement annuel',
                        onSuccess: () async {
                          // Le paiement a réussi, effectuez la mise à niveau
                          await upgradeToPremium();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('Paiement FedaPay effectué avec succès !'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          // Fermez la WebView et retournez true
                          Navigator.of(context).pop(true);
                        },
                        onError: (String error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur FedaPay: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          // Fermez la WebView et retournez false
                          Navigator.of(context).pop(false);
                        },
                        onCancel: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Paiement annulé'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          // Fermez la WebView et retournez false
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ),
                  );

                  return result ?? false;
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
                      'Préparation...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Payer avec FedaPay',
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

  // Méthode pour afficher les options de paiement
  void showPaymentOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
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
              'Choisir votre moyen de paiement',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Option PayPal
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF0070BA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance_wallet, color: Color(0xFF0070BA)),
              ),
              title: Text('PayPal'),
              subtitle: Text('Cartes internationales, PayPal'),
              onTap: () {
                Navigator.pop(context);
                simulatePurchase(context);
              },
            ),
            Divider(),
            // Option FedaPay
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment, color: Color(0xFF4CAF50)),
              ),
              title: Text('FedaPay'),
              subtitle: Text('Mobile Money, Cartes locales'),
              onTap: () {
                Navigator.pop(context);
                purchaseWithFedaPay(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

// Widget PayPal WebView privé (non modifié)
class _PayPalWebView extends StatefulWidget {
  final String checkoutUrl;
  final Function(String) onSuccess;
  final Function(String) onError;
  final Function() onCancel;

  const _PayPalWebView({
    Key? key,
    required this.checkoutUrl,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
  }) : super(key: key);

  @override
  __PayPalWebViewState createState() => __PayPalWebViewState();
}

class __PayPalWebViewState extends State<_PayPalWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);

            if (request.url.contains('return_url')) {
              final paymentId = uri.queryParameters['paymentId'];
              final payerId = uri.queryParameters['PayerID'];

              if (paymentId != null && payerId != null) {
                widget.onSuccess('$paymentId|$payerId');
              } else {
                widget.onError('Paramètres de paiement manquants');
              }
              return NavigationDecision.prevent;
            }

            if (request.url.contains('cancel_url')) {
              widget.onCancel();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement PayPal'),
        backgroundColor: Color(0xFF0070BA),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            widget.onCancel();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF0070BA),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement de PayPal...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Widget FedaPay WebView privé (MODIFIÉ)
class _FedaPayWebView extends StatefulWidget {
  final int amountInCents;
  final String description;
  final Function() onSuccess;
  final Function(String) onError;
  final Function() onCancel;

  const _FedaPayWebView({
    Key? key,
    required this.amountInCents,
    required this.description,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
  }) : super(key: key);

  @override
  _FedaPayWebViewState createState() => _FedaPayWebViewState();
}

class _FedaPayWebViewState extends State<_FedaPayWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final htmlContent = """
      <!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement sécurisé</title>
    <script src="https://cdn.fedapay.com/checkout.js?v=1.1.7"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f0f2f5;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-align: center;
            color: #333;
        }
        .container {
            width: 90%;
            max-width: 400px;
            padding: 32px;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            animation: fadeIn 0.8s ease-in-out;
        }
        .logo-container {
            margin-bottom: 24px;
        }
        .logo-container img {
            max-width: 120px;
        }
        h1 {
            font-size: 24px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 8px;
        }
        h2 {
            font-size: 16px;
            font-weight: 400;
            color: #7f8c8d;
            margin-top: 0;
            margin-bottom: 24px;
        }
        .price-display {
            font-size: 32px;
            font-weight: 700;
            color: #27ae60;
            margin: 24px 0;
        }
        button {
            width: 100%;
            background-image: linear-gradient(to right, #4CAF50, #27ae60);
            color: white;
            border: none;
            padding: 18px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(46, 204, 113, 0.6);
        }
        .info-section {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-top: 24px;
            font-size: 12px;
            color: #95a5a6;
        }
        .info-section img {
            height: 16px;
            margin-right: 8px;
        }
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo-container">
            <img src="https://i.imgur.com/cYPfUgX.png" alt="SmartSpend Logo">
        </div>
        <h1>Paiement sécurisé</h1>
        <h2>Abonnement annuel SmartSpend Premium</h2>

        <p class="price-display">
            ${(widget.amountInCents).toStringAsFixed(0)} FCFA
        </p>

        <button id="pay-btn">Payer maintenant</button>

        <div class="info-section">
        
            Paiement 100% sécurisé via FedaPay
        </div>
    </div>

    <script type="text/javascript">
        const widget = FedaPay.init({
            public_key: '${PremiumService._fedaPayPublicKey}',
            transaction: {
                amount: ${widget.amountInCents},
                description: '${widget.description}'
            },
            onComplete: function(response) {
                // Notifier Flutter que le paiement a réussi
                window.flutter_inappwebview.callHandler('onSuccess', response.id);
            },
            onCancel: function() {
                // Notifier Flutter que l'utilisateur a annulé
                window.flutter_inappwebview.callHandler('onCancel');
            },
            onError: function(error) {
                // Notifier Flutter qu'une erreur est survenue
                window.flutter_inappwebview.callHandler('onError', error.message);
            }
        });

        document.getElementById('pay-btn').addEventListener('click', () => {
            widget.open();
        });
    </script>
</body>
</html>
    """;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
          },
          // Cette ligne gère les redirections après le paiement
          onNavigationRequest: (NavigationRequest request) {
            // FedaPay peut rediriger vers une page de succès ou d'échec
            // Vous pouvez intercepter ces URLs ici
            if (request.url.contains('fedapay.com/success')) {
              // Ici, vous pourriez avoir une logique pour dire au code Flutter que c'est un succès
              widget.onSuccess();
              return NavigationDecision.prevent; // Empêche le chargement de la page
            }
            if (request.url.contains('fedapay.com/cancel')) {
              widget.onCancel();
              return NavigationDecision.prevent;
            }
            // Si l'utilisateur clique sur le bouton "retour" de la page web, cela déclenchera un onNavigationRequest
            if (request.url.contains('fedapay.com/checkout')) {
              // Gérer les retours en arrière ici si nécessaire
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          final parts = message.message.split('|');
          final type = parts[0];
          final data = parts.length > 1 ? parts[1] : null;

          if (type == 'onSuccess') {
            widget.onSuccess();
          } else if (type == 'onCancel') {
            widget.onCancel();
          } else if (type == 'onError') {
            widget.onError(data ?? 'Erreur inconnue');
          }
        },
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement FedaPay'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          // IMPORTANT: Vous devez gérer le bouton de fermeture de manière plus intelligente.
          // Si l'utilisateur ferme, vous devez considérer le paiement comme "en cours"
          // et vérifier l'état du paiement plus tard.
          onPressed: () {
            // Afficher un dialogue de confirmation pour éviter les annulations accidentelles
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Annuler le paiement ?'),
                content: Text('Êtes-vous sûr de vouloir annuler le processus de paiement ? La transaction pourrait être toujours en cours.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(), // Rester sur la page
                    child: Text('Continuer le paiement'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Fermer le dialogue de confirmation
                      Navigator.of(context).pop(false); // Fermer la webview avec 'false'
                    },
                    child: Text('Oui, annuler'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement de FedaPay...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}