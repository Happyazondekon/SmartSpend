import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'models/user_data.dart';
import 'models/transaction.dart';
import 'models/financial_goal.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Nom des collections
  static const String usersCollection = 'users';
  static const String transactionsSubCollection = 'transactions';

  // Obtenir l'ID utilisateur actuel
  String? get currentUserId => _auth.currentUser?.uid;

  // ===================================================================
  // =================== GESTION DES DONNÉES UTILISATEUR =============
  // ===================================================================

  // Référence du document utilisateur
  DocumentReference? get _userDocument {
    if (currentUserId == null) return null;
    return _firestore.collection(usersCollection).doc(currentUserId);
  }

  // Initialiser les données utilisateur (première connexion)
  Future<void> initializeUserData() async {
    if (currentUserId == null) return;

    try {
      final userDoc = await _userDocument!.get();

      if (!userDoc.exists) {
        // Créer les données par défaut pour le nouvel utilisateur
        final userData = UserData.empty(currentUserId!);
        await _userDocument!.set(userData.toFirestore());

        debugPrint('Données utilisateur initialisées pour: $currentUserId');
      } else {
        debugPrint('Données utilisateur existantes trouvées pour: $currentUserId');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation des données utilisateur: $e');
      throw 'Erreur lors de l\'initialisation des données';
    }
  }

  // Charger les données utilisateur
  Future<UserData?> loadUserData() async {
    if (currentUserId == null) return null;

    try {
      final userDoc = await _userDocument!.get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        return UserData.fromFirestore(data, currentUserId!);
      } else {
        // Si pas de données, initialiser
        await initializeUserData();
        return UserData.empty(currentUserId!);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur: $e');
      throw 'Erreur lors du chargement des données';
    }
  }

  // Sauvegarder les données utilisateur
  Future<void> saveUserData(UserData userData) async {
    if (currentUserId == null) return;

    try {
      await _userDocument!.set(userData.toFirestore(), SetOptions(merge: true));
      debugPrint('Données utilisateur sauvegardées avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des données utilisateur: $e');
      throw 'Erreur lors de la sauvegarde';
    }
  }

  // ===================================================================
  // =================== GESTION DES TRANSACTIONS ====================
  // ===================================================================

  // Stream pour écouter les changements de données utilisateur
  Stream<UserData?> userDataStream() {
    if (currentUserId == null) return Stream.value(null);

    return _userDocument!.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return UserData.fromFirestore(data, currentUserId!);
      }
      return null;
    });
  }

  // Ajouter une transaction
  Future<void> addTransaction(Transaction transaction) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Ajouter la nouvelle transaction
      final updatedTransactions = List<Transaction>.from(userData.transactions);
      updatedTransactions.add(transaction);

      // Sauvegarder
      final updatedUserData = userData.copyWith(transactions: updatedTransactions);
      await saveUserData(updatedUserData);

      debugPrint('Transaction ajoutée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la transaction: $e');
      throw 'Erreur lors de l\'ajout de la transaction';
    }
  }

  // Modifier une transaction
  Future<void> updateTransaction(String transactionId, double newAmount, String newDescription) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Modifier la transaction
      final updatedTransactions = userData.transactions.map((t) {
        if (t.id == transactionId) {
          return Transaction(
            id: t.id,
            category: t.category,
            amount: newAmount,
            description: newDescription,
            date: t.date,
          );
        }
        return t;
      }).toList();

      // Sauvegarder
      final updatedUserData = userData.copyWith(transactions: updatedTransactions);
      await saveUserData(updatedUserData);

      debugPrint('Transaction modifiée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la modification de la transaction: $e');
      throw 'Erreur lors de la modification de la transaction';
    }
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Supprimer la transaction
      final updatedTransactions = userData.transactions
          .where((t) => t.id != transactionId)
          .toList();

      // Sauvegarder
      final updatedUserData = userData.copyWith(transactions: updatedTransactions);
      await saveUserData(updatedUserData);

      debugPrint('Transaction supprimée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la transaction: $e');
      throw 'Erreur lors de la suppression de la transaction';
    }
  }

  // ===================================================================
  // =================== GESTION DU BUDGET ===========================
  // ===================================================================

  // Mettre à jour le salaire
  Future<void> updateSalary(double salary) async {
    if (currentUserId == null) return;

    try {
      final userData = await loadUserData();
      if (userData == null) return;

      final updatedUserData = userData.copyWith(salary: salary);
      await saveUserData(updatedUserData);

      debugPrint('Salaire mis à jour avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du salaire: $e');
      throw 'Erreur lors de la mise à jour du salaire';
    }
  }

  // Mettre à jour la devise
  Future<void> updateCurrency(String currency) async {
    if (currentUserId == null) return;

    try {
      final userData = await loadUserData();
      if (userData == null) return;

      final updatedUserData = userData.copyWith(currency: currency);
      await saveUserData(updatedUserData);

      debugPrint('Devise mise à jour avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la devise: $e');
      throw 'Erreur lors de la mise à jour de la devise';
    }
  }

  // Mettre à jour le budget complet
  Future<void> updateBudget(Map<String, Map<String, dynamic>> budget) async {
    if (currentUserId == null) return;

    try {
      final userData = await loadUserData();
      if (userData == null) return;

      final updatedUserData = userData.copyWith(budget: budget);
      await saveUserData(updatedUserData);

      debugPrint('Budget mis à jour avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du budget: $e');
      throw 'Erreur lors de la mise à jour du budget';
    }
  }

  // Mettre à jour les notifications
  Future<void> updateNotificationSettings(bool enabled) async {
    if (currentUserId == null) return;

    try {
      final userData = await loadUserData();
      if (userData == null) return;

      final updatedUserData = userData.copyWith(notificationsEnabled: enabled);
      await saveUserData(updatedUserData);

      debugPrint('Paramètres de notification mis à jour avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des notifications: $e');
      throw 'Erreur lors de la mise à jour des notifications';
    }
  }

  // ===================================================================
  // =================== UTILITAIRES ==================================
  // ===================================================================

  // Supprimer toutes les données utilisateur (suppression de compte)
  Future<void> deleteUserData() async {
    if (currentUserId == null) return;

    try {
      await _userDocument!.delete();
      debugPrint('Données utilisateur supprimées avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la suppression des données utilisateur: $e');
      throw 'Erreur lors de la suppression des données';
    }
  }

  // Vérifier la connectivité et la synchronisation
  Future<bool> isOnline() async {
    try {
      await _firestore.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Forcer la synchronisation
  Future<void> forceSynchronization() async {
    try {
      await _firestore.clearPersistence();
      await _firestore.enableNetwork();
      debugPrint('Synchronisation forcée terminée');
    } catch (e) {
      debugPrint('Erreur lors de la synchronisation forcée: $e');
    }
  }

  // ===================================================================
// =================== GESTION DES OBJECTIFS FINANCIERS =============
// ===================================================================

// Ajouter un objectif financier
  Future<void> addFinancialGoal(FinancialGoal goal) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Ajouter le nouvel objectif
      final updatedGoals = List<FinancialGoal>.from(userData.financialGoals);
      updatedGoals.add(goal);

      // Sauvegarder
      final updatedUserData = userData.copyWith(financialGoals: updatedGoals);
      await saveUserData(updatedUserData);

      debugPrint('Objectif financier ajouté avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de l\'objectif financier: $e');
      throw 'Erreur lors de l\'ajout de l\'objectif financier';
    }
  }

// Modifier un objectif financier
  Future<void> updateFinancialGoal(FinancialGoal updatedGoal) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Modifier l'objectif
      final updatedGoals = userData.financialGoals.map((g) {
        if (g.id == updatedGoal.id) {
          return updatedGoal;
        }
        return g;
      }).toList();

      // Sauvegarder
      final updatedUserData = userData.copyWith(financialGoals: updatedGoals);
      await saveUserData(updatedUserData);

      debugPrint('Objectif financier modifié avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la modification de l\'objectif financier: $e');
      throw 'Erreur lors de la modification de l\'objectif financier';
    }
  }

// Supprimer un objectif financier
  Future<void> deleteFinancialGoal(String goalId) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Supprimer l'objectif
      final updatedGoals = userData.financialGoals
          .where((g) => g.id != goalId)
          .toList();

      // Sauvegarder
      final updatedUserData = userData.copyWith(financialGoals: updatedGoals);
      await saveUserData(updatedUserData);

      debugPrint('Objectif financier supprimé avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la suppression de l\'objectif financier: $e');
      throw 'Erreur lors de la suppression de l\'objectif financier';
    }
  }

// Mettre à jour le montant épargné pour un objectif
  Future<void> updateGoalProgress(String goalId, double additionalAmount) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Trouver et modifier l'objectif
      final updatedGoals = userData.financialGoals.map((g) {
        if (g.id == goalId) {
          final newCurrentAmount = g.currentAmount + additionalAmount;
          final isCompleted = newCurrentAmount >= g.targetAmount;
          return g.copyWith(
            currentAmount: newCurrentAmount,
            isCompleted: isCompleted,
          );
        }
        return g;
      }).toList();

      // Sauvegarder
      final updatedUserData = userData.copyWith(financialGoals: updatedGoals);
      await saveUserData(updatedUserData);

      debugPrint('Progression de l\'objectif mise à jour avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la progression: $e');
      throw 'Erreur lors de la mise à jour de la progression';
    }
  }

// Marquer un objectif comme terminé
  Future<void> completeFinancialGoal(String goalId) async {
    if (currentUserId == null) return;

    try {
      // Charger les données actuelles
      final userData = await loadUserData();
      if (userData == null) return;

      // Marquer l'objectif comme terminé
      final updatedGoals = userData.financialGoals.map((g) {
        if (g.id == goalId) {
          return g.copyWith(isCompleted: true);
        }
        return g;
      }).toList();

      // Sauvegarder
      final updatedUserData = userData.copyWith(financialGoals: updatedGoals);
      await saveUserData(updatedUserData);

      debugPrint('Objectif financier marqué comme terminé');
    } catch (e) {
      debugPrint('Erreur lors de la finalisation de l\'objectif: $e');
      throw 'Erreur lors de la finalisation de l\'objectif';
    }
  }
}