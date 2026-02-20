import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/screens/product_detail_screen.dart';
import 'package:app_firma_sabor/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/home_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final HomeService _homeService = HomeService();

  bool _isLoading = true;
  List<dynamic> _categories = [];
  List<dynamic> _recentProducts = [];
  List<dynamic> _recentlyViewed = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _ejecutarBusqueda(String query) {
    print("Buscando en Laravel: $query");

    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(query: query)));
  }
  // Carga los datos desde Laravel
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final data = await _homeService.fetchHomeData();

    if (data.isNotEmpty) {
      setState(() {
        _categories = data['categories'] ?? [];
        _recentProducts = data['recent_products'] ?? [];
        _recentlyViewed = data['recently_viewed'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      // Aquí podrías mostrar un Snackbar de error
    }
  }

  // Cambia el estado del favorito y recarga la interfaz
  void _toggleFavoriteStatus(int productId, List<dynamic> list,
      int index) async {
    try {
      // Optimistic UI: Cambiamos el color al instante para que se sienta rápido
      setState(() {
        list[index]['is_favorite'] = !list[index]['is_favorite'];
      });

      // Llamamos a la API en segundo plano
      final isNowFavorite = await _homeService.toggleFavorite(productId);

      // Si por algo la API devolvió algo diferente a lo que pintamos, lo corregimos
      if (list[index]['is_favorite'] != isNowFavorite) {
        setState(() {
          list[index]['is_favorite'] = isNowFavorite;
        });
      }
    } catch (e) {
      // Si falló la API, revertimos el color
      setState(() {
        list[index]['is_favorite'] = !list[index]['is_favorite'];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar favorito')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.orangeBrand));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BARRA DE BÚSQUEDA ---
// --- 1. BARRA DE BÚSQUEDA ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECE4),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    // CAMBIO AQUÍ: ¡Ahora es un campo de texto de verdad!
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar algo rico...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        // Si presionan Enter en el teclado, también busca
                        if (value.trim().isNotEmpty) {
                          _ejecutarBusqueda(value.trim());
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  button: true,
                  label: "Ejecutar búsqueda",
                  child: GestureDetector(
                    onTap: () {
                      // Al tocar el botón naranja
                      if (_searchController.text.trim().isNotEmpty) {
                        _ejecutarBusqueda(_searchController.text.trim());
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.orangeBrand,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- 2. CATEGORÍAS (Dinámicas) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: _buildCategoryChip(category['name'],
                        Icons.category), // Usamos icono genérico por ahora
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // --- 3. SECCIÓN: AGREGADOS RECIENTEMENTE (Dinámicos) ---
            _buildSectionHeader('Agregados recientemente'),
            const SizedBox(height: 15),
            if (_recentProducts.isEmpty)
              const Text("No hay productos recientes.",
                  style: TextStyle(color: Colors.grey))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_recentProducts.length, (index) {
                    final product = _recentProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _buildProductCard(
                        product: product,
                        onFavoriteTap: () =>
                            _toggleFavoriteStatus(
                                product['product_id'], _recentProducts, index),
                      ),
                    );
                  }),
                ),
              ),

            const SizedBox(height: 30),

            // --- 4. SECCIÓN: ÚLTIMOS VISTOS (Dinámicos) ---
            if (_recentlyViewed.isNotEmpty) ...[
              _buildSectionHeader('Últimos vistos'),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_recentlyViewed.length, (index) {
                    final product = _recentlyViewed[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _buildProductCard(
                        product: product,
                        onFavoriteTap: () =>
                            _toggleFavoriteStatus(
                            product['product_id'], _recentlyViewed, index),
                      ),
                    );
                  }),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS REUTILIZABLES ---
  Widget _buildSectionHeader(String title) {
    return Semantics(
      header: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppTheme.orangeBrand,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const Text(
            'Ver todo',
            style: TextStyle(color: AppTheme.orangeBrand,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.navyBlue, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppTheme.navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProductCard({required Map<String, dynamic> product, required VoidCallback onFavoriteTap}) {
    return Semantics(
      label: "Producto: ${product['name']}, Precio: ${product['price']}.",
      // 1. EL TOQUE DE TODA LA TARJETA (Navega a los detalles)
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product['product_id']),
            ),
          );
        },
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGEN
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  // Bypass temporal
                  'https://media.airedesantafe.com.ar/p/9ac096426bd44b6fe19d566ec41b5083/adjuntos/268/imagenes/003/771/0003771857/1200x0/smart/imagepng.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // INFO
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['description'] ?? '',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 2. EL BOTÓN DE FAVORITOS (Ejecuta la función onFavoriteTap que guarda en la BD)
                        Semantics(
                          button: true,
                          label: product['is_favorite'] == true ? "Quitar de favoritos" : "Añadir a favoritos",
                          child: GestureDetector(
                            onTap: onFavoriteTap, // <-- ESTO FALTABA
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.navyBlue,
                              child: Icon(
                                Icons.bookmark,
                                size: 16,
                                color: product['is_favorite'] == true ? Colors.redAccent : AppTheme.backgroundLight,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product['price'] ?? '', style: const TextStyle(color: AppTheme.navyBlue, fontSize: 16)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.brandYellow, size: 16),
                            Text(product['rating'] ?? '0.0', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}