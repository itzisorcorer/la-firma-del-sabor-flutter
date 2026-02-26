import 'package:app_firma_sabor/screens/admin/admin_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/screens/login_screen.dart';
import 'package:app_firma_sabor/screens/main_screen.dart';
import 'package:app_firma_sabor/screens/gestor/gestor_main_screen.dart';
import 'package:app_firma_sabor/services/auth_service.dart';

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
      // En vez de ir al Login directo, pasamos por nuestra aduana secreta
      home: const SplashScreen(),
    );
  }
}

// 🕵️‍♂️ PANTALLA ADUANA (SPLASH SCREEN)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  Future<void> _checkSavedSession() async {
    final authService = AuthService();
    final token = await authService.getToken();
    final role = await authService.getRole();

    // Le damos 1 segundito de gracia para que no se vea un parpadeo brusco
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Si tiene un token válido guardado en su celular
    if (token != null && token.isNotEmpty) {
      // 🚦 Bifurcación de caminos (Igual que en el Login)
      if (role == 'gestor') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GestorMainScreen()));
      } else if(role == 'admin'){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const admin_main_screen()));
      }else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
      }
    } else {
      // Si no hay token, a la pantalla de Login a poner sus datos
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ponemos logo mmientras carga
            Image.asset('assets/images/logo_firma.png', height: 150),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: AppTheme.orangeBrand),
          ],
        ),
      ),
    );
  }
}