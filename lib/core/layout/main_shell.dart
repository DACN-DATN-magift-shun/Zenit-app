import 'package:flutter/material.dart';
import 'package:zenit/core/layout/navigation_bar.dart';
import 'package:zenit/features/main/screens/home_content.dart';
import 'package:zenit/features/main/screens/settings_content.dart';
import 'package:zenit/features/main/screens/statistic_content.dart';
import 'package:zenit/features/main/screens/history_content.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _historyTabIndex = 2;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeContent(),      // index 0
          const StatisticContent(), // index 1
          HistoryContent(isActive: _currentIndex == _historyTabIndex), // index 2
          const SettingsContent(),  // index 3
        ],
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
