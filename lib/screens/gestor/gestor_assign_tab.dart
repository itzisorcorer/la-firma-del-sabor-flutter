import 'package:flutter/material.dart';
import 'package:app_firma_sabor/services/gestor_service.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';

class GestorAssignTab extends StatefulWidget {
  const GestorAssignTab({super.key});

  @override
  State<GestorAssignTab> createState() => _GestorAssignTabState();
}

class _GestorAssignTabState extends State<GestorAssignTab> {
  final GestorService _gestorService = GestorService();
  bool _isLoading = true;
  List<dynamic> _orders = [];
  List<dynamic> _admins = [];

  // Para guardar qué administrador selecciona en el dropdown cada tarjeta
  Map<int, int?> _selectedAdmins = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final adminsData = await _gestorService.fetchAdmins();
    final ordersData = await _gestorService.fetchAllOrders();

    if (mounted) {
      setState(() {
        _admins = adminsData;
        // En esta pestaña mostramos los 'unassigned' o los que ya están 'in_transit' (asignados)
        _orders = ordersData.where((o) => ['unassigned', 'in_transit'].contains(o['status'])).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand));

    return Column(
      children: [
        const SizedBox(height: 15),
        // APLICARÍAN LOS FILTROS DE NOMBRES DE ADMIN AQUÍ... (Simplificado por espacio)

        Expanded(
          child: _orders.isEmpty
              ? const Center(child: Text('No hay pedidos por asignar 🚚', style: TextStyle(color: AppTheme.navyBlue, fontSize: 18)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              final isAssigned = order['assigned_admin_id'] != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pedido #${order['order_id']} - 2x Productos', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.navyBlue)),
                      const SizedBox(height: 15),

                      // EL DROPDOWN DE ADMINISTRADORES
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(15)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            hint: const Text('Elige 1 administrador...'),
                            // Valor seleccionado actualmente (o el de la BD)
                            value: _selectedAdmins[order['order_id']] ?? order['assigned_admin_id'],
                            items: _admins.map((admin) {
                              return DropdownMenuItem<int>(
                                value: admin['id'],
                                child: Row(children: [const Icon(Icons.grid_view, size: 20, color: Colors.grey), const SizedBox(width: 10), Text(admin['name'])]),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedAdmins[order['order_id']] = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // LOS BOTONES DEL MOCKUP 7
                      Center(
                        child: !isAssigned
                            ? SizedBox(
                          height: 45, width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orangeBrand, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                            onPressed: () async {
                              final chosenAdmin = _selectedAdmins[order['order_id']];
                              if (chosenAdmin != null) {
                                // Asignamos admin y cambiamos el estado para que empiece el envío
                                bool success = await _gestorService.updateOrder(order['order_id'], adminId: chosenAdmin, status: 'in_transit');
                                if (success) _loadData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona un administrador')));
                              }
                            },
                            child: const Text('Asignar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                              onPressed: () {}, child: const Text('Asignado', style: TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                              onPressed: () async {
                                final chosenAdmin = _selectedAdmins[order['order_id']];
                                if (chosenAdmin != null) {
                                  bool success = await _gestorService.updateOrder(order['order_id'], adminId: chosenAdmin);
                                  if (success) _loadData();
                                }
                              }, child: const Text('Reasignar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}