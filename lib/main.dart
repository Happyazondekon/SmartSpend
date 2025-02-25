import 'package:flutter/material.dart';
import 'budget_screen.dart';

void main() {
  runApp(SmartSpendApp());
}

class SmartSpendApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartSpend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BudgetScreen(),
    );
  }
}