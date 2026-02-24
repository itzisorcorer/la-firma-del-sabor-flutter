import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/product_service.dart';
import 'package:app_firma_sabor/services/home_service.dart';
import 'package:app_firma_sabor/services/cart_service.dart';
import 'package:app_firma_sabor/screens/creator_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final HomeService _homeService = HomeService(); // Para reciclar la función del toggle

  bool _isLoading = true;
  Map<String, dynamic>? _product;
  bool _isFavorite = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    final data = await _productService.fetchProductDetails(widget.productId);

    if (data != null && mounted) {
      setState(() {
        _product = data['product'];
        _isFavorite = data['is_favorite'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Lógica de Favoritos
  void _toggleFavorite() async {
    // 1. Cambio visual instantáneo
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      // 2. Llamada a Laravel
      final isNowFavorite = await _homeService.toggleFavorite(widget.productId);
      if (_isFavorite != isNowFavorite && mounted) {
        setState(() => _isFavorite = isNowFavorite);
      }
    } catch (e) {
      // 3. Si falla, revertimos
      if (mounted) {
        setState(() => _isFavorite = !_isFavorite);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar favorito')));
      }
    }
  }

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F5F0),
        body: Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand)),
      );
    }

    if (_product == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F5F0),
        body: Center(child: Text("Error al cargar el producto")),
      );
    }

    final creatorName = _product!['creator']?['name'] ?? 'Creador';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0), // Fondo cremita de tu diseño
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // --- 1. IMAGEN DE FONDO (Capa inferior) ---
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Image.network(
                // Bypass con la imagen que SÍ funciona
                'https://media.airedesantafe.com.ar/p/9ac096426bd44b6fe19d566ec41b5083/adjuntos/268/imagenes/003/771/0003771857/1200x0/smart/imagepng.png',
                fit: BoxFit.cover,
              ),
            ),

            // --- 2. CONTENIDO CREMITA (Sube un poco para tapar la foto) ---
            Container(
              margin: const EdgeInsets.only(top: 320), // Empieza en el pixel 320
              decoration: const BoxDecoration(
                color: Color(0xFFF9F5F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 45.0, left: 25.0, right: 25.0, bottom: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      _product!['name'],
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                    ),
                    const SizedBox(height: 10),

                    // Precio y Contador
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_product!['price']}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _decrement,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.navyBlue, width: 1.5),
                                ),
                                child: const Icon(Icons.remove, color: AppTheme.navyBlue, size: 20),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: _increment,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.orangeBrand,
                                  border: Border.all(color: AppTheme.orangeBrand, width: 1.5),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Acerca del producto
                    const Text(
                      "Acerca del producto",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _product!['description'],
                      style: TextStyle(color: AppTheme.navyBlue.withOpacity(0.7), fontSize: 16, height: 1.6),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 25),

                    // Conoce más (Videos en Carrusel Horizontal)
                    const Text(
                      "Conoce más este producto",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                    ),
                    const SizedBox(height: 15),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildVideoLink(),
                          const SizedBox(width: 15),
                          _buildVideoLink(),
                          const SizedBox(width: 15),
                          _buildVideoLink(),
                          const SizedBox(width: 15),
                          _buildVideoLink(), // Puedes agregar más y se deslizarán
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botón Agregar al carrito
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orangeBrand,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          //guarda el producto en el carrito
                          CartService().addToCart(_product!, _quantity);
                          //alerta de exito
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Agregaste $_quantity ${_product!['name']} al carrito! 🛒'),
                              backgroundColor: AppTheme.orangeBrand,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          "Agregar al carrito",
                          style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- 3. BOTONES FLOTANTES ---

            // Botón Conoce a [Creador]
            Positioned(
              top: 300,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  // Navegamos a la pantalla del perfil del creador
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatorProfileScreen(
                        // Ojo: Asegúrate de pasar el ID real si lo tienes a la mano en esta pantalla
                        creatorId: _product!['creator_id'],
                        creatorName: creatorName,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.brandYellow,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppTheme.navyBlue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: AppTheme.navyBlue, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '¡Conoce a $creatorName!',
                        style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón Favoritos
            Positioned(
              top: 295, // Costura
              right: 30,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.navyBlue,
                  child: Icon(
                    Icons.bookmark,
                    color: _isFavorite ? Colors.redAccent : const Color(0xFFF9F5F0),
                    size: 28,
                  ),
                ),
              ),
            ),

            // Botón Atrás
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.reply, color: AppTheme.navyBlue, size: 28),
                ),
              ),
            ),

            // Flecha del carrusel de imágenes
            Positioned(
              top: 150,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: AppTheme.orangeBrand),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLink() {
    return Column(
      children: [
        const Text("video", style: TextStyle(color: AppTheme.navyBlue, fontSize: 14)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Icon(Icons.link, color: Colors.blue, size: 30),
        ),
      ],
    );
  }
}