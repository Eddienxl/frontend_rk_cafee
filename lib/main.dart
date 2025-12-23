import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RKCafeApp());
}

class RKCafeApp extends StatelessWidget {
  const RKCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RK Cafe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D4037)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
