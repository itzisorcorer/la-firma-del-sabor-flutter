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
  String _selectedFilter = 'Todos';

  // Solo mostraremos los filtros relevantes para esta etapa
  final List<String> _filters = ['Todos', 'pending', 'in_progress', 'labeled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _gestorService.fetchAllOrders();
    if (mounted) {
      setState(() {
        // En esta pestaña SOLO mostramos los que no han sido asignados
        _orders = orders.where((o) => ['pending', 'in_progress', 'labeled'].contains(o['status'])).toList();
        _isLoading = false;
      });
    }
  }

  // Traducción visual
  String _translateStatus(String dbStatus) {
    switch (dbStatus) {
      case 'pending': return 'Pendiente';
      case 'in_progress': return 'En proceso';
      case 'labeled': return 'Etiquetado';
      default: return dbStatus;
    }
  }

  // Configuración interactiva del botón
  Map<String, dynamic> _getButtonAction(String status) {
    switch (status) {
      case 'pending': return {'text': 'Empezar a preparar', 'color': AppTheme.orangeBrand, 'nextStatus': 'in_progress'};
      case 'in_progress': return {'text': 'Marcar como etiquetado', 'color': AppTheme.orangeBrand, 'nextStatus': 'labeled'};
      case 'labeled': return {'text': 'Asignar Administrador', 'color': AppTheme.orangeBrand, 'nextStatus': 'unassigned'};
      default: return {'text': 'Actualizando...', 'color': Colors.grey, 'nextStatus': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand));

    final filteredOrders = _selectedFilter == 'Todos'
        ? _orders
        : _orders.where((o) => o['status'] == _selectedFilter).toList();

    return Column(
      children: [
        const SizedBox(height: 15),
        // CARRUSEL DE FILTROS
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.navyBlue.withOpacity(isSelected ? 1.0 : 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text(filter == 'Todos' ? 'Todos' : _translateStatus(filter), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        // TARJETAS
        Expanded(
          child: filteredOrders.isEmpty
              ? const Center(child: Text('No hay pedidos en esta fase 📦', style: TextStyle(color: AppTheme.navyBlue, fontSize: 18)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final String currentStatus = order['status'];
              final btnAction = _getButtonAction(currentStatus);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pedido #${order['order_id']} - 2x Productos', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.navyBlue)),
                          const SizedBox(height: 8),
                          Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.black54), const SizedBox(width: 5), Text('Hace unos minutos', style: TextStyle(color: Colors.grey.shade700, fontSize: 14))]),
                          const SizedBox(height: 20),

                          // BOTÓN MÁGICO
                          Center(
                            child: SizedBox(
                              height: 45, width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: btnAction['color'], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                                onPressed: () async {
                                  if (btnAction['nextStatus'] != null) {
                                    // Lanzamos la actualización a Laravel
                                    bool success = await _gestorService.updateOrder(order['order_id'], status: btnAction['nextStatus']);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Estado actualizado!')));
                                      _loadOrders(); // Recargamos la lista
                                    }
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
                        decoration: const BoxDecoration(color: AppTheme.brandYellow, borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(15))),
                        child: Text(_translateStatus(currentStatus).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}