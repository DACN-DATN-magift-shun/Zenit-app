import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:zenit/l10n/app_localizations_en.dart';
import 'package:zenit/l10n/app_localizations_vi.dart';
import 'package:flutter/material.dart';
void main() {
  test('supportedLocales contains English and Vietnamese', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('vi')));
  });

  test('English translations expose expected strings', () {
    final l10n = AppLocalizationsEn();

    expect(l10n.appTitle, 'Zenit');
    expect(l10n.loginButton, 'Log in');
    expect(l10n.logoutConfirmMessage, 'Are you sure you want to log out?');
    expect(l10n.chatNoConversations, 'No conversations yet');
  });

  test('Vietnamese translations expose expected strings', () {
    final l10n = AppLocalizationsVi();

    expect(l10n.appTitle, 'Zenit');
    expect(l10n.loginButton, 'Đăng nhập');
    expect(l10n.logoutConfirmMessage, 'Bạn có chắc muốn đăng xuất không?');
    expect(l10n.chatNoConversations, 'Chưa có hội thoại nào');
  });

  test('English translations - broad coverage', () {
    final l10n = AppLocalizationsEn();

    // Common labels
    expect(l10n.home, 'Home');
    expect(l10n.statistics, 'Statistics');
    expect(l10n.settings, 'Settings');
    expect(l10n.languages, 'Language');
    expect(l10n.english, 'English');
    expect(l10n.vietnamese, 'Vietnamese');

    // Auth related
    expect(l10n.signupTitle, 'Create account');
    expect(l10n.forgotPassword, 'Forgot password?');
    expect(l10n.username, 'Username');
    expect(l10n.invalidEmail, 'Invalid email');
    expect(l10n.weakPassword.startsWith('Password must be longer'), isTrue);

    // Chat helpers and plurals-like methods
    expect(l10n.chatUpdatedAt('yesterday'), 'Updated yesterday');
    expect(l10n.chatConfirmDeleteConversation('X'), 'Are you sure you want to delete conversation "X"?');

    // OTP / resend
    expect(l10n.resendAfterSeconds(5), contains('5s'));

    // Errors and formatted messages
    expect(l10n.unknownErrorWithReason('oops'), contains('oops'));
    expect(l10n.welcomeBackUser('Alice'), 'Welcome back, Alice');

    // Actions and transaction messages
    expect(l10n.actionTransfer, 'Transfer');
    expect(l10n.transactionAddedSuccess, 'Transaction added successfully!');
    expect(l10n.deleteTransactionSuccess('T'), 'Deleted transaction "T"');
    expect(l10n.genericErrorWithReason('fail'), 'Error: fail');
    expect(l10n.exportReportFailedWithReason('no space'), contains('no space'));
  });

  test('Vietnamese translations - broad coverage', () {
    final l10n = AppLocalizationsVi();

    // Common labels
    expect(l10n.home, 'Trang chủ');
    expect(l10n.statistics, 'Thống kê');
    expect(l10n.settings, 'Cài đặt');
    expect(l10n.languages, 'Ngôn ngữ');
    expect(l10n.english, 'Tiếng Anh');
    expect(l10n.vietnamese, 'Tiếng Việt');

    // Auth related
    expect(l10n.signupTitle, 'Tạo tài khoản');
    expect(l10n.forgotPassword, 'Quên mật khẩu?');
    expect(l10n.username, 'Tên người dùng');
    expect(l10n.invalidEmail, 'Email không hợp lệ');
    expect(l10n.weakPassword.startsWith('Mật khẩu phải dài'), isTrue);

    // Chat helpers and plurals-like methods
    expect(l10n.chatUpdatedAt('hôm qua'), 'Cập nhật hôm qua');
    expect(l10n.chatConfirmDeleteConversation('Y'), 'Bạn có chắc muốn xóa hội thoại "Y"?');

    // OTP / resend
    expect(l10n.resendAfterSeconds(10), contains('10s'));

    // Errors and formatted messages
    expect(l10n.unknownErrorWithReason('lý do'), contains('lý do'));
    expect(l10n.welcomeBackUser('B'), contains('B'));

    // Actions and transaction messages
    expect(l10n.actionTransfer, 'Chuyển tiền');
    expect(l10n.transactionAddedSuccess, 'Thêm giao dịch thành công!');
    expect(l10n.deleteTransactionSuccess('T'), contains('Đã xóa giao dịch'));
    expect(l10n.genericErrorWithReason('thất bại'), contains('thất bại'));
  });
}