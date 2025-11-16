// THIS IS JUST A DRAFT TO SHOW THE COMMONS USAGE, NOT THE FINAL IMPLEMENTATION
import 'package:flutter/material.dart';
import 'package:zenit/common/layout/navigation_bar.dart';
import 'package:zenit/common/layout/app_bar.dart';

// THIS IS JUST A DRAFT TO SHOW THE COMMONS USAGE, NOT THE FINAL IMPLEMENTATION
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
// THIS IS JUST A DRAFT TO SHOW THE COMMONS USAGE, NOT THE FINAL IMPLEMENTATION

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Wellcome back, Tuan',
        showSecondaryText: true,
        secondaryText: "Have a nice day!",
      ),
      bottomNavigationBar: const AppNavigationBar(),
    );
  }
}
