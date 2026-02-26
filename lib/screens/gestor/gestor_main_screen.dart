import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/screens/login_screen.dart';
import 'package:app_firma_sabor/screens/gestor/gestor_orders_tab.dart';
import 'package:app_firma_sabor/screens/gestor/gestor_assign_tab.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        backgroundColor: const Color(0xFFF9F5F0), // El fondo hueso del mockup

        // 1. EL APPBAR
        appBar: AppBar(
          backgroundColor: AppTheme.brandYellow,
          elevation: 0,
          title: Text(
            _currentIndex == 0 ? 'Panel de gestor' : 'Mi perfil',
            style: const TextStyle(
              color: AppTheme.navyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          bottom: _currentIndex == 0 ? const TabBar(
            indicatorColor: AppTheme.navyBlue,
            labelColor: AppTheme.navyBlue,
            unselectedLabelColor: Colors.black54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Pedidos por procesar'),
              Tab(text: 'Pedidos por asignar'),
            ],
          ) : null,
        ),

        // 2. EL MENÚ HAMBURGUESA
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand)),
                  );

                  await AuthService().logout();

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

        // 3. EL CUERPO (Donde cargan las pestañas o el perfil)
        body: _currentIndex == 0
            ? const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            GestorOrdersTab(),
            GestorAssignTab()
          ],
        )
            : _pages[1],

        // 4. LA BARRA DE NAVEGACIÓN INFERIOR
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
      ),
    );
  }
}