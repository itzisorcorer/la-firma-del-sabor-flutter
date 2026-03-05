import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final int productId; //ID del producto a editar

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores de texto
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _accessibilityCtrl = TextEditingController();
  final TextEditingController _expirationCtrl = TextEditingController();

  // Listas de Base de Datos
  List<dynamic> _creators = [];
  List<dynamic> _categories = [];
  List<dynamic> _subcategories = [];
  List<dynamic> _filteredSubcategories = [];

  // Variables seleccionadas
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedCreator;
  bool _isActive = true;

  // Archivos existentes y nuevos
  List<dynamic> _existingImages = [];
  List<dynamic> _existingVideos = [];
  List<String> _deletedImages = [];
  List<String> _deletedVideos = [];

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<TextEditingController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  //Descargamos todos y llenamos los campos
  Future<void> _loadInitialData() async {
    try {
      final token = await AuthService().getToken();
      final headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

      // 1. Traer los detalles del producto
      final prodData = await ProductService().fetchProductDetails(widget.productId);
      final prod = prodData?['product'];

      if (prod != null) {
        _nameCtrl.text = prod['name'] ?? '';
        _priceCtrl.text = prod['price']?.toString() ?? '';
        _stockCtrl.text = prod['stock']?.toString() ?? '';
        _descCtrl.text = prod['description'] ?? '';
        _accessibilityCtrl.text = prod['accessibility_description'] ?? '';
        _expirationCtrl.text = prod['expiration_date'] ?? '';
        _isActive = prod['status'] == 1 || prod['status'] == true;
        _selectedSubcategory = prod['subcategory_id']?.toString();
        _selectedCreator = prod['creator_id']?.toString();
        _existingImages = prod['images'] ?? [];
        _existingVideos = prod['videos'] ?? [];
      }

      // 2. Traer Creadoras
      final creatorsRes = await http.get(Uri.parse('${ApiConstants.baseUrl}/creators'), headers: headers);
      if (creatorsRes.statusCode == 200) {
        _creators = jsonDecode(creatorsRes.body)['data'];
      }

      // 3. Traer Categorías para llenar los Dropdowns
      final catRes = await http.get(Uri.parse('${ApiConstants.baseUrl}/categories-data'), headers: headers);
      if (catRes.statusCode == 200) {
        final catData = jsonDecode(catRes.body)['data'];
        _categories = catData['categories'];
        _subcategories = catData['subcategories'];

        // Truco: Buscamos a qué Categoría Madre pertenece la Subcategoría del producto
        if (_selectedSubcategory != null) {
          final sub = _subcategories.firstWhere((s) => s['subcategory_id'].toString() == _selectedSubcategory, orElse: () => null);
          if (sub != null) {
            _selectedCategory = sub['category_id'].toString();
            _filteredSubcategories = _subcategories.where((s) => s['category_id'].toString() == _selectedCategory).toList();
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error cargando edición: $e");
      setState(() => _isLoading = false);
    }
  }

  // Función para procesar imágenes de Laravel (igual que en el Home)
  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final serverUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    return '$serverUrl/storage/$path';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.orangeBrand, onPrimary: Colors.white, onSurface: AppTheme.navyBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _expirationCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) setState(() => _selectedImages.addAll(images));
  }

  @override
  void dispose() {
    for (var ctrl in _videoControllers) { ctrl.dispose(); }
    _nameCtrl.dispose(); _priceCtrl.dispose(); _stockCtrl.dispose();
    _descCtrl.dispose(); _accessibilityCtrl.dispose(); _expirationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        leading: IconButton(
          icon: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.reply, color: AppTheme.navyBlue)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Panel de Administrador', style: TextStyle(color: AppTheme.navyBlue, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Editar producto', style: TextStyle(color: AppTheme.navyBlue, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- IMÁGENES ACTUALES ---
              if (_existingImages.isNotEmpty) ...[
                const Text('Imágenes actuales', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImages.length,
                    itemBuilder: (context, index) {
                      final img = _existingImages[index];
                      return Stack(
                        children: [
                          Container(
                            width: 100, margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(image: NetworkImage(_getImageUrl(img['image_url'])
                              ),
                              fit: BoxFit.cover
                              ),
                            ),

                          ),
                          //----------Boton de eliminar foto
                          Positioned(
                            top: 5, right: 20,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _deletedImages.add(img['image_url']);
                                  _existingImages.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 15, color: Colors.white)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // --- NUEVAS IMÁGENES ---
              const Text('Agregar MÁS imágenes', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 120, margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(color: const Color(0xFFF9F5F0), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 40, color: AppTheme.navyBlue), SizedBox(height: 5), Text('Agregar foto', style: TextStyle(color: AppTheme.navyBlue, fontSize: 12))]),
                      ),
                    ),
                    ..._selectedImages.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 120, margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: FileImage(File(entry.value.path)), fit: BoxFit.cover)),
                          ),
                          Positioned(top: 5, right: 20, child: GestureDetector(onTap: () => setState(() => _selectedImages.removeAt(entry.key)), child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 15, color: Colors.white)))),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- FORMULARIO PRECARGADO ---
              _buildInputLabel('Nombre del producto'),
              _buildTextField(_nameCtrl, 'Ej. Salsa boloñesa'),

              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('Precio (\$)'), _buildTextField(_priceCtrl, '\$00.00', isNumber: true)])),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('Stock disponible'), _buildTextField(_stockCtrl, 'Cantidad', isNumber: true)])),
                ],
              ),

              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildInputLabel('Categoría'),
                    _buildDynamicDropdown(
                      items: _categories, idKey: 'category_id', nameKey: 'name', hint: 'Seleccionar...', selectedValue: _selectedCategory,
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val; _selectedSubcategory = null;
                          _filteredSubcategories = _subcategories.where((sub) => sub['category_id'].toString() == val).toList();
                        });
                      },
                    ),
                  ])),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildInputLabel('Subcategoría'),
                    _buildDynamicDropdown(items: _filteredSubcategories, idKey: 'subcategory_id', nameKey: 'name', hint: 'Seleccionar...', selectedValue: _selectedSubcategory, onChanged: (val) => setState(() => _selectedSubcategory = val)),
                  ])),
                ],
              ),

              Row(children: [_buildInputLabel('Estado (Activo)'), Checkbox(value: _isActive, activeColor: AppTheme.navyBlue, onChanged: (val) => setState(() => _isActive = val!))]),

              _buildInputLabel('Descripción del producto'),
              _buildTextField(_descCtrl, 'Escribe los detalles aquí...', maxLines: 3),

              _buildInputLabel('Descripción para accesibilidad'),
              _buildTextField(_accessibilityCtrl, 'Ej. Frasco de vidrio con salsa roja...', maxLines: 2),

              _buildInputLabel('Artesano que vende este producto'),
              _buildDynamicDropdown(items: _creators, idKey: 'creator_id', nameKey: 'name', hint: 'Seleccionar artesano...', selectedValue: _selectedCreator, onChanged: (val) => setState(() => _selectedCreator = val)),

              _buildInputLabel('Fecha de caducidad (Opcional)'),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(child: _buildTextField(_expirationCtrl, 'YYYY-MM-DD', icon: Icons.calendar_today)),
              ),

              const SizedBox(height: 15),

              // --- VIDEOS ---
              if (_existingVideos.isNotEmpty) ...[
                const Text('Videos actuales', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
                const SizedBox(height: 5),
                ..._existingVideos.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var v = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.ondemand_video, color: AppTheme.navyBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(v['url_youtube'], style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        // ------------Botón de eliminar video actual----------------
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _deletedVideos.add(v['url_youtube']); // Se va a la lista negra
                              _existingVideos.removeAt(idx);        // Desaparece de la vista
                            });
                          },
                        )
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 15),
              ],

              const Text('Agregar MÁS enlaces de video (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
              ..._videoControllers.asMap().entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 10, top: 10), child: Row(children: [Expanded(child: _buildTextField(entry.value, 'https://youtube.com/...')), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() { _videoControllers[entry.key].dispose(); _videoControllers.removeAt(entry.key); }))]))),

              TextButton.icon(onPressed: () => setState(() => _videoControllers.add(TextEditingController())), icon: const Icon(Icons.add_link, color: AppTheme.orangeBrand), label: const Text('Agregar enlace de video', style: TextStyle(color: AppTheme.orangeBrand, fontWeight: FontWeight.bold))),

              const SizedBox(height: 40),

              // --- BOTÓN FINAL DE GUARDAR ---
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orangeBrand, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: _isSaving ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isSaving = true);

                      List<String> videosToSave = _videoControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

                      Map<String, dynamic> dataToSend = {
                        'name': _nameCtrl.text, 'price': _priceCtrl.text, 'stock': _stockCtrl.text,
                        'description': _descCtrl.text, 'accessibility_description': _accessibilityCtrl.text,
                        'status': _isActive ? '1' : '0', 'subcategory_id': _selectedSubcategory, 'creator_id': _selectedCreator,
                      };
                      if (_expirationCtrl.text.isNotEmpty) dataToSend['expiration_date'] = _expirationCtrl.text;

                      final success = await ProductService().updateProducts(
                        productId: widget.productId,
                        productData: dataToSend,
                        newImages: _selectedImages,
                        newVideos: videosToSave,
                        deletedVideos: _deletedVideos,
                        deletedImages: _deletedImages,
                      );

                      setState(() => _isSaving = false);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Producto actualizado exitosamente! 🚀'), backgroundColor: Colors.green));
                        Navigator.pop(context); // 👈 Regresa al catálogo
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar.'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  icon: _isSaving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3)) : const Icon(Icons.save, color: Colors.black),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar cambios', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 5, top: 10), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)));
  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1, IconData? icon}) => TextFormField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400), suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.navyBlue, width: 1)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.orangeBrand, width: 2))), validator: (value) => value!.isEmpty ? 'Campo requerido' : null);
  Widget _buildDynamicDropdown({required List<dynamic> items, required String idKey, required String nameKey, required String hint, required String? selectedValue, required Function(String?) onChanged}) => DropdownButtonFormField<String>(isExpanded: true, value: selectedValue, decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.navyBlue, width: 1)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.orangeBrand, width: 2))), hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14), overflow: TextOverflow.ellipsis), icon: const Icon(Icons.arrow_drop_down, color: AppTheme.navyBlue), items: items.map<DropdownMenuItem<String>>((item) => DropdownMenuItem<String>(value: item[idKey].toString(), child: Text(item[nameKey].toString(), overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged, validator: (value) => value == null ? 'Obligatorio' : null);
}