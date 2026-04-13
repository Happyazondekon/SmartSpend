import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'SmartSpend'**
  String get appTitle;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filterAll;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour ! 👋'**
  String get loginWelcomeTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour gérer vos finances'**
  String get loginSubtitle;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte trouvé avec cet email'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Format d\'email invalide'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorTooManyAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez plus tard'**
  String get loginErrorTooManyAttempts;

  /// No description provided for @loginErrorGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez'**
  String get loginErrorGeneral;

  /// No description provided for @loginValidationEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get loginValidationEmailRequired;

  /// No description provided for @loginValidationPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get loginValidationPasswordRequired;

  /// No description provided for @loginForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @loginOrDivider.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get loginOrDivider;

  /// No description provided for @loginWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get loginWithGoogle;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginCreateAccount;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez SmartSpend et prenez le contrôle de vos finances'**
  String get registerSubtitle;

  /// No description provided for @registerFieldFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get registerFieldFullName;

  /// No description provided for @registerFieldFullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Jean Dupont'**
  String get registerFieldFullNameHint;

  /// No description provided for @registerFieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get registerFieldEmail;

  /// No description provided for @registerFieldEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get registerFieldEmailHint;

  /// No description provided for @registerFieldPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerFieldPassword;

  /// No description provided for @registerFieldPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'••••••••'**
  String get registerFieldPasswordHint;

  /// No description provided for @registerFieldConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get registerFieldConfirmPassword;

  /// No description provided for @registerValidationPasswordMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 6 caractères'**
  String get registerValidationPasswordMinLength;

  /// No description provided for @registerValidationNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get registerValidationNameRequired;

  /// No description provided for @registerValidationNameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Nom trop court'**
  String get registerValidationNameTooShort;

  /// No description provided for @registerValidationPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un mot de passe'**
  String get registerValidationPasswordRequired;

  /// No description provided for @registerValidationPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get registerValidationPasswordMismatch;

  /// No description provided for @registerValidationTermsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez accepter les conditions d\'utilisation'**
  String get registerValidationTermsRequired;

  /// No description provided for @registerValidationTerms.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez accepter les conditions d\'utilisation'**
  String get registerValidationTerms;

  /// No description provided for @termsPrefix.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les '**
  String get termsPrefix;

  /// No description provided for @termsOfUse.
  ///
  /// In fr, this message translates to:
  /// **'conditions d\'utilisation'**
  String get termsOfUse;

  /// No description provided for @termsMiddle.
  ///
  /// In fr, this message translates to:
  /// **' et la '**
  String get termsMiddle;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @registerValidationEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get registerValidationEmailRequired;

  /// No description provided for @registerValidationInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Format d\'email invalide'**
  String get registerValidationInvalidEmail;

  /// No description provided for @registerValidationPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 6 caractères'**
  String get registerValidationPasswordTooShort;

  /// No description provided for @registerErrorGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get registerErrorGeneral;

  /// No description provided for @registerErrorGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion avec Google'**
  String get registerErrorGoogle;

  /// No description provided for @registerButtonSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get registerButtonSubmit;

  /// No description provided for @registerExistingAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get registerExistingAccount;

  /// No description provided for @registerErrorEmailInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse email est déjà utilisée'**
  String get registerErrorEmailInUse;

  /// No description provided for @registerErrorGoogleSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion avec Google'**
  String get registerErrorGoogleSignIn;

  /// No description provided for @registerPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get registerPrivacyPolicy;

  /// No description provided for @registerTermsOfUse.
  ///
  /// In fr, this message translates to:
  /// **'conditions d\'utilisation'**
  String get registerTermsOfUse;

  /// No description provided for @registerAgreeTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les'**
  String get registerAgreeTerms;

  /// No description provided for @registerAndThe.
  ///
  /// In fr, this message translates to:
  /// **'et la'**
  String get registerAndThe;

  /// No description provided for @emailVerificationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre email'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerificationSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Email vérifié ! 🎉'**
  String get emailVerificationSuccess;

  /// No description provided for @emailVerificationSuccessMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte est maintenant activé. Redirection en cours...'**
  String get emailVerificationSuccessMessage;

  /// No description provided for @emailVerificationSentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nous avons envoyé un email de vérification à :'**
  String get emailVerificationSentMessage;

  /// No description provided for @emailVerificationErrorSending.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'envoi de l\'email'**
  String get emailVerificationErrorSending;

  /// No description provided for @emailVerificationSendError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'envoi de l\'email'**
  String get emailVerificationSendError;

  /// No description provided for @emailVerificationInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez sur le lien de vérification'**
  String get emailVerificationInstructions;

  /// No description provided for @emailVerificationResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer l\'email'**
  String get emailVerificationResend;

  /// No description provided for @emailVerificationResendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {seconds}s'**
  String emailVerificationResendIn(int seconds);

  /// No description provided for @emailVerificationCheckSpam.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez également votre dossier spam'**
  String get emailVerificationCheckSpam;

  /// No description provided for @emailVerificationChangeEmail.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'email'**
  String get emailVerificationChangeEmail;

  /// No description provided for @emailVerificationStep1.
  ///
  /// In fr, this message translates to:
  /// **'1. Ouvrez votre boîte mail'**
  String get emailVerificationStep1;

  /// No description provided for @emailVerificationStep3.
  ///
  /// In fr, this message translates to:
  /// **'3. Revenez sur l\'application'**
  String get emailVerificationStep3;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'Email envoyé !'**
  String get forgotPasswordEmailSent;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.'**
  String get forgotPasswordDescription;

  /// No description provided for @forgotPasswordSuccessDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.'**
  String get forgotPasswordSuccessDescription;

  /// No description provided for @forgotPasswordCheckInbox.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.'**
  String get forgotPasswordCheckInbox;

  /// No description provided for @forgotPasswordError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Vérifiez votre adresse email.'**
  String get forgotPasswordError;

  /// No description provided for @forgotPasswordSendButton.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get forgotPasswordSendButton;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @forgotPasswordResendEmail.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer l\'email'**
  String get forgotPasswordResendEmail;

  /// No description provided for @forgotPasswordResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer'**
  String get forgotPasswordResend;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Format d\'email invalide'**
  String get forgotPasswordInvalidEmail;

  /// No description provided for @forgotPasswordRemember.
  ///
  /// In fr, this message translates to:
  /// **'Vous vous souvenez ?'**
  String get forgotPasswordRemember;

  /// No description provided for @forgotPasswordSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get forgotPasswordSignIn;

  /// No description provided for @pinSetupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre code PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinSetupConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre code'**
  String get pinSetupConfirmTitle;

  /// No description provided for @pinSetupDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ce code protégera l\'accès à vos données'**
  String get pinSetupDescription;

  /// No description provided for @pinSetupConfirmDescription.
  ///
  /// In fr, this message translates to:
  /// **'Entrez à nouveau votre code à 4 chiffres'**
  String get pinSetupConfirmDescription;

  /// No description provided for @pinSetupErrorMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les codes ne correspondent pas'**
  String get pinSetupErrorMismatch;

  /// No description provided for @pinSetupRestart.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer'**
  String get pinSetupRestart;

  /// No description provided for @pinLockBiometricPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillez SmartSpend avec votre empreinte'**
  String get pinLockBiometricPrompt;

  /// No description provided for @pinLockErrorIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect ({attemptsRemaining} essais restants)'**
  String pinLockErrorIncorrect(int attemptsRemaining);

  /// No description provided for @pinLockErrorLocked.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez dans {seconds} secondes'**
  String pinLockErrorLocked(int seconds);

  /// No description provided for @pinLockBiometricButton.
  ///
  /// In fr, this message translates to:
  /// **'Biométrie'**
  String get pinLockBiometricButton;

  /// No description provided for @pinLockLogoutButton.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get pinLockLogoutButton;

  /// No description provided for @pinLockTooManyAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives'**
  String get pinLockTooManyAttempts;

  /// No description provided for @pinLockEnterCode.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code PIN'**
  String get pinLockEnterCode;

  /// No description provided for @navBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @quickActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quickActionsTitle;

  /// No description provided for @quickActionTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Transaction'**
  String get quickActionTransaction;

  /// No description provided for @quickActionGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get quickActionGoal;

  /// No description provided for @quickActionAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant'**
  String get quickActionAssistant;

  /// No description provided for @budgetHeaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get budgetHeaderTitle;

  /// No description provided for @budgetSetButtonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Définir'**
  String get budgetSetButtonLabel;

  /// No description provided for @budgetUsedLabel.
  ///
  /// In fr, this message translates to:
  /// **'utilisé'**
  String get budgetUsedLabel;

  /// No description provided for @budgetSpentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dépensé'**
  String get budgetSpentLabel;

  /// No description provided for @budgetCategoriesSection.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get budgetCategoriesSection;

  /// No description provided for @budgetRecentTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions récentes'**
  String get budgetRecentTransactions;

  /// No description provided for @greetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour ☀️'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon après-midi ☀️'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir 🌙'**
  String get greetingEvening;

  /// No description provided for @budgetManageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le budget'**
  String get budgetManageTitle;

  /// No description provided for @budgetSetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Définir le budget'**
  String get budgetSetTitle;

  /// No description provided for @budgetNotSet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun budget défini'**
  String get budgetNotSet;

  /// No description provided for @budgetSupplementaryIncome.
  ///
  /// In fr, this message translates to:
  /// **'Pour les revenus supplémentaires'**
  String get budgetSupplementaryIncome;

  /// No description provided for @budgetSupplementaryIncomeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un revenu supplémentaire à votre budget actuel'**
  String get budgetSupplementaryIncomeDescription;

  /// No description provided for @budgetSupplementaryAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant à ajouter'**
  String get budgetSupplementaryAmountLabel;

  /// No description provided for @budgetNewCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get budgetNewCategoryTitle;

  /// No description provided for @budgetCategoryNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get budgetCategoryNameLabel;

  /// No description provided for @budgetAllocatedAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant alloué'**
  String get budgetAllocatedAmountLabel;

  /// No description provided for @budgetEquivalentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Équivalent: {amount}'**
  String budgetEquivalentLabel(String amount);

  /// No description provided for @budgetIconLabel.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get budgetIconLabel;

  /// No description provided for @budgetAddCategoryButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la catégorie'**
  String get budgetAddCategoryButton;

  /// No description provided for @budgetEditCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la catégorie'**
  String get budgetEditCategoryTitle;

  /// No description provided for @budgetRemainingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Restant'**
  String get budgetRemainingLabel;

  /// No description provided for @budgetAvailableLabel.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get budgetAvailableLabel;

  /// No description provided for @budgetOf.
  ///
  /// In fr, this message translates to:
  /// **'sur'**
  String get budgetOf;

  /// No description provided for @transactionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @transactionsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une transaction...'**
  String get transactionsSearchHint;

  /// No description provided for @transactionsSummaryThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get transactionsSummaryThisMonth;

  /// No description provided for @transactionsSummaryCount.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get transactionsSummaryCount;

  /// No description provided for @transactionsSummaryAveragePerDay.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne/jour'**
  String get transactionsSummaryAveragePerDay;

  /// No description provided for @transactionsEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Vos transactions apparaîtront ici'**
  String get transactionsEmptyState;

  /// No description provided for @transactionsEmptyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre première transaction pour commencer à suivre vos dépenses'**
  String get transactionsEmptyDescription;

  /// No description provided for @transactionNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle transaction'**
  String get transactionNewTitle;

  /// No description provided for @transactionFieldCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get transactionFieldCategory;

  /// No description provided for @transactionFieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get transactionFieldDescription;

  /// No description provided for @transactionFieldDescriptionOptional.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get transactionFieldDescriptionOptional;

  /// No description provided for @transactionFieldDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Courses du weekend'**
  String get transactionFieldDescriptionHint;

  /// No description provided for @transactionEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la transaction'**
  String get transactionEditTitle;

  /// No description provided for @transactionFieldDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get transactionFieldDate;

  /// No description provided for @transactionModified.
  ///
  /// In fr, this message translates to:
  /// **'Transaction modifiée'**
  String get transactionModified;

  /// No description provided for @saveButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveButton;

  /// No description provided for @transactionFieldAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get transactionFieldAmount;

  /// No description provided for @addButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addButton;

  /// No description provided for @transactionWarningIrreversible.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get transactionWarningIrreversible;

  /// No description provided for @transactionModifiedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Transaction modifiée'**
  String get transactionModifiedSuccess;

  /// No description provided for @transactionDeletedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Transaction supprimée'**
  String get transactionDeletedSuccess;

  /// No description provided for @transactionAddedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Transaction ajoutée avec succès'**
  String get transactionAddedSuccess;

  /// No description provided for @transactionDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette transaction ?'**
  String get transactionDeleteConfirm;

  /// No description provided for @categoryHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In fr, this message translates to:
  /// **'Éducation'**
  String get categoryEducation;

  /// No description provided for @categorySavings.
  ///
  /// In fr, this message translates to:
  /// **'Épargne'**
  String get categorySavings;

  /// No description provided for @categoryRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyer'**
  String get categoryRent;

  /// No description provided for @categoryTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryUtilities.
  ///
  /// In fr, this message translates to:
  /// **'Électricité/Eau'**
  String get categoryUtilities;

  /// No description provided for @categoryInternet.
  ///
  /// In fr, this message translates to:
  /// **'Internet'**
  String get categoryInternet;

  /// No description provided for @categoryFood.
  ///
  /// In fr, this message translates to:
  /// **'Nourriture'**
  String get categoryFood;

  /// No description provided for @categoryEntertainment.
  ///
  /// In fr, this message translates to:
  /// **'Loisirs'**
  String get categoryEntertainment;

  /// No description provided for @categoryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get categoryOther;

  /// No description provided for @monthJan.
  ///
  /// In fr, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In fr, this message translates to:
  /// **'Fév'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In fr, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In fr, this message translates to:
  /// **'Avr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In fr, this message translates to:
  /// **'Mai'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In fr, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In fr, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In fr, this message translates to:
  /// **'Aoû'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In fr, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In fr, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In fr, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In fr, this message translates to:
  /// **'Déc'**
  String get monthDec;

  /// No description provided for @reportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get reportsTitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Analysez vos dépenses'**
  String get reportsSubtitle;

  /// No description provided for @reportsPeriodThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get reportsPeriodThisMonth;

  /// No description provided for @reportsPeriod3Months.
  ///
  /// In fr, this message translates to:
  /// **'3 mois'**
  String get reportsPeriod3Months;

  /// No description provided for @reportsPeriod6Months.
  ///
  /// In fr, this message translates to:
  /// **'6 mois'**
  String get reportsPeriod6Months;

  /// No description provided for @reportsPeriod1Year.
  ///
  /// In fr, this message translates to:
  /// **'1 an'**
  String get reportsPeriod1Year;

  /// No description provided for @reportsSpendingDistribution.
  ///
  /// In fr, this message translates to:
  /// **'Répartition des dépenses'**
  String get reportsSpendingDistribution;

  /// No description provided for @reportsTotalSpent.
  ///
  /// In fr, this message translates to:
  /// **'Total dépensé'**
  String get reportsTotalSpent;

  /// No description provided for @reportsNoData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée'**
  String get reportsNoData;

  /// No description provided for @reportsNoDataDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des transactions pour voir vos rapports'**
  String get reportsNoDataDescription;

  /// No description provided for @reportsSpent.
  ///
  /// In fr, this message translates to:
  /// **'Dépensé'**
  String get reportsSpent;

  /// No description provided for @reportsSavings.
  ///
  /// In fr, this message translates to:
  /// **'Épargne'**
  String get reportsSavings;

  /// No description provided for @reportsBudgetVsSpending.
  ///
  /// In fr, this message translates to:
  /// **'Budget vs Dépenses'**
  String get reportsBudgetVsSpending;

  /// No description provided for @reportsCategoryDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails par catégorie'**
  String get reportsCategoryDetails;

  /// No description provided for @reportsExportPDF.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get reportsExportPDF;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisez votre expérience'**
  String get settingsSubtitle;

  /// No description provided for @settingsSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get settingsSecurity;

  /// No description provided for @settingsChangePINTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le code PIN'**
  String get settingsChangePINTitle;

  /// No description provided for @settingsChangePINSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier votre code de sécurité'**
  String get settingsChangePINSubtitle;

  /// No description provided for @settingsData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsData;

  /// No description provided for @settingsExportData.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger vos données en PDF'**
  String get settingsExportDataSubtitle;

  /// No description provided for @settingsMonthlyHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique mensuel'**
  String get settingsMonthlyHistory;

  /// No description provided for @settingsMonthlyHistorySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'historique de vos mois clôturés'**
  String get settingsMonthlyHistorySubtitle;

  /// No description provided for @settingsResetData.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les données'**
  String get settingsResetData;

  /// No description provided for @settingsResetDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer toutes vos données'**
  String get settingsResetDataSubtitle;

  /// No description provided for @settingsPinProtection.
  ///
  /// In fr, this message translates to:
  /// **'Protéger l\'accès à l\'application'**
  String get settingsPinProtection;

  /// No description provided for @settingsPinEnabledSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN activé avec succès'**
  String get settingsPinEnabledSuccess;

  /// No description provided for @settingsDisablePinConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver le code PIN ?'**
  String get settingsDisablePinConfirm;

  /// No description provided for @settingsDisablePinWarning.
  ///
  /// In fr, this message translates to:
  /// **'Votre application ne sera plus protégée par un code de sécurité.'**
  String get settingsDisablePinWarning;

  /// No description provided for @settingsPinDisabledSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN désactivé'**
  String get settingsPinDisabledSuccess;

  /// No description provided for @settingsDisableButton.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get settingsDisableButton;

  /// No description provided for @settingsPinChangedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN modifié avec succès'**
  String get settingsPinChangedSuccess;

  /// No description provided for @settingsPremium.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Premium'**
  String get settingsPremium;

  /// No description provided for @settingsPremiumDescription.
  ///
  /// In fr, this message translates to:
  /// **'Débloquez toutes les fonctionnalités : exports PDF illimités, assistant IA illimité, et plus encore.'**
  String get settingsPremiumDescription;

  /// No description provided for @settingsLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get settingsLogout;

  /// No description provided for @settingsNoClosedMonths.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mois clôturé'**
  String get settingsNoClosedMonths;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les données ?'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetWarning.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos données seront supprimées. Cette action est irréversible.'**
  String get settingsResetWarning;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Données réinitialisées'**
  String get settingsResetSuccess;

  /// No description provided for @settingsResetButton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get settingsResetButton;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsLogoutWarning.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont sauvegardées dans le cloud.'**
  String get settingsLogoutWarning;

  /// No description provided for @settingsLogoutButton.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter'**
  String get settingsLogoutButton;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsDarkMode;

  /// No description provided for @settingsLightMode.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsLightMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get currency;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les rappels et alertes'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @user.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get user;

  /// No description provided for @freeVersion.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get freeVersion;

  /// No description provided for @transactionRemindersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de transactions'**
  String get transactionRemindersTitle;

  /// No description provided for @transactionRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des rappels matin, midi et soir'**
  String get transactionRemindersSubtitle;

  /// No description provided for @pinCode.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN'**
  String get pinCode;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @deleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteButton;

  /// No description provided for @transactionDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Transaction supprimée'**
  String get transactionDeleted;

  /// No description provided for @seeOffers.
  ///
  /// In fr, this message translates to:
  /// **'Voir les offres'**
  String get seeOffers;

  /// No description provided for @incomes.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get incomes;

  /// No description provided for @transactions.
  ///
  /// In fr, this message translates to:
  /// **'transactions'**
  String get transactions;

  /// No description provided for @goalsScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs Financiers'**
  String get goalsScreenTitle;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objectif défini'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier objectif financier pour commencer à épargner avec un but précis !'**
  String get goalsEmptyDescription;

  /// No description provided for @goalsCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer un objectif'**
  String get goalsCreateButton;

  /// No description provided for @goalsAddMoney.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter de l\'argent'**
  String get goalsAddMoney;

  /// No description provided for @goalsMarkComplete.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme terminé'**
  String get goalsMarkComplete;

  /// No description provided for @goalsEditButton.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get goalsEditButton;

  /// No description provided for @goalsDeleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get goalsDeleteButton;

  /// No description provided for @goalsProgressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get goalsProgressLabel;

  /// No description provided for @goalsDeadlineLabel.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get goalsDeadlineLabel;

  /// No description provided for @goalsTargetLabel.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get goalsTargetLabel;

  /// No description provided for @goalsCurrentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get goalsCurrentLabel;

  /// No description provided for @goalsNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel objectif'**
  String get goalsNewTitle;

  /// No description provided for @goalsEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'objectif'**
  String get goalsEditTitle;

  /// No description provided for @goalsNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'objectif'**
  String get goalsNameLabel;

  /// No description provided for @goalsAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant cible'**
  String get goalsAmountLabel;

  /// No description provided for @goalsDescriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get goalsDescriptionLabel;

  /// No description provided for @goalsDeadlineDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date limite'**
  String get goalsDeadlineDateLabel;

  /// No description provided for @goalsIconLabel.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get goalsIconLabel;

  /// No description provided for @goalsColorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get goalsColorLabel;

  /// No description provided for @goalsCreateButtonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get goalsCreateButtonLabel;

  /// No description provided for @goalsSaveButtonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get goalsSaveButtonLabel;

  /// No description provided for @goalsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet objectif ?'**
  String get goalsDeleteConfirm;

  /// No description provided for @goalsAchieved.
  ///
  /// In fr, this message translates to:
  /// **'Objectif atteint ! 🎉'**
  String get goalsAchieved;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission de notification refusée. Activez-la dans les paramètres.'**
  String get notificationPermissionDenied;

  /// No description provided for @notificationDisabledAndroid.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications sont désactivées dans les paramètres Android'**
  String get notificationDisabledAndroid;

  /// No description provided for @notificationBatteryOptimization.
  ///
  /// In fr, this message translates to:
  /// **'Pour des rappels fiables, désactivez l\'optimisation de batterie pour SmartSpend'**
  String get notificationBatteryOptimization;

  /// No description provided for @notificationReminderDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Rappels désactivés'**
  String get notificationReminderDisabled;

  /// No description provided for @notificationDisableError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la désactivation: {error}'**
  String notificationDisableError(String error);

  /// No description provided for @notificationSystemDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications ne sont pas activées au niveau système'**
  String get notificationSystemDisabled;

  /// No description provided for @notificationTestStarted.
  ///
  /// In fr, this message translates to:
  /// **'Tests lancés : • Notification immédiate • Notification dans 3 secondes'**
  String get notificationTestStarted;

  /// No description provided for @newMonthTitle.
  ///
  /// In fr, this message translates to:
  /// **'🎉 Nouveau mois !'**
  String get newMonthTitle;

  /// No description provided for @newMonthWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue en {month} {year} !'**
  String newMonthWelcome(String month, String year);

  /// No description provided for @newMonthCloseQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous clôturer {month} et commencer le nouveau mois ?'**
  String newMonthCloseQuestion(String month);

  /// No description provided for @newMonthInfo.
  ///
  /// In fr, this message translates to:
  /// **'• Vos catégories seront conservées\n• Les dépenses seront archivées\n• Vous pourrez entrer vos nouveaux revenus'**
  String get newMonthInfo;

  /// No description provided for @newMonthRemainingBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget restant: {amount}'**
  String newMonthRemainingBudget(String amount);

  /// No description provided for @newMonthCarryOver.
  ///
  /// In fr, this message translates to:
  /// **'Reporter ce montant au mois suivant'**
  String get newMonthCarryOver;

  /// No description provided for @newMonthLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get newMonthLater;

  /// No description provided for @newMonthCloseButton.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer le mois'**
  String get newMonthCloseButton;

  /// No description provided for @newMonthClosedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mois clôturé ! {amount} reporté. Ajoutez vos revenus.'**
  String newMonthClosedSuccess(String amount);

  /// No description provided for @newMonthClosedNoCarryOver.
  ///
  /// In fr, this message translates to:
  /// **'Mois clôturé ! Entrez vos revenus pour ce mois.'**
  String get newMonthClosedNoCarryOver;

  /// No description provided for @newMonthCloseError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la clôture du mois'**
  String get newMonthCloseError;

  /// No description provided for @chatbotGreeting.
  ///
  /// In fr, this message translates to:
  /// **'👋 Bonjour et bienvenue, {userName} !'**
  String chatbotGreeting(String userName);

  /// No description provided for @chatbotThinking.
  ///
  /// In fr, this message translates to:
  /// **'SmartBot réfléchit...'**
  String get chatbotThinking;

  /// No description provided for @chatbotInputHint.
  ///
  /// In fr, this message translates to:
  /// **'Posez votre question financière...'**
  String get chatbotInputHint;

  /// No description provided for @chatbotConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Connexion temporairement indisponible. Essayez une question des suggestions ci-dessous.'**
  String get chatbotConnectionError;

  /// No description provided for @chatbotLastFreeUse.
  ///
  /// In fr, this message translates to:
  /// **'C\'était votre dernière utilisation gratuite de l\'assistant.'**
  String get chatbotLastFreeUse;

  /// No description provided for @chatbotFreeUsesRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count} utilisations gratuites restantes'**
  String chatbotFreeUsesRemaining(int count);

  /// No description provided for @chatbotSuggestions.
  ///
  /// In fr, this message translates to:
  /// **'💡 Suggestions'**
  String get chatbotSuggestions;

  /// No description provided for @faqAddTransaction.
  ///
  /// In fr, this message translates to:
  /// **'📱 Comment ajouter une transaction?'**
  String get faqAddTransaction;

  /// No description provided for @faqCreateBudget.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Comment créer un budget?'**
  String get faqCreateBudget;

  /// No description provided for @faqViewStats.
  ///
  /// In fr, this message translates to:
  /// **'📊 Comment consulter mes statistiques?'**
  String get faqViewStats;

  /// No description provided for @faqSaveEffectively.
  ///
  /// In fr, this message translates to:
  /// **'💰 Comment économiser efficacement?'**
  String get faqSaveEffectively;

  /// No description provided for @faqReduceSpending.
  ///
  /// In fr, this message translates to:
  /// **'✂️ Comment réduire mes dépenses?'**
  String get faqReduceSpending;

  /// No description provided for @faqBeginnerInvesting.
  ///
  /// In fr, this message translates to:
  /// **'📊 Conseils investissement débutant?'**
  String get faqBeginnerInvesting;

  /// No description provided for @faqManageDebt.
  ///
  /// In fr, this message translates to:
  /// **'💳 Comment gérer mes dettes?'**
  String get faqManageDebt;

  /// No description provided for @faqCreateGoal.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Comment créer un objectif?'**
  String get faqCreateGoal;

  /// No description provided for @faqAddTransactionAnswer.
  ///
  /// In fr, this message translates to:
  /// **'📝 Ajouter une transaction:\n\n1. Ouvrez l\'onglet \'Transactions\'\n2. Appuyez sur le bouton \'+\' \n3. Saisissez le montant, choisissez la catégorie et ajoutez une description\n4. Validez pour enregistrer\n\n💡 Astuce: Ajoutez vos transactions immédiatement pour un suivi précis!'**
  String get faqAddTransactionAnswer;

  /// No description provided for @faqCreateBudgetAnswer.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Créer un budget efficace:\n\n1. Accédez à l\'onglet \'Budget\'\n2. Cliquez sur \'+\' pour ajouter un nouveau budget\n3. Définissez le montant maximal par catégorie\n4. Activez les alertes pour rester dans les limites\n\n💰 Conseil: Suivez la règle 50/30/20 (besoins/envies/épargne)'**
  String get faqCreateBudgetAnswer;

  /// No description provided for @faqViewStatsAnswer.
  ///
  /// In fr, this message translates to:
  /// **'📊 Analyser vos finances:\n\nL\'onglet \'Statistiques\' vous offre:\n• Graphiques de dépenses par catégorie\n• Évolution mensuelle de vos finances\n• Comparaisons périodiques\n• Tendances de consommation\n\n🔍 Utilisez ces données pour identifier vos habitudes et optimiser votre budget!'**
  String get faqViewStatsAnswer;

  /// No description provided for @faqSaveEffectivelyAnswer.
  ///
  /// In fr, this message translates to:
  /// **'💰 Stratégies d\'épargne éprouvées:\n\n🎯 Méthode des 52 semaines: Épargnez 1€ la 1ère semaine, 2€ la 2ème...\n🏦 Épargne automatique: 10-20% de chaque revenu\n📱 Utilisez SmartSpend pour tracker vos progrès\n⚡ Réduisez les abonnements non-essentiels\n\nObjectif: Constituez d\'abord un fonds d\'urgence (3-6 mois de charges)!'**
  String get faqSaveEffectivelyAnswer;

  /// No description provided for @faqReduceSpendingAnswer.
  ///
  /// In fr, this message translates to:
  /// **'✂️ Optimisation des dépenses:\n\n🔍 Analysez vos statistiques SmartSpend:\n• Identifiez les catégories les plus coûteuses\n• Repérez les dépenses récurrentes\n• Trouvez les \'fuites\' budgétaires\n\n💡 Actions concrètes:\n• Comparez les prix avant d\'acheter\n• Cuisinez plus à la maison\n• Renégociez vos contrats (assurance, téléphone)\n• Privilégiez l\'occasion quand possible'**
  String get faqReduceSpendingAnswer;

  /// No description provided for @faqBeginnerInvestingAnswer.
  ///
  /// In fr, this message translates to:
  /// **'🚀 Débuter en investissement:\n\n⚠️ Prérequis essentiels:\n✓ Fonds d\'urgence constitué (3-6 mois)\n✓ Dettes remboursées (sauf prêt immobilier)\n✓ Budget maîtrisé avec SmartSpend\n\n📈 Premiers pas:\n• Commencez petit (50-100€/mois)\n• Diversifiez vos placements\n• Privilégiez le long terme\n• Formez-vous avant d\'investir\n\n🏦 Options: Livret A, PEL, assurance-vie, PEA'**
  String get faqBeginnerInvestingAnswer;

  /// No description provided for @faqManageDebtAnswer.
  ///
  /// In fr, this message translates to:
  /// **'💳 Stratégie de remboursement:\n\n🎯 Méthode \'Boule de neige\':\n1. Listez toutes vos dettes\n2. Payez les minimums partout\n3. Attaquez la plus petite dette en premier\n4. Une fois remboursée, passez à la suivante\n\n📊 Utilisez SmartSpend pour tracker vos remboursements et célébrer vos progrès!\n\n⚡ Négociez avec vos créanciers si nécessaire.'**
  String get faqManageDebtAnswer;

  /// No description provided for @faqCreateGoalAnswer.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Créer un objectif financier:\n\n1. Accédez à l\'onglet \'Objectifs\'\n2. Appuyez sur \'+\' pour ajouter un nouvel objectif\n3. Indiquez le nom, la description (facultative), le montant cible et la date limite\n4. Choisissez une icône et une couleur pour personnaliser votre objectif\n5. Validez en appuyant sur \'Créer\''**
  String get faqCreateGoalAnswer;

  /// No description provided for @budgetExceededWarning.
  ///
  /// In fr, this message translates to:
  /// **'Budget dépassé. Essayez de réduire vos dépenses.'**
  String get budgetExceededWarning;

  /// No description provided for @syncCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation terminée'**
  String get syncCompleted;

  /// No description provided for @dataInitError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'initialisation des données'**
  String get dataInitError;

  /// No description provided for @allDataDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les données ont été supprimées'**
  String get allDataDeleted;

  /// No description provided for @dataDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression des données'**
  String dataDeleteError(String error);

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In fr, this message translates to:
  /// **'Cette catégorie existe déjà'**
  String get categoryAlreadyExists;

  /// No description provided for @budgetPercentageError.
  ///
  /// In fr, this message translates to:
  /// **'Le total des pourcentages ne peut pas dépasser 100%. Disponible: {percent}%'**
  String budgetPercentageError(String percent);

  /// No description provided for @budgetValidationError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom valide et un pourcentage supérieur à 0'**
  String get budgetValidationError;

  /// No description provided for @cannotDeleteCategoryWithTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer une catégorie avec des transactions'**
  String get cannotDeleteCategoryWithTransactions;

  /// No description provided for @noTransactionsToExport.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction à exporter'**
  String get noTransactionsToExport;

  /// No description provided for @csvHeaders.
  ///
  /// In fr, this message translates to:
  /// **'Date,Catégorie,Description,Montant'**
  String get csvHeaders;

  /// No description provided for @pdfTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relevé Financier de : {name}'**
  String pdfTitle(String name);

  /// No description provided for @pdfGeneratedDate.
  ///
  /// In fr, this message translates to:
  /// **'Généré le {date}'**
  String pdfGeneratedDate(String date);

  /// No description provided for @pdfSituation.
  ///
  /// In fr, this message translates to:
  /// **'SITUATION FINANCIÈRE'**
  String get pdfSituation;

  /// No description provided for @pdfTotalSpent.
  ///
  /// In fr, this message translates to:
  /// **'Total des dépenses:'**
  String get pdfTotalSpent;

  /// No description provided for @pdfTransactionDetails.
  ///
  /// In fr, this message translates to:
  /// **'DÉTAIL DES TRANSACTIONS'**
  String get pdfTransactionDetails;

  /// No description provided for @pdfCategoryAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'ANALYSE PAR CATÉGORIE'**
  String get pdfCategoryAnalysis;

  /// No description provided for @pdfFooter.
  ///
  /// In fr, this message translates to:
  /// **'SmartSpend - Gestion financière intelligente'**
  String get pdfFooter;

  /// No description provided for @pdfCategoryHeader.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get pdfCategoryHeader;

  /// No description provided for @pdfAmountHeader.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get pdfAmountHeader;

  /// No description provided for @pdfBudgetHeader.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get pdfBudgetHeader;

  /// No description provided for @pdfVarianceHeader.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get pdfVarianceHeader;

  /// No description provided for @goalCreatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Objectif financier créé avec succès !'**
  String get goalCreatedSuccess;

  /// No description provided for @goalCreationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création de l\'objectif'**
  String get goalCreationError;

  /// No description provided for @goalModifiedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Objectif modifié avec succès !'**
  String get goalModifiedSuccess;

  /// No description provided for @goalDeletedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Objectif supprimé'**
  String get goalDeletedSuccess;

  /// No description provided for @goalAmountAddedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Montant ajouté avec succès !'**
  String get goalAmountAddedSuccess;

  /// No description provided for @savingSuggestionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suggestion d\'épargne'**
  String get savingSuggestionTitle;

  /// No description provided for @goalDeadlineApproaching.
  ///
  /// In fr, this message translates to:
  /// **'Votre objectif \"{goalName}\" arrive bientôt à échéance !'**
  String goalDeadlineApproaching(String goalName);

  /// No description provided for @goalDeadlineDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance: {date}'**
  String goalDeadlineDate(String date);

  /// No description provided for @goalSavingSuggestion.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous épargner {amount} pour cet objectif ?'**
  String goalSavingSuggestion(String amount);

  /// No description provided for @goalSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Épargner'**
  String get goalSaveButton;

  /// No description provided for @goalEncouragement.
  ///
  /// In fr, this message translates to:
  /// **'Continuez sur cette lancée pour atteindre tous vos objectifs financiers !'**
  String get goalEncouragement;

  /// No description provided for @premiumUnlockFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Débloquez toutes les fonctionnalités :'**
  String get premiumUnlockFeatures;

  /// No description provided for @premiumUnlimitedPDF.
  ///
  /// In fr, this message translates to:
  /// **'Exports PDF illimités'**
  String get premiumUnlimitedPDF;

  /// No description provided for @premiumUnlimitedAI.
  ///
  /// In fr, this message translates to:
  /// **'Assistant IA illimité'**
  String get premiumUnlimitedAI;

  /// No description provided for @premiumAdvancedAnalytics.
  ///
  /// In fr, this message translates to:
  /// **'Analyses avancées'**
  String get premiumAdvancedAnalytics;

  /// No description provided for @premiumNoAds.
  ///
  /// In fr, this message translates to:
  /// **'Pas de publicités'**
  String get premiumNoAds;

  /// No description provided for @premiumPurchaseError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'achat. Réessayez.'**
  String get premiumPurchaseError;

  /// No description provided for @premiumProductNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Produit non disponible. Réessayez plus tard.'**
  String get premiumProductNotAvailable;

  /// No description provided for @premiumPDFLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez utilisé vos 3 exports PDF gratuits.'**
  String get premiumPDFLimitReached;

  /// No description provided for @premiumUpgradePrompt.
  ///
  /// In fr, this message translates to:
  /// **'Passez à Premium pour des exports illimités et un accès complet à l\'assistant financier.'**
  String get premiumUpgradePrompt;

  /// No description provided for @premiumChatbotLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez utilisé vos 3 sessions gratuites de l\'assistant IA.'**
  String get premiumChatbotLimitReached;

  /// No description provided for @premiumLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Limite atteinte'**
  String get premiumLimitReached;

  /// No description provided for @premiumViewButton.
  ///
  /// In fr, this message translates to:
  /// **'Voir Premium'**
  String get premiumViewButton;

  /// No description provided for @closeButton.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get closeButton;

  /// No description provided for @premiumLastFreeExport.
  ///
  /// In fr, this message translates to:
  /// **'C\'était votre dernier export PDF gratuit.'**
  String get premiumLastFreeExport;

  /// No description provided for @premiumYearly.
  ///
  /// In fr, this message translates to:
  /// **'Annuel'**
  String get premiumYearly;

  /// No description provided for @premiumMonthly.
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get premiumMonthly;

  /// No description provided for @premiumPerYear.
  ///
  /// In fr, this message translates to:
  /// **'/ an'**
  String get premiumPerYear;

  /// No description provided for @premiumPerMonth.
  ///
  /// In fr, this message translates to:
  /// **'/ mois'**
  String get premiumPerMonth;

  /// No description provided for @premiumBestValue.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur choix'**
  String get premiumBestValue;

  /// No description provided for @premiumUpgradeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passez à Premium 💎'**
  String get premiumUpgradeTitle;

  /// No description provided for @premiumRestorePurchases.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer les achats'**
  String get premiumRestorePurchases;

  /// No description provided for @authVerifying.
  ///
  /// In fr, this message translates to:
  /// **'Vérification...'**
  String get authVerifying;

  /// No description provided for @authInitializingData.
  ///
  /// In fr, this message translates to:
  /// **'Initialisation de vos données...'**
  String get authInitializingData;

  /// No description provided for @authVerifyingSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de la sécurité...'**
  String get authVerifyingSecurity;

  /// No description provided for @authPreparingExperience.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de votre expérience...'**
  String get authPreparingExperience;

  /// No description provided for @loadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get loadingError;

  /// No description provided for @dataLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger vos données'**
  String get dataLoadingError;

  /// No description provided for @retryButton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retryButton;

  /// No description provided for @updateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour requise'**
  String get updateRequired;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle version de SmartSpend est disponible avec des améliorations importantes et des corrections de bugs.'**
  String get updateAvailableMessage;

  /// No description provided for @updateMandatoryMessage.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez mettre à jour l\'application pour continuer à l\'utiliser.'**
  String get updateMandatoryMessage;

  /// No description provided for @updateNowButton.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour maintenant'**
  String get updateNowButton;

  /// No description provided for @updateDataSafeMessage.
  ///
  /// In fr, this message translates to:
  /// **'💡 Vos données sont sauvegardées et seront restaurées après la mise à jour.'**
  String get updateDataSafeMessage;

  /// No description provided for @onboardingBudgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez votre budget'**
  String get onboardingBudgetTitle;

  /// No description provided for @onboardingBudgetDescription.
  ///
  /// In fr, this message translates to:
  /// **'Définissez votre salaire ou revenus et répartissez-le intelligemment entre vos différentes catégories de dépenses.'**
  String get onboardingBudgetDescription;

  /// No description provided for @onboardingTrackingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos dépenses'**
  String get onboardingTrackingTitle;

  /// No description provided for @onboardingTrackingDescription.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez chaque transaction et visualisez en temps réel où va votre argent grâce à des graphiques clairs.'**
  String get onboardingTrackingDescription;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Atteignez vos objectifs'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Créez des objectifs d\'épargne personnalisés et suivez votre progression jusqu\'à leur réalisation.'**
  String get onboardingGoalsDescription;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// No description provided for @syncSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation réussie'**
  String get syncSuccess;

  /// No description provided for @offlineMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne - Données non synchronisées'**
  String get offlineMode;

  /// No description provided for @syncRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get syncRetry;

  /// No description provided for @cancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelButton;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get warning;

  /// No description provided for @editButton.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editButton;

  /// No description provided for @monthProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression du mois'**
  String get monthProgress;

  /// No description provided for @daysRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours restants'**
  String daysRemaining(int count);

  /// No description provided for @noTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction'**
  String get noTransaction;

  /// No description provided for @budgetLabel.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get budgetLabel;

  /// No description provided for @calculateBudgetButton.
  ///
  /// In fr, this message translates to:
  /// **'Calculer le budget'**
  String get calculateBudgetButton;

  /// No description provided for @budgetAddToBudgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au budget'**
  String get budgetAddToBudgetTitle;

  /// No description provided for @budgetAddToBudgetButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au budget'**
  String get budgetAddToBudgetButton;

  /// No description provided for @budgetMonthlyIncomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos revenus mensuels'**
  String get budgetMonthlyIncomeTitle;

  /// No description provided for @budgetEnterMonthlyIncome.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre salaire ou revenus mensuels nets'**
  String get budgetEnterMonthlyIncome;

  /// No description provided for @budgetCurrentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Budget actuel'**
  String get budgetCurrentLabel;

  /// No description provided for @budgetNewLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau budget: {amount}'**
  String budgetNewLabel(String amount);

  /// No description provided for @budgetPercentageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage'**
  String get budgetPercentageLabel;

  /// No description provided for @budgetAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get budgetAmountLabel;

  /// No description provided for @budgetBudgetPercentageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage du budget'**
  String get budgetBudgetPercentageLabel;

  /// No description provided for @budgetMaxLabel.
  ///
  /// In fr, this message translates to:
  /// **'Max: {value}'**
  String budgetMaxLabel(String value);

  /// No description provided for @budgetSaveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get budgetSaveChanges;

  /// No description provided for @budgetOfBudget.
  ///
  /// In fr, this message translates to:
  /// **'du budget'**
  String get budgetOfBudget;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageCode.
  ///
  /// In fr, this message translates to:
  /// **'fr'**
  String get languageCode;

  /// No description provided for @chatbotSystemPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Tu es SmartBot, l\'assistant IA premium de SmartSpend, expert en finances personnelles et conseiller financier bienveillant.'**
  String get chatbotSystemPrompt;

  /// No description provided for @chatbotSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Conseiller financier'**
  String get chatbotSubtitle;

  /// No description provided for @chatbotIntro.
  ///
  /// In fr, this message translates to:
  /// **'🤖 Je suis SmartBot, votre conseiller financier intelligent et assistant personnel pour SmartSpend.'**
  String get chatbotIntro;

  /// No description provided for @chatbotCapabilities.
  ///
  /// In fr, this message translates to:
  /// **'💡 Je peux vous aider avec:\n• 📊 Conseils financiers personnalisés\n• 📱 Guide d\'utilisation SmartSpend\n• 💰 Stratégies d\'épargne et d\'investissement\n• 📈 Analyse de vos habitudes financières'**
  String get chatbotCapabilities;

  /// No description provided for @chatbotPrompt.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Commençons ! Choisissez un sujet ci-dessous ou posez-moi directement votre question.'**
  String get chatbotPrompt;

  /// No description provided for @chatbotError.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Une erreur est survenue. Veuillez réessayer ou choisir une suggestion.'**
  String get chatbotError;

  /// No description provided for @chatbotTabPopular.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Populaire'**
  String get chatbotTabPopular;

  /// No description provided for @chatbotTabFinance.
  ///
  /// In fr, this message translates to:
  /// **'💰 Finances'**
  String get chatbotTabFinance;

  /// No description provided for @chatbotTabApp.
  ///
  /// In fr, this message translates to:
  /// **'📱 App'**
  String get chatbotTabApp;

  /// No description provided for @chatbotDefaultUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get chatbotDefaultUser;

  /// No description provided for @goalsCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminé ✓'**
  String get goalsCompleted;

  /// No description provided for @goalsOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get goalsOverdue;

  /// No description provided for @goalsDaysRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours restants'**
  String goalsDaysRemaining(int count);

  /// No description provided for @goalsToReachObjective.
  ///
  /// In fr, this message translates to:
  /// **'Pour atteindre votre objectif:'**
  String get goalsToReachObjective;

  /// No description provided for @goalsDailyAmount.
  ///
  /// In fr, this message translates to:
  /// **'• {amount} {currency} par jour'**
  String goalsDailyAmount(String amount, String currency);

  /// No description provided for @goalsMonthlyAmount.
  ///
  /// In fr, this message translates to:
  /// **'• {amount} {currency} par mois'**
  String goalsMonthlyAmount(String amount, String currency);

  /// No description provided for @goalsNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Voyage au Bénin'**
  String get goalsNameHint;

  /// No description provided for @goalsDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Plus de détails sur votre objectif...'**
  String get goalsDescriptionHint;

  /// No description provided for @goalsValidationError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir le nom et le montant'**
  String get goalsValidationError;

  /// No description provided for @goalsPercentReached.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% atteint'**
  String goalsPercentReached(String percent);

  /// No description provided for @goalsAmountToAdd.
  ///
  /// In fr, this message translates to:
  /// **'Montant à ajouter'**
  String get goalsAmountToAdd;

  /// No description provided for @goalsRemainingToReach.
  ///
  /// In fr, this message translates to:
  /// **'Il reste {amount} {currency} pour atteindre l\'objectif'**
  String goalsRemainingToReach(String amount, String currency);

  /// No description provided for @goalsInvalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un montant valide'**
  String get goalsInvalidAmount;

  /// No description provided for @goalsCreateSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Objectif créé avec succès !'**
  String get goalsCreateSuccess;

  /// No description provided for @goalsCreateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création de l\'objectif'**
  String get goalsCreateError;

  /// No description provided for @goalsEditSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Objectif modifié avec succès !'**
  String get goalsEditSuccess;

  /// No description provided for @goalsEditError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la modification'**
  String get goalsEditError;

  /// No description provided for @goalsDeleteSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Objectif supprimé'**
  String get goalsDeleteSuccess;

  /// No description provided for @goalsDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get goalsDeleteError;

  /// No description provided for @goalsAmountExceedsRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Le montant ajouté dépasse le montant restant à atteindre.\nIl reste {amount} à compléter.'**
  String goalsAmountExceedsRemaining(String amount);

  /// No description provided for @goalsAmountAdded.
  ///
  /// In fr, this message translates to:
  /// **'Montant ajouté !'**
  String get goalsAmountAdded;

  /// No description provided for @goalsAddError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'ajout'**
  String get goalsAddError;

  /// No description provided for @goalsCongratulations.
  ///
  /// In fr, this message translates to:
  /// **'🎉 Félicitations !'**
  String get goalsCongratulations;

  /// No description provided for @goalsAchievedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Objectif \"{name}\" atteint !'**
  String goalsAchievedMessage(String name);

  /// No description provided for @goalsGreatButton.
  ///
  /// In fr, this message translates to:
  /// **'Super !'**
  String get goalsGreatButton;

  /// No description provided for @goalsFinalizeError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la finalisation'**
  String get goalsFinalizeError;

  /// No description provided for @goalsDeleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer \"{name}\" ?'**
  String goalsDeleteConfirmMessage(String name);

  /// No description provided for @goalsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des objectifs'**
  String get goalsLoadError;

  /// No description provided for @goalsMarkedComplete.
  ///
  /// In fr, this message translates to:
  /// **'🎉 Objectif marqué comme terminé !'**
  String get goalsMarkedComplete;

  /// No description provided for @notifActivationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'activation des rappels: {error}'**
  String notifActivationError(String error);

  /// No description provided for @notifDeactivationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la désactivation: {error}'**
  String notifDeactivationError(String error);

  /// No description provided for @notifRemindersDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Rappels désactivés'**
  String get notifRemindersDisabled;

  /// No description provided for @invalidIncomeError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer des revenus valides'**
  String get invalidIncomeError;

  /// No description provided for @invalidAmountError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un montant valide'**
  String get invalidAmountError;

  /// No description provided for @budgetAmountAdded.
  ///
  /// In fr, this message translates to:
  /// **'{amount} ajouté au budget'**
  String budgetAmountAdded(String amount);

  /// No description provided for @budgetExceeded.
  ///
  /// In fr, this message translates to:
  /// **'Budget dépassé. Essayez de réduire vos dépenses.'**
  String get budgetExceeded;

  /// No description provided for @budgetLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Attention, vous avez atteint la limite de votre budget.'**
  String get budgetLimitReached;

  /// No description provided for @budgetNearLimit.
  ///
  /// In fr, this message translates to:
  /// **'Attention, vous approchez de la limite de votre budget.'**
  String get budgetNearLimit;

  /// No description provided for @categoryInvalidNamePercent.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou pourcentage invalide'**
  String get categoryInvalidNamePercent;

  /// No description provided for @categoryInvalidInput.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom valide et un pourcentage supérieur à 0'**
  String get categoryInvalidInput;

  /// No description provided for @categoryDeleteHasTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer une catégorie avec des transactions'**
  String get categoryDeleteHasTransactions;

  /// No description provided for @pdfMonthlyIncome.
  ///
  /// In fr, this message translates to:
  /// **'Revenus mensuels:'**
  String get pdfMonthlyIncome;

  /// No description provided for @pdfRemainingBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde restant:'**
  String get pdfRemainingBalance;

  /// No description provided for @pdfTotalExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Total des dépenses:'**
  String get pdfTotalExpenses;

  /// No description provided for @pdfIncomeSpentPercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% de vos revenus dépensés'**
  String pdfIncomeSpentPercent(String percent);

  /// No description provided for @pdfAdviceTitle.
  ///
  /// In fr, this message translates to:
  /// **'CONSEILS SMARTSPEND'**
  String get pdfAdviceTitle;

  /// No description provided for @pdfPersonalReport.
  ///
  /// In fr, this message translates to:
  /// **'Rapport financier personnel de {name}'**
  String pdfPersonalReport(String name);

  /// No description provided for @pdfShareText.
  ///
  /// In fr, this message translates to:
  /// **'Rapport financier SmartSpend de {name} - {month}'**
  String pdfShareText(String name, String month);

  /// No description provided for @pdfForUser.
  ///
  /// In fr, this message translates to:
  /// **'Pour {name}'**
  String pdfForUser(String name);

  /// No description provided for @pdfAdviceOverBudget.
  ///
  /// In fr, this message translates to:
  /// **'{name}, attention ! Vous avez dépassé votre budget ce mois-ci. Essayez de réduire vos dépenses le mois prochain.'**
  String pdfAdviceOverBudget(String name);

  /// No description provided for @pdfAdviceGreatSaving.
  ///
  /// In fr, this message translates to:
  /// **'Excellent travail, {name} ! Vous avez économisé plus de 30% de vos revenus ce mois-ci.'**
  String pdfAdviceGreatSaving(String name);

  /// No description provided for @pdfAdviceOnTrack.
  ///
  /// In fr, this message translates to:
  /// **'{name}, vous êtes dans les clous avec {amount} {currency} restants ce mois-ci.'**
  String pdfAdviceOnTrack(String name, String amount, String currency);

  /// No description provided for @pdfAdviceCategoryHigh.
  ///
  /// In fr, this message translates to:
  /// **'{name}, la catégorie \"{category}\" représente une part importante ({percent}%) de vos dépenses. Pensez à diversifier.'**
  String pdfAdviceCategoryHigh(String name, String category, String percent);

  /// No description provided for @pdfAdviceSavingsLow.
  ///
  /// In fr, this message translates to:
  /// **'{name}, votre épargne est inférieure à 10% de vos revenus. Essayez d\'augmenter cette part progressivement.'**
  String pdfAdviceSavingsLow(String name);

  /// No description provided for @pdfAdviceBalanced.
  ///
  /// In fr, this message translates to:
  /// **'{name}, votre gestion financière est équilibrée ce mois-ci. Continuez ainsi !'**
  String pdfAdviceBalanced(String name);

  /// No description provided for @csvHeaderFull.
  ///
  /// In fr, this message translates to:
  /// **'Date,Catégorie,Description,Montant ({currency})'**
  String csvHeaderFull(String currency);

  /// No description provided for @premiumPurchasing.
  ///
  /// In fr, this message translates to:
  /// **'Lancement de l\'achat...'**
  String get premiumPurchasing;

  /// No description provided for @premiumRestoring.
  ///
  /// In fr, this message translates to:
  /// **'Restauration des achats...'**
  String get premiumRestoring;

  /// No description provided for @premiumRestoreButton.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get premiumRestoreButton;

  /// No description provided for @premiumBestBadge.
  ///
  /// In fr, this message translates to:
  /// **'MEILLEUR'**
  String get premiumBestBadge;

  /// No description provided for @laterButton.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get laterButton;

  /// No description provided for @premiumWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue Premium !'**
  String get premiumWelcome;

  /// No description provided for @premiumCongratulationsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium de SmartSpend.'**
  String get premiumCongratulationsMessage;

  /// No description provided for @premiumEnjoyFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Profitez de toutes les fonctionnalités sans limite !'**
  String get premiumEnjoyFeatures;

  /// No description provided for @goalsSavingSuggestion.
  ///
  /// In fr, this message translates to:
  /// **'Suggestion d\'épargne'**
  String get goalsSavingSuggestion;

  /// No description provided for @goalsSavingSuggestionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Votre objectif \"{name}\" arrive bientôt à échéance !'**
  String goalsSavingSuggestionDesc(String name);

  /// No description provided for @goalsProgressLabel2.
  ///
  /// In fr, this message translates to:
  /// **'Progression: {percent}%'**
  String goalsProgressLabel2(String percent);

  /// No description provided for @goalsRemainingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Restant: {amount} {currency}'**
  String goalsRemainingLabel(String amount, String currency);

  /// No description provided for @goalsDeadlineDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance: {date}'**
  String goalsDeadlineDate(String date);

  /// No description provided for @goalsSavingPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous épargner {amount} {currency} pour cet objectif ?'**
  String goalsSavingPrompt(String amount, String currency);

  /// No description provided for @goalsSaveNowButton.
  ///
  /// In fr, this message translates to:
  /// **'Épargner'**
  String get goalsSaveNowButton;

  /// No description provided for @createCategoryFirst.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez d\'abord créer une catégorie.'**
  String get createCategoryFirst;

  /// No description provided for @transactionAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une transaction'**
  String get transactionAddTitle;

  /// No description provided for @defineIncomeFirst.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez d\'abord définir vos revenus.'**
  String get defineIncomeFirst;

  /// No description provided for @categoryBudgetExceeded.
  ///
  /// In fr, this message translates to:
  /// **'Le montant dépasse le budget restant disponible !'**
  String get categoryBudgetExceeded;

  /// No description provided for @categoryNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Catégorie'**
  String get categoryNewTitle;

  /// No description provided for @categoryEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la Catégorie'**
  String get categoryEditTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get categoryNameLabel;

  /// No description provided for @settingsDailyReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels quotidiens'**
  String get settingsDailyReminders;

  /// No description provided for @settingsDailyRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappel du soir pour vos transactions'**
  String get settingsDailyRemindersSubtitle;

  /// No description provided for @settingsGoals.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs financiers'**
  String get settingsGoals;

  /// No description provided for @settingsGoalsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Définir et suivre vos objectifs d\'épargne'**
  String get settingsGoalsSubtitle;

  /// No description provided for @chatbotAccessError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'accès à l\'assistant'**
  String get chatbotAccessError;

  /// No description provided for @pdfExportError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'export PDF'**
  String get pdfExportError;

  /// No description provided for @premiumUpgradeError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à niveau'**
  String get premiumUpgradeError;

  /// No description provided for @budgetRemainingBudget.
  ///
  /// In fr, this message translates to:
  /// **'Restant:'**
  String get budgetRemainingBudget;

  /// No description provided for @monthFullJan.
  ///
  /// In fr, this message translates to:
  /// **'Janvier'**
  String get monthFullJan;

  /// No description provided for @monthFullFeb.
  ///
  /// In fr, this message translates to:
  /// **'Février'**
  String get monthFullFeb;

  /// No description provided for @monthFullMar.
  ///
  /// In fr, this message translates to:
  /// **'Mars'**
  String get monthFullMar;

  /// No description provided for @monthFullApr.
  ///
  /// In fr, this message translates to:
  /// **'Avril'**
  String get monthFullApr;

  /// No description provided for @monthFullMay.
  ///
  /// In fr, this message translates to:
  /// **'Mai'**
  String get monthFullMay;

  /// No description provided for @monthFullJun.
  ///
  /// In fr, this message translates to:
  /// **'Juin'**
  String get monthFullJun;

  /// No description provided for @monthFullJul.
  ///
  /// In fr, this message translates to:
  /// **'Juillet'**
  String get monthFullJul;

  /// No description provided for @monthFullAug.
  ///
  /// In fr, this message translates to:
  /// **'Août'**
  String get monthFullAug;

  /// No description provided for @monthFullSep.
  ///
  /// In fr, this message translates to:
  /// **'Septembre'**
  String get monthFullSep;

  /// No description provided for @monthFullOct.
  ///
  /// In fr, this message translates to:
  /// **'Octobre'**
  String get monthFullOct;

  /// No description provided for @monthFullNov.
  ///
  /// In fr, this message translates to:
  /// **'Novembre'**
  String get monthFullNov;

  /// No description provided for @monthFullDec.
  ///
  /// In fr, this message translates to:
  /// **'Décembre'**
  String get monthFullDec;

  /// No description provided for @notifPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission de notification refusée. Activez-la dans les paramètres.'**
  String get notifPermissionDenied;

  /// No description provided for @notifSystemDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications sont désactivées dans les paramètres Android'**
  String get notifSystemDisabled;

  /// No description provided for @notifBatteryOptimization.
  ///
  /// In fr, this message translates to:
  /// **'Pour des rappels fiables, désactivez l\'optimisation de batterie pour SmartSpend'**
  String get notifBatteryOptimization;

  /// No description provided for @notifActivated.
  ///
  /// In fr, this message translates to:
  /// **'✅ Rappels activés !\nMatin (8h30) et Soir (20h00)'**
  String get notifActivated;

  /// No description provided for @notifTestLaunched.
  ///
  /// In fr, this message translates to:
  /// **'Tests lancés :\n• Notification immédiate\n• Notification dans 3 secondes'**
  String get notifTestLaunched;

  /// No description provided for @notifSystemNotEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications ne sont pas activées au niveau système'**
  String get notifSystemNotEnabled;

  /// No description provided for @notifTestError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur test notification: {error}'**
  String notifTestError(String error);

  /// No description provided for @newMonthDetails.
  ///
  /// In fr, this message translates to:
  /// **'• Vos catégories seront conservées\n• Les dépenses seront archivées\n• Vous pourrez entrer vos nouveaux revenus'**
  String get newMonthDetails;

  /// No description provided for @closeMonthButton.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer le mois'**
  String get closeMonthButton;

  /// No description provided for @monthClosedWithCarryOver.
  ///
  /// In fr, this message translates to:
  /// **'✅ Mois clôturé ! {amount} reporté. Ajoutez vos revenus.'**
  String monthClosedWithCarryOver(String amount);

  /// No description provided for @monthClosedEnterIncome.
  ///
  /// In fr, this message translates to:
  /// **'✅ Mois clôturé ! Entrez vos revenus pour ce mois.'**
  String get monthClosedEnterIncome;

  /// No description provided for @monthCloseError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la clôture du mois'**
  String get monthCloseError;

  /// No description provided for @transactionAddError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'ajout de la transaction'**
  String get transactionAddError;

  /// No description provided for @transactionEditError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la modification de la transaction'**
  String get transactionEditError;

  /// No description provided for @transactionDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression de la transaction'**
  String get transactionDeleteError;

  /// No description provided for @syncComplete.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation terminée'**
  String get syncComplete;

  /// No description provided for @syncError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchronisation'**
  String get syncError;

  /// No description provided for @dataDeletedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les données ont été supprimées'**
  String get dataDeletedSuccess;

  /// No description provided for @categoryPercentExceeded.
  ///
  /// In fr, this message translates to:
  /// **'Le total des pourcentages ne peut pas dépasser 100%. Disponible: {percent}%'**
  String categoryPercentExceeded(String percent);

  /// No description provided for @categoryServerEditError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la modification sur le serveur'**
  String get categoryServerEditError;

  /// No description provided for @categoryServerDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression sur le serveur'**
  String get categoryServerDeleteError;

  /// No description provided for @pdfFinancialStatement.
  ///
  /// In fr, this message translates to:
  /// **'Relevé Financier de : {month}'**
  String pdfFinancialStatement(String month);

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In fr, this message translates to:
  /// **'Généré le {date}'**
  String pdfGeneratedOn(String date);

  /// No description provided for @pdfFinancialOverview.
  ///
  /// In fr, this message translates to:
  /// **'SITUATION FINANCIÈRE'**
  String get pdfFinancialOverview;

  /// No description provided for @pdfSmartSpendFooter.
  ///
  /// In fr, this message translates to:
  /// **'SmartSpend - Gestion financière intelligente'**
  String get pdfSmartSpendFooter;

  /// No description provided for @pdfTableDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get pdfTableDate;

  /// No description provided for @pdfTableCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get pdfTableCategory;

  /// No description provided for @pdfTableDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get pdfTableDescription;

  /// No description provided for @pdfTableAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant ({currency})'**
  String pdfTableAmount(String currency);

  /// No description provided for @pdfCategoryTableCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get pdfCategoryTableCategory;

  /// No description provided for @pdfCategoryTableAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get pdfCategoryTableAmount;

  /// No description provided for @pdfCategoryTableBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get pdfCategoryTableBudget;

  /// No description provided for @pdfCategoryTableDiff.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get pdfCategoryTableDiff;

  /// No description provided for @premiumUnlimitedPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exports PDF illimités'**
  String get premiumUnlimitedPdf;

  /// No description provided for @premiumAnnual.
  ///
  /// In fr, this message translates to:
  /// **'Annuel'**
  String get premiumAnnual;

  /// No description provided for @premiumProductUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Produit non disponible. Réessayez plus tard.'**
  String get premiumProductUnavailable;

  /// No description provided for @pdfLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Limite atteinte'**
  String get pdfLimitReached;

  /// No description provided for @pdfLimitMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez utilisé vos 3 exports PDF gratuits.'**
  String get pdfLimitMessage;

  /// No description provided for @pdfLimitUpgrade.
  ///
  /// In fr, this message translates to:
  /// **'Passez à Premium pour des exports illimités et un accès complet à l\'assistant financier.'**
  String get pdfLimitUpgrade;

  /// No description provided for @pdfLastFreeExport.
  ///
  /// In fr, this message translates to:
  /// **'C\'était votre dernier export PDF gratuit.'**
  String get pdfLastFreeExport;

  /// No description provided for @viewPremiumButton.
  ///
  /// In fr, this message translates to:
  /// **'Voir Premium'**
  String get viewPremiumButton;

  /// No description provided for @startButton.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get startButton;

  /// No description provided for @goalsKeepGoingMessage.
  ///
  /// In fr, this message translates to:
  /// **'Continuez sur cette lancée pour atteindre tous vos objectifs financiers !'**
  String get goalsKeepGoingMessage;

  /// No description provided for @goalsSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Épargner'**
  String get goalsSaveButton;

  /// No description provided for @premiumRequired.
  ///
  /// In fr, this message translates to:
  /// **'Premium requis'**
  String get premiumRequired;

  /// No description provided for @premiumRemainingTrials.
  ///
  /// In fr, this message translates to:
  /// **'Il vous reste {count} essais gratuits pour {feature}'**
  String premiumRemainingTrials(int count, String feature);

  /// No description provided for @premiumTrialsExhausted.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez épuisé vos essais gratuits pour {feature}'**
  String premiumTrialsExhausted(String feature);

  /// No description provided for @premiumUpgradeTo.
  ///
  /// In fr, this message translates to:
  /// **'Passez à SmartSpend Premium pour :'**
  String get premiumUpgradeTo;

  /// No description provided for @premiumFeaturePdf.
  ///
  /// In fr, this message translates to:
  /// **'✨ Exports PDF illimités'**
  String get premiumFeaturePdf;

  /// No description provided for @premiumFeatureAI.
  ///
  /// In fr, this message translates to:
  /// **'🤖 Assistant financier illimité'**
  String get premiumFeatureAI;

  /// No description provided for @premiumFeatureAnalytics.
  ///
  /// In fr, this message translates to:
  /// **'📊 Analyses avancées'**
  String get premiumFeatureAnalytics;

  /// No description provided for @premiumFeatureCloud.
  ///
  /// In fr, this message translates to:
  /// **'☁️ Synchronisation cloud prioritaire'**
  String get premiumFeatureCloud;

  /// No description provided for @premiumFeatureGoals.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Objectifs financiers avancés'**
  String get premiumFeatureGoals;

  /// No description provided for @premiumFeatureSupport.
  ///
  /// In fr, this message translates to:
  /// **'📱 Support prioritaire'**
  String get premiumFeatureSupport;

  /// No description provided for @premiumTryFree.
  ///
  /// In fr, this message translates to:
  /// **'Essayer gratuitement'**
  String get premiumTryFree;

  /// No description provided for @premiumUpgradeButton.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Premium'**
  String get premiumUpgradeButton;

  /// No description provided for @premiumChooseSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Choisir votre abonnement'**
  String get premiumChooseSubscription;

  /// No description provided for @premiumSaveBadge.
  ///
  /// In fr, this message translates to:
  /// **'ÉCONOMISEZ'**
  String get premiumSaveBadge;

  /// No description provided for @premiumPurchasesRestoredSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Achats restaurés avec succès !'**
  String get premiumPurchasesRestoredSuccess;

  /// No description provided for @premiumNoPurchaseToRestore.
  ///
  /// In fr, this message translates to:
  /// **'Aucun achat à restaurer'**
  String get premiumNoPurchaseToRestore;

  /// No description provided for @premiumProcessingPurchase.
  ///
  /// In fr, this message translates to:
  /// **'Traitement de votre achat...'**
  String get premiumProcessingPurchase;

  /// No description provided for @premiumPurchaseErrorDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'achat: {error}'**
  String premiumPurchaseErrorDetail(String error);

  /// No description provided for @premiumWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue Premium !'**
  String get premiumWelcomeTitle;

  /// No description provided for @premiumCongratulationsDetail.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium de SmartSpend.'**
  String get premiumCongratulationsDetail;

  /// No description provided for @premiumEnjoyNoLimits.
  ///
  /// In fr, this message translates to:
  /// **'Profitez de toutes les fonctionnalités sans limite !'**
  String get premiumEnjoyNoLimits;

  /// No description provided for @premiumProductLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement des produits. Veuillez réessayer.'**
  String get premiumProductLoadError;

  /// No description provided for @premiumUpgradeErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à niveau Premium'**
  String get premiumUpgradeErrorGeneric;

  /// No description provided for @exportCsv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get exportCsv;

  /// No description provided for @exportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get exportPdf;

  /// No description provided for @exportOptions.
  ///
  /// In fr, this message translates to:
  /// **'Options d\'export'**
  String get exportOptions;

  /// No description provided for @exportSuccessNoMore.
  ///
  /// In fr, this message translates to:
  /// **'🎉 Export réussi ! Plus d\'essais gratuits disponibles.'**
  String get exportSuccessNoMore;

  /// No description provided for @exportSuccessRemaining.
  ///
  /// In fr, this message translates to:
  /// **'🎉 Export réussi ! {count} essais restants.'**
  String exportSuccessRemaining(int count);

  /// No description provided for @pdfExportLabel.
  ///
  /// In fr, this message translates to:
  /// **'l\'export PDF'**
  String get pdfExportLabel;

  /// No description provided for @pdfExportErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'export PDF'**
  String get pdfExportErrorGeneric;

  /// No description provided for @drawerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre assistant financier personnel'**
  String get drawerSubtitle;

  /// No description provided for @drawerNotifications.
  ///
  /// In fr, this message translates to:
  /// **'NOTIFICATIONS'**
  String get drawerNotifications;

  /// No description provided for @drawerManagement.
  ///
  /// In fr, this message translates to:
  /// **'GESTION'**
  String get drawerManagement;

  /// No description provided for @drawerFinancialAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant financier'**
  String get drawerFinancialAssistant;

  /// No description provided for @drawerFinancialAssistantSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Obtenez des conseils personnalisés'**
  String get drawerFinancialAssistantSubtitle;

  /// No description provided for @drawerFinancialAssistantLabel.
  ///
  /// In fr, this message translates to:
  /// **'l\'assistant financier'**
  String get drawerFinancialAssistantLabel;

  /// No description provided for @drawerAccessError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'accès à l\'assistant'**
  String get drawerAccessError;

  /// No description provided for @drawerMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get drawerMyProfile;

  /// No description provided for @drawerMyProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos informations de compte'**
  String get drawerMyProfileSubtitle;

  /// No description provided for @transactionOptions.
  ///
  /// In fr, this message translates to:
  /// **'Options de la transaction'**
  String get transactionOptions;

  /// No description provided for @editTransactionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la transaction'**
  String get editTransactionTitle;

  /// No description provided for @transactionCategoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie: {name}'**
  String transactionCategoryLabel(String name);

  /// No description provided for @percentageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage (%)'**
  String get percentageLabel;

  /// No description provided for @amountCurrencyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant ({currency})'**
  String amountCurrencyLabel(String currency);

  /// No description provided for @switchToAmount.
  ///
  /// In fr, this message translates to:
  /// **'Changer en Montant'**
  String get switchToAmount;

  /// No description provided for @switchToPercent.
  ///
  /// In fr, this message translates to:
  /// **'Changer en Pourcentage'**
  String get switchToPercent;

  /// No description provided for @iconLabel.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get colorLabel;

  /// No description provided for @categoryNameEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le nom ne peut pas être vide.'**
  String get categoryNameEmpty;

  /// No description provided for @budgetTotalAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Budget total dispo.:'**
  String get budgetTotalAvailable;

  /// No description provided for @premiumUpgradeDialogWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue Premium !'**
  String get premiumUpgradeDialogWelcome;

  /// No description provided for @premiumUpgradeDialogCongrats.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium.'**
  String get premiumUpgradeDialogCongrats;

  /// No description provided for @premiumUpgradeDialogFeature.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez maintenant utiliser {feature} sans limite !'**
  String premiumUpgradeDialogFeature(String feature);

  /// No description provided for @premiumUpgradeDialogButton.
  ///
  /// In fr, this message translates to:
  /// **'Parfait !'**
  String get premiumUpgradeDialogButton;

  /// No description provided for @premiumUpgradeDialogError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à niveau'**
  String get premiumUpgradeDialogError;

  /// No description provided for @addTransactionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une transaction'**
  String get addTransactionTitle;

  /// No description provided for @categoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get categoryLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @drawerDailyReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels quotidiens'**
  String get drawerDailyReminders;

  /// No description provided for @drawerDailyRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappel du soir pour vos transactions'**
  String get drawerDailyRemindersSubtitle;

  /// No description provided for @drawerFinancialGoals.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs financiers'**
  String get drawerFinancialGoals;

  /// No description provided for @drawerFinancialGoalsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Définir et suivre vos objectifs d\'épargne'**
  String get drawerFinancialGoalsSubtitle;

  /// No description provided for @newCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Catégorie'**
  String get newCategoryTitle;

  /// No description provided for @editCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la Catégorie'**
  String get editCategoryTitle;

  /// No description provided for @equivalentAmount.
  ///
  /// In fr, this message translates to:
  /// **'Équivalent: {amount} {currency}'**
  String equivalentAmount(String amount, String currency);

  /// No description provided for @equivalentPercent.
  ///
  /// In fr, this message translates to:
  /// **'Équivalent: {percent}%'**
  String equivalentPercent(String percent);

  /// No description provided for @budgetExceedsRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Le montant dépasse le budget restant disponible !'**
  String get budgetExceedsRemaining;

  /// No description provided for @incomeFirstMessage.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez d\'abord définir votre salaire.'**
  String get incomeFirstMessage;

  /// No description provided for @switchToLabel.
  ///
  /// In fr, this message translates to:
  /// **'Changer en {mode}'**
  String switchToLabel(String mode);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
