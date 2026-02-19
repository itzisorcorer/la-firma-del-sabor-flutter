import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/screens/login_screen.dart';


void main() {
  runApp(const AppFirmaSabor());
}

class AppFirmaSabor extends StatelessWidget {
  const AppFirmaSabor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'La Firma del Sabor',

      theme: AppTheme.lightTheme,

      home: const LoginScreen(),
    );
  }
}