import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.items;

    // ¡Adiós Scaffold! Ahora solo devolvemos un Container con el contenido
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Tu carrito está vacío 🛒", style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              physics: const BouncingScrollPhysics(),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartItem(item, index);
              },
            ),
          ),
          if (cartItems.isNotEmpty) _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0E7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(25)),
            child: Image.network(
              // 👇 SALVAVIDAS 1: Si la imagen es null, usamos la de prueba
              item['image'] ?? 'https://media.airedesantafe.com.ar/p/9ac096426bd44b6fe19d566ec41b5083/adjuntos/268/imagenes/003/771/0003771857/1200x0/smart/imagepng.png',
              width: 110,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          // 👇 SALVAVIDAS 2: Nombre por defecto si viene vacío
                          item['name'] ?? 'Producto delicioso',
                          style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.w900, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _cartService.removeItem(index));
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(Icons.close, color: Colors.grey, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // 👇 SALVAVIDAS 3: Descripción por defecto
                    item['description'] ?? 'Elaborado con los mejores ingredientes...',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item['price'].toStringAsFixed(2)} c/u',
                        style: const TextStyle(color: AppTheme.navyBlue, fontSize: 14),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.orangeBrand, borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _cartService.updateQuantity(index, item['quantity'] - 1)),
                              child: const Icon(Icons.remove, size: 16, color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => setState(() => _cartService.updateQuantity(index, item['quantity'] + 1)),
                              child: const Icon(Icons.add, size: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 25),
      decoration: const BoxDecoration(
        color: AppTheme.navyBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_cartService.totalItems} ítems', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text('seleccionados', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total a pagar:', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('\$${_cartService.totalPagar.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orangeBrand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: _isProcessing
                  ? null // Deshabilita el botón si está cargando
                  : () async {
                setState(() => _isProcessing = true);

                final success = await _cartService.checkout();

                setState(() => _isProcessing = false);

                if (success) {

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Pago exitoso! Tu pedido está en camino'),
                        backgroundColor: Colors.green,
                      ),
                    );

                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hubo un error al procesar el pago'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pagar", style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}