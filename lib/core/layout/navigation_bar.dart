import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    // Lấy kích thước màn hình để chỉnh padding cho hợp lý
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
              // Lớp nền Gradient mờ ảo
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromRGBO(255, 255, 255, 0.20),
                        const Color.fromRGBO(255, 255, 255, 0.02),
                      ],
                      stops: const [0.0, 1.0],
                      transform: const GradientRotation(-0.8),
                    ),
                  ),
                ),
              ),
              // Lớp Blur và nội dung chính
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
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(255, 255, 255, 0.08),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(116, 137, 255, 0.12),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: outerPadding,
                    child: GNav(
                      selectedIndex: selectedIndex,
                      gap: gap,
                      padding: gnavPadding,
                      backgroundColor: Colors.transparent,
                      color: Colors.blue.shade900, // Màu icon khi chưa chọn
                      activeColor: Colors.blue.shade800, // Màu icon khi ĐANG chọn
                      tabBackgroundColor: const Color.fromRGBO(255, 255, 255, 0.5),
                      onTabChange: onTabChange,
                      tabs: const [

                        GButton(icon: Symbols.home, text: 'Home'),
                        GButton(icon: Symbols.bar_chart, text: 'Statistic'), // Thay timelapse cho hợp
                        GButton(icon: Symbols.history, text: 'History'),
                        GButton(icon: Symbols.settings, text: 'Settings'), // Bỏ cái fill: 1.0 đi
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