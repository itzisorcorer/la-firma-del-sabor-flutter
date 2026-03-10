import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/screens/login_screen.dart';
import 'package:app_firma_sabor/screens/admin/admin_home_tab.dart'; // La crearemos ahorita
import 'package:app_firma_sabor/screens/admin/admin_orders_tab.dart';

import 'admin_creators_list.dart';
import 'create_creator_screen.dart'; // Esta la haremos en el paso 3

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeTab(), // El cascarón de productos
    const AdminOrdersTab(), // Aquí irá admin_orders_tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. APPBAR AMARILLO (Igual que el Gestor)
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        title: Text(
          _currentIndex == 0 ? 'Panel de Administrador' : 'Mis Entregas',
          style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),

      // 2. EL MENÚ HAMBURGUESA (Exactamente el mismo que ya tienes para salir)
      drawer: Drawer(
        backgroundColor: const Color(0xFFF9F5F0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: AppTheme.navyBlue,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                    ),
                    child: Center(child: Image.asset('assets/images/logo_firma.png', height: 100)),
                  ),
                  const SizedBox(height: 10),
                  //crear artesano
                  ListTile(leading: const Icon(Icons.supervised_user_circle_outlined, color: AppTheme.navyBlue), title: const Text('Crear Artesano', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)), onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCreatorScreen()));
                  }),

                  //visualizar artesanos
                  ListTile(leading: const Icon(Icons.supervised_user_circle_outlined, color: AppTheme.navyBlue), title: const Text('Gestionar artesanos', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)), onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCreatorsListScreen()));
                  }),

                  //Acerca de
                  ListTile(leading: const Icon(Icons.info_outline, color: AppTheme.navyBlue), title: const Text('Acerca de', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)), onTap: () {}),
                ],
              ),
            ),
            const Divider(color: Colors.black12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // 3. EL CUERPO
      body: _pages[_currentIndex],

      // 4. BARRA INFERIOR (Agregamos el camioncito)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12, width: 1))),
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
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Entregas'), // 👈 EL NUEVO ÍCONO
          ],
        ),
      ),
    );
  }
}