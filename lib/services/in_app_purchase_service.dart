import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // IDs des produits (à configurer dans Google Play Console et App Store Connect)
  static const String premiumYearlyProductId = 'smartspend_premium_yearly';
  static const String premiumMonthlyProductId = 'smartspend_premium_monthly';

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;

  String? get currentUserId => _auth.currentUser?.uid;

  // ===================================================================
  // =================== INITIALISATION ===============================
  // ===================================================================

  Future<void> initialize() async {
    // Vérifier la disponibilité de l'In-App Purchase
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      debugPrint('In-App Purchase non disponible');
      return;
    }

    // Configurer le listener pour les achats
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Charger les produits
    await loadProducts();

    // Restaurer les achats précédents (important pour iOS)
    await restorePurchases();
  }

  void dispose() {
    _subscription.cancel();
  }

  // ===================================================================
  // =================== CHARGEMENT DES PRODUITS ======================
  // ===================================================================

  Future<void> loadProducts() async {
    if (!_isAvailable) {
      debugPrint('In-App Purchase non disponible');
      return;
    }

    const Set<String> productIds = {
      premiumYearlyProductId,
      premiumMonthlyProductId,
    };

    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Produits non trouvés: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        _queryProductError = response.error!.message;
        debugPrint('Erreur lors du chargement des produits: $_queryProductError');
        return;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('Aucun produit trouvé');
        return;
      }

      _products = response.productDetails;
      debugPrint('${_products.length} produits chargés avec succès');
    } catch (e) {
      debugPrint('Erreur lors du chargement des produits: $e');
    }
  }

  // ===================================================================
  // =================== GESTION DES ACHATS ===========================
  // ===================================================================

  Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      debugPrint('In-App Purchase non disponible');
      return false;
    }

    if (_purchasePending) {
      debugPrint('Un achat est déjà en cours');
      return false;
    }

    final ProductDetails? productDetails = _products.firstWhere(
          (product) => product.id == productId,
      orElse: () => throw Exception('Produit non trouvé'),
    );

    if (productDetails == null) {
      debugPrint('Produit non trouvé: $productId');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: currentUserId,
    );

    try {
      _purchasePending = true;

      // Lancer l'achat
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        _purchasePending = false;
        debugPrint('Échec du lancement de l\'achat');
        return false;
      }

      // L'achat est en cours, le résultat sera géré dans _onPurchaseUpdate
      return true;
    } catch (e) {
      _purchasePending = false;
      debugPrint('Erreur lors de l\'achat: $e');
      return false;
    }
  }

  // ===================================================================
  // =================== RESTAURATION DES ACHATS ======================
  // ===================================================================

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('In-App Purchase non disponible');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('Restauration des achats lancée');
    } catch (e) {
      debugPrint('Erreur lors de la restauration des achats: $e');
    }
  }

  // ===================================================================
  // =================== GESTION DES MISES À JOUR =====================
  // ===================================================================

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Achat en attente');
        _purchasePending = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Erreur d\'achat: ${purchaseDetails.error}');
          _purchasePending = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {

          // Vérifier l'achat côté serveur
          final bool valid = await _verifyPurchase(purchaseDetails);

          if (valid) {
            debugPrint('Achat vérifié avec succès');
            await _deliverProduct(purchaseDetails);
          } else {
            debugPrint('Échec de la vérification de l\'achat');
            _purchasePending = false;
            return;
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
          _purchasePending = false;
        }
      }
    });
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
    debugPrint('Stream d\'achats terminé');
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Erreur du stream d\'achats: $error');
  }

  // ===================================================================
  // =================== VÉRIFICATION ET LIVRAISON ====================
  // ===================================================================

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // IMPORTANT: Dans une application en production, vous devez vérifier
    // l'achat côté serveur en utilisant les API Google Play ou App Store

    // Pour Android
    if (purchaseDetails is GooglePlayPurchaseDetails) {
      // Vérifier la signature avec votre serveur
      debugPrint('Vérification Android: ${purchaseDetails.verificationData.serverVerificationData}');
    }

    // Pour iOS
    if (purchaseDetails is AppStorePurchaseDetails) {
      // Vérifier le reçu avec votre serveur
      debugPrint('Vérification iOS: ${purchaseDetails.verificationData.serverVerificationData}');
    }

    // Pour l'instant, on accepte tous les achats (À MODIFIER EN PRODUCTION)
    return true;
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (currentUserId == null) {
      debugPrint('Utilisateur non connecté');
      return;
    }

    try {
      // Déterminer la durée en fonction du produit
      DateTime expiryDate;
      if (purchaseDetails.productID == premiumYearlyProductId) {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      } else if (purchaseDetails.productID == premiumMonthlyProductId) {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      } else {
        debugPrint('Produit inconnu: ${purchaseDetails.productID}');
        return;
      }

      // Mettre à jour Firestore avec le statut Premium
      await _firestore.collection('users').doc(currentUserId).update({
        'isPremium': true,
        'premiumExpiryDate': Timestamp.fromDate(expiryDate),
        'premiumUpgradeDate': Timestamp.now(),
        'lastPurchaseId': purchaseDetails.purchaseID,
        'lastProductId': purchaseDetails.productID,
      });

      debugPrint('Produit livré avec succès: ${purchaseDetails.productID}');
    } catch (e) {
      debugPrint('Erreur lors de la livraison du produit: $e');
    }
  }

  // ===================================================================
  // =================== GETTERS UTILITAIRES ==========================
  // ===================================================================

  bool get isAvailable => _isAvailable;

  List<ProductDetails> get products => _products;

  bool get isPurchasePending => _purchasePending;

  String? get queryProductError => _queryProductError;

  ProductDetails? getProductDetails(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Formatage du prix pour l'affichage
  String getFormattedPrice(String productId) {
    final product = getProductDetails(productId);
    return product?.price ?? 'N/A';
  }

  // ===================================================================
  // =================== VÉRIFICATION DU STATUT PREMIUM ===============
  // ===================================================================

  Future<bool> checkPremiumStatus() async {
    if (currentUserId == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final isPremium = data['isPremium'] ?? false;
        final premiumExpiryDate = data['premiumExpiryDate'] as Timestamp?;

        if (isPremium && premiumExpiryDate != null) {
          final expiryDate = premiumExpiryDate.toDate();

          // Vérifier si l'abonnement est toujours valide
          if (expiryDate.isBefore(DateTime.now())) {
            // L'abonnement a expiré, mettre à jour le statut
            await _firestore.collection('users').doc(currentUserId).update({
              'isPremium': false,
            });
            return false;
          }

          return true;
        }

        return isPremium;
      }

      return false;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut Premium: $e');
      return false;
    }
  }
}