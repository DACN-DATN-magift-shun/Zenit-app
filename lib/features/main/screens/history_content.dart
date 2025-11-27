import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';

class HistoryContent extends StatelessWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'History',
        showSecondaryText: false,
      ),
      body: const Center(
        child: Text(
          'History Page - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
