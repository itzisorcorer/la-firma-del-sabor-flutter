import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/home_service.dart';
import 'package:app_firma_sabor/screens/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final HomeService _homeService = HomeService();
  bool _isLoading = true;
  List<dynamic> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favs = await _homeService.fetchFavorites();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _isLoading = false;
      });
    }
  }

  // Si quita el favorito desde aquí, lo borramos de la lista visualmente
  void _removeFavorite(int productId, int index) async {
    setState(() {
      _favorites.removeAt(index);
    });
    await _homeService.toggleFavorite(productId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eliminado de favoritos'), duration: Duration(seconds: 1)),
      );
    }
  }

  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return Image.asset('assets/images/not_available.jpg', fit: BoxFit.cover);
    if (imagePath.startsWith('http')) return Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/not_available.jpg', fit: BoxFit.cover));
    final serverUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    return Image.network('$serverUrl/storage/$imagePath', fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/not_available.jpg', fit: BoxFit.cover));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mis Favoritos', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.w900)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand))
          : _favorites.isEmpty
          ? const Center(
        child: Text(
          "Aún no tienes productos favoritos...",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.70,
        ),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final product = _favorites[index];
          return GestureDetector(
            onTap: () async {
              // Navegamos y al regresar recargamos por si quitó el favorito en los detalles
              await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product['product_id'])));
              _loadFavorites();
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(height: 120, width: double.infinity, child: _buildImage(product['image_url'])),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'], style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: Text(product['description'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis)),
                            GestureDetector(
                              onTap: () => _removeFavorite(product['product_id'], index), //Función para quitar de favoritos
                              child: const CircleAvatar(radius: 14, backgroundColor: AppTheme.navyBlue, child: Icon(Icons.bookmark, size: 16, color: Colors.redAccent)),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(product['price'], style: const TextStyle(color: AppTheme.navyBlue, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}