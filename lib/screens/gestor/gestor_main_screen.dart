import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/screens/login_screen.dart';
import 'package:app_firma_sabor/screens/gestor/gestor_orders_tab.dart';

class GestorMainScreen extends StatefulWidget {
  const GestorMainScreen({super.key});

  @override
  State<GestorMainScreen> createState() => _GestorMainScreenState();
}

class _GestorMainScreenState extends State<GestorMainScreen> {
  int _currentIndex = 0;

  // Las dos pestañas del gestor
  final List<Widget> _pages = [
    const GestorOrdersTab(),
    const Center(child: Text("Pantalla de Configuración/Perfil", style: TextStyle(fontSize: 20))),
  ];

  // Títulos para el AppBar
  final List<String> _titles = ['Pedidos por procesar', 'Mi Perfil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0), // El fondo hueso del mockup

      // 👇 1. AGREGAMOS EL APPBAR AMARILLO
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: AppTheme.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      // 👇 2. AGREGAMOS EL MENÚ HAMBURGUESA EXACTAMENTE IGUAL AL DEL COMPRADOR
      drawer: Drawer(
        backgroundColor: const Color(0xFFF9F5F0), // Fondo crema
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Encabezado con el fondo marino que acordamos
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: AppTheme.navyBlue,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                    ),
                    child: Center(
                      child: Image.asset('assets/images/logo_firma.png', height: 100),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Opciones genéricas
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppTheme.navyBlue),
                    title: const Text('Acerca de Firma del Sabor', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: AppTheme.navyBlue),
                    title: const Text('Términos y Condiciones', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.accessibility_new, color: AppTheme.navyBlue),
                    title: const Text('Soporte y Accesibilidad', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Botón de Cerrar Sesión
            const Divider(color: Colors.black12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () async {
                // Indicador de carga
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand)),
                );

                // Cerramos sesión
                await AuthService().logout();

                // Navegamos al Login
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      body: _pages[_currentIndex],

      // La Bottom Navigation Bar amarilla
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.brandYellow,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppTheme.navyBlue,
          unselectedItemColor: AppTheme.navyBlue.withOpacity(0.5),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 32,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_outlined),
              activeIcon: Icon(Icons.manage_accounts),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}