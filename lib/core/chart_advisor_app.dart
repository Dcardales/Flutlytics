import 'package:flutter/material.dart';

import '../features/home/home_page.dart';
import 'flutlytics_theme.dart';

class FlutlyticsApp extends StatelessWidget {
  const FlutlyticsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutlytics',
    debugShowCheckedModeBanner: false,
    theme: FlutlyticsTheme.light,
    home: const HomePage(),
  );
}
