import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTabChange;

  const AppNavigationBar({
    super.key,
    this.selectedIndex = 0,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.light.neutralBackground,
        // color: const Color.fromARGB(255, 80, 45, 45),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadiusMedium),
          topRight: Radius.circular(AppSizes.borderRadiusMedium),
          bottomLeft: Radius.circular(1),
          bottomRight: Radius.circular(0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.navBarPadding,
            vertical: AppSizes.navBarPadding,
          ),
          child: GNav(
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
            gap: AppSizes.m,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.navBarTabPadding,
              vertical: AppSizes.elementSpacing,
            ),
            duration: const Duration(milliseconds: 400),
            backgroundColor: Colors.transparent,
            color: AppColors.light.primaryShade,
            activeColor: AppColors.light.primaryShade,
            tabBackgroundColor: AppColors.light.secondaryMain,
            tabs: const [
              GButton(
                icon: Symbols.home,
                text: 'Home',
                iconSize: AppSizes.iconNav,
              ),
              GButton(
                icon: Symbols.timelapse,
                text: 'Statistics',
                iconSize: AppSizes.iconNav,
              ),
              GButton(
                icon: Symbols.menu,
                text: 'History',
                iconSize: AppSizes.iconNav,
              ),
              GButton(
                icon: Symbols.settings,
                text: 'Settings',
                iconSize: AppSizes.iconNav,
              ),
            ],
          ),
        ),
      ),
    );
  }
}