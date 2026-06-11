import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_confirm_dialog.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/main_layout.dart';
import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/authenticated_network_image.dart';
import 'package:zenit/features/main/widgets/setting/setting_items.dart';
import 'package:zenit/features/photos/services/photo_service.dart';

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  final AuthService _authService = AuthService();
  final PhotoService _photoService = PhotoService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  Response? _userInfoResponse;
  String? _resolvedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    final isAuth = await _authService.isAuthenticated();

    if (isAuth) {
      final response = await _authService.getUserInfo();

      if (response != null && response.statusCode == 200) {
        final resolvedAvatarUrl = await _resolveAvatarUrl(response.data);
        setState(() {
          _isAuthenticated = true;
          _userInfoResponse = response;
          _resolvedAvatarUrl = resolvedAvatarUrl;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // Bắt buộc đăng nhập
      NavigationService.instance.pushAndRemoveUntil('/login');
    }
  }

  Future<String?> _resolveAvatarUrl(dynamic rawData) async {
    final data = (rawData is Map && rawData['data'] is Map)
        ? Map<String, dynamic>.from(rawData['data'])
        : (rawData is Map)
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    final directUrl =
        (data['avatar'] ?? data['avatarUrl'] ?? data['photoUrl'] ?? data['url'])
            as String?;
    if (directUrl != null && directUrl.isNotEmpty) {
      return directUrl;
    }

    final photoId = (data['photoId'] ?? data['photoID']) as String?;
    if (photoId == null || photoId.isEmpty) {
      return null;
    }

    try {
      final photo = await _photoService.getPhotoById(photoId);
      return photo.url;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleLogout() async {
    final l10n = context.l10n;

    final confirm = await AppConfirmDialog.show(
      context: context,
      title: l10n.logoutConfirmTitle,
      message: l10n.logoutConfirmMessage,
      confirmText: l10n.logout,
      isDestructive: true,
    );

    if (!confirm || !mounted) return;

    try {
      await _authService.logout();

      if (!mounted) return;

      NavigationService.instance.pushAndRemoveUntil(
        '/login',
        arguments: {'snackMessage': l10n.logoutSuccess},
      );
    } catch (e) {
      if (!mounted) return;
      AppFlash.error(context, l10n.unknownErrorWithReason(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainLayout(
      appBar: CommonAppBar(title: l10n.settings, showSecondaryText: false),
      child: _isAuthenticated && _userInfoResponse != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.s,
                horizontal: AppSizes.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User profile card (avatar, name, username, chevron)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.l,
                      vertical: AppSizes.l,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).extension<AppColorExtension>()!.neutralBackground,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusLarge,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).extension<AppColorExtension>()!.primaryShade,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).extension<AppColorExtension>()!.primaryMain,
                              width: 2.5, // tăng độ dày của border
                            ),
                          ),
                          child: ClipOval(child: _buildAvatar()),
                        ),
                        const SizedBox(width: 12),

                        // Name + username
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // vi hienj tai chi co usser name, nen se dung user name thay the cho name nhe
                                (_userInfoResponse!.data['username']
                                        as String?) ??
                                    l10n.notLoggedIn,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.usernameLabel(
                                  (_userInfoResponse!.data['username']
                                          as String?) ??
                                      'N/A',
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).extension<AppColorExtension>()!.neutralBackground,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            icon: Icon(
                              Symbols.expand_circle_right,
                              size: 36, // reduced size
                              color: Theme.of(
                                context,
                              ).extension<AppColorExtension>()!.primaryActive,
                            ),
                            onPressed: () {
                              // Navigate to account details within settings
                              NavigationService.instance
                                  .navigateTo('/settings/account_details')
                                  ?.then((_) => _loadUserInfo());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SettingItem(
                    icon: Symbols.settings_rounded,
                    title: l10n.generalSettingsItem,
                    onTap: () {
                      NavigationService.instance.navigateTo(
                        '/settings/general',
                      );
                    },
                  ),
                  SettingItem(
                    icon: Symbols.style_rounded,
                    title: l10n.categoryManagement,
                    onTap: () {
                      NavigationService.instance.navigateTo(
                        '/settings/category_manage',
                      );
                    },
                  ),
                  SettingItem(
                    icon: Symbols.account_balance_wallet_rounded,
                    title: l10n.moneySourceManagement,
                    onTap: () {
                      NavigationService.instance.navigateTo(
                        '/settings/money_source_manage',
                      );
                    },
                  ),
                  SettingItem(
                    icon: Symbols.notifications_rounded,
                    title: l10n.notifications,
                    onTap: () {
                      NavigationService.instance.navigateTo(
                        '/settings/notifications',
                      );
                    },
                  ),
                  SettingItem(
                    icon: Symbols.shield_toggle,
                    title: l10n.security,
                  ),
                  SettingItem(
                    icon: Symbols.support_agent_rounded,
                    title: l10n.supportCenter,
                    onTap: () {
                      NavigationService.instance.navigateTo(
                        '/settings/contact-us',
                      );
                    },
                  ),
                  SettingItem(
                    icon: Symbols.privacy_tip_rounded,
                    title: l10n.privacyPolicyAndTerms,
                    onTap: () {
                      NavigationService.instance.navigateTo(
                        '/settings/terms-and-privacy',
                      );
                    },
                  ),
                  SettingItem(
                    icon: Symbols.logout_rounded,
                    title: l10n.logout,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.notLoggedIn,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.pleaseLogin,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      NavigationService.instance.pushAndRemoveUntil('/login');
                    },
                    icon: const Icon(Symbols.login),
                    label: Text(l10n.loginButton),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget _buildInfoRow(String label, String value) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 80,
  //           child: Text(
  //             '$label:',
  //             style: const TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAvatar() {
    final avatarUrl = _resolvedAvatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return AuthenticatedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        errorBuilder: (context, error, stack) => _avatarFallback(),
      );
    }

    return _avatarFallback();
  }

  Widget _avatarFallback() {
    final username = _userInfoResponse?.data['username'] as String?;
    final String initial = (username != null && username.isNotEmpty)
        ? username[0].toUpperCase()
        : '?';

    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
