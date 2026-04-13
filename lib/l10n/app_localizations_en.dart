// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zenit';

  @override
  String get home => 'Home';

  @override
  String get statistics => 'Statistics';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get languages => 'Language';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get appVersion => 'App version';

  @override
  String get appVersionValue => '1.0 (beta)';

  @override
  String get generalSettingsItem => 'General settings';

  @override
  String get categoryManagement => 'Category management';

  @override
  String get moneySourceManagement => 'Money source management';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get supportCenter => 'Support center';

  @override
  String get privacyPolicyAndTerms => 'Privacy policy and terms';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Confirm logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get loginTitle => 'Welcome back!';

  @override
  String get loginSubtitle => 'Log in';

  @override
  String get signupTitle => 'Create account';

  @override
  String get signupSubtitle => 'Sign up';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get resetPasswordSubtitle => 'Reset password';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'your.email@example.com';

  @override
  String get password => 'Password';

  @override
  String get enterPasswordHint => 'Enter password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Log in';

  @override
  String get noAccountSignup => 'Don\'t have an account? Sign up now';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Log in';

  @override
  String get loginTermsText =>
      'By logging in, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'username';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get reenterPasswordHint => 'Re-enter password';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get enterAddressHint => 'Enter your address';

  @override
  String get signupButton => 'Sign up';

  @override
  String get enterEmail => 'Please enter email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get enterPassword => 'Please enter password';

  @override
  String get weakPassword =>
      'Password must be longer than 8 characters and contain at least one number and one special character';

  @override
  String get enterUsername => 'Please enter username';

  @override
  String get usernameLengthInvalid =>
      'Username must be between 3 and 20 characters';

  @override
  String get usernameFormatInvalid =>
      'Username can only contain letters, numbers and underscore';

  @override
  String get confirmPasswordRequired => 'Please confirm password';

  @override
  String get passwordNotMatch => 'Passwords do not match';

  @override
  String get enterPhone => 'Please enter phone number';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get phoneLengthInvalid => 'Phone number must have 10 digits';

  @override
  String get enterAddress => 'Please enter address';

  @override
  String get addressTooShort => 'Address is too short';

  @override
  String get send => 'Send';

  @override
  String get registeredEmailOrUsername => 'Registered email or username';

  @override
  String get otp => 'OTP';

  @override
  String get otpHint => 'OTP';

  @override
  String get pleaseEnterOtp => 'Please enter OTP';

  @override
  String get otpSentInstruction =>
      'We will send you an OTP by email. Check spam if you do not see it.';

  @override
  String resendAfterSeconds(int seconds) {
    return 'Haven\'t received the email yet? Try again after ${seconds}s';
  }

  @override
  String get resendNow => 'Haven\'t received the email yet? Try again';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get resetPasswordHint =>
      'We will take you back to the login screen to sign in with the new password.';

  @override
  String get confirm => 'Confirm';

  @override
  String get continueTermsText =>
      'By continuing, you agree with our terms and privacy policy.';

  @override
  String get signupSuccessPleaseLogin => 'Sign up successfully, please login';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get invalidResponseData => 'Invalid response data';

  @override
  String get loginError => 'Login failed';

  @override
  String get signupError => 'Sign up failed';

  @override
  String get unknownErrorOccurred =>
      'An unexpected error occurred. Please try again.';

  @override
  String unknownErrorWithReason(String reason) {
    return 'An error occurred: $reason';
  }

  @override
  String get sendOtpError => 'Send OTP failed';

  @override
  String get invalidOtp => 'Invalid OTP';

  @override
  String get resetPasswordError => 'Reset password failed';

  @override
  String get resetPasswordSuccess => 'Password reset successfully!';

  @override
  String get resetPasswordSuccessNavigate =>
      'Password reset successfully! Please log in.';

  @override
  String welcomeBackUser(String username) {
    return 'Welcome back, $username';
  }

  @override
  String get homeGuestTitle => 'Home - Not logged in';

  @override
  String get haveNiceDay => 'Have a nice day!';

  @override
  String get actionTransaction => 'Transaction';

  @override
  String get actionQuickImport => 'Quick import';

  @override
  String get actionLoans => 'Loans';

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionMoneySource => 'Wallets';

  @override
  String get actionGoals => 'Goals';

  @override
  String get actionMoreActions => 'More actions';

  @override
  String get loansTitle => 'Loans';

  @override
  String get transferTitle => 'Transfer';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get transactionAddedSuccess => 'Transaction added successfully!';

  @override
  String genericErrorWithReason(String reason) {
    return 'Error: $reason';
  }

  @override
  String get navigateQuickImport => 'Navigate to Quick Import';

  @override
  String get navigateGoals => 'Navigate to Goals';

  @override
  String get showMoreActions => 'Show More Actions';

  @override
  String get transactionDetail => 'Transaction detail';

  @override
  String deleteTransactionSuccess(String title) {
    return 'Deleted transaction \"$title\"';
  }

  @override
  String get transactionIdNotFound => 'Transaction ID not found';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get pullToRefresh => 'Pull down to refresh';

  @override
  String get needLoginHistory =>
      'You need to log in to view transaction history';

  @override
  String get recentTransactionsTitle => 'Recent transactions';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get needLoginStatistics => 'You need to log in to view statistics';

  @override
  String get cannotLoadData => 'Unable to load data';

  @override
  String get noData => 'No data yet';

  @override
  String get noTransactionsInRange =>
      'There are no transactions in this period';

  @override
  String get exportReport => 'Export report';

  @override
  String get exportReportSuccess => 'Exported report successfully!';

  @override
  String exportReportFailedWithReason(String reason) {
    return 'Export failed: $reason';
  }

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get searchForTag => 'Search for a tag';

  @override
  String get tagManage => 'Tag manage';

  @override
  String get chooseTagForTransaction => 'Choose a tag for transaction';

  @override
  String get selectCategoryWarning => 'Please select a category';

  @override
  String get amount => 'Amount';

  @override
  String get time => 'Time';

  @override
  String get today => 'Today';

  @override
  String get category => 'Category';

  @override
  String get singleCategory => 'Single Category';

  @override
  String get select => 'Select';

  @override
  String get note => 'Note';

  @override
  String get transactionName => 'Transaction name';

  @override
  String get noteEmpty => 'No note';

  @override
  String get enterAmount => 'Please enter amount';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get transactionLoadError => 'Error loading transaction details';

  @override
  String get transactionNotFound => 'Transaction not found';

  @override
  String get updateTransactionSuccess => 'Transaction updated';

  @override
  String get transactionIdMissingUpdate =>
      'Cannot find transaction ID for update';

  @override
  String get unknown => 'Unknown';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String confirmDeleteTransactionMessage(String title) {
    return 'Are you sure you want to delete transaction \"$title\"?';
  }

  @override
  String get supportCenterTitle => 'Support center';

  @override
  String get contactViaEmail => 'Contact us via Email';

  @override
  String get contactViaPhone => 'Contact us via Phone';

  @override
  String get unableOpenApp => 'Unable to open this app right now.';

  @override
  String contactInfo(String email, String phone) {
    return 'Email: $email\nPhone: $phone';
  }

  @override
  String get notificationManageTitle => 'Notification';

  @override
  String get receiveEmailUpdates => 'Receive our update via email';

  @override
  String get profile => 'Profile';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get unableUpdateProfile => 'Unable to update profile';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get termsAndPolicy => 'Terms and Policy';

  @override
  String get termsWelcomeTitle => '1. Welcome to Zenit';

  @override
  String get termsWelcomeBody1 =>
      'Welcome to Zenit! We are delighted that you have chosen to use our application. To ensure you feel secure while using our services, Zenit has prepared these comprehensive Terms of Service and Privacy Policy. This document clearly outlines your rights and obligations, and explains how we manage your personal data.';

  @override
  String get termsWelcomeBody2 =>
      'By continuing to use the Zenit application, you confirm that you have read, understood, and agreed to all the terms outlined below.';

  @override
  String get termsGeneralTitle => '2. General Terms of Service';

  @override
  String get termsEligibilityTitle => '1. Eligibility:';

  @override
  String get termsEligibilityBody =>
      'You affirm that you are of legal age (typically 16 years old or older, depending on applicable law) to enter into these binding legal agreements. If you are under this age, please use the application under the supervision of a parent or guardian.';

  @override
  String get termsLawfulUseTitle => '2. Lawful Use:';

  @override
  String get termsLawfulUseBody =>
      'You agree to use Zenit for lawful purposes only, without violating any current laws, and without causing harm, annoyance, or disruption to the experience of other users.';

  @override
  String get termsIntellectualPropertyTitle => '3. Intellectual Property:';

  @override
  String get termsIntellectualPropertyBody =>
      'All content (design, text, graphics, etc.) within Zenit is the property of us (or our licensors). You are permitted to use this content through the application but are not allowed to copy, distribute, or modify it without permission.';

  @override
  String get termsUserAccountsTitle => '3. User Accounts';

  @override
  String get termsUserAccountsBody1 =>
      'To access certain features of Zenit, users may be required to create an account. You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. Zenit will not be liable for any loss or damage arising from your failure to comply with these obligations.';

  @override
  String get termsUserAccountsBody2 =>
      'You agree to provide accurate, complete, and up-to-date information when creating your account. If we suspect that the information you provided is false or misleading, we reserve the right to suspend or terminate your account at any time.';

  @override
  String get termsPrivacyTitle => '4. Privacy and Data Collection';

  @override
  String get termsPrivacyBody1 =>
      'Zenit respects your privacy and is committed to protecting your personal data. We may collect certain information such as your email address, usage data, and device information in order to provide and improve our services.';

  @override
  String get termsPrivacyBody2 =>
      'This information may be used for authentication, security monitoring, analytics, and improving user experience. We do not sell your personal data to third parties.';

  @override
  String get termsDataSecurityTitle => '5. Data Security';

  @override
  String get termsDataSecurityBody1 =>
      'We implement reasonable security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. However, no method of electronic storage or transmission over the internet is completely secure.';

  @override
  String get termsDataSecurityBody2 =>
      'While we strive to use commercially acceptable means to protect your data, we cannot guarantee its absolute security.';

  @override
  String get termsThirdPartyTitle => '6. Third-Party Services';

  @override
  String get termsThirdPartyBody1 =>
      'Zenit may integrate or rely on third-party services such as analytics providers, cloud storage, or authentication systems. These services may collect information in accordance with their own privacy policies.';

  @override
  String get termsThirdPartyBody2 =>
      'We encourage users to review the privacy policies of any third-party services that may interact with the Zenit application.';

  @override
  String get termsLiabilityTitle => '7. Limitation of Liability';

  @override
  String get termsLiabilityBody1 =>
      'Zenit is provided on an \"as-is\" and \"as-available\" basis. We do not guarantee that the application will be uninterrupted, secure, or error-free.';

  @override
  String get termsLiabilityBody2 =>
      'Under no circumstances shall Zenit or its developers be liable for any indirect, incidental, special, or consequential damages resulting from the use or inability to use the application.';

  @override
  String get termsTerminationTitle => '8. Termination';

  @override
  String get termsTerminationBody =>
      'We reserve the right to suspend or terminate your access to the application at any time without prior notice if you violate these terms or engage in behavior that may harm the application or other users.';

  @override
  String get termsChangesTitle => '9. Changes to These Policies';

  @override
  String get termsChangesBody =>
      'Zenit may update these Terms of Service and Privacy Policy from time to time. Any updates will be reflected within the application, and continued use of the application after such updates constitutes acceptance of the revised terms.';

  @override
  String get termsContactTitle => '10. Contact Us';

  @override
  String get termsContactBody =>
      'If you have any questions regarding these Terms and Privacy Policy, please contact our support team through the contact information provided within the application.';

  @override
  String get categoryManage => 'Category Manage';

  @override
  String get edit => 'Edit';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get deleteCategoryConfirm =>
      'Are you sure you want to delete this category?';

  @override
  String get deleteCategorySuccess => 'Category deleted';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get editCategory => 'Edit category';

  @override
  String get addCategory => 'Add a category';

  @override
  String categoryUpdatedSuccess(String name) {
    return 'Category updated: $name';
  }

  @override
  String get categoryUpdateFailed => 'Category update failed';

  @override
  String categoryAddedSuccess(String name) {
    return 'Category added: $name';
  }

  @override
  String get categoryAddFailed => 'Adding category failed';

  @override
  String get categoryName => 'Category name';

  @override
  String get enterCategoryName => 'Enter category name';

  @override
  String get belongToGroup => 'Belong to group';

  @override
  String get expenseLimit => 'Expense limit';

  @override
  String get enterExpenseLimitOptional => 'Enter expense limit (optional)';

  @override
  String get selectIcon => 'Select icon';

  @override
  String get done => 'Done';

  @override
  String get pleaseSelectIcon => 'Please select an icon';

  @override
  String get pleaseEnterCategoryName => 'Please enter category name';

  @override
  String get groupNecessary => 'Necessary';

  @override
  String get groupSavings => 'Savings';

  @override
  String get groupSelfDevelopment => 'Self Development';

  @override
  String get groupEntertainment => 'Entertainment';

  @override
  String get groupGiving => 'Giving';

  @override
  String usernameLabel(String username) {
    return 'Username: $username';
  }

  @override
  String get notLoggedIn => 'You are not logged in';

  @override
  String get pleaseLogin => 'Please sign in to view information';
}
