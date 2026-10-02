import 'package:flutter/material.dart';

import '../features/home/home_page.dart';

class ChartAdvisorApp extends StatelessWidget {
  const ChartAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Chart Advisor',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3154B4)),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    home: const HomePage(),
  );
}
