import 'package:flutter/material.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  void _doRegister() async {
    // 1. Validaciones básicas locales
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Llamada al servicio
    final result = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Éxito: Volvemos al Login o vamos al Home (depende de tu flujo)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta creada! Por favor inicia sesión.')),
      );
      Navigator.pop(context); // Regresa al Login
    } else {
      // Error
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
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // --- CAPA 1: EL FONDO (Misma Onda Naranja) ---
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: ExcludeSemantics(
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFFFFCA28)],
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

          // --- CAPA 2: CONTENIDO ---
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Botón para regresar (Accesibilidad)
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
                      tooltip: 'Regresar al inicio de sesión',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Logo pequeño
                  Semantics(
                    label: "Logo de La Firma del Sabor",
                    image: true,
                    child: Image.asset('assets/images/logo_firma.png', height: 135),
                  ),

                  const SizedBox(height: 20),

                  // --- TARJETA BLANCA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
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
                        Semantics(
                          header: true,
                        child: Text(
                          'Crear Cuenta',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                        ),
                        ),
                        const SizedBox(height: 20),


                        // Inputs
                        CustomInput(
                          label: 'Nombre Completo',
                          hint: 'Tu nombre',
                          icon: Icons.person_outline,
                          controller: _nameController,
                        ),
                        CustomInput(
                          label: 'Correo Electrónico',
                          hint: 'ejemplo@correo.com',
                          icon: Icons.email_outlined,
                          type: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        CustomInput(
                          label: 'Contraseña',
                          hint: 'Crea una contraseña segura',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passController,
                        ),
                        CustomInput(
                          label: 'Confirmar Contraseña',
                          hint: 'Repite tu contraseña',
                          icon: Icons.lock_reset,
                          isPassword: true,
                          controller: _confirmPassController,
                        ),

                        const SizedBox(height: 20),

                        // Botón Registrar
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _doRegister,
                            child: _isLoading
                                ? Semantics(
                              label: "Procesando registro, por favor espere...",
                              child: const CircularProgressIndicator(color: Colors.white),
                            )
                                : const Text('REGISTRARSE'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Link a Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta?'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Inicia Sesión'),
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