import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'screens/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
  // responsive helpers
  final double width = MediaQuery.of(context).size.width;
  final bool compact = width < 380; // breakpoint for small devices
  // smaller paddings to allow labels to remain visible on narrow screens
  final EdgeInsets gnavPadding = compact
    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
    : const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  final double gap = compact ? 4 : 8;
  final EdgeInsets outerPadding = compact
    ? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 14.0)
    : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 🩵 Gradient nền (để glass thấy rõ)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF74ABE2),
                  Color(0xFF5563DE),
                  Color(0xFFB798F8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 📜 Nội dung mô phỏng danh sách
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
            itemCount: 15,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color.fromRGBO(255, 255, 255, 0.12),
                          child: Icon(
                            index % 2 == 0
                                ? Icons.shopping_bag_rounded
                                : Icons.restaurant_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              index % 2 == 0 ? 'Shopping' : 'Food & Drink',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Nov ${5 - index ~/ 3}, 2025',
                                style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      index % 2 == 0 ? '-\$${20 + index}' : '-\$${12 + index}',
                        style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // 💎 iOS Glassmorphism Navbar (responsive)
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          // reduce outer margin so the nav is more compact
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ✨ Hiệu ứng ánh sáng nghiêng (refraction)
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
                      transform: const GradientRotation(-0.8), // góc -45°
                    ),
                  ),
                ),
              ),

              // 💧 Hiệu ứng glass blur chính
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.08), // độ trong
                    borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                      color: Color.fromRGBO(255, 255, 255, 0.18),
                      width: 1.4,
                    ),
                    boxShadow: [
                      // Shadow ngoài (depth)
                      BoxShadow(
                        color: Color.fromRGBO(255, 255, 255, 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                      // Giả lập inner shadow nhẹ (nếu Flutter <3.10 không support inset)
                      BoxShadow(
                        color: Color.fromRGBO(116, 137, 255, 0.12),
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
                          // Navigate to Login screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      tabs: [
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
      ),
    );
  }
}
