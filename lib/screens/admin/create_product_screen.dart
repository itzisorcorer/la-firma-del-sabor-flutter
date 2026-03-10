import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/services/product_service.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controladores de texto estándar
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _accessibilityCtrl = TextEditingController();
  final TextEditingController _expirationCtrl = TextEditingController();

  //istas para almacenar los datos de la Base de Datos
  List<dynamic> _creators = [];
  List<dynamic> _categories = [];
  List<dynamic> _subcategories = [];
  List<dynamic> _filteredSubcategories = []; // Para el filtro dinámico

  // Variables para guardar las selecciones
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedCreator;
  bool _isActive = true;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<TextEditingController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  //Función para buscar los datos de las listas
  Future<void> _loadDropdownData() async {
    try {
      final token = await AuthService().getToken();
      final headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

      // 1. Traer Creadoras
      final creatorsRes = await http.get(Uri.parse('${ApiConstants.baseUrl}/creators'), headers: headers);
      if (creatorsRes.statusCode == 200) {
        setState(() {
          _creators = jsonDecode(creatorsRes.body)['data'];
        });
      }

      // 2. Traer Categorías y Subcategorías
      final catRes = await http.get(Uri.parse('${ApiConstants.baseUrl}/categories-data'), headers: headers);
      if (catRes.statusCode == 200) {
        final catData = jsonDecode(catRes.body)['data'];
        setState(() {
          _categories = catData['categories'];
          _subcategories = catData['subcategories'];
        });
      }

    } catch (e) {
      print("Error cargando listas reales: $e");
    }
  }

  // 👇 NUEVO: Función para abrir el calendario nativo
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030), // Límite máximo
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.orangeBrand, // Color de cabecera
              onPrimary: Colors.white,
              onSurface: AppTheme.navyBlue, // Color del texto
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Formateamos para que Laravel lo entienda: YYYY-MM-DD
        _expirationCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 1200,
    );
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _addVideoField() {
    setState(() => _videoControllers.add(TextEditingController()));
  }

  void _removeVideoField(int index) {
    setState(() {
      _videoControllers[index].dispose();
      _videoControllers.removeAt(index);
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.reply, color: AppTheme.navyBlue),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Panel de Administrador', style: TextStyle(color: AppTheme.navyBlue, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Crear nuevo producto', style: TextStyle(color: AppTheme.navyBlue, fontSize: 20, fontWeight: FontWeight.w900)),
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

              const Text('Imágenes del producto', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F5F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 40, color: AppTheme.navyBlue),
                            SizedBox(height: 5),
                            Text('Agregar foto', style: TextStyle(color: AppTheme.navyBlue, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    ..._selectedImages.asMap().entries.map((entry) {
                      int idx = entry.key;
                      XFile image = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(image: FileImage(File(image.path)), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 5, right: 20,
                            child: GestureDetector(
                              onTap: () => _removeImage(idx),
                              child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 15, color: Colors.white)),
                            ),
                          ),
                          if (idx == 0)
                            Positioned(
                              bottom: 5, left: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.brandYellow, borderRadius: BorderRadius.circular(10)),
                                child: const Text('Portada', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            )
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              _buildInputLabel('Nombre del producto'),
              _buildTextField(_nameCtrl, 'Ej. Salsa boloñesa'),

              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildInputLabel('Precio (\$)'),
                    _buildTextField(_priceCtrl, '\$00.00', isNumber: true),
                  ])),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildInputLabel('Stock disponible'),
                    _buildTextField(_stockCtrl, 'Cantidad', isNumber: true),
                  ])),
                ],
              ),

              // 👇 NUEVO: Dropdowns Conectados y Filtrados
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildInputLabel('Categoría'),
                    _buildDynamicDropdown(
                      items: _categories,
                      idKey: 'category_id',
                      nameKey: 'name',
                      hint: 'Seleccionar...',
                      selectedValue: _selectedCategory,
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                          _selectedSubcategory = null; // Reiniciar subcategoría
                          // Filtrar subcategorías
                          _filteredSubcategories = _subcategories
                              .where((sub) => sub['category_id'].toString() == val)
                              .toList();
                        });
                      },
                    ),
                  ])),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildInputLabel('Subcategoría'),
                    _buildDynamicDropdown(
                      items: _filteredSubcategories, // Se llena según la categoría
                      idKey: 'subcategory_id',
                      nameKey: 'name',
                      hint: 'Seleccionar...',
                      selectedValue: _selectedSubcategory,
                      onChanged: (val) => setState(() => _selectedSubcategory = val),
                    ),
                  ])),
                ],
              ),

              Row(
                children: [
                  _buildInputLabel('Estado (Activo)'),
                  Checkbox(
                    value: _isActive,
                    activeColor: AppTheme.navyBlue,
                    onChanged: (val) => setState(() => _isActive = val!),
                  ),
                ],
              ),

              _buildInputLabel('Descripción del producto'),
              _buildTextField(_descCtrl, 'Escribe los detalles aquí...', maxLines: 3),

              _buildInputLabel('Descripción para accesibilidad'),
              _buildTextField(_accessibilityCtrl, 'Ej. Frasco de vidrio con salsa roja...', maxLines: 2),

              // 👇 NUEVO: Dropdown conectado a Creadoras
              _buildInputLabel('Artesano que vende este producto'),
              _buildDynamicDropdown(
                items: _creators,
                idKey: 'creator_id',
                nameKey: 'name',
                hint: 'Seleccionar artesano...',
                selectedValue: _selectedCreator,
                onChanged: (val) => setState(() => _selectedCreator = val),
              ),

              // 👇 NUEVO: Input que abre el Calendario
              _buildInputLabel('Fecha de caducidad (Opcional)'),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer( // AbsorbPointer evita que salga el teclado normal
                  child: _buildTextField(_expirationCtrl, 'YYYY-MM-DD', icon: Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 15),

              const Text('Agrega los enlaces de video (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
              const SizedBox(height: 10),

              ..._videoControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(child: _buildTextField(ctrl, 'https://youtube.com/...')),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeVideoField(idx),
                      )
                    ],
                  ),
                );
              }),

              TextButton.icon(
                onPressed: _addVideoField,
                icon: const Icon(Icons.add_link, color: AppTheme.orangeBrand),
                label: const Text('Agregar otro enlace de video', style: TextStyle(color: AppTheme.orangeBrand, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orangeBrand,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _isSaving ? null : () async {
                    if (_formKey.currentState!.validate()) {

                      if (_selectedImages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes agregar al menos la foto de portada', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                        return;
                      }

                      setState(() => _isSaving = true);

                      List<String> videosToSave = _videoControllers
                          .map((ctrl) => ctrl.text.trim())
                          .where((text) => text.isNotEmpty)
                          .toList();

                      Map<String, dynamic> dataToSend = {
                        'name': _nameCtrl.text,
                        'price': _priceCtrl.text,
                        'stock': _stockCtrl.text,
                        'description': _descCtrl.text,
                        'accessibility_description': _accessibilityCtrl.text,
                        'status': _isActive ? '1' : '0',
                        'subcategory_id': _selectedSubcategory, // ID Real
                        'creator_id': _selectedCreator,         // ID Real
                      };

                      if (_expirationCtrl.text.isNotEmpty) {
                        dataToSend['expiration_date'] = _expirationCtrl.text;
                      }

                      final success = await ProductService().createProduct(
                        productData: dataToSend,
                        images: _selectedImages,
                        videos: videosToSave,
                      );

                      setState(() => _isSaving = false);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Producto creado exitosamente! 🚀'), backgroundColor: Colors.green));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al crear el producto.'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  icon: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                      : const Icon(Icons.add, color: Colors.black),
                  label: Text(
                      _isSaving ? 'Guardando...' : 'Agregar nuevo producto',
                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1, IconData? icon}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.navyBlue, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.orangeBrand, width: 2)),
      ),
      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
    );
  }

  //Componente universal para pintar los Dropdowns
  Widget _buildDynamicDropdown({
    required List<dynamic> items,
    required String idKey,
    required String nameKey,
    required String hint,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedValue,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.navyBlue, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.orangeBrand, width: 2)),
      ),
      hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      overflow: TextOverflow.ellipsis,
      ),
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.navyBlue),
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item[idKey].toString(),
          child: Text(item[nameKey].toString(),
          overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Obligatorio' : null,
    );
  }
}