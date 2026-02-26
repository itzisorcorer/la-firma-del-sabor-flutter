import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // CONTENIDO PRINCIPAL SCROLLEABLE
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inicio', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.navyBlue)),
              const SizedBox(height: 20),

              // BUSCADOR
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: AppTheme.orangeBrand, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FILTROS HORIZONTALES
              Row(
                children: [
                  _buildFilterChip('🍹', 'Bebidas'),
                  const SizedBox(width: 10),
                  _buildFilterChip('🥫', 'Salsas y aderezos'),
                ],
              ),
              const SizedBox(height: 30),

              // LISTA DE PRODUCTOS (CASCARÓN)
              _buildProductCard('Salsa de tomate', 'Hecha con ingredientes naturales...', '\$50.00 c/u', 'assets/images/salsa_tomate.jpg'),
              _buildProductCard('Guacamole', 'Aguacate traído exclusivamente...', '\$100.00 c/u', 'assets/images/guacamole.jpg'),

              const SizedBox(height: 100), // Espacio para que el botón flotante no tape el último producto
            ],
          ),
        ),

        // BOTÓN FLOTANTE INFERIOR
        Positioned(
          bottom: 20, left: 20, right: 20,
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orangeBrand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                shadowColor: AppTheme.orangeBrand.withOpacity(0.5),
              ),
              onPressed: () {
                // Aquí abriremos el formulario para crear producto después
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.black, size: 28),
                  SizedBox(width: 10),
                  Text('Agregar nuevo producto', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET AYUDANTE: Chips de Filtro
  Widget _buildFilterChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
        ],
      ),
    );
  }

  // WIDGET AYUDANTE: Tarjeta de Producto
  Widget _buildProductCard(String title, String subtitle, String price, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 120,
      decoration: BoxDecoration(color: const Color(0xFFF9F5F0), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          // Imagen (Usamos un contenedor gris por si no tienes las imágenes aún)
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            ),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)), // Cambiar por Image.asset cuando tengas las fotos
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: const TextStyle(fontSize: 16, color: AppTheme.navyBlue)),
                      Column(
                        children: [
                          const Icon(Icons.edit_square, color: Colors.black87),
                          Text('Editar', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}