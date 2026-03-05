import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/admin_service.dart';
import 'package:app_firma_sabor/screens/admin/create_product_screen.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;

  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];

  // 👇 NUEVO: Variables para los filtros
  List<dynamic> _categories = [];
  String _selectedCategoryId = ''; // Si está vacío, significa "Todos"

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); // Cambiamos el nombre porque ahora carga 2 cosas
  }

  // 1. Cargar productos y categorías al mismo tiempo
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final products = await _adminService.fetchAdminProducts();
    final categories = await _adminService.fetchCategories();

    if (mounted) {
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  // 2. Filtro Maestro (Busca por Texto + Categoría)
  void _applyFilters() {
    final query = _searchCtrl.text.toLowerCase();

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // A) Validar texto
        final name = product['name'].toString().toLowerCase();
        final matchesSearch = name.contains(query);

        // B) Validar categoría tocada
        final matchesCategory = _selectedCategoryId.isEmpty ||
            product['category_id'].toString() == _selectedCategoryId;

        // Mostrar solo si cumple ambas condiciones
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // 3. Obtener la ruta de la imagen
  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset('assets/images/not_available.jpg', fit: BoxFit.cover);
    }
    final serverUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final fullUrl = '$serverUrl/storage/$imagePath';

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/not_available.jpg', fit: BoxFit.cover),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          color: AppTheme.orangeBrand,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    controller: _searchCtrl,
                    onChanged: (val) => _applyFilters(), // 👈 Dispara el filtro al teclear
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

                // FILTROS DINÁMICOS CONECTADOS
                if (_categories.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('', 'Todos', ''), // Botón por defecto para limpiar filtros

                        ..._categories.map((cat) {
                          // Truquito para darle un emoji distinto a cada palabra clave
                          String emoji = '';
                          final catName = cat['name'].toString().toLowerCase();
                          if (catName.contains('bebida')) emoji = '';
                          if (catName.contains('salsa')) emoji = '';
                          if (catName.contains('dulce') || catName.contains('postre')) emoji = '';

                          return Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: _buildFilterChip(cat['category_id'].toString(), cat['name'], emoji),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),

                // LISTA DE PRODUCTOS
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand))
                else if (_filteredProducts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text('No se encontraron productos', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  )
                else
                  ..._filteredProducts.map((product) => _buildProductCard(product)).toList(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // BOTÓN FLOTANTE
        Positioned(
          bottom: 20, left: 20, right: 20,
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orangeBrand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
              ),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateProductScreen()));
                _loadData();
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

  // WIDGET AYUDANTE: Chips Interactivos
  Widget _buildFilterChip(String categoryId, String text, String emoji) {
    final isSelected = _selectedCategoryId == categoryId; // Verifica si es el botón tocado

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategoryId = categoryId); // Guarda el filtro
        _applyFilters(); // Aplica la búsqueda visual
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            color: isSelected ? AppTheme.orangeBrand : Colors.grey.shade100, // Se pinta naranja si está seleccionado
            borderRadius: BorderRadius.circular(15)
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
                text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : AppTheme.navyBlue // Cambia de color para contrastar
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final int stock = product['stock'] ?? 0;
    final bool isLowStock = stock <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 120,
      decoration: BoxDecoration(
          color: const Color(0xFFF9F5F0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
              child: _buildProductImage(product['main_image_url']),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(product['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                        isLowStock ? 'Agotado' : 'Stock: $stock',
                        style: TextStyle(fontSize: 10, color: isLowStock ? Colors.red : Colors.green, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product['price']}', style: const TextStyle(fontSize: 16, color: AppTheme.navyBlue, fontWeight: FontWeight.w900)),
                      GestureDetector(
                        onTap: () {
                          // PRÓXIMAMENTE: Pantalla de Edición
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.edit_square, color: Colors.black87, size: 20),
                            Text('Editar', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                          ],
                        ),
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