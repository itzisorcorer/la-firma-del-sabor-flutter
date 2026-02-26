import 'package:flutter/material.dart';
import 'package:app_firma_sabor/services/gestor_service.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';

class GestorOrdersTab extends StatefulWidget {
  const GestorOrdersTab({super.key});

  @override
  State<GestorOrdersTab> createState() => _GestorOrdersTabState();
}

class _GestorOrdersTabState extends State<GestorOrdersTab> {
  final GestorService _gestorService = GestorService();
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _gestorService.fetchAllOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand));
    }

    if (_orders.isEmpty) {
      return const Center(child: Text('No hay pedidos por procesar 📦', style: TextStyle(fontSize: 18, color: AppTheme.navyBlue)));
    }

    // Por ahora solo mostraremos una lista básica para confirmar que llegan los datos
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Card(
          child: ListTile(
            title: Text('Pedido #${order['order_id']} - Cliente: ${order['buyer_name']}'),
            subtitle: Text('Estado actual: ${order['status']}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 15),
          ),
        );
      },
    );
  }
}