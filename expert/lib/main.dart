import 'package:flutter/material.dart';
import 'user/dashboard.dart';
import 'admin/dashboard_admin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expert Printing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E4CB9)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
      routes: {'/admin-dashboard': (context) => const DashboardAdminPage()},
    );
  }
}
