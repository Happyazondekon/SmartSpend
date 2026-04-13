// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SmartSpend';

  @override
  String get filterAll => 'Tout';

  @override
  String get loginWelcomeTitle => 'Bon retour ! 👋';

  @override
  String get loginSubtitle => 'Connectez-vous pour gérer vos finances';

  @override
  String get loginErrorUserNotFound => 'Aucun compte trouvé avec cet email';

  @override
  String get loginErrorWrongPassword => 'Mot de passe incorrect';

  @override
  String get loginErrorInvalidEmail => 'Format d\'email invalide';

  @override
  String get loginErrorTooManyAttempts => 'Trop de tentatives. Réessayez plus tard';

  @override
  String get loginErrorGeneral => 'Une erreur est survenue. Réessayez';

  @override
  String get loginValidationEmailRequired => 'Veuillez entrer votre email';

  @override
  String get loginValidationPasswordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginOrDivider => 'ou';

  @override
  String get loginWithGoogle => 'Continuer avec Google';

  @override
  String get loginNoAccount => 'Pas encore de compte ?';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle => 'Rejoignez SmartSpend et prenez le contrôle de vos finances';

  @override
  String get registerFieldFullName => 'Nom complet';

  @override
  String get registerFieldFullNameHint => 'Jean Dupont';

  @override
  String get registerFieldEmail => 'Email';

  @override
  String get registerFieldEmailHint => 'votre@email.com';

  @override
  String get registerFieldPassword => 'Mot de passe';

  @override
  String get registerFieldPasswordHint => '••••••••';

  @override
  String get registerFieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerValidationPasswordMinLength => 'Minimum 6 caractères';

  @override
  String get registerValidationNameRequired => 'Veuillez entrer votre nom';

  @override
  String get registerValidationNameTooShort => 'Nom trop court';

  @override
  String get registerValidationPasswordRequired => 'Veuillez entrer un mot de passe';

  @override
  String get registerValidationPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get registerValidationTermsRequired => 'Veuillez accepter les conditions d\'utilisation';

  @override
  String get registerValidationTerms => 'Veuillez accepter les conditions d\'utilisation';

  @override
  String get termsPrefix => 'J\'accepte les ';

  @override
  String get termsOfUse => 'conditions d\'utilisation';

  @override
  String get termsMiddle => ' et la ';

  @override
  String get privacyPolicy => 'politique de confidentialité';

  @override
  String get registerValidationEmailRequired => 'Veuillez entrer votre email';

  @override
  String get registerValidationInvalidEmail => 'Format d\'email invalide';

  @override
  String get registerValidationPasswordTooShort => 'Minimum 6 caractères';

  @override
  String get registerErrorGeneral => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get registerErrorGoogle => 'Erreur de connexion avec Google';

  @override
  String get registerButtonSubmit => 'Créer mon compte';

  @override
  String get registerExistingAccount => 'Déjà un compte ?';

  @override
  String get registerErrorEmailInUse => 'Cette adresse email est déjà utilisée';

  @override
  String get registerErrorGoogleSignIn => 'Erreur de connexion avec Google';

  @override
  String get registerPrivacyPolicy => 'politique de confidentialité';

  @override
  String get registerTermsOfUse => 'conditions d\'utilisation';

  @override
  String get registerAgreeTerms => 'J\'accepte les';

  @override
  String get registerAndThe => 'et la';

  @override
  String get emailVerificationTitle => 'Vérifiez votre email';

  @override
  String get emailVerificationSuccess => 'Email vérifié ! 🎉';

  @override
  String get emailVerificationSuccessMessage => 'Votre compte est maintenant activé. Redirection en cours...';

  @override
  String get emailVerificationSentMessage => 'Nous avons envoyé un email de vérification à :';

  @override
  String get emailVerificationErrorSending => 'Erreur lors de l\'envoi de l\'email';

  @override
  String get emailVerificationSendError => 'Erreur lors de l\'envoi de l\'email';

  @override
  String get emailVerificationInstructions => 'Cliquez sur le lien de vérification';

  @override
  String get emailVerificationResend => 'Renvoyer l\'email';

  @override
  String emailVerificationResendIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get emailVerificationCheckSpam => 'Vérifiez également votre dossier spam';

  @override
  String get emailVerificationChangeEmail => 'Changer d\'email';

  @override
  String get emailVerificationStep1 => '1. Ouvrez votre boîte mail';

  @override
  String get emailVerificationStep3 => '3. Revenez sur l\'application';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordEmailSent => 'Email envoyé !';

  @override
  String get forgotPasswordDescription => 'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get forgotPasswordSuccessDescription => 'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.';

  @override
  String get forgotPasswordCheckInbox => 'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.';

  @override
  String get forgotPasswordError => 'Une erreur est survenue. Vérifiez votre adresse email.';

  @override
  String get forgotPasswordSendButton => 'Envoyer le lien';

  @override
  String get forgotPasswordBackToLogin => 'Retour à la connexion';

  @override
  String get forgotPasswordResendEmail => 'Renvoyer l\'email';

  @override
  String get forgotPasswordResend => 'Renvoyer';

  @override
  String get forgotPasswordEmailRequired => 'Veuillez entrer votre email';

  @override
  String get forgotPasswordInvalidEmail => 'Format d\'email invalide';

  @override
  String get forgotPasswordRemember => 'Vous vous souvenez ?';

  @override
  String get forgotPasswordSignIn => 'Se connecter';

  @override
  String get pinSetupTitle => 'Créez votre code PIN';

  @override
  String get pinSetupConfirmTitle => 'Confirmez votre code';

  @override
  String get pinSetupDescription => 'Ce code protégera l\'accès à vos données';

  @override
  String get pinSetupConfirmDescription => 'Entrez à nouveau votre code à 4 chiffres';

  @override
  String get pinSetupErrorMismatch => 'Les codes ne correspondent pas';

  @override
  String get pinSetupRestart => 'Recommencer';

  @override
  String get pinLockBiometricPrompt => 'Déverrouillez SmartSpend avec votre empreinte';

  @override
  String pinLockErrorIncorrect(int attemptsRemaining) {
    return 'Code incorrect ($attemptsRemaining essais restants)';
  }

  @override
  String pinLockErrorLocked(int seconds) {
    return 'Réessayez dans $seconds secondes';
  }

  @override
  String get pinLockBiometricButton => 'Biométrie';

  @override
  String get pinLockLogoutButton => 'Déconnexion';

  @override
  String get pinLockTooManyAttempts => 'Trop de tentatives';

  @override
  String get pinLockEnterCode => 'Entrez votre code PIN';

  @override
  String get navBudget => 'Budget';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navReports => 'Rapports';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get quickActionsTitle => 'Actions rapides';

  @override
  String get quickActionTransaction => 'Transaction';

  @override
  String get quickActionGoal => 'Objectif';

  @override
  String get quickActionAssistant => 'Assistant';

  @override
  String get budgetHeaderTitle => 'Vue d\'ensemble';

  @override
  String get budgetSetButtonLabel => 'Définir';

  @override
  String get budgetUsedLabel => 'utilisé';

  @override
  String get budgetSpentLabel => 'Dépensé';

  @override
  String get budgetCategoriesSection => 'Catégories';

  @override
  String get budgetRecentTransactions => 'Transactions récentes';

  @override
  String get greetingMorning => 'Bonjour ☀️';

  @override
  String get greetingAfternoon => 'Bon après-midi ☀️';

  @override
  String get greetingEvening => 'Bonsoir 🌙';

  @override
  String get budgetManageTitle => 'Gérer le budget';

  @override
  String get budgetSetTitle => 'Définir le budget';

  @override
  String get budgetNotSet => 'Aucun budget défini';

  @override
  String get budgetSupplementaryIncome => 'Pour les revenus supplémentaires';

  @override
  String get budgetSupplementaryIncomeDescription => 'Ajoutez un revenu supplémentaire à votre budget actuel';

  @override
  String get budgetSupplementaryAmountLabel => 'Montant à ajouter';

  @override
  String get budgetNewCategoryTitle => 'Nouvelle catégorie';

  @override
  String get budgetCategoryNameLabel => 'Nom de la catégorie';

  @override
  String get budgetAllocatedAmountLabel => 'Montant alloué';

  @override
  String budgetEquivalentLabel(String amount) {
    return 'Équivalent: $amount';
  }

  @override
  String get budgetIconLabel => 'Icône';

  @override
  String get budgetAddCategoryButton => 'Ajouter la catégorie';

  @override
  String get budgetEditCategoryTitle => 'Modifier la catégorie';

  @override
  String get budgetRemainingLabel => 'Restant';

  @override
  String get budgetAvailableLabel => 'Disponible';

  @override
  String get budgetOf => 'sur';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsSearchHint => 'Rechercher une transaction...';

  @override
  String get transactionsSummaryThisMonth => 'Ce mois';

  @override
  String get transactionsSummaryCount => 'Transactions';

  @override
  String get transactionsSummaryAveragePerDay => 'Moyenne/jour';

  @override
  String get transactionsEmptyState => 'Vos transactions apparaîtront ici';

  @override
  String get transactionsEmptyDescription => 'Ajoutez votre première transaction pour commencer à suivre vos dépenses';

  @override
  String get transactionNewTitle => 'Nouvelle transaction';

  @override
  String get transactionFieldCategory => 'Catégorie';

  @override
  String get transactionFieldDescription => 'Description';

  @override
  String get transactionFieldDescriptionOptional => 'Description (optionnel)';

  @override
  String get transactionFieldDescriptionHint => 'Ex: Courses du weekend';

  @override
  String get transactionEditTitle => 'Modifier la transaction';

  @override
  String get transactionFieldDate => 'Date';

  @override
  String get transactionModified => 'Transaction modifiée';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get transactionFieldAmount => 'Montant';

  @override
  String get addButton => 'Ajouter';

  @override
  String get transactionWarningIrreversible => 'Cette action est irréversible.';

  @override
  String get transactionModifiedSuccess => 'Transaction modifiée';

  @override
  String get transactionDeletedSuccess => 'Transaction supprimée';

  @override
  String get transactionAddedSuccess => 'Transaction ajoutée avec succès';

  @override
  String get transactionDeleteConfirm => 'Supprimer cette transaction ?';

  @override
  String get categoryHealth => 'Santé';

  @override
  String get categoryEducation => 'Éducation';

  @override
  String get categorySavings => 'Épargne';

  @override
  String get categoryRent => 'Loyer';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryUtilities => 'Électricité/Eau';

  @override
  String get categoryInternet => 'Internet';

  @override
  String get categoryFood => 'Nourriture';

  @override
  String get categoryEntertainment => 'Loisirs';

  @override
  String get categoryOther => 'Autre';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Fév';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Avr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aoû';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Déc';

  @override
  String get reportsTitle => 'Rapports';

  @override
  String get reportsSubtitle => 'Analysez vos dépenses';

  @override
  String get reportsPeriodThisMonth => 'Ce mois';

  @override
  String get reportsPeriod3Months => '3 mois';

  @override
  String get reportsPeriod6Months => '6 mois';

  @override
  String get reportsPeriod1Year => '1 an';

  @override
  String get reportsSpendingDistribution => 'Répartition des dépenses';

  @override
  String get reportsTotalSpent => 'Total dépensé';

  @override
  String get reportsNoData => 'Aucune donnée';

  @override
  String get reportsNoDataDescription => 'Ajoutez des transactions pour voir vos rapports';

  @override
  String get reportsSpent => 'Dépensé';

  @override
  String get reportsSavings => 'Épargne';

  @override
  String get reportsBudgetVsSpending => 'Budget vs Dépenses';

  @override
  String get reportsCategoryDetails => 'Détails par catégorie';

  @override
  String get reportsExportPDF => 'Exporter en PDF';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle => 'Personnalisez votre expérience';

  @override
  String get settingsSecurity => 'Sécurité';

  @override
  String get settingsChangePINTitle => 'Changer le code PIN';

  @override
  String get settingsChangePINSubtitle => 'Modifier votre code de sécurité';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsExportData => 'Exporter les données';

  @override
  String get settingsExportDataSubtitle => 'Télécharger vos données en PDF';

  @override
  String get settingsMonthlyHistory => 'Historique mensuel';

  @override
  String get settingsMonthlyHistorySubtitle => 'Voir l\'historique de vos mois clôturés';

  @override
  String get settingsResetData => 'Réinitialiser les données';

  @override
  String get settingsResetDataSubtitle => 'Supprimer toutes vos données';

  @override
  String get settingsPinProtection => 'Protéger l\'accès à l\'application';

  @override
  String get settingsPinEnabledSuccess => 'Code PIN activé avec succès';

  @override
  String get settingsDisablePinConfirm => 'Désactiver le code PIN ?';

  @override
  String get settingsDisablePinWarning => 'Votre application ne sera plus protégée par un code de sécurité.';

  @override
  String get settingsPinDisabledSuccess => 'Code PIN désactivé';

  @override
  String get settingsDisableButton => 'Désactiver';

  @override
  String get settingsPinChangedSuccess => 'Code PIN modifié avec succès';

  @override
  String get settingsPremium => 'Passer à Premium';

  @override
  String get settingsPremiumDescription => 'Débloquez toutes les fonctionnalités : exports PDF illimités, assistant IA illimité, et plus encore.';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsNoClosedMonths => 'Aucun mois clôturé';

  @override
  String get settingsResetConfirm => 'Réinitialiser les données ?';

  @override
  String get settingsResetWarning => 'Toutes vos données seront supprimées. Cette action est irréversible.';

  @override
  String get settingsResetSuccess => 'Données réinitialisées';

  @override
  String get settingsResetButton => 'Réinitialiser';

  @override
  String get settingsLogoutConfirm => 'Se déconnecter ?';

  @override
  String get settingsLogoutWarning => 'Vos données sont sauvegardées dans le cloud.';

  @override
  String get settingsLogoutButton => 'Déconnecter';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsDarkMode => 'Sombre';

  @override
  String get settingsLightMode => 'Clair';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get currency => 'Devise';

  @override
  String get language => 'Langue';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Gérer les rappels et alertes';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get user => 'Utilisateur';

  @override
  String get freeVersion => 'Gratuit';

  @override
  String get transactionRemindersTitle => 'Rappels de transactions';

  @override
  String get transactionRemindersSubtitle => 'Recevoir des rappels matin, midi et soir';

  @override
  String get pinCode => 'Code PIN';

  @override
  String get cancel => 'Annuler';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get transactionDeleted => 'Transaction supprimée';

  @override
  String get seeOffers => 'Voir les offres';

  @override
  String get incomes => 'Revenus';

  @override
  String get transactions => 'transactions';

  @override
  String get goalsScreenTitle => 'Objectifs Financiers';

  @override
  String get goalsEmptyTitle => 'Aucun objectif défini';

  @override
  String get goalsEmptyDescription => 'Créez votre premier objectif financier pour commencer à épargner avec un but précis !';

  @override
  String get goalsCreateButton => 'Créer un objectif';

  @override
  String get goalsAddMoney => 'Ajouter de l\'argent';

  @override
  String get goalsMarkComplete => 'Marquer comme terminé';

  @override
  String get goalsEditButton => 'Modifier';

  @override
  String get goalsDeleteButton => 'Supprimer';

  @override
  String get goalsProgressLabel => 'Progression';

  @override
  String get goalsDeadlineLabel => 'Échéance';

  @override
  String get goalsTargetLabel => 'Objectif';

  @override
  String get goalsCurrentLabel => 'Actuel';

  @override
  String get goalsNewTitle => 'Nouvel objectif';

  @override
  String get goalsEditTitle => 'Modifier l\'objectif';

  @override
  String get goalsNameLabel => 'Nom de l\'objectif';

  @override
  String get goalsAmountLabel => 'Montant cible';

  @override
  String get goalsDescriptionLabel => 'Description (optionnel)';

  @override
  String get goalsDeadlineDateLabel => 'Date limite';

  @override
  String get goalsIconLabel => 'Icône';

  @override
  String get goalsColorLabel => 'Couleur';

  @override
  String get goalsCreateButtonLabel => 'Créer';

  @override
  String get goalsSaveButtonLabel => 'Enregistrer';

  @override
  String get goalsDeleteConfirm => 'Supprimer cet objectif ?';

  @override
  String get goalsAchieved => 'Objectif atteint ! 🎉';

  @override
  String get notificationPermissionDenied => 'Permission de notification refusée. Activez-la dans les paramètres.';

  @override
  String get notificationDisabledAndroid => 'Les notifications sont désactivées dans les paramètres Android';

  @override
  String get notificationBatteryOptimization => 'Pour des rappels fiables, désactivez l\'optimisation de batterie pour SmartSpend';

  @override
  String get notificationReminderDisabled => 'Rappels désactivés';

  @override
  String notificationDisableError(String error) {
    return 'Erreur lors de la désactivation: $error';
  }

  @override
  String get notificationSystemDisabled => 'Les notifications ne sont pas activées au niveau système';

  @override
  String get notificationTestStarted => 'Tests lancés : • Notification immédiate • Notification dans 3 secondes';

  @override
  String get newMonthTitle => '🎉 Nouveau mois !';

  @override
  String newMonthWelcome(String month, String year) {
    return 'Bienvenue en $month $year !';
  }

  @override
  String newMonthCloseQuestion(String month) {
    return 'Voulez-vous clôturer $month et commencer le nouveau mois ?';
  }

  @override
  String get newMonthInfo => '• Vos catégories seront conservées\n• Les dépenses seront archivées\n• Vous pourrez entrer vos nouveaux revenus';

  @override
  String newMonthRemainingBudget(String amount) {
    return 'Budget restant: $amount';
  }

  @override
  String get newMonthCarryOver => 'Reporter ce montant au mois suivant';

  @override
  String get newMonthLater => 'Plus tard';

  @override
  String get newMonthCloseButton => 'Clôturer le mois';

  @override
  String newMonthClosedSuccess(String amount) {
    return 'Mois clôturé ! $amount reporté. Ajoutez vos revenus.';
  }

  @override
  String get newMonthClosedNoCarryOver => 'Mois clôturé ! Entrez vos revenus pour ce mois.';

  @override
  String get newMonthCloseError => 'Erreur lors de la clôture du mois';

  @override
  String chatbotGreeting(String userName) {
    return '👋 Bonjour et bienvenue, $userName !';
  }

  @override
  String get chatbotThinking => 'SmartBot réfléchit...';

  @override
  String get chatbotInputHint => 'Posez votre question financière...';

  @override
  String get chatbotConnectionError => '⚠️ Connexion temporairement indisponible. Essayez une question des suggestions ci-dessous.';

  @override
  String get chatbotLastFreeUse => 'C\'était votre dernière utilisation gratuite de l\'assistant.';

  @override
  String chatbotFreeUsesRemaining(int count) {
    return '$count utilisations gratuites restantes';
  }

  @override
  String get chatbotSuggestions => '💡 Suggestions';

  @override
  String get faqAddTransaction => '📱 Comment ajouter une transaction?';

  @override
  String get faqCreateBudget => '🎯 Comment créer un budget?';

  @override
  String get faqViewStats => '📊 Comment consulter mes statistiques?';

  @override
  String get faqSaveEffectively => '💰 Comment économiser efficacement?';

  @override
  String get faqReduceSpending => '✂️ Comment réduire mes dépenses?';

  @override
  String get faqBeginnerInvesting => '📊 Conseils investissement débutant?';

  @override
  String get faqManageDebt => '💳 Comment gérer mes dettes?';

  @override
  String get faqCreateGoal => '🎯 Comment créer un objectif?';

  @override
  String get faqAddTransactionAnswer => '📝 Ajouter une transaction:\n\n1. Ouvrez l\'onglet \'Transactions\'\n2. Appuyez sur le bouton \'+\' \n3. Saisissez le montant, choisissez la catégorie et ajoutez une description\n4. Validez pour enregistrer\n\n💡 Astuce: Ajoutez vos transactions immédiatement pour un suivi précis!';

  @override
  String get faqCreateBudgetAnswer => '🎯 Créer un budget efficace:\n\n1. Accédez à l\'onglet \'Budget\'\n2. Cliquez sur \'+\' pour ajouter un nouveau budget\n3. Définissez le montant maximal par catégorie\n4. Activez les alertes pour rester dans les limites\n\n💰 Conseil: Suivez la règle 50/30/20 (besoins/envies/épargne)';

  @override
  String get faqViewStatsAnswer => '📊 Analyser vos finances:\n\nL\'onglet \'Statistiques\' vous offre:\n• Graphiques de dépenses par catégorie\n• Évolution mensuelle de vos finances\n• Comparaisons périodiques\n• Tendances de consommation\n\n🔍 Utilisez ces données pour identifier vos habitudes et optimiser votre budget!';

  @override
  String get faqSaveEffectivelyAnswer => '💰 Stratégies d\'épargne éprouvées:\n\n🎯 Méthode des 52 semaines: Épargnez 1€ la 1ère semaine, 2€ la 2ème...\n🏦 Épargne automatique: 10-20% de chaque revenu\n📱 Utilisez SmartSpend pour tracker vos progrès\n⚡ Réduisez les abonnements non-essentiels\n\nObjectif: Constituez d\'abord un fonds d\'urgence (3-6 mois de charges)!';

  @override
  String get faqReduceSpendingAnswer => '✂️ Optimisation des dépenses:\n\n🔍 Analysez vos statistiques SmartSpend:\n• Identifiez les catégories les plus coûteuses\n• Repérez les dépenses récurrentes\n• Trouvez les \'fuites\' budgétaires\n\n💡 Actions concrètes:\n• Comparez les prix avant d\'acheter\n• Cuisinez plus à la maison\n• Renégociez vos contrats (assurance, téléphone)\n• Privilégiez l\'occasion quand possible';

  @override
  String get faqBeginnerInvestingAnswer => '🚀 Débuter en investissement:\n\n⚠️ Prérequis essentiels:\n✓ Fonds d\'urgence constitué (3-6 mois)\n✓ Dettes remboursées (sauf prêt immobilier)\n✓ Budget maîtrisé avec SmartSpend\n\n📈 Premiers pas:\n• Commencez petit (50-100€/mois)\n• Diversifiez vos placements\n• Privilégiez le long terme\n• Formez-vous avant d\'investir\n\n🏦 Options: Livret A, PEL, assurance-vie, PEA';

  @override
  String get faqManageDebtAnswer => '💳 Stratégie de remboursement:\n\n🎯 Méthode \'Boule de neige\':\n1. Listez toutes vos dettes\n2. Payez les minimums partout\n3. Attaquez la plus petite dette en premier\n4. Une fois remboursée, passez à la suivante\n\n📊 Utilisez SmartSpend pour tracker vos remboursements et célébrer vos progrès!\n\n⚡ Négociez avec vos créanciers si nécessaire.';

  @override
  String get faqCreateGoalAnswer => '🎯 Créer un objectif financier:\n\n1. Accédez à l\'onglet \'Objectifs\'\n2. Appuyez sur \'+\' pour ajouter un nouvel objectif\n3. Indiquez le nom, la description (facultative), le montant cible et la date limite\n4. Choisissez une icône et une couleur pour personnaliser votre objectif\n5. Validez en appuyant sur \'Créer\'';

  @override
  String get budgetExceededWarning => 'Budget dépassé. Essayez de réduire vos dépenses.';

  @override
  String get syncCompleted => 'Synchronisation terminée';

  @override
  String get dataInitError => 'Erreur lors de l\'initialisation des données';

  @override
  String get allDataDeleted => 'Toutes les données ont été supprimées';

  @override
  String dataDeleteError(String error) {
    return 'Erreur lors de la suppression des données';
  }

  @override
  String get categoryAlreadyExists => 'Cette catégorie existe déjà';

  @override
  String budgetPercentageError(String percent) {
    return 'Le total des pourcentages ne peut pas dépasser 100%. Disponible: $percent%';
  }

  @override
  String get budgetValidationError => 'Veuillez entrer un nom valide et un pourcentage supérieur à 0';

  @override
  String get cannotDeleteCategoryWithTransactions => 'Impossible de supprimer une catégorie avec des transactions';

  @override
  String get noTransactionsToExport => 'Aucune transaction à exporter';

  @override
  String get csvHeaders => 'Date,Catégorie,Description,Montant';

  @override
  String pdfTitle(String name) {
    return 'Relevé Financier de : $name';
  }

  @override
  String pdfGeneratedDate(String date) {
    return 'Généré le $date';
  }

  @override
  String get pdfSituation => 'SITUATION FINANCIÈRE';

  @override
  String get pdfTotalSpent => 'Total des dépenses:';

  @override
  String get pdfTransactionDetails => 'DÉTAIL DES TRANSACTIONS';

  @override
  String get pdfCategoryAnalysis => 'ANALYSE PAR CATÉGORIE';

  @override
  String get pdfFooter => 'SmartSpend - Gestion financière intelligente';

  @override
  String get pdfCategoryHeader => 'Catégorie';

  @override
  String get pdfAmountHeader => 'Montant';

  @override
  String get pdfBudgetHeader => 'Budget';

  @override
  String get pdfVarianceHeader => 'Écart';

  @override
  String get goalCreatedSuccess => 'Objectif financier créé avec succès !';

  @override
  String get goalCreationError => 'Erreur lors de la création de l\'objectif';

  @override
  String get goalModifiedSuccess => 'Objectif modifié avec succès !';

  @override
  String get goalDeletedSuccess => 'Objectif supprimé';

  @override
  String get goalAmountAddedSuccess => 'Montant ajouté avec succès !';

  @override
  String get savingSuggestionTitle => 'Suggestion d\'épargne';

  @override
  String goalDeadlineApproaching(String goalName) {
    return 'Votre objectif \"$goalName\" arrive bientôt à échéance !';
  }

  @override
  String goalDeadlineDate(String date) {
    return 'Échéance: $date';
  }

  @override
  String goalSavingSuggestion(String amount) {
    return 'Voulez-vous épargner $amount pour cet objectif ?';
  }

  @override
  String get goalSaveButton => 'Épargner';

  @override
  String get goalEncouragement => 'Continuez sur cette lancée pour atteindre tous vos objectifs financiers !';

  @override
  String get premiumUnlockFeatures => 'Débloquez toutes les fonctionnalités :';

  @override
  String get premiumUnlimitedPDF => 'Exports PDF illimités';

  @override
  String get premiumUnlimitedAI => 'Assistant IA illimité';

  @override
  String get premiumAdvancedAnalytics => 'Analyses avancées';

  @override
  String get premiumNoAds => 'Pas de publicités';

  @override
  String get premiumPurchaseError => 'Erreur lors de l\'achat. Réessayez.';

  @override
  String get premiumProductNotAvailable => 'Produit non disponible. Réessayez plus tard.';

  @override
  String get premiumPDFLimitReached => 'Vous avez utilisé vos 3 exports PDF gratuits.';

  @override
  String get premiumUpgradePrompt => 'Passez à Premium pour des exports illimités et un accès complet à l\'assistant financier.';

  @override
  String get premiumChatbotLimitReached => 'Vous avez utilisé vos 3 sessions gratuites de l\'assistant IA.';

  @override
  String get premiumLimitReached => 'Limite atteinte';

  @override
  String get premiumViewButton => 'Voir Premium';

  @override
  String get closeButton => 'Fermer';

  @override
  String get premiumLastFreeExport => 'C\'était votre dernier export PDF gratuit.';

  @override
  String get premiumYearly => 'Annuel';

  @override
  String get premiumMonthly => 'Mensuel';

  @override
  String get premiumPerYear => '/ an';

  @override
  String get premiumPerMonth => '/ mois';

  @override
  String get premiumBestValue => 'Meilleur choix';

  @override
  String get premiumUpgradeTitle => 'Passez à Premium 💎';

  @override
  String get premiumRestorePurchases => 'Restaurer les achats';

  @override
  String get authVerifying => 'Vérification...';

  @override
  String get authInitializingData => 'Initialisation de vos données...';

  @override
  String get authVerifyingSecurity => 'Vérification de la sécurité...';

  @override
  String get authPreparingExperience => 'Préparation de votre expérience...';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get dataLoadingError => 'Impossible de charger vos données';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get updateRequired => 'Mise à jour requise';

  @override
  String get updateAvailableMessage => 'Une nouvelle version de SmartSpend est disponible avec des améliorations importantes et des corrections de bugs.';

  @override
  String get updateMandatoryMessage => 'Veuillez mettre à jour l\'application pour continuer à l\'utiliser.';

  @override
  String get updateNowButton => 'Mettre à jour maintenant';

  @override
  String get updateDataSafeMessage => '💡 Vos données sont sauvegardées et seront restaurées après la mise à jour.';

  @override
  String get onboardingBudgetTitle => 'Gérez votre budget';

  @override
  String get onboardingBudgetDescription => 'Définissez votre salaire ou revenus et répartissez-le intelligemment entre vos différentes catégories de dépenses.';

  @override
  String get onboardingTrackingTitle => 'Suivez vos dépenses';

  @override
  String get onboardingTrackingDescription => 'Enregistrez chaque transaction et visualisez en temps réel où va votre argent grâce à des graphiques clairs.';

  @override
  String get onboardingGoalsTitle => 'Atteignez vos objectifs';

  @override
  String get onboardingGoalsDescription => 'Créez des objectifs d\'épargne personnalisés et suivez votre progression jusqu\'à leur réalisation.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get syncSuccess => 'Synchronisation réussie';

  @override
  String get offlineMode => 'Mode hors ligne - Données non synchronisées';

  @override
  String get syncRetry => 'Réessayer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Attention';

  @override
  String get editButton => 'Modifier';

  @override
  String get monthProgress => 'Progression du mois';

  @override
  String daysRemaining(int count) {
    return '$count jours restants';
  }

  @override
  String get noTransaction => 'Aucune transaction';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get calculateBudgetButton => 'Calculer le budget';

  @override
  String get budgetAddToBudgetTitle => 'Ajouter au budget';

  @override
  String get budgetAddToBudgetButton => 'Ajouter au budget';

  @override
  String get budgetMonthlyIncomeTitle => 'Vos revenus mensuels';

  @override
  String get budgetEnterMonthlyIncome => 'Entrez votre salaire ou revenus mensuels nets';

  @override
  String get budgetCurrentLabel => 'Budget actuel';

  @override
  String budgetNewLabel(String amount) {
    return 'Nouveau budget: $amount';
  }

  @override
  String get budgetPercentageLabel => 'Pourcentage';

  @override
  String get budgetAmountLabel => 'Montant';

  @override
  String get budgetBudgetPercentageLabel => 'Pourcentage du budget';

  @override
  String budgetMaxLabel(String value) {
    return 'Max: $value';
  }

  @override
  String get budgetSaveChanges => 'Enregistrer les modifications';

  @override
  String get budgetOfBudget => 'du budget';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageCode => 'fr';

  @override
  String get chatbotSystemPrompt => 'Tu es SmartBot, l\'assistant IA premium de SmartSpend, expert en finances personnelles et conseiller financier bienveillant.';

  @override
  String get chatbotSubtitle => 'Conseiller financier';

  @override
  String get chatbotIntro => '🤖 Je suis SmartBot, votre conseiller financier intelligent et assistant personnel pour SmartSpend.';

  @override
  String get chatbotCapabilities => '💡 Je peux vous aider avec:\n• 📊 Conseils financiers personnalisés\n• 📱 Guide d\'utilisation SmartSpend\n• 💰 Stratégies d\'épargne et d\'investissement\n• 📈 Analyse de vos habitudes financières';

  @override
  String get chatbotPrompt => '🎯 Commençons ! Choisissez un sujet ci-dessous ou posez-moi directement votre question.';

  @override
  String get chatbotError => '⚠️ Une erreur est survenue. Veuillez réessayer ou choisir une suggestion.';

  @override
  String get chatbotTabPopular => '🎯 Populaire';

  @override
  String get chatbotTabFinance => '💰 Finances';

  @override
  String get chatbotTabApp => '📱 App';

  @override
  String get chatbotDefaultUser => 'Utilisateur';

  @override
  String get goalsCompleted => 'Terminé ✓';

  @override
  String get goalsOverdue => 'En retard';

  @override
  String goalsDaysRemaining(int count) {
    return '$count jours restants';
  }

  @override
  String get goalsToReachObjective => 'Pour atteindre votre objectif:';

  @override
  String goalsDailyAmount(String amount, String currency) {
    return '• $amount $currency par jour';
  }

  @override
  String goalsMonthlyAmount(String amount, String currency) {
    return '• $amount $currency par mois';
  }

  @override
  String get goalsNameHint => 'Ex: Voyage au Bénin';

  @override
  String get goalsDescriptionHint => 'Plus de détails sur votre objectif...';

  @override
  String get goalsValidationError => 'Veuillez remplir le nom et le montant';

  @override
  String goalsPercentReached(String percent) {
    return '$percent% atteint';
  }

  @override
  String get goalsAmountToAdd => 'Montant à ajouter';

  @override
  String goalsRemainingToReach(String amount, String currency) {
    return 'Il reste $amount $currency pour atteindre l\'objectif';
  }

  @override
  String get goalsInvalidAmount => 'Veuillez entrer un montant valide';

  @override
  String get goalsCreateSuccess => 'Objectif créé avec succès !';

  @override
  String get goalsCreateError => 'Erreur lors de la création de l\'objectif';

  @override
  String get goalsEditSuccess => 'Objectif modifié avec succès !';

  @override
  String get goalsEditError => 'Erreur lors de la modification';

  @override
  String get goalsDeleteSuccess => 'Objectif supprimé';

  @override
  String get goalsDeleteError => 'Erreur lors de la suppression';

  @override
  String goalsAmountExceedsRemaining(String amount) {
    return 'Le montant ajouté dépasse le montant restant à atteindre.\nIl reste $amount à compléter.';
  }

  @override
  String get goalsAmountAdded => 'Montant ajouté !';

  @override
  String get goalsAddError => 'Erreur lors de l\'ajout';

  @override
  String get goalsCongratulations => '🎉 Félicitations !';

  @override
  String goalsAchievedMessage(String name) {
    return 'Objectif \"$name\" atteint !';
  }

  @override
  String get goalsGreatButton => 'Super !';

  @override
  String get goalsFinalizeError => 'Erreur lors de la finalisation';

  @override
  String goalsDeleteConfirmMessage(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get goalsLoadError => 'Erreur lors du chargement des objectifs';

  @override
  String get goalsMarkedComplete => '🎉 Objectif marqué comme terminé !';

  @override
  String notifActivationError(String error) {
    return 'Erreur lors de l\'activation des rappels: $error';
  }

  @override
  String notifDeactivationError(String error) {
    return 'Erreur lors de la désactivation: $error';
  }

  @override
  String get notifRemindersDisabled => 'Rappels désactivés';

  @override
  String get invalidIncomeError => 'Veuillez entrer des revenus valides';

  @override
  String get invalidAmountError => 'Veuillez entrer un montant valide';

  @override
  String budgetAmountAdded(String amount) {
    return '$amount ajouté au budget';
  }

  @override
  String get budgetExceeded => 'Budget dépassé. Essayez de réduire vos dépenses.';

  @override
  String get budgetLimitReached => 'Attention, vous avez atteint la limite de votre budget.';

  @override
  String get budgetNearLimit => 'Attention, vous approchez de la limite de votre budget.';

  @override
  String get categoryInvalidNamePercent => 'Nom ou pourcentage invalide';

  @override
  String get categoryInvalidInput => 'Veuillez entrer un nom valide et un pourcentage supérieur à 0';

  @override
  String get categoryDeleteHasTransactions => 'Impossible de supprimer une catégorie avec des transactions';

  @override
  String get pdfMonthlyIncome => 'Revenus mensuels:';

  @override
  String get pdfRemainingBalance => 'Solde restant:';

  @override
  String get pdfTotalExpenses => 'Total des dépenses:';

  @override
  String pdfIncomeSpentPercent(String percent) {
    return '$percent% de vos revenus dépensés';
  }

  @override
  String get pdfAdviceTitle => 'CONSEILS SMARTSPEND';

  @override
  String pdfPersonalReport(String name) {
    return 'Rapport financier personnel de $name';
  }

  @override
  String pdfShareText(String name, String month) {
    return 'Rapport financier SmartSpend de $name - $month';
  }

  @override
  String pdfForUser(String name) {
    return 'Pour $name';
  }

  @override
  String pdfAdviceOverBudget(String name) {
    return '$name, attention ! Vous avez dépassé votre budget ce mois-ci. Essayez de réduire vos dépenses le mois prochain.';
  }

  @override
  String pdfAdviceGreatSaving(String name) {
    return 'Excellent travail, $name ! Vous avez économisé plus de 30% de vos revenus ce mois-ci.';
  }

  @override
  String pdfAdviceOnTrack(String name, String amount, String currency) {
    return '$name, vous êtes dans les clous avec $amount $currency restants ce mois-ci.';
  }

  @override
  String pdfAdviceCategoryHigh(String name, String category, String percent) {
    return '$name, la catégorie \"$category\" représente une part importante ($percent%) de vos dépenses. Pensez à diversifier.';
  }

  @override
  String pdfAdviceSavingsLow(String name) {
    return '$name, votre épargne est inférieure à 10% de vos revenus. Essayez d\'augmenter cette part progressivement.';
  }

  @override
  String pdfAdviceBalanced(String name) {
    return '$name, votre gestion financière est équilibrée ce mois-ci. Continuez ainsi !';
  }

  @override
  String csvHeaderFull(String currency) {
    return 'Date,Catégorie,Description,Montant ($currency)';
  }

  @override
  String get premiumPurchasing => 'Lancement de l\'achat...';

  @override
  String get premiumRestoring => 'Restauration des achats...';

  @override
  String get premiumRestoreButton => 'Restaurer';

  @override
  String get premiumBestBadge => 'MEILLEUR';

  @override
  String get laterButton => 'Plus tard';

  @override
  String get premiumWelcome => 'Bienvenue Premium !';

  @override
  String get premiumCongratulationsMessage => 'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium de SmartSpend.';

  @override
  String get premiumEnjoyFeatures => 'Profitez de toutes les fonctionnalités sans limite !';

  @override
  String get goalsSavingSuggestion => 'Suggestion d\'épargne';

  @override
  String goalsSavingSuggestionDesc(String name) {
    return 'Votre objectif \"$name\" arrive bientôt à échéance !';
  }

  @override
  String goalsProgressLabel2(String percent) {
    return 'Progression: $percent%';
  }

  @override
  String goalsRemainingLabel(String amount, String currency) {
    return 'Restant: $amount $currency';
  }

  @override
  String goalsDeadlineDate(String date) {
    return 'Échéance: $date';
  }

  @override
  String goalsSavingPrompt(String amount, String currency) {
    return 'Voulez-vous épargner $amount $currency pour cet objectif ?';
  }

  @override
  String get goalsSaveNowButton => 'Épargner';

  @override
  String get createCategoryFirst => 'Veuillez d\'abord créer une catégorie.';

  @override
  String get transactionAddTitle => 'Ajouter une transaction';

  @override
  String get defineIncomeFirst => 'Veuillez d\'abord définir vos revenus.';

  @override
  String get categoryBudgetExceeded => 'Le montant dépasse le budget restant disponible !';

  @override
  String get categoryNewTitle => 'Nouvelle Catégorie';

  @override
  String get categoryEditTitle => 'Modifier la Catégorie';

  @override
  String get categoryNameLabel => 'Nom de la catégorie';

  @override
  String get settingsDailyReminders => 'Rappels quotidiens';

  @override
  String get settingsDailyRemindersSubtitle => 'Rappel du soir pour vos transactions';

  @override
  String get settingsGoals => 'Objectifs financiers';

  @override
  String get settingsGoalsSubtitle => 'Définir et suivre vos objectifs d\'épargne';

  @override
  String get chatbotAccessError => 'Erreur lors de l\'accès à l\'assistant';

  @override
  String get pdfExportError => 'Erreur lors de l\'export PDF';

  @override
  String get premiumUpgradeError => 'Erreur lors de la mise à niveau';

  @override
  String get budgetRemainingBudget => 'Restant:';

  @override
  String get monthFullJan => 'Janvier';

  @override
  String get monthFullFeb => 'Février';

  @override
  String get monthFullMar => 'Mars';

  @override
  String get monthFullApr => 'Avril';

  @override
  String get monthFullMay => 'Mai';

  @override
  String get monthFullJun => 'Juin';

  @override
  String get monthFullJul => 'Juillet';

  @override
  String get monthFullAug => 'Août';

  @override
  String get monthFullSep => 'Septembre';

  @override
  String get monthFullOct => 'Octobre';

  @override
  String get monthFullNov => 'Novembre';

  @override
  String get monthFullDec => 'Décembre';

  @override
  String get notifPermissionDenied => 'Permission de notification refusée. Activez-la dans les paramètres.';

  @override
  String get notifSystemDisabled => 'Les notifications sont désactivées dans les paramètres Android';

  @override
  String get notifBatteryOptimization => 'Pour des rappels fiables, désactivez l\'optimisation de batterie pour SmartSpend';

  @override
  String get notifActivated => '✅ Rappels activés !\nMatin (8h30) et Soir (20h00)';

  @override
  String get notifTestLaunched => 'Tests lancés :\n• Notification immédiate\n• Notification dans 3 secondes';

  @override
  String get notifSystemNotEnabled => 'Les notifications ne sont pas activées au niveau système';

  @override
  String notifTestError(String error) {
    return 'Erreur test notification: $error';
  }

  @override
  String get newMonthDetails => '• Vos catégories seront conservées\n• Les dépenses seront archivées\n• Vous pourrez entrer vos nouveaux revenus';

  @override
  String get closeMonthButton => 'Clôturer le mois';

  @override
  String monthClosedWithCarryOver(String amount) {
    return '✅ Mois clôturé ! $amount reporté. Ajoutez vos revenus.';
  }

  @override
  String get monthClosedEnterIncome => '✅ Mois clôturé ! Entrez vos revenus pour ce mois.';

  @override
  String get monthCloseError => 'Erreur lors de la clôture du mois';

  @override
  String get transactionAddError => 'Erreur lors de l\'ajout de la transaction';

  @override
  String get transactionEditError => 'Erreur lors de la modification de la transaction';

  @override
  String get transactionDeleteError => 'Erreur lors de la suppression de la transaction';

  @override
  String get syncComplete => 'Synchronisation terminée';

  @override
  String get syncError => 'Erreur de synchronisation';

  @override
  String get dataDeletedSuccess => 'Toutes les données ont été supprimées';

  @override
  String categoryPercentExceeded(String percent) {
    return 'Le total des pourcentages ne peut pas dépasser 100%. Disponible: $percent%';
  }

  @override
  String get categoryServerEditError => 'Erreur lors de la modification sur le serveur';

  @override
  String get categoryServerDeleteError => 'Erreur lors de la suppression sur le serveur';

  @override
  String pdfFinancialStatement(String month) {
    return 'Relevé Financier de : $month';
  }

  @override
  String pdfGeneratedOn(String date) {
    return 'Généré le $date';
  }

  @override
  String get pdfFinancialOverview => 'SITUATION FINANCIÈRE';

  @override
  String get pdfSmartSpendFooter => 'SmartSpend - Gestion financière intelligente';

  @override
  String get pdfTableDate => 'Date';

  @override
  String get pdfTableCategory => 'Catégorie';

  @override
  String get pdfTableDescription => 'Description';

  @override
  String pdfTableAmount(String currency) {
    return 'Montant ($currency)';
  }

  @override
  String get pdfCategoryTableCategory => 'Catégorie';

  @override
  String get pdfCategoryTableAmount => 'Montant';

  @override
  String get pdfCategoryTableBudget => 'Budget';

  @override
  String get pdfCategoryTableDiff => 'Écart';

  @override
  String get premiumUnlimitedPdf => 'Exports PDF illimités';

  @override
  String get premiumAnnual => 'Annuel';

  @override
  String get premiumProductUnavailable => 'Produit non disponible. Réessayez plus tard.';

  @override
  String get pdfLimitReached => 'Limite atteinte';

  @override
  String get pdfLimitMessage => 'Vous avez utilisé vos 3 exports PDF gratuits.';

  @override
  String get pdfLimitUpgrade => 'Passez à Premium pour des exports illimités et un accès complet à l\'assistant financier.';

  @override
  String get pdfLastFreeExport => 'C\'était votre dernier export PDF gratuit.';

  @override
  String get viewPremiumButton => 'Voir Premium';

  @override
  String get startButton => 'Commencer';

  @override
  String get goalsKeepGoingMessage => 'Continuez sur cette lancée pour atteindre tous vos objectifs financiers !';

  @override
  String get goalsSaveButton => 'Épargner';

  @override
  String get premiumRequired => 'Premium requis';

  @override
  String premiumRemainingTrials(int count, String feature) {
    return 'Il vous reste $count essais gratuits pour $feature';
  }

  @override
  String premiumTrialsExhausted(String feature) {
    return 'Vous avez épuisé vos essais gratuits pour $feature';
  }

  @override
  String get premiumUpgradeTo => 'Passez à SmartSpend Premium pour :';

  @override
  String get premiumFeaturePdf => '✨ Exports PDF illimités';

  @override
  String get premiumFeatureAI => '🤖 Assistant financier illimité';

  @override
  String get premiumFeatureAnalytics => '📊 Analyses avancées';

  @override
  String get premiumFeatureCloud => '☁️ Synchronisation cloud prioritaire';

  @override
  String get premiumFeatureGoals => '🎯 Objectifs financiers avancés';

  @override
  String get premiumFeatureSupport => '📱 Support prioritaire';

  @override
  String get premiumTryFree => 'Essayer gratuitement';

  @override
  String get premiumUpgradeButton => 'Passer à Premium';

  @override
  String get premiumChooseSubscription => 'Choisir votre abonnement';

  @override
  String get premiumSaveBadge => 'ÉCONOMISEZ';

  @override
  String get premiumPurchasesRestoredSuccess => 'Achats restaurés avec succès !';

  @override
  String get premiumNoPurchaseToRestore => 'Aucun achat à restaurer';

  @override
  String get premiumProcessingPurchase => 'Traitement de votre achat...';

  @override
  String premiumPurchaseErrorDetail(String error) {
    return 'Erreur lors de l\'achat: $error';
  }

  @override
  String get premiumWelcomeTitle => 'Bienvenue Premium !';

  @override
  String get premiumCongratulationsDetail => 'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium de SmartSpend.';

  @override
  String get premiumEnjoyNoLimits => 'Profitez de toutes les fonctionnalités sans limite !';

  @override
  String get premiumProductLoadError => 'Erreur de chargement des produits. Veuillez réessayer.';

  @override
  String get premiumUpgradeErrorGeneric => 'Erreur lors de la mise à niveau Premium';

  @override
  String get exportCsv => 'Exporter en CSV';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get exportOptions => 'Options d\'export';

  @override
  String get exportSuccessNoMore => '🎉 Export réussi ! Plus d\'essais gratuits disponibles.';

  @override
  String exportSuccessRemaining(int count) {
    return '🎉 Export réussi ! $count essais restants.';
  }

  @override
  String get pdfExportLabel => 'l\'export PDF';

  @override
  String get pdfExportErrorGeneric => 'Erreur lors de l\'export PDF';

  @override
  String get drawerSubtitle => 'Votre assistant financier personnel';

  @override
  String get drawerNotifications => 'NOTIFICATIONS';

  @override
  String get drawerManagement => 'GESTION';

  @override
  String get drawerFinancialAssistant => 'Assistant financier';

  @override
  String get drawerFinancialAssistantSubtitle => 'Obtenez des conseils personnalisés';

  @override
  String get drawerFinancialAssistantLabel => 'l\'assistant financier';

  @override
  String get drawerAccessError => 'Erreur lors de l\'accès à l\'assistant';

  @override
  String get drawerMyProfile => 'Mon Profil';

  @override
  String get drawerMyProfileSubtitle => 'Gérez vos informations de compte';

  @override
  String get transactionOptions => 'Options de la transaction';

  @override
  String get editTransactionTitle => 'Modifier la transaction';

  @override
  String transactionCategoryLabel(String name) {
    return 'Catégorie: $name';
  }

  @override
  String get percentageLabel => 'Pourcentage (%)';

  @override
  String amountCurrencyLabel(String currency) {
    return 'Montant ($currency)';
  }

  @override
  String get switchToAmount => 'Changer en Montant';

  @override
  String get switchToPercent => 'Changer en Pourcentage';

  @override
  String get iconLabel => 'Icône';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get categoryNameEmpty => 'Le nom ne peut pas être vide.';

  @override
  String get budgetTotalAvailable => 'Budget total dispo.:';

  @override
  String get premiumUpgradeDialogWelcome => 'Bienvenue Premium !';

  @override
  String get premiumUpgradeDialogCongrats => 'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium.';

  @override
  String premiumUpgradeDialogFeature(String feature) {
    return 'Vous pouvez maintenant utiliser $feature sans limite !';
  }

  @override
  String get premiumUpgradeDialogButton => 'Parfait !';

  @override
  String get premiumUpgradeDialogError => 'Erreur lors de la mise à niveau';

  @override
  String get addTransactionTitle => 'Ajouter une transaction';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get drawerDailyReminders => 'Rappels quotidiens';

  @override
  String get drawerDailyRemindersSubtitle => 'Rappel du soir pour vos transactions';

  @override
  String get drawerFinancialGoals => 'Objectifs financiers';

  @override
  String get drawerFinancialGoalsSubtitle => 'Définir et suivre vos objectifs d\'épargne';

  @override
  String get newCategoryTitle => 'Nouvelle Catégorie';

  @override
  String get editCategoryTitle => 'Modifier la Catégorie';

  @override
  String equivalentAmount(String amount, String currency) {
    return 'Équivalent: $amount $currency';
  }

  @override
  String equivalentPercent(String percent) {
    return 'Équivalent: $percent%';
  }

  @override
  String get budgetExceedsRemaining => 'Le montant dépasse le budget restant disponible !';

  @override
  String get incomeFirstMessage => 'Veuillez d\'abord définir votre salaire.';

  @override
  String switchToLabel(String mode) {
    return 'Changer en $mode';
  }
}
