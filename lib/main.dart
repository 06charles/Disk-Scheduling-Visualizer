import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/dashboard_screen.dart';

void main() {
  runApp(const DiskSchedulerApp());
}

class DiskSchedulerApp extends StatelessWidget {
  const DiskSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disk Scheduling Visualizer',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF00BFFF),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        textTheme: GoogleFonts.robotoMonoTextTheme(
          ThemeData.light().textTheme.apply(bodyColor: Colors.black87, displayColor: Colors.black87),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00BFFF),
          secondary: Color(0xFF008000), // Darker green for light mode
          surface: Colors.white,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
