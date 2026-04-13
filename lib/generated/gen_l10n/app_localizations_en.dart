// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartSpend';

  @override
  String get filterAll => 'All';

  @override
  String get loginWelcomeTitle => 'Welcome back! 👋';

  @override
  String get loginSubtitle => 'Sign in to manage your finances';

  @override
  String get loginErrorUserNotFound => 'No account found with this email';

  @override
  String get loginErrorWrongPassword => 'Incorrect password';

  @override
  String get loginErrorInvalidEmail => 'Invalid email format';

  @override
  String get loginErrorTooManyAttempts => 'Too many attempts. Try again later';

  @override
  String get loginErrorGeneral => 'An error occurred. Try again';

  @override
  String get loginValidationEmailRequired => 'Please enter your email';

  @override
  String get loginValidationPasswordRequired => 'Please enter your password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginOrDivider => 'or';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Join SmartSpend and take control of your finances';

  @override
  String get registerFieldFullName => 'Full name';

  @override
  String get registerFieldFullNameHint => 'John Doe';

  @override
  String get registerFieldEmail => 'Email';

  @override
  String get registerFieldEmailHint => 'your@email.com';

  @override
  String get registerFieldPassword => 'Password';

  @override
  String get registerFieldPasswordHint => '••••••••';

  @override
  String get registerFieldConfirmPassword => 'Confirm password';

  @override
  String get registerValidationPasswordMinLength => 'Minimum 6 characters';

  @override
  String get registerValidationNameRequired => 'Please enter your name';

  @override
  String get registerValidationNameTooShort => 'Name too short';

  @override
  String get registerValidationPasswordRequired => 'Please enter a password';

  @override
  String get registerValidationPasswordMismatch => 'Passwords do not match';

  @override
  String get registerValidationTermsRequired => 'Please accept the terms of use';

  @override
  String get registerValidationTerms => 'Please accept the terms of use';

  @override
  String get termsPrefix => 'I accept the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get termsMiddle => ' and the ';

  @override
  String get privacyPolicy => 'privacy policy';

  @override
  String get registerValidationEmailRequired => 'Please enter your email';

  @override
  String get registerValidationInvalidEmail => 'Invalid email format';

  @override
  String get registerValidationPasswordTooShort => 'Minimum 6 characters';

  @override
  String get registerErrorGeneral => 'An error occurred. Please try again.';

  @override
  String get registerErrorGoogle => 'Google sign-in error';

  @override
  String get registerButtonSubmit => 'Create my account';

  @override
  String get registerExistingAccount => 'Already have an account?';

  @override
  String get registerErrorEmailInUse => 'This email address is already in use';

  @override
  String get registerErrorGoogleSignIn => 'Google sign-in error';

  @override
  String get registerPrivacyPolicy => 'privacy policy';

  @override
  String get registerTermsOfUse => 'terms of use';

  @override
  String get registerAgreeTerms => 'I agree to the';

  @override
  String get registerAndThe => 'and the';

  @override
  String get emailVerificationTitle => 'Verify your email';

  @override
  String get emailVerificationSuccess => 'Email verified! 🎉';

  @override
  String get emailVerificationSuccessMessage => 'Your account is now activated. Redirecting...';

  @override
  String get emailVerificationSentMessage => 'We sent a verification email to:';

  @override
  String get emailVerificationErrorSending => 'Error sending verification email';

  @override
  String get emailVerificationSendError => 'Error sending verification email';

  @override
  String get emailVerificationInstructions => 'Click the verification link';

  @override
  String get emailVerificationResend => 'Resend email';

  @override
  String emailVerificationResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get emailVerificationCheckSpam => 'Also check your spam folder';

  @override
  String get emailVerificationChangeEmail => 'Change email';

  @override
  String get emailVerificationStep1 => '1. Open your email';

  @override
  String get emailVerificationStep3 => '3. Come back to the app';

  @override
  String get forgotPasswordTitle => 'Forgot password?';

  @override
  String get forgotPasswordEmailSent => 'Email sent!';

  @override
  String get forgotPasswordDescription => 'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordSuccessDescription => 'Check your inbox and follow the instructions to reset your password.';

  @override
  String get forgotPasswordCheckInbox => 'Check your inbox and follow the instructions to reset your password.';

  @override
  String get forgotPasswordError => 'An error occurred. Check your email address.';

  @override
  String get forgotPasswordSendButton => 'Send link';

  @override
  String get forgotPasswordBackToLogin => 'Back to login';

  @override
  String get forgotPasswordResendEmail => 'Resend email';

  @override
  String get forgotPasswordResend => 'Resend';

  @override
  String get forgotPasswordEmailRequired => 'Please enter your email';

  @override
  String get forgotPasswordInvalidEmail => 'Invalid email format';

  @override
  String get forgotPasswordRemember => 'Remember?';

  @override
  String get forgotPasswordSignIn => 'Sign in';

  @override
  String get pinSetupTitle => 'Create your PIN code';

  @override
  String get pinSetupConfirmTitle => 'Confirm your code';

  @override
  String get pinSetupDescription => 'This code will protect access to your data';

  @override
  String get pinSetupConfirmDescription => 'Enter your 4-digit code again';

  @override
  String get pinSetupErrorMismatch => 'Codes do not match';

  @override
  String get pinSetupRestart => 'Restart';

  @override
  String get pinLockBiometricPrompt => 'Unlock SmartSpend with your fingerprint';

  @override
  String pinLockErrorIncorrect(int attemptsRemaining) {
    return 'Incorrect code ($attemptsRemaining attempts remaining)';
  }

  @override
  String pinLockErrorLocked(int seconds) {
    return 'Try again in $seconds seconds';
  }

  @override
  String get pinLockBiometricButton => 'Biometrics';

  @override
  String get pinLockLogoutButton => 'Logout';

  @override
  String get pinLockTooManyAttempts => 'Too many attempts';

  @override
  String get pinLockEnterCode => 'Enter your PIN code';

  @override
  String get navBudget => 'Budget';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get quickActionTransaction => 'Transaction';

  @override
  String get quickActionGoal => 'Goal';

  @override
  String get quickActionAssistant => 'Assistant';

  @override
  String get budgetHeaderTitle => 'Overview';

  @override
  String get budgetSetButtonLabel => 'Set';

  @override
  String get budgetUsedLabel => 'used';

  @override
  String get budgetSpentLabel => 'Spent';

  @override
  String get budgetCategoriesSection => 'Categories';

  @override
  String get budgetRecentTransactions => 'Recent Transactions';

  @override
  String get greetingMorning => 'Good morning ☀️';

  @override
  String get greetingAfternoon => 'Good afternoon ☀️';

  @override
  String get greetingEvening => 'Good evening 🌙';

  @override
  String get budgetManageTitle => 'Manage Budget';

  @override
  String get budgetSetTitle => 'Set Budget';

  @override
  String get budgetNotSet => 'No budget set';

  @override
  String get budgetSupplementaryIncome => 'For supplementary income';

  @override
  String get budgetSupplementaryIncomeDescription => 'Add supplementary income to your current budget';

  @override
  String get budgetSupplementaryAmountLabel => 'Amount to add';

  @override
  String get budgetNewCategoryTitle => 'New Category';

  @override
  String get budgetCategoryNameLabel => 'Category name';

  @override
  String get budgetAllocatedAmountLabel => 'Allocated amount';

  @override
  String budgetEquivalentLabel(String amount) {
    return 'Equivalent: $amount';
  }

  @override
  String get budgetIconLabel => 'Icon';

  @override
  String get budgetAddCategoryButton => 'Add category';

  @override
  String get budgetEditCategoryTitle => 'Edit category';

  @override
  String get budgetRemainingLabel => 'Remaining';

  @override
  String get budgetAvailableLabel => 'Available';

  @override
  String get budgetOf => 'of';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsSearchHint => 'Search for a transaction...';

  @override
  String get transactionsSummaryThisMonth => 'This month';

  @override
  String get transactionsSummaryCount => 'Transactions';

  @override
  String get transactionsSummaryAveragePerDay => 'Average/day';

  @override
  String get transactionsEmptyState => 'Your transactions will appear here';

  @override
  String get transactionsEmptyDescription => 'Add your first transaction to start tracking your expenses';

  @override
  String get transactionNewTitle => 'New transaction';

  @override
  String get transactionFieldCategory => 'Category';

  @override
  String get transactionFieldDescription => 'Description';

  @override
  String get transactionFieldDescriptionOptional => 'Description (optional)';

  @override
  String get transactionFieldDescriptionHint => 'E.g: Weekend groceries';

  @override
  String get transactionEditTitle => 'Edit transaction';

  @override
  String get transactionFieldDate => 'Date';

  @override
  String get transactionModified => 'Transaction modified';

  @override
  String get saveButton => 'Save';

  @override
  String get transactionFieldAmount => 'Amount';

  @override
  String get addButton => 'Add';

  @override
  String get transactionWarningIrreversible => 'This action is irreversible.';

  @override
  String get transactionModifiedSuccess => 'Transaction modified';

  @override
  String get transactionDeletedSuccess => 'Transaction deleted';

  @override
  String get transactionAddedSuccess => 'Transaction added successfully';

  @override
  String get transactionDeleteConfirm => 'Delete this transaction?';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categorySavings => 'Savings';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryUtilities => 'Electricity/Water';

  @override
  String get categoryInternet => 'Internet';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryOther => 'Other';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsSubtitle => 'Analyze your spending';

  @override
  String get reportsPeriodThisMonth => 'This month';

  @override
  String get reportsPeriod3Months => '3 months';

  @override
  String get reportsPeriod6Months => '6 months';

  @override
  String get reportsPeriod1Year => '1 year';

  @override
  String get reportsSpendingDistribution => 'Spending Distribution';

  @override
  String get reportsTotalSpent => 'Total Spent';

  @override
  String get reportsNoData => 'No data';

  @override
  String get reportsNoDataDescription => 'Add transactions to see your reports';

  @override
  String get reportsSpent => 'Spent';

  @override
  String get reportsSavings => 'Savings';

  @override
  String get reportsBudgetVsSpending => 'Budget vs Spending';

  @override
  String get reportsCategoryDetails => 'Category Details';

  @override
  String get reportsExportPDF => 'Export to PDF';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Customize your experience';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsChangePINTitle => 'Change PIN code';

  @override
  String get settingsChangePINSubtitle => 'Change your security code';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExportData => 'Export data';

  @override
  String get settingsExportDataSubtitle => 'Download your data as PDF';

  @override
  String get settingsMonthlyHistory => 'Monthly history';

  @override
  String get settingsMonthlyHistorySubtitle => 'View your closed months history';

  @override
  String get settingsResetData => 'Reset data';

  @override
  String get settingsResetDataSubtitle => 'Delete all your data';

  @override
  String get settingsPinProtection => 'Protect app access';

  @override
  String get settingsPinEnabledSuccess => 'PIN code enabled successfully';

  @override
  String get settingsDisablePinConfirm => 'Disable PIN code?';

  @override
  String get settingsDisablePinWarning => 'Your app will no longer be protected by a security code.';

  @override
  String get settingsPinDisabledSuccess => 'PIN disabled';

  @override
  String get settingsDisableButton => 'Disable';

  @override
  String get settingsPinChangedSuccess => 'PIN changed successfully';

  @override
  String get settingsPremium => 'Upgrade to Premium';

  @override
  String get settingsPremiumDescription => 'Unlock all features: unlimited PDF exports, unlimited AI assistant, and more.';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsNoClosedMonths => 'No closed months';

  @override
  String get settingsResetConfirm => 'Reset data?';

  @override
  String get settingsResetWarning => 'All your data will be deleted. This action is irreversible.';

  @override
  String get settingsResetSuccess => 'Data reset';

  @override
  String get settingsResetButton => 'Reset';

  @override
  String get settingsLogoutConfirm => 'Logout?';

  @override
  String get settingsLogoutWarning => 'Your data is backed up in the cloud.';

  @override
  String get settingsLogoutButton => 'Logout';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsLightMode => 'Light';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Manage reminders and alerts';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get user => 'User';

  @override
  String get freeVersion => 'Free';

  @override
  String get transactionRemindersTitle => 'Transaction reminders';

  @override
  String get transactionRemindersSubtitle => 'Receive reminders morning, noon and evening';

  @override
  String get pinCode => 'PIN Code';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get seeOffers => 'See offers';

  @override
  String get incomes => 'Income';

  @override
  String get transactions => 'transactions';

  @override
  String get goalsScreenTitle => 'Financial Goals';

  @override
  String get goalsEmptyTitle => 'No goals defined';

  @override
  String get goalsEmptyDescription => 'Create your first financial goal to start saving with a clear target!';

  @override
  String get goalsCreateButton => 'Create goal';

  @override
  String get goalsAddMoney => 'Add money';

  @override
  String get goalsMarkComplete => 'Mark as complete';

  @override
  String get goalsEditButton => 'Edit';

  @override
  String get goalsDeleteButton => 'Delete';

  @override
  String get goalsProgressLabel => 'Progress';

  @override
  String get goalsDeadlineLabel => 'Deadline';

  @override
  String get goalsTargetLabel => 'Target';

  @override
  String get goalsCurrentLabel => 'Current';

  @override
  String get goalsNewTitle => 'New goal';

  @override
  String get goalsEditTitle => 'Edit goal';

  @override
  String get goalsNameLabel => 'Goal name';

  @override
  String get goalsAmountLabel => 'Target amount';

  @override
  String get goalsDescriptionLabel => 'Description (optional)';

  @override
  String get goalsDeadlineDateLabel => 'Deadline';

  @override
  String get goalsIconLabel => 'Icon';

  @override
  String get goalsColorLabel => 'Color';

  @override
  String get goalsCreateButtonLabel => 'Create';

  @override
  String get goalsSaveButtonLabel => 'Save';

  @override
  String get goalsDeleteConfirm => 'Delete this goal?';

  @override
  String get goalsAchieved => 'Goal achieved! 🎉';

  @override
  String get notificationPermissionDenied => 'Notification permission denied. Enable it in settings.';

  @override
  String get notificationDisabledAndroid => 'Notifications are disabled in Android settings';

  @override
  String get notificationBatteryOptimization => 'For reliable reminders, disable battery optimization for SmartSpend';

  @override
  String get notificationReminderDisabled => 'Reminders disabled';

  @override
  String notificationDisableError(String error) {
    return 'Error disabling reminders: $error';
  }

  @override
  String get notificationSystemDisabled => 'Notifications are not enabled at system level';

  @override
  String get notificationTestStarted => 'Tests started: • Immediate notification • Notification in 3 seconds';

  @override
  String get newMonthTitle => '🎉 New month!';

  @override
  String newMonthWelcome(String month, String year) {
    return 'Welcome to $month $year!';
  }

  @override
  String newMonthCloseQuestion(String month) {
    return 'Would you like to close $month and start the new month?';
  }

  @override
  String get newMonthInfo => '• Your categories will be kept\n• Expenses will be archived\n• You can enter your new income';

  @override
  String newMonthRemainingBudget(String amount) {
    return 'Remaining budget: $amount';
  }

  @override
  String get newMonthCarryOver => 'Carry over this amount to next month';

  @override
  String get newMonthLater => 'Later';

  @override
  String get newMonthCloseButton => 'Close month';

  @override
  String newMonthClosedSuccess(String amount) {
    return 'Month closed! $amount carried over. Add your income.';
  }

  @override
  String get newMonthClosedNoCarryOver => 'Month closed! Enter your income for this month.';

  @override
  String get newMonthCloseError => 'Error closing month';

  @override
  String chatbotGreeting(String userName) {
    return '👋 Hello and welcome, $userName!';
  }

  @override
  String get chatbotThinking => 'SmartBot is thinking...';

  @override
  String get chatbotInputHint => 'Ask your financial question...';

  @override
  String get chatbotConnectionError => '⚠️ Connection temporarily unavailable. Try a question from the suggestions below.';

  @override
  String get chatbotLastFreeUse => 'This was your last free assistant use.';

  @override
  String chatbotFreeUsesRemaining(int count) {
    return '$count free uses remaining';
  }

  @override
  String get chatbotSuggestions => '💡 Suggestions';

  @override
  String get faqAddTransaction => '📱 How to add a transaction?';

  @override
  String get faqCreateBudget => '🎯 How to create a budget?';

  @override
  String get faqViewStats => '📊 How to view my statistics?';

  @override
  String get faqSaveEffectively => '💰 How to save effectively?';

  @override
  String get faqReduceSpending => '✂️ How to reduce spending?';

  @override
  String get faqBeginnerInvesting => '📊 Beginner investing tips?';

  @override
  String get faqManageDebt => '💳 How to manage my debt?';

  @override
  String get faqCreateGoal => '🎯 How to create a goal?';

  @override
  String get faqAddTransactionAnswer => '📝 Add a transaction:\n\n1. Open the \'Transactions\' tab\n2. Tap the \'+\' button\n3. Enter the amount, choose the category and add a description\n4. Confirm to save\n\n💡 Tip: Add your transactions immediately for accurate tracking!';

  @override
  String get faqCreateBudgetAnswer => '🎯 Create an effective budget:\n\n1. Go to the \'Budget\' tab\n2. Click \'+\' to add a new budget\n3. Set the maximum amount per category\n4. Enable alerts to stay within limits\n\n💰 Tip: Follow the 50/30/20 rule (needs/wants/savings)';

  @override
  String get faqViewStatsAnswer => '📊 Analyze your finances:\n\nThe \'Statistics\' tab offers:\n• Spending charts by category\n• Monthly evolution of your finances\n• Periodic comparisons\n• Consumption trends\n\n🔍 Use this data to identify your habits and optimize your budget!';

  @override
  String get faqSaveEffectivelyAnswer => '💰 Proven saving strategies:\n\n🎯 52-week method: Save \$1 week 1, \$2 week 2...\n🏦 Automatic savings: 10-20% of each income\n📱 Use SmartSpend to track your progress\n⚡ Reduce non-essential subscriptions\n\nGoal: First build an emergency fund (3-6 months of expenses)!';

  @override
  String get faqReduceSpendingAnswer => '✂️ Spending optimization:\n\n🔍 Analyze your SmartSpend statistics:\n• Identify the most expensive categories\n• Spot recurring expenses\n• Find budget \'leaks\'\n\n💡 Concrete actions:\n• Compare prices before buying\n• Cook more at home\n• Renegotiate contracts (insurance, phone)\n• Choose second-hand when possible';

  @override
  String get faqBeginnerInvestingAnswer => '🚀 Getting started with investing:\n\n⚠️ Essential prerequisites:\n✓ Emergency fund saved (3-6 months)\n✓ Debts paid off (except mortgage)\n✓ Budget managed with SmartSpend\n\n📈 First steps:\n• Start small (\$50-100/month)\n• Diversify your investments\n• Focus on long-term\n• Learn before investing\n\n🏦 Options: Savings accounts, index funds, retirement accounts';

  @override
  String get faqManageDebtAnswer => '💳 Repayment strategy:\n\n🎯 \'Snowball\' method:\n1. List all your debts\n2. Pay minimums everywhere\n3. Attack the smallest debt first\n4. Once paid, move to the next\n\n📊 Use SmartSpend to track your repayments and celebrate your progress!\n\n⚡ Negotiate with your creditors if necessary.';

  @override
  String get faqCreateGoalAnswer => '🎯 Create a financial goal:\n\n1. Go to the \'Goals\' tab\n2. Tap \'+\' to add a new goal\n3. Enter the name, description (optional), target amount and deadline\n4. Choose an icon and color to personalize your goal\n5. Confirm by tapping \'Create\'';

  @override
  String get budgetExceededWarning => 'Budget exceeded. Try reducing your expenses.';

  @override
  String get syncCompleted => 'Sync completed';

  @override
  String get dataInitError => 'Error initializing data';

  @override
  String get allDataDeleted => 'All data deleted';

  @override
  String dataDeleteError(String error) {
    return 'Error deleting data';
  }

  @override
  String get categoryAlreadyExists => 'This category already exists';

  @override
  String budgetPercentageError(String percent) {
    return 'Total percentages cannot exceed 100%. Available: $percent%';
  }

  @override
  String get budgetValidationError => 'Please enter a valid name and percentage greater than 0';

  @override
  String get cannotDeleteCategoryWithTransactions => 'Cannot delete a category with transactions';

  @override
  String get noTransactionsToExport => 'No transactions to export';

  @override
  String get csvHeaders => 'Date,Category,Description,Amount';

  @override
  String pdfTitle(String name) {
    return 'Financial Statement for: $name';
  }

  @override
  String pdfGeneratedDate(String date) {
    return 'Generated on $date';
  }

  @override
  String get pdfSituation => 'FINANCIAL SITUATION';

  @override
  String get pdfTotalSpent => 'Total Spent:';

  @override
  String get pdfTransactionDetails => 'TRANSACTION DETAILS';

  @override
  String get pdfCategoryAnalysis => 'CATEGORY ANALYSIS';

  @override
  String get pdfFooter => 'SmartSpend - Smart Financial Management';

  @override
  String get pdfCategoryHeader => 'Category';

  @override
  String get pdfAmountHeader => 'Amount';

  @override
  String get pdfBudgetHeader => 'Budget';

  @override
  String get pdfVarianceHeader => 'Variance';

  @override
  String get goalCreatedSuccess => 'Financial goal created successfully!';

  @override
  String get goalCreationError => 'Error creating goal';

  @override
  String get goalModifiedSuccess => 'Goal modified successfully!';

  @override
  String get goalDeletedSuccess => 'Goal deleted';

  @override
  String get goalAmountAddedSuccess => 'Amount added successfully!';

  @override
  String get savingSuggestionTitle => 'Saving Suggestion';

  @override
  String goalDeadlineApproaching(String goalName) {
    return 'Your goal \"$goalName\" is coming due soon!';
  }

  @override
  String goalDeadlineDate(String date) {
    return 'Due date: $date';
  }

  @override
  String goalSavingSuggestion(String amount) {
    return 'Would you like to save $amount for this goal?';
  }

  @override
  String get goalSaveButton => 'Save';

  @override
  String get goalEncouragement => 'Keep it up to reach all your financial goals!';

  @override
  String get premiumUnlockFeatures => 'Unlock all features:';

  @override
  String get premiumUnlimitedPDF => 'Unlimited PDF exports';

  @override
  String get premiumUnlimitedAI => 'Unlimited AI assistant';

  @override
  String get premiumAdvancedAnalytics => 'Advanced analytics';

  @override
  String get premiumNoAds => 'No ads';

  @override
  String get premiumPurchaseError => 'Purchase error. Try again.';

  @override
  String get premiumProductNotAvailable => 'Product not available. Try again later.';

  @override
  String get premiumPDFLimitReached => 'You\'ve used your 3 free PDF exports.';

  @override
  String get premiumUpgradePrompt => 'Upgrade to Premium for unlimited exports and full financial assistant access.';

  @override
  String get premiumChatbotLimitReached => 'You\'ve used your 3 free AI assistant sessions.';

  @override
  String get premiumLimitReached => 'Limit reached';

  @override
  String get premiumViewButton => 'View Premium';

  @override
  String get closeButton => 'Close';

  @override
  String get premiumLastFreeExport => 'This was your last free PDF export.';

  @override
  String get premiumYearly => 'Yearly';

  @override
  String get premiumMonthly => 'Monthly';

  @override
  String get premiumPerYear => '/ year';

  @override
  String get premiumPerMonth => '/ month';

  @override
  String get premiumBestValue => 'Best value';

  @override
  String get premiumUpgradeTitle => 'Upgrade to Premium 💎';

  @override
  String get premiumRestorePurchases => 'Restore purchases';

  @override
  String get authVerifying => 'Verifying...';

  @override
  String get authInitializingData => 'Initializing your data...';

  @override
  String get authVerifyingSecurity => 'Verifying security...';

  @override
  String get authPreparingExperience => 'Preparing your experience...';

  @override
  String get loadingError => 'Loading error';

  @override
  String get dataLoadingError => 'Unable to load your data';

  @override
  String get retryButton => 'Retry';

  @override
  String get updateRequired => 'Update required';

  @override
  String get updateAvailableMessage => 'A new version of SmartSpend is available with important improvements and bug fixes.';

  @override
  String get updateMandatoryMessage => 'Please update the app to continue using it.';

  @override
  String get updateNowButton => 'Update now';

  @override
  String get updateDataSafeMessage => '💡 Your data is backed up and will be restored after the update.';

  @override
  String get onboardingBudgetTitle => 'Manage your budget';

  @override
  String get onboardingBudgetDescription => 'Set your salary or income and distribute it intelligently among your different spending categories.';

  @override
  String get onboardingTrackingTitle => 'Track your spending';

  @override
  String get onboardingTrackingDescription => 'Record each transaction and visualize in real-time where your money goes with clear charts.';

  @override
  String get onboardingGoalsTitle => 'Achieve your goals';

  @override
  String get onboardingGoalsDescription => 'Create personalized savings goals and track your progress to achieve them.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get syncSuccess => 'Sync successful';

  @override
  String get offlineMode => 'Offline mode - Data not synced';

  @override
  String get syncRetry => 'Retry';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get editButton => 'Edit';

  @override
  String get monthProgress => 'Monthly progress';

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String get noTransaction => 'No transaction';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get calculateBudgetButton => 'Calculate budget';

  @override
  String get budgetAddToBudgetTitle => 'Add to budget';

  @override
  String get budgetAddToBudgetButton => 'Add to budget';

  @override
  String get budgetMonthlyIncomeTitle => 'Your monthly income';

  @override
  String get budgetEnterMonthlyIncome => 'Enter your net monthly salary or income';

  @override
  String get budgetCurrentLabel => 'Current budget';

  @override
  String budgetNewLabel(String amount) {
    return 'New budget: $amount';
  }

  @override
  String get budgetPercentageLabel => 'Percentage';

  @override
  String get budgetAmountLabel => 'Amount';

  @override
  String get budgetBudgetPercentageLabel => 'Percentage of budget';

  @override
  String budgetMaxLabel(String value) {
    return 'Max: $value';
  }

  @override
  String get budgetSaveChanges => 'Save changes';

  @override
  String get budgetOfBudget => 'of budget';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageCode => 'en';

  @override
  String get chatbotSystemPrompt => 'You are SmartBot, SmartSpend\'s premium AI assistant, a personal finance expert and caring financial advisor.';

  @override
  String get chatbotSubtitle => 'Financial advisor';

  @override
  String get chatbotIntro => '🤖 I\'m SmartBot, your intelligent financial advisor and personal assistant for SmartSpend.';

  @override
  String get chatbotCapabilities => '💡 I can help you with:\n• 📊 Personalized financial advice\n• 📱 SmartSpend usage guide\n• 💰 Savings and investment strategies\n• 📈 Analysis of your financial habits';

  @override
  String get chatbotPrompt => '🎯 Let\'s start! Choose a topic below or ask me your question directly.';

  @override
  String get chatbotError => '⚠️ An error occurred. Please try again or choose a suggestion.';

  @override
  String get chatbotTabPopular => '🎯 Popular';

  @override
  String get chatbotTabFinance => '💰 Finance';

  @override
  String get chatbotTabApp => '📱 App';

  @override
  String get chatbotDefaultUser => 'User';

  @override
  String get goalsCompleted => 'Completed ✓';

  @override
  String get goalsOverdue => 'Overdue';

  @override
  String goalsDaysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String get goalsToReachObjective => 'To reach your goal:';

  @override
  String goalsDailyAmount(String amount, String currency) {
    return '• $amount $currency per day';
  }

  @override
  String goalsMonthlyAmount(String amount, String currency) {
    return '• $amount $currency per month';
  }

  @override
  String get goalsNameHint => 'E.g: Trip to Benin';

  @override
  String get goalsDescriptionHint => 'More details about your goal...';

  @override
  String get goalsValidationError => 'Please fill in the name and amount';

  @override
  String goalsPercentReached(String percent) {
    return '$percent% reached';
  }

  @override
  String get goalsAmountToAdd => 'Amount to add';

  @override
  String goalsRemainingToReach(String amount, String currency) {
    return '$amount $currency remaining to reach the goal';
  }

  @override
  String get goalsInvalidAmount => 'Please enter a valid amount';

  @override
  String get goalsCreateSuccess => 'Goal created successfully!';

  @override
  String get goalsCreateError => 'Error creating goal';

  @override
  String get goalsEditSuccess => 'Goal modified successfully!';

  @override
  String get goalsEditError => 'Error modifying goal';

  @override
  String get goalsDeleteSuccess => 'Goal deleted';

  @override
  String get goalsDeleteError => 'Error deleting goal';

  @override
  String goalsAmountExceedsRemaining(String amount) {
    return 'The amount added exceeds the remaining amount.\n$amount left to complete.';
  }

  @override
  String get goalsAmountAdded => 'Amount added!';

  @override
  String get goalsAddError => 'Error adding amount';

  @override
  String get goalsCongratulations => '🎉 Congratulations!';

  @override
  String goalsAchievedMessage(String name) {
    return 'Goal \"$name\" achieved!';
  }

  @override
  String get goalsGreatButton => 'Great!';

  @override
  String get goalsFinalizeError => 'Error finalizing';

  @override
  String goalsDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get goalsLoadError => 'Error loading goals';

  @override
  String get goalsMarkedComplete => '🎉 Goal marked as complete!';

  @override
  String notifActivationError(String error) {
    return 'Error activating reminders: $error';
  }

  @override
  String notifDeactivationError(String error) {
    return 'Error deactivating: $error';
  }

  @override
  String get notifRemindersDisabled => 'Reminders disabled';

  @override
  String get invalidIncomeError => 'Please enter valid income';

  @override
  String get invalidAmountError => 'Please enter a valid amount';

  @override
  String budgetAmountAdded(String amount) {
    return '$amount added to budget';
  }

  @override
  String get budgetExceeded => 'Budget exceeded. Try reducing your expenses.';

  @override
  String get budgetLimitReached => 'Warning, you\'ve reached the limit of your budget.';

  @override
  String get budgetNearLimit => 'Warning, you\'re approaching the limit of your budget.';

  @override
  String get categoryInvalidNamePercent => 'Invalid name or percentage';

  @override
  String get categoryInvalidInput => 'Please enter a valid name and percentage greater than 0';

  @override
  String get categoryDeleteHasTransactions => 'Cannot delete a category with transactions';

  @override
  String get pdfMonthlyIncome => 'Monthly income:';

  @override
  String get pdfRemainingBalance => 'Remaining balance:';

  @override
  String get pdfTotalExpenses => 'Total expenses:';

  @override
  String pdfIncomeSpentPercent(String percent) {
    return '$percent% of your income spent';
  }

  @override
  String get pdfAdviceTitle => 'SMARTSPEND ADVICE';

  @override
  String pdfPersonalReport(String name) {
    return 'Personal financial report of $name';
  }

  @override
  String pdfShareText(String name, String month) {
    return 'SmartSpend financial report of $name - $month';
  }

  @override
  String pdfForUser(String name) {
    return 'For $name';
  }

  @override
  String pdfAdviceOverBudget(String name) {
    return '$name, warning! You exceeded your budget this month. Try to reduce your spending next month.';
  }

  @override
  String pdfAdviceGreatSaving(String name) {
    return 'Excellent work, $name! You saved more than 30% of your income this month.';
  }

  @override
  String pdfAdviceOnTrack(String name, String amount, String currency) {
    return '$name, you\'re on track with $amount $currency remaining this month.';
  }

  @override
  String pdfAdviceCategoryHigh(String name, String category, String percent) {
    return '$name, the category \"$category\" represents a significant share ($percent%) of your spending. Consider diversifying.';
  }

  @override
  String pdfAdviceSavingsLow(String name) {
    return '$name, your savings are below 10% of your income. Try to gradually increase this share.';
  }

  @override
  String pdfAdviceBalanced(String name) {
    return '$name, your financial management is balanced this month. Keep it up!';
  }

  @override
  String csvHeaderFull(String currency) {
    return 'Date,Category,Description,Amount ($currency)';
  }

  @override
  String get premiumPurchasing => 'Launching purchase...';

  @override
  String get premiumRestoring => 'Restoring purchases...';

  @override
  String get premiumRestoreButton => 'Restore';

  @override
  String get premiumBestBadge => 'BEST';

  @override
  String get laterButton => 'Later';

  @override
  String get premiumWelcome => 'Welcome Premium!';

  @override
  String get premiumCongratulationsMessage => 'Congratulations! You now have access to all SmartSpend Premium features.';

  @override
  String get premiumEnjoyFeatures => 'Enjoy all features without limits!';

  @override
  String get goalsSavingSuggestion => 'Saving suggestion';

  @override
  String goalsSavingSuggestionDesc(String name) {
    return 'Your goal \"$name\" is coming due soon!';
  }

  @override
  String goalsProgressLabel2(String percent) {
    return 'Progress: $percent%';
  }

  @override
  String goalsRemainingLabel(String amount, String currency) {
    return 'Remaining: $amount $currency';
  }

  @override
  String goalsDeadlineDate(String date) {
    return 'Due date: $date';
  }

  @override
  String goalsSavingPrompt(String amount, String currency) {
    return 'Would you like to save $amount $currency for this goal?';
  }

  @override
  String get goalsSaveNowButton => 'Save now';

  @override
  String get createCategoryFirst => 'Please create a category first.';

  @override
  String get transactionAddTitle => 'Add transaction';

  @override
  String get defineIncomeFirst => 'Please set your income first.';

  @override
  String get categoryBudgetExceeded => 'Amount exceeds remaining available budget!';

  @override
  String get categoryNewTitle => 'New Category';

  @override
  String get categoryEditTitle => 'Edit Category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get settingsDailyReminders => 'Daily reminders';

  @override
  String get settingsDailyRemindersSubtitle => 'Evening reminder for your transactions';

  @override
  String get settingsGoals => 'Financial goals';

  @override
  String get settingsGoalsSubtitle => 'Set and track your savings goals';

  @override
  String get chatbotAccessError => 'Error accessing the assistant';

  @override
  String get pdfExportError => 'Error exporting PDF';

  @override
  String get premiumUpgradeError => 'Error upgrading';

  @override
  String get budgetRemainingBudget => 'Remaining:';

  @override
  String get monthFullJan => 'January';

  @override
  String get monthFullFeb => 'February';

  @override
  String get monthFullMar => 'March';

  @override
  String get monthFullApr => 'April';

  @override
  String get monthFullMay => 'May';

  @override
  String get monthFullJun => 'June';

  @override
  String get monthFullJul => 'July';

  @override
  String get monthFullAug => 'August';

  @override
  String get monthFullSep => 'September';

  @override
  String get monthFullOct => 'October';

  @override
  String get monthFullNov => 'November';

  @override
  String get monthFullDec => 'December';

  @override
  String get notifPermissionDenied => 'Notification permission denied. Enable it in settings.';

  @override
  String get notifSystemDisabled => 'Notifications are disabled in Android settings';

  @override
  String get notifBatteryOptimization => 'For reliable reminders, disable battery optimization for SmartSpend';

  @override
  String get notifActivated => '✅ Reminders activated!\nMorning (8:30 AM) and Evening (8:00 PM)';

  @override
  String get notifTestLaunched => 'Tests launched:\n• Immediate notification\n• Notification in 3 seconds';

  @override
  String get notifSystemNotEnabled => 'Notifications are not enabled at system level';

  @override
  String notifTestError(String error) {
    return 'Notification test error: $error';
  }

  @override
  String get newMonthDetails => '• Your categories will be kept\n• Expenses will be archived\n• You can enter your new income';

  @override
  String get closeMonthButton => 'Close the month';

  @override
  String monthClosedWithCarryOver(String amount) {
    return '✅ Month closed! $amount carried over. Enter your income.';
  }

  @override
  String get monthClosedEnterIncome => '✅ Month closed! Enter your income for this month.';

  @override
  String get monthCloseError => 'Error closing the month';

  @override
  String get transactionAddError => 'Error adding transaction';

  @override
  String get transactionEditError => 'Error editing transaction';

  @override
  String get transactionDeleteError => 'Error deleting transaction';

  @override
  String get syncComplete => 'Synchronization complete';

  @override
  String get syncError => 'Synchronization error';

  @override
  String get dataDeletedSuccess => 'All data has been deleted';

  @override
  String categoryPercentExceeded(String percent) {
    return 'Total percentages cannot exceed 100%. Available: $percent%';
  }

  @override
  String get categoryServerEditError => 'Error editing on server';

  @override
  String get categoryServerDeleteError => 'Error deleting on server';

  @override
  String pdfFinancialStatement(String month) {
    return 'Financial Statement of: $month';
  }

  @override
  String pdfGeneratedOn(String date) {
    return 'Generated on $date';
  }

  @override
  String get pdfFinancialOverview => 'FINANCIAL OVERVIEW';

  @override
  String get pdfSmartSpendFooter => 'SmartSpend - Smart financial management';

  @override
  String get pdfTableDate => 'Date';

  @override
  String get pdfTableCategory => 'Category';

  @override
  String get pdfTableDescription => 'Description';

  @override
  String pdfTableAmount(String currency) {
    return 'Amount ($currency)';
  }

  @override
  String get pdfCategoryTableCategory => 'Category';

  @override
  String get pdfCategoryTableAmount => 'Amount';

  @override
  String get pdfCategoryTableBudget => 'Budget';

  @override
  String get pdfCategoryTableDiff => 'Difference';

  @override
  String get premiumUnlimitedPdf => 'Unlimited PDF exports';

  @override
  String get premiumAnnual => 'Annual';

  @override
  String get premiumProductUnavailable => 'Product unavailable. Try again later.';

  @override
  String get pdfLimitReached => 'Limit reached';

  @override
  String get pdfLimitMessage => 'You\'ve used your 3 free PDF exports.';

  @override
  String get pdfLimitUpgrade => 'Upgrade to Premium for unlimited exports and full access to the financial assistant.';

  @override
  String get pdfLastFreeExport => 'This was your last free PDF export.';

  @override
  String get viewPremiumButton => 'View Premium';

  @override
  String get startButton => 'Start';

  @override
  String get goalsKeepGoingMessage => 'Keep going to reach all your financial goals!';

  @override
  String get goalsSaveButton => 'Save';

  @override
  String get premiumRequired => 'Premium required';

  @override
  String premiumRemainingTrials(int count, String feature) {
    return 'You have $count free trials left for $feature';
  }

  @override
  String premiumTrialsExhausted(String feature) {
    return 'You\'ve used all your free trials for $feature';
  }

  @override
  String get premiumUpgradeTo => 'Upgrade to SmartSpend Premium for:';

  @override
  String get premiumFeaturePdf => '✨ Unlimited PDF exports';

  @override
  String get premiumFeatureAI => '🤖 Unlimited financial assistant';

  @override
  String get premiumFeatureAnalytics => '📊 Advanced analytics';

  @override
  String get premiumFeatureCloud => '☁️ Priority cloud sync';

  @override
  String get premiumFeatureGoals => '🎯 Advanced financial goals';

  @override
  String get premiumFeatureSupport => '📱 Priority support';

  @override
  String get premiumTryFree => 'Try for free';

  @override
  String get premiumUpgradeButton => 'Upgrade to Premium';

  @override
  String get premiumChooseSubscription => 'Choose your subscription';

  @override
  String get premiumSaveBadge => 'SAVE';

  @override
  String get premiumPurchasesRestoredSuccess => 'Purchases restored successfully!';

  @override
  String get premiumNoPurchaseToRestore => 'No purchase to restore';

  @override
  String get premiumProcessingPurchase => 'Processing your purchase...';

  @override
  String premiumPurchaseErrorDetail(String error) {
    return 'Purchase error: $error';
  }

  @override
  String get premiumWelcomeTitle => 'Welcome Premium!';

  @override
  String get premiumCongratulationsDetail => 'Congratulations! You now have access to all SmartSpend Premium features.';

  @override
  String get premiumEnjoyNoLimits => 'Enjoy all features without limits!';

  @override
  String get premiumProductLoadError => 'Error loading products. Please try again.';

  @override
  String get premiumUpgradeErrorGeneric => 'Error upgrading to Premium';

  @override
  String get exportCsv => 'Export as CSV';

  @override
  String get exportPdf => 'Export as PDF';

  @override
  String get exportOptions => 'Export options';

  @override
  String get exportSuccessNoMore => '🎉 Export successful! No more free trials available.';

  @override
  String exportSuccessRemaining(int count) {
    return '🎉 Export successful! $count trials remaining.';
  }

  @override
  String get pdfExportLabel => 'PDF export';

  @override
  String get pdfExportErrorGeneric => 'Error during PDF export';

  @override
  String get drawerSubtitle => 'Your personal financial assistant';

  @override
  String get drawerNotifications => 'NOTIFICATIONS';

  @override
  String get drawerManagement => 'MANAGEMENT';

  @override
  String get drawerFinancialAssistant => 'Financial assistant';

  @override
  String get drawerFinancialAssistantSubtitle => 'Get personalized advice';

  @override
  String get drawerFinancialAssistantLabel => 'financial assistant';

  @override
  String get drawerAccessError => 'Error accessing assistant';

  @override
  String get drawerMyProfile => 'My Profile';

  @override
  String get drawerMyProfileSubtitle => 'Manage your account information';

  @override
  String get transactionOptions => 'Transaction options';

  @override
  String get editTransactionTitle => 'Edit transaction';

  @override
  String transactionCategoryLabel(String name) {
    return 'Category: $name';
  }

  @override
  String get percentageLabel => 'Percentage (%)';

  @override
  String amountCurrencyLabel(String currency) {
    return 'Amount ($currency)';
  }

  @override
  String get switchToAmount => 'Switch to Amount';

  @override
  String get switchToPercent => 'Switch to Percentage';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String get categoryNameEmpty => 'Category name cannot be empty.';

  @override
  String get budgetTotalAvailable => 'Total budget available:';

  @override
  String get premiumUpgradeDialogWelcome => 'Welcome Premium!';

  @override
  String get premiumUpgradeDialogCongrats => 'Congratulations! You now have access to all Premium features.';

  @override
  String premiumUpgradeDialogFeature(String feature) {
    return 'You can now use $feature without limits!';
  }

  @override
  String get premiumUpgradeDialogButton => 'Perfect!';

  @override
  String get premiumUpgradeDialogError => 'Error upgrading';

  @override
  String get addTransactionTitle => 'Add a transaction';

  @override
  String get categoryLabel => 'Category';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get drawerDailyReminders => 'Daily reminders';

  @override
  String get drawerDailyRemindersSubtitle => 'Evening reminder for your transactions';

  @override
  String get drawerFinancialGoals => 'Financial goals';

  @override
  String get drawerFinancialGoalsSubtitle => 'Set and track your savings goals';

  @override
  String get newCategoryTitle => 'New Category';

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String equivalentAmount(String amount, String currency) {
    return 'Equivalent: $amount $currency';
  }

  @override
  String equivalentPercent(String percent) {
    return 'Equivalent: $percent%';
  }

  @override
  String get budgetExceedsRemaining => 'Amount exceeds available remaining budget!';

  @override
  String get incomeFirstMessage => 'Please set your income first.';

  @override
  String switchToLabel(String mode) {
    return 'Switch to $mode';
  }
}
