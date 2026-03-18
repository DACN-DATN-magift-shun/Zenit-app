import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zenit'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languages;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @appVersionValue.
  ///
  /// In en, this message translates to:
  /// **'1.0 (beta)'**
  String get appVersionValue;

  /// No description provided for @generalSettingsItem.
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get generalSettingsItem;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category management'**
  String get categoryManagement;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @supportCenter.
  ///
  /// In en, this message translates to:
  /// **'Support center'**
  String get supportCenter;

  /// No description provided for @privacyPolicyAndTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy and terms'**
  String get privacyPolicyAndTerms;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccess;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubtitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signupSubtitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPasswordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @noAccountSignup.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up now'**
  String get noAccountSignup;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @loginTermsText.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to our Terms of Service and Privacy Policy.'**
  String get loginTermsText;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get usernameHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @reenterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reenterPasswordHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterAddressHint;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signupButton;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be longer than 8 characters and contain at least one number and one special character'**
  String get weakPassword;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get enterUsername;

  /// No description provided for @usernameLengthInvalid.
  ///
  /// In en, this message translates to:
  /// **'Username must be between 3 and 20 characters'**
  String get usernameLengthInvalid;

  /// No description provided for @usernameFormatInvalid.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers and underscore'**
  String get usernameFormatInvalid;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get enterPhone;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @phoneLengthInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number must have 10 digits'**
  String get phoneLengthInvalid;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get enterAddress;

  /// No description provided for @addressTooShort.
  ///
  /// In en, this message translates to:
  /// **'Address is too short'**
  String get addressTooShort;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @registeredEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Registered email or username'**
  String get registeredEmailOrUsername;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otpHint;

  /// No description provided for @pleaseEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get pleaseEnterOtp;

  /// No description provided for @otpSentInstruction.
  ///
  /// In en, this message translates to:
  /// **'We will send you an OTP by email. Check spam if you do not see it.'**
  String get otpSentInstruction;

  /// No description provided for @resendAfterSeconds.
  ///
  /// In en, this message translates to:
  /// **'Haven\'t received the email yet? Try again after {seconds}s'**
  String resendAfterSeconds(int seconds);

  /// No description provided for @resendNow.
  ///
  /// In en, this message translates to:
  /// **'Haven\'t received the email yet? Try again'**
  String get resendNow;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @resetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'We will take you back to the login screen to sign in with the new password.'**
  String get resetPasswordHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @continueTermsText.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree with our terms and privacy policy.'**
  String get continueTermsText;

  /// No description provided for @signupSuccessPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign up successfully, please login'**
  String get signupSuccessPleaseLogin;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @invalidResponseData.
  ///
  /// In en, this message translates to:
  /// **'Invalid response data'**
  String get invalidResponseData;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginError;

  /// No description provided for @signupError.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed'**
  String get signupError;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownErrorOccurred;

  /// No description provided for @unknownErrorWithReason.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {reason}'**
  String unknownErrorWithReason(String reason);

  /// No description provided for @sendOtpError.
  ///
  /// In en, this message translates to:
  /// **'Send OTP failed'**
  String get sendOtpError;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOtp;

  /// No description provided for @resetPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Reset password failed'**
  String get resetPasswordError;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordSuccessNavigate.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please log in.'**
  String get resetPasswordSuccessNavigate;

  /// No description provided for @welcomeBackUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {username}'**
  String welcomeBackUser(String username);

  /// No description provided for @homeGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Home - Not logged in'**
  String get homeGuestTitle;

  /// No description provided for @haveNiceDay.
  ///
  /// In en, this message translates to:
  /// **'Have a nice day!'**
  String get haveNiceDay;

  /// No description provided for @actionTransaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get actionTransaction;

  /// No description provided for @actionQuickImport.
  ///
  /// In en, this message translates to:
  /// **'Quick import'**
  String get actionQuickImport;

  /// No description provided for @actionGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get actionGoals;

  /// No description provided for @actionMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get actionMoreActions;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @transactionAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully!'**
  String get transactionAddedSuccess;

  /// No description provided for @genericErrorWithReason.
  ///
  /// In en, this message translates to:
  /// **'Error: {reason}'**
  String genericErrorWithReason(String reason);

  /// No description provided for @navigateQuickImport.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Quick Import'**
  String get navigateQuickImport;

  /// No description provided for @navigateGoals.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Goals'**
  String get navigateGoals;

  /// No description provided for @showMoreActions.
  ///
  /// In en, this message translates to:
  /// **'Show More Actions'**
  String get showMoreActions;

  /// No description provided for @transactionDetail.
  ///
  /// In en, this message translates to:
  /// **'Transaction detail'**
  String get transactionDetail;

  /// No description provided for @deleteTransactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted transaction \"{title}\"'**
  String deleteTransactionSuccess(String title);

  /// No description provided for @transactionIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID not found'**
  String get transactionIdNotFound;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullToRefresh;

  /// No description provided for @needLoginHistory.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to view transaction history'**
  String get needLoginHistory;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @needLoginStatistics.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to view statistics'**
  String get needLoginStatistics;

  /// No description provided for @cannotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data'**
  String get cannotLoadData;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noData;

  /// No description provided for @noTransactionsInRange.
  ///
  /// In en, this message translates to:
  /// **'There are no transactions in this period'**
  String get noTransactionsInRange;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export report'**
  String get exportReport;

  /// No description provided for @exportReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported report successfully!'**
  String get exportReportSuccess;

  /// No description provided for @exportReportFailedWithReason.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {reason}'**
  String exportReportFailedWithReason(String reason);

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @searchForTag.
  ///
  /// In en, this message translates to:
  /// **'Search for a tag'**
  String get searchForTag;

  /// No description provided for @tagManage.
  ///
  /// In en, this message translates to:
  /// **'Tag manage'**
  String get tagManage;

  /// No description provided for @chooseTagForTransaction.
  ///
  /// In en, this message translates to:
  /// **'Choose a tag for transaction'**
  String get chooseTagForTransaction;

  /// No description provided for @selectCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategoryWarning;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @singleCategory.
  ///
  /// In en, this message translates to:
  /// **'Single Category'**
  String get singleCategory;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @transactionName.
  ///
  /// In en, this message translates to:
  /// **'Transaction name'**
  String get transactionName;

  /// No description provided for @noteEmpty.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get noteEmpty;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get enterAmount;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @transactionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading transaction details'**
  String get transactionLoadError;

  /// No description provided for @transactionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Transaction not found'**
  String get transactionNotFound;

  /// No description provided for @updateTransactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get updateTransactionSuccess;

  /// No description provided for @transactionIdMissingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Cannot find transaction ID for update'**
  String get transactionIdMissingUpdate;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete transaction \"{title}\"?'**
  String confirmDeleteTransactionMessage(String title);

  /// No description provided for @supportCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Support center'**
  String get supportCenterTitle;

  /// No description provided for @contactViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact us via Email'**
  String get contactViaEmail;

  /// No description provided for @contactViaPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact us via Phone'**
  String get contactViaPhone;

  /// No description provided for @unableOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this app right now.'**
  String get unableOpenApp;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}\nPhone: {phone}'**
  String contactInfo(String email, String phone);

  /// No description provided for @notificationManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationManageTitle;

  /// No description provided for @receiveEmailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive our update via email'**
  String get receiveEmailUpdates;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @unableUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile'**
  String get unableUpdateProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @termsAndPolicy.
  ///
  /// In en, this message translates to:
  /// **'Terms and Policy'**
  String get termsAndPolicy;

  /// No description provided for @termsWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Welcome to Zenit'**
  String get termsWelcomeTitle;

  /// No description provided for @termsWelcomeBody1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zenit! We are delighted that you have chosen to use our application. To ensure you feel secure while using our services, Zenit has prepared these comprehensive Terms of Service and Privacy Policy. This document clearly outlines your rights and obligations, and explains how we manage your personal data.'**
  String get termsWelcomeBody1;

  /// No description provided for @termsWelcomeBody2.
  ///
  /// In en, this message translates to:
  /// **'By continuing to use the Zenit application, you confirm that you have read, understood, and agreed to all the terms outlined below.'**
  String get termsWelcomeBody2;

  /// No description provided for @termsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'2. General Terms of Service'**
  String get termsGeneralTitle;

  /// No description provided for @termsEligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Eligibility:'**
  String get termsEligibilityTitle;

  /// No description provided for @termsEligibilityBody.
  ///
  /// In en, this message translates to:
  /// **'You affirm that you are of legal age (typically 16 years old or older, depending on applicable law) to enter into these binding legal agreements. If you are under this age, please use the application under the supervision of a parent or guardian.'**
  String get termsEligibilityBody;

  /// No description provided for @termsLawfulUseTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Lawful Use:'**
  String get termsLawfulUseTitle;

  /// No description provided for @termsLawfulUseBody.
  ///
  /// In en, this message translates to:
  /// **'You agree to use Zenit for lawful purposes only, without violating any current laws, and without causing harm, annoyance, or disruption to the experience of other users.'**
  String get termsLawfulUseBody;

  /// No description provided for @termsIntellectualPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Intellectual Property:'**
  String get termsIntellectualPropertyTitle;

  /// No description provided for @termsIntellectualPropertyBody.
  ///
  /// In en, this message translates to:
  /// **'All content (design, text, graphics, etc.) within Zenit is the property of us (or our licensors). You are permitted to use this content through the application but are not allowed to copy, distribute, or modify it without permission.'**
  String get termsIntellectualPropertyBody;

  /// No description provided for @termsUserAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'3. User Accounts'**
  String get termsUserAccountsTitle;

  /// No description provided for @termsUserAccountsBody1.
  ///
  /// In en, this message translates to:
  /// **'To access certain features of Zenit, users may be required to create an account. You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. Zenit will not be liable for any loss or damage arising from your failure to comply with these obligations.'**
  String get termsUserAccountsBody1;

  /// No description provided for @termsUserAccountsBody2.
  ///
  /// In en, this message translates to:
  /// **'You agree to provide accurate, complete, and up-to-date information when creating your account. If we suspect that the information you provided is false or misleading, we reserve the right to suspend or terminate your account at any time.'**
  String get termsUserAccountsBody2;

  /// No description provided for @termsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Privacy and Data Collection'**
  String get termsPrivacyTitle;

  /// No description provided for @termsPrivacyBody1.
  ///
  /// In en, this message translates to:
  /// **'Zenit respects your privacy and is committed to protecting your personal data. We may collect certain information such as your email address, usage data, and device information in order to provide and improve our services.'**
  String get termsPrivacyBody1;

  /// No description provided for @termsPrivacyBody2.
  ///
  /// In en, this message translates to:
  /// **'This information may be used for authentication, security monitoring, analytics, and improving user experience. We do not sell your personal data to third parties.'**
  String get termsPrivacyBody2;

  /// No description provided for @termsDataSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Data Security'**
  String get termsDataSecurityTitle;

  /// No description provided for @termsDataSecurityBody1.
  ///
  /// In en, this message translates to:
  /// **'We implement reasonable security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. However, no method of electronic storage or transmission over the internet is completely secure.'**
  String get termsDataSecurityBody1;

  /// No description provided for @termsDataSecurityBody2.
  ///
  /// In en, this message translates to:
  /// **'While we strive to use commercially acceptable means to protect your data, we cannot guarantee its absolute security.'**
  String get termsDataSecurityBody2;

  /// No description provided for @termsThirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Third-Party Services'**
  String get termsThirdPartyTitle;

  /// No description provided for @termsThirdPartyBody1.
  ///
  /// In en, this message translates to:
  /// **'Zenit may integrate or rely on third-party services such as analytics providers, cloud storage, or authentication systems. These services may collect information in accordance with their own privacy policies.'**
  String get termsThirdPartyBody1;

  /// No description provided for @termsThirdPartyBody2.
  ///
  /// In en, this message translates to:
  /// **'We encourage users to review the privacy policies of any third-party services that may interact with the Zenit application.'**
  String get termsThirdPartyBody2;

  /// No description provided for @termsLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Limitation of Liability'**
  String get termsLiabilityTitle;

  /// No description provided for @termsLiabilityBody1.
  ///
  /// In en, this message translates to:
  /// **'Zenit is provided on an \"as-is\" and \"as-available\" basis. We do not guarantee that the application will be uninterrupted, secure, or error-free.'**
  String get termsLiabilityBody1;

  /// No description provided for @termsLiabilityBody2.
  ///
  /// In en, this message translates to:
  /// **'Under no circumstances shall Zenit or its developers be liable for any indirect, incidental, special, or consequential damages resulting from the use or inability to use the application.'**
  String get termsLiabilityBody2;

  /// No description provided for @termsTerminationTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Termination'**
  String get termsTerminationTitle;

  /// No description provided for @termsTerminationBody.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend or terminate your access to the application at any time without prior notice if you violate these terms or engage in behavior that may harm the application or other users.'**
  String get termsTerminationBody;

  /// No description provided for @termsChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Changes to These Policies'**
  String get termsChangesTitle;

  /// No description provided for @termsChangesBody.
  ///
  /// In en, this message translates to:
  /// **'Zenit may update these Terms of Service and Privacy Policy from time to time. Any updates will be reflected within the application, and continued use of the application after such updates constitutes acceptance of the revised terms.'**
  String get termsChangesBody;

  /// No description provided for @termsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'10. Contact Us'**
  String get termsContactTitle;

  /// No description provided for @termsContactBody.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions regarding these Terms and Privacy Policy, please contact our support team through the contact information provided within the application.'**
  String get termsContactBody;

  /// No description provided for @categoryManage.
  ///
  /// In en, this message translates to:
  /// **'Category Manage'**
  String get categoryManage;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get deleteCategoryConfirm;

  /// No description provided for @deleteCategorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get deleteCategorySuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a category'**
  String get addCategory;

  /// No description provided for @categoryUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated: {name}'**
  String categoryUpdatedSuccess(String name);

  /// No description provided for @categoryUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Category update failed'**
  String get categoryUpdateFailed;

  /// No description provided for @categoryAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added: {name}'**
  String categoryAddedSuccess(String name);

  /// No description provided for @categoryAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Adding category failed'**
  String get categoryAddFailed;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @belongToGroup.
  ///
  /// In en, this message translates to:
  /// **'Belong to group'**
  String get belongToGroup;

  /// No description provided for @expenseLimit.
  ///
  /// In en, this message translates to:
  /// **'Expense limit'**
  String get expenseLimit;

  /// No description provided for @enterExpenseLimitOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter expense limit (optional)'**
  String get enterExpenseLimitOptional;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select icon'**
  String get selectIcon;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pleaseSelectIcon.
  ///
  /// In en, this message translates to:
  /// **'Please select an icon'**
  String get pleaseSelectIcon;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @groupNecessary.
  ///
  /// In en, this message translates to:
  /// **'Necessary'**
  String get groupNecessary;

  /// No description provided for @groupSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get groupSavings;

  /// No description provided for @groupSelfDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Self Development'**
  String get groupSelfDevelopment;

  /// No description provided for @groupEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get groupEntertainment;

  /// No description provided for @groupGiving.
  ///
  /// In en, this message translates to:
  /// **'Giving'**
  String get groupGiving;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username: {username}'**
  String usernameLabel(String username);

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get notLoggedIn;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view information'**
  String get pleaseLogin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
