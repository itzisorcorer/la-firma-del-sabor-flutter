import 'package:flutter/material.dart';
import 'package:app_firma_sabor/services/admin_service.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _adminService.fetchMyAssignedOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  // Traducción visual del estado
  String _translateStatus(String dbStatus) {
    switch (dbStatus) {
      case 'in_transit': return 'En camino';
      case 'delivered': return 'Entregado';
      case 'completed': return 'Finalizado';
      default: return dbStatus;
    }
  }

  // Lógica del botón de acción
  Map<String, dynamic> _getButtonAction(String status) {
    switch (status) {
      case 'in_transit': return {'text': 'Marcar como Entregado', 'color': AppTheme.orangeBrand, 'nextStatus': 'delivered'};
      case 'delivered': return {'text': 'Completar Orden', 'color': Colors.greenAccent.shade400, 'nextStatus': 'completed'};
      default: return {'text': 'Finalizado', 'color': Colors.grey, 'nextStatus': null}; // Para 'completed'
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand));

    if (_orders.isEmpty) {
      return const Center(child: Text('No tienes entregas asignadas 🎉', style: TextStyle(fontSize: 18, color: AppTheme.navyBlue)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final currentStatus = order['status'];
        final btnAction = _getButtonAction(currentStatus);

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido #${order['order_id']} - ${order['buyer_name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.navyBlue)),
                    const SizedBox(height: 8),
                    const Row(children: [Icon(Icons.location_on_outlined, size: 16, color: Colors.black54), SizedBox(width: 5), Text('Dirección del cliente...', style: TextStyle(color: Colors.black54))]),
                    const SizedBox(height: 20),

                    // BOTÓN PARA AVANZAR ESTADO
                    Center(
                      child: SizedBox(
                        height: 45, width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: btnAction['color'],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0
                          ),
                          onPressed: btnAction['nextStatus'] == null ? null : () async {
                            bool success = await _adminService.updateOrderStatus(order['order_id'], btnAction['nextStatus']);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Estado actualizado!')));
                              _loadOrders(); // Recargar para ver el nuevo estado
                            }
                          },
                          child: Text(btnAction['text'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PÍLDORA DE ESTADO
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  decoration: BoxDecoration(
                      color: currentStatus == 'completed' ? Colors.green : AppTheme.brandYellow,
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(15))
                  ),
                  child: Text(_translateStatus(currentStatus).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}