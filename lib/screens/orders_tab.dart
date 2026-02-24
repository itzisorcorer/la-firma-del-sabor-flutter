import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/order_service.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _orderService.fetchMyOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  //Colores por nivel de estatus
  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'pending': return {'text': 'Pendiente', 'color': Colors.orange};
      case 'in_progress': return {'text': 'En Preparación', 'color': Colors.blue};
      case 'labeled': return {'text': 'Etiquetado', 'color': Colors.indigo};
      case 'in_transit': return {'text': 'En Camino', 'color': Colors.purple};
      case 'delivered': return {'text': 'Entregado', 'color': Colors.green};
      case 'canceled': return {'text': 'Cancelado', 'color': Colors.red};
      default: return {'text': 'Procesando', 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand));
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text("Aún no tienes pedidos", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.orangeBrand,
      onRefresh: _loadOrders, // Deslizar para recargar
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(20),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final statusConfig = _getStatusConfig(order['status']);
          final items = order['items'] as List<dynamic>;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Theme(
              // Quitamos las lineas raras del ExpansionTile por defecto
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Orden #${order['order_id']}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontSize: 18),
                    ),
                    Text(
                      '\$${order['total_amount']}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.orangeBrand, fontSize: 18),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 5),
                      Text(order['date'], style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      const Spacer(),
                      // Píldora de estatus
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusConfig['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          statusConfig['text'],
                          style: TextStyle(color: statusConfig['color'], fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Aquí adentro van los productos cuando el usuario despliega la tarjeta
                children: [
                  const Divider(indent: 20, endIndent: 20),
                  ...items.map((item) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['main_image_url'] ?? 'https://via.placeholder.com/50',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 14)),
                      subtitle: Text('Cantidad: ${item['amount_item']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: Text('\$${item['purchase_price']} c/u', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}