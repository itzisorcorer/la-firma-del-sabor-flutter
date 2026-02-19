import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
// Importaremos el contenido de Inicio en el siguiente paso
import 'package:app_firma_sabor/screens/home_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Controla qué pestaña está activa

  // Lista de las pantallas que irán en el centro
  final List<Widget> _pages = [
    const HomeTab(), // Índice 0: Inicio
    const Center(child: Text('Carrito en construcción 🛒')), // Índice 1: Carrito
    const Center(child: Text('Mis Pedidos en construcción 🛍️')), // Índice 2: Bolsa
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,

      // --- BARRA SUPERIOR AMARILLA ---
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        // Menú hamburguesa a la izquierda
        leading: Semantics(
          label: "Menú principal",
          child: IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.navyBlue, size: 30),
            onPressed: () {
              // TODO: Abrir Drawer
            },
          ),
        ),
        // Título centrado
        title: Text(
          'Inicio',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // En el mockup está a la izquierda del centro

        // Icono de perfil a la derecha
        actions: [
          Semantics(
            label: "Mi perfil",
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined, color: AppTheme.navyBlue, size: 35),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10), // Espacio al borde
        ],
      ),

      // --- EL CONTENIDO CAMBIANTE ---
      body: _pages[_currentIndex],

      // --- BARRA INFERIOR AMARILLA ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.brandYellow,
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.navyBlue, // Azul oscuro cuando está activo
        unselectedItemColor: AppTheme.navyBlue.withOpacity(0.5), // Medio transparente inactivo
        showSelectedLabels: false, // El mockup no tiene textos abajo
        showUnselectedLabels: false,
        iconSize: 32,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Semantics(label: "Pestaña Inicio", child: Icon(Icons.home)),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Semantics(label: "Pestaña Carrito", child: Icon(Icons.shopping_cart_outlined)),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Semantics(label: "Pestaña Mis Pedidos", child: Icon(Icons.shopping_bag_outlined)),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}