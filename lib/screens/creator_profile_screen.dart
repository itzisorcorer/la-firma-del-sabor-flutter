import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/creator_service.dart';
import 'package:app_firma_sabor/screens/product_detail_screen.dart';

class CreatorProfileScreen extends StatefulWidget {
  final int creatorId;
  final String creatorName;

  const CreatorProfileScreen({
    super.key,
    required this.creatorId,
    required this.creatorName,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  final CreatorService _creatorService = CreatorService();
  bool _isLoading = true;
  Map<String, dynamic>? _creatorData;

  @override
  void initState() {
    super.initState();
    _loadCreatorProfile();
  }

  Future<void> _loadCreatorProfile() async {
    final data = await _creatorService.fetchCreatorProfile(widget.creatorId);
    if (mounted) {
      setState(() {
        _creatorData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. PANTALLA DE CARGA
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand)),
      );
    }

    // 2. ERROR SI NO LLEGAN DATOS
    if (_creatorData == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppTheme.navyBlue)),
        body: const Center(child: Text('Error al cargar el perfil del creador', style: TextStyle(color: AppTheme.navyBlue, fontSize: 18))),
      );
    }

    // 3. LA PANTALLA REAL CON DATOS DE LA BD
    return Scaffold(
      backgroundColor: const Color(0xFFE1AEA2),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // IMAGEN DE FONDO
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_creatorData!['background_image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // BOTÓN DE REGRESAR
            Positioned(
              top: 40,
              left: 20,
              child: CircleAvatar(
                backgroundColor: const Color(0xFFE1AEA2),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.navyBlue),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // CONTENEDOR BLANCO PRINCIPAL
            Container(
              margin: const EdgeInsets.only(top: 240),
              padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F6F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _creatorData!['name'],
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _creatorData!['specialty'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppTheme.brandYellow, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '${_creatorData!['rating']} (${_creatorData!['reviews_count']} opiniones)',
                        style: const TextStyle(fontSize: 14, color: AppTheme.navyBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // SECCIÓN: SOBRE EL CREADOR
                  _buildSectionTitle('Sobre ${_creatorData!['name'].split(' ').take(2).join(' ')}'),
                  const SizedBox(height: 10),
                  Text(
                    _creatorData!['about'],
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 30),

                  // SECCIÓN: MEJORES VALORADOS
                  _buildSectionTitle('Mejores valorados'),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: (_creatorData!['best_rated'] as List).map((product) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: _buildMiniProductCard(product),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // SECCIÓN: RESEÑAS DESTACADAS
                  _buildSectionTitle('Reseñas destacadas'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
                    ),
                    child: Text(
                      _creatorData!['featured_review'],
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // BOTÓN NARANJA FINAL
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.orangeBrand,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text("Conoce su biografía", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            // FOTO DE PERFIL (SUPERPUESTA)
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundLight,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_creatorData!['profile_image']),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
    );
  }

  Widget _buildMiniProductCard(Map<String, dynamic> product) {
    final String imageUrl = product['image'] ?? 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?q=80&w=400&auto=format&fit=crop';
    final String name = product['name'] ?? 'Producto sin nombre';
    final String description = product['description'] ?? 'Sin descripción disponible.';
    final String price = product['price']?.toString() ?? '0.00';
    final String rating = product['rating']?.toString() ?? '5.0';

    return GestureDetector(
      onTap: () {
        // Viajamos al detalle de este producto en específico
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product['product_id']),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white, // La tarjeta se queda blanca para resaltar sobre el hueso
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100, width: double.infinity, color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$$price c/u', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 12)),
                      GestureDetector(
                        onTap: () {
                          // Aquí irá tu lógica de agregar a favoritos después
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name guardado en favoritos'), duration: const Duration(seconds: 1)),
                          );
                        },
                        child: const Icon(Icons.bookmark, color: AppTheme.navyBlue, size: 18),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.brandYellow, size: 14),
                      Text(rating, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}