import 'package:app_firma_sabor/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/screens/home_tab.dart';
import 'package:app_firma_sabor/screens/cart_screen.dart';
import 'package:app_firma_sabor/services/cart_service.dart';
import 'package:app_firma_sabor/screens/orders_tab.dart';
// 👇 IMPORTAMOS EL SERVICIO Y LA PANTALLA DE LOGIN
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 1. Aquí metemos la pantalla real del carrito
  final List<Widget> _pages = [
    const HomeTab(),
    const CartScreen(), // ¡Nuestra pestaña real!
    const OrdersTab(),
  ];

  // 2. Títulos dinámicos para el AppBar superior
  final List<String> _titles = ['Inicio', 'Mi Carrito', 'Mis Pedidos'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,

      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        // Eliminamos el 'leading' manual para que Flutter ponga el ícono de hamburguesa automático que abre el Drawer
        title: Text(
          _titles[_currentIndex],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Semantics(
            label: "Mi perfil",
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined, color: AppTheme.navyBlue, size: 35),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // 👇 AQUÍ AGREGAMOS NUESTRO MENÚ LATERAL (DRAWER)
      drawer: Drawer(
        backgroundColor: const Color(0xFFF9F5F0), // Fondo crema
        child: Column(
          children: [
            // PARTE SUPERIOR (Opciones del menú)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Encabezado del menú
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: AppTheme.navyBlue,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(1)),
                    ),
                    child: Center(
                      child: Image.asset('assets/images/logo_firma.png', height: 200),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Opciones de relleno
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

            //Botón de Cerrar Sesión)
            const Divider(color: Colors.black12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () async {
                // 1. Mostramos indicador de carga (opcional pero se ve pro)
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand)),
                );

                // 2. Borramos el token y el rol de la memoria del teléfono
                await AuthService().logout();

                // 3. Navegamos al LoginScreen y destruimos el historial de pantallas
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 30), // Espacio abajo para que no pegue con el borde del celular
          ],
        ),
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.brandYellow,
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.navyBlue,
        unselectedItemColor: AppTheme.navyBlue.withOpacity(0.5),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 32,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Cambio de pestaña natural
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Semantics(label: "Pestaña Inicio", child: const Icon(Icons.home)),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Pestaña Carrito",
              child: Badge(
                isLabelVisible: CartService().totalItems > 0,
                label: Text(
                  CartService().totalItems.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Semantics(label: "Pestaña Mis Pedidos", child: const Icon(Icons.shopping_bag_outlined)),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}