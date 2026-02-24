import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/screens/home_tab.dart';
import 'package:app_firma_sabor/screens/cart_screen.dart';
import 'package:app_firma_sabor/services/cart_service.dart';
import 'package:app_firma_sabor/screens/orders_tab.dart';

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
        leading: Semantics(
          label: "Menú principal",
          child: IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.navyBlue, size: 30),
            onPressed: () {},
          ),
        ),
        // Aquí le decimos que cambie el título según la pestaña
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
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10),
        ],
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
            icon: Semantics(label: "Pestaña Inicio", child: Icon(Icons.home)),
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
            icon: Semantics(label: "Pestaña Mis Pedidos", child: Icon(Icons.shopping_bag_outlined)),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}