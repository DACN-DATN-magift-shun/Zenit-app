import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/common/utils/services/navigation_service.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool compact = width < 380;
    final EdgeInsets gnavPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    final double gap = compact ? 4 : 8;
    final EdgeInsets outerPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 14.0)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0);

    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(255, 255, 255, 0.20),
                        Color.fromRGBO(255, 255, 255, 0.02),
                      ],
                      stops: const [0.0, 1.0],
                      transform: const GradientRotation(-0.8),
                    ),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 255, 255, 0.18),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(255, 255, 255, 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: const Color.fromRGBO(116, 137, 255, 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: outerPadding,
                    child: GNav(
                      gap: gap,
                      padding: gnavPadding,
                      backgroundColor: Colors.transparent,
                      color: Colors.blue.shade900,
                      activeColor: Colors.blue.shade800,
                      tabBackgroundColor: const Color.fromRGBO(255, 255, 255, 0.5),
                      onTabChange: (index) {
                        if (index == 4) {
                          NavigationService.instance.navigateTo('/login');
                        }
                      },
                      tabs: const [
                        GButton(icon: Symbols.home_app_logo_rounded, text: 'Home'),
                        GButton(icon: Symbols.timelapse_rounded, text: 'Statistic'),
                        GButton(icon: Symbols.view_object_track, text: 'History'),
                        GButton(icon: Symbols.settings_rounded, text: 'Settings'),
                        GButton(icon: Symbols.login_rounded, text: 'Login'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

