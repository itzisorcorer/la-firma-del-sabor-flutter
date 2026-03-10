import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/order_service.dart';
import 'package:app_firma_sabor/services/product_service.dart';

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

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'pending': return {'text': 'Pendiente', 'color': Colors.orange};
      case 'in_progress': return {'text': 'En Preparación', 'color': Colors.blue};
      case 'labeled': return {'text': 'Etiquetado', 'color': Colors.indigo};
      case 'in_transit': return {'text': 'En Camino', 'color': Colors.purple};
      case 'delivered': return {'text': 'Entregado', 'color': Colors.green};
      case 'canceled': return {'text': 'Cancelado', 'color': Colors.red};
      case 'completed': return {'text': 'Completado', 'color': Colors.purpleAccent};
      default: return {'text': 'Procesando', 'color': Colors.grey};
    }
  }

  //Función para abrir la ventana de calificación
  void _showReviewModal(BuildContext context, int productId, String productName) {
    int _rating = 5;
    final TextEditingController _commentCtrl = TextEditingController();
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  Text('Califica: $productName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyBlue), textAlign: TextAlign.center),
                  const SizedBox(height: 20),

                  // ESTRELLAS INTERACTIVAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: AppTheme.brandYellow,
                          size: 40,
                        ),
                        onPressed: () {
                          setModalState(() => _rating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // CAJA DE COMENTARIOS
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '¿Qué te pareció este producto?',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BOTÓN DE ENVIAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.orangeBrand,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _isSubmitting ? null : () async {
                        setModalState(() => _isSubmitting = true);
                        final success = await ProductService().submitReview(productId, _rating, _commentCtrl.text.trim()
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Cierra el modal
                        }
                        if(success){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gracias por su opinión!'), backgroundColor: Colors.green),
                          );
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hubo un error al enviar su opinión'),
                            ),
                            );
                        }

                      },
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Enviar opinión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
      onRefresh: _loadOrders,
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
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Orden #${order['order_id']}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontSize: 18)),
                    Text('\$${order['total_amount']}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.orangeBrand, fontSize: 18)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusConfig['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(statusConfig['text'], style: TextStyle(color: statusConfig['color'], fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                children: [
                  const Divider(indent: 20, endIndent: 20),
                  ...items.map((item) {
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item['main_image_url'] ?? 'https://via.placeholder.com/50',
                              width: 50, height: 50, fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 14)),
                          subtitle: Text('Cantidad: ${item['amount_item']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          trailing: Text('\$${item['purchase_price']} c/u', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                        ),
                        //Botón de opinar SOLO si la orden está completada
                        if (order['status'] == 'completed')
                          Padding(
                            padding: const EdgeInsets.only(right: 20, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {

                                  final rawId = item['product_id'] ?? item['id'];

                                  if (rawId == null) {

                                    print('No se encontró el ID del producto.');
                                    print('Datos que llegaron de Laravel: $item');

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Error: Faltan datos del producto en la orden.'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }


                                  final int productId = int.tryParse(rawId.toString()) ?? 0;


                                  _showReviewModal(context, productId, item['name'] ?? 'Producto');
                                },
                                icon: const Icon(Icons.star_outline, color: AppTheme.orangeBrand, size: 18),
                                label: const Text("Opinar sobre este producto", style: TextStyle(color: AppTheme.orangeBrand, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ),
                      ],
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