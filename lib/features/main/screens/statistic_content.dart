import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';

class StatisticContent extends StatelessWidget {
  const StatisticContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Statistic',
        showSecondaryText: false,
      ),
      body: const Center(
        child: Text(
          'Statistic Page - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
