import 'package:flutter/material.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/widgets/custom_input.dart';
import 'package:app_firma_sabor/screens/register_screen.dart';
import 'package:app_firma_sabor/screens/gestor/gestor_main_screen.dart';
import 'package:app_firma_sabor/screens/admin/admin_main_screen.dart';

import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _doLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.login(
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Bienvenido!')),
      );


      final String role = result['user']['role'] ?? 'comprador';

      if (role == 'gestor') {
        // Al panel de Gestor
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const GestorMainScreen()),
              (route) => false,
        );
      } else if (role == 'admin') {
        //al panel de admin
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const admin_main_screen()), (route) => false,
        );

      }else{
        //al home de comprador
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
        );

      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Para saber el tamaño de la pantalla
    final theme = Theme.of(context);

    return Scaffold(
      // Usamos Stack para encimar elementos
      body: Stack(
        children: [

          // CAPA 1: EL FONDO (La forma naranja superior derecha)

          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: ExcludeSemantics(
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(

                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    const Color(0xFFFFCA28),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size.width),
                ),
              ),
            ),
            ),
          ),


          // CAPA 2: EL CONTENIDO (La tarjeta blanca central)

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 50), // Espacio superior para no tapar la onda

                  // --- LOGO (Fuera de la tarjeta)
                  Semantics(
                    label: "Logo de La Firma del Sabor.",
                    image: true,
                    child: Image.asset(
                      'assets/images/logo_firma.png',
                      height: 200,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- LA TARJETA BLANCA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface, // Blanco superficie
                      borderRadius: BorderRadius.circular(24), // Bordes redondeados
                      boxShadow: [

                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Título
                        Semantics(
                        child: Text(
                          '¡Hola, bienvenido!',
                          style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        ),
                        Text(
                          'Inicia sesión en tu cuenta',
                          style: theme.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 30),

                        // Inputs
                        CustomInput(
                          label: 'Correo Electrónico',
                          hint: 'ejemplo@correo.com',
                          icon: Icons.email_outlined,
                          type: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        CustomInput(
                          label: 'Contraseña',
                          hint: '********',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passController,
                        ),

                        // Olvidé contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botón Login
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _doLogin,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                            ),

                            child: _isLoading
                            ? Semantics(
                              label: "Iniciando sesión, por favor espere...",
                                child: const CircularProgressIndicator(color: Colors.white)
                          )
                                : const Text('INGRESAR'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ENLACE REGISTRO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()),);
                        },
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}