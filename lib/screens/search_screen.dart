import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/product_service.dart';
import 'package:app_firma_sabor/services/home_service.dart';
import 'package:app_firma_sabor/screens/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final HomeService _homeService = HomeService();

  bool _isLoading = true;
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _realizarBusqueda();
  }

  Future<void> _realizarBusqueda() async {
    final data = await _productService.searchProducts(widget.query);
    if (mounted) {
      setState(() {
        _results = data;
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(int productId, int index) async {
    setState(() => _results[index]['is_favorite'] = !_results[index]['is_favorite']);
    try {
      final isNowFavorite = await _homeService.toggleFavorite(productId);
      if (_results[index]['is_favorite'] != isNowFavorite && mounted) {
        setState(() => _results[index]['is_favorite'] = isNowFavorite);
      }
    } catch (e) {
      setState(() => _results[index]['is_favorite'] = !_results[index]['is_favorite']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buscando: "${widget.query}"',
          style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand))
          : _results.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos columnas
          childAspectRatio: 0.7, // Proporción de las tarjetas
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final product = _results[index];
          return _buildSearchProductCard(product, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text(
            'No encontramos "${widget.query}"\n¡Intenta con otra cosa!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Usamos una versión adaptada de tu tarjeta para que quepa en el Grid
  Widget _buildSearchProductCard(Map<String, dynamic> product, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product['product_id']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  'https://media.airedesantafe.com.ar/p/9ac096426bd44b6fe19d566ec41b5083/adjuntos/268/imagenes/003/771/0003771857/1200x0/smart/imagepng.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product['price'], style: const TextStyle(color: AppTheme.navyBlue, fontSize: 13)),
                      GestureDetector(
                        onTap: () => _toggleFavorite(product['product_id'], index),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.navyBlue,
                          child: Icon(
                            Icons.bookmark,
                            size: 14,
                            color: product['is_favorite'] ? Colors.redAccent : AppTheme.backgroundLight,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}