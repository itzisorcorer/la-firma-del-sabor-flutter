import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/admin_service.dart';

class EditCreatorScreen extends StatefulWidget {
  final Map<String, dynamic> creatorData;

  const EditCreatorScreen({super.key, required this.creatorData});

  @override
  State<EditCreatorScreen> createState() => _EditCreatorScreenState();
}

class _EditCreatorScreenState extends State<EditCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _bioCtrl;

  File? _profilePhoto;
  File? _coverPhoto;
  File? _cvFile;
  String? _cvFileName;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Precargamos los datos existentes
    _nameCtrl = TextEditingController(text: widget.creatorData['name'] ?? '');
    _locationCtrl = TextEditingController(text: widget.creatorData['location'] ?? '');
    _bioCtrl = TextEditingController(text: widget.creatorData['biography'] ?? '');
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?q=80';
    if (path.startsWith('http')) return path;
    final serverUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    return '$serverUrl/storage/$path';
  }

  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // 👈 La Bala de Plata
      maxWidth: 1200,
    );
    if (image != null) {
      setState(() {
        if (isProfile) _profilePhoto = File(image.path);
        else _coverPhoto = File(image.path);
      });
    }
  }

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
        _cvFileName = result.files.single.name;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _locationCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definimos qué foto mostrar: Si hay una nueva, la mostramos. Si no, mostramos la de internet.
    ImageProvider coverProvider = _coverPhoto != null
        ? FileImage(_coverPhoto!) as ImageProvider
        : CachedNetworkImageProvider(_getFullImageUrl(widget.creatorData['cover_photo_url']));

    ImageProvider profileProvider = _profilePhoto != null
        ? FileImage(_profilePhoto!) as ImageProvider
        : CachedNetworkImageProvider(_getFullImageUrl(widget.creatorData['photo_url']));

    bool hasPdf = _cvFile != null || widget.creatorData['cv_url'] != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow, elevation: 0,
        leading: IconButton(
          icon: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.reply, color: AppTheme.navyBlue)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Panel de Administrador', style: TextStyle(color: AppTheme.navyBlue, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Editar Artesano', style: TextStyle(color: AppTheme.navyBlue, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN FOTOS ---
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 180, width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade200, image: DecorationImage(image: coverProvider, fit: BoxFit.cover)),
                        child: Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.all(10.0), child: CircleAvatar(backgroundColor: Colors.black54, child: const Icon(Icons.edit, color: Colors.white, size: 20)))),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      child: GestureDetector(
                        onTap: () => _pickImage(true),
                        child: Container(
                          height: 130, width: 130,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))], image: DecorationImage(image: profileProvider, fit: BoxFit.cover)),
                        ),
                      ),
                    ),
                    Positioned(top: 200, right: MediaQuery.of(context).size.width / 2 - 65, child: const CircleAvatar(radius: 15, backgroundColor: AppTheme.orangeBrand, child: Icon(Icons.edit, color: Colors.white, size: 16)))
                  ],
                ),
              ),

              // --- FORMULARIO ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Nombre del Artesano'), _buildTextField(_nameCtrl, 'Ej. Doña María Elena'),
                    _buildInputLabel('Ubicación / Ciudad'), _buildTextField(_locationCtrl, 'Ej. Oaxaca, Oax.', icon: Icons.location_on_outlined),
                    _buildInputLabel('Biografía e Historia'), _buildTextField(_bioCtrl, 'Cuéntanos la historia...', maxLines: 4),
                    const SizedBox(height: 10),

                    // --- SECCIÓN CV (PDF) ---
                    _buildInputLabel('Currículum o Documento'),
                    GestureDetector(
                      onTap: _pickCV,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: hasPdf ? Colors.green.withOpacity(0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: hasPdf ? Colors.green : Colors.grey.shade300, width: 2)),
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: hasPdf ? Colors.green : Colors.redAccent, size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hasPdf ? 'Documento actual guardado' : 'Subir archivo PDF', style: TextStyle(fontWeight: FontWeight.bold, color: hasPdf ? Colors.green : AppTheme.navyBlue)),
                                  if (_cvFileName != null) Text('NUEVO: $_cvFileName', style: const TextStyle(fontSize: 12, color: AppTheme.orangeBrand, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const Icon(Icons.upload_file, color: AppTheme.navyBlue)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- BOTÓN ACTUALIZAR ---
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orangeBrand, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: _isSaving ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isSaving = true);

                            final success = await AdminService().updateCreator(
                              id: widget.creatorData['creator_id'],
                              name: _nameCtrl.text, biography: _bioCtrl.text, location: _locationCtrl.text,
                              photo: _profilePhoto, coverPhoto: _coverPhoto, cvFile: _cvFile,
                            );

                            setState(() => _isSaving = false);

                            if (success) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Artesano actualizado! 🎉'), backgroundColor: Colors.green));
                                Navigator.pop(context, true); // Regresamos 'true' para indicar que hubo cambios
                              }
                            } else {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar.'), backgroundColor: Colors.red));
                            }
                          }
                        },
                        icon: _isSaving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3)) : const Icon(Icons.save, color: Colors.black),
                        label: Text(_isSaving ? 'Guardando...' : 'Actualizar datos', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 5, top: 15), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)));
  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, IconData? icon}) => TextFormField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400), prefixIcon: icon != null ? Icon(icon, color: AppTheme.orangeBrand) : null, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.navyBlue, width: 1)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.orangeBrand, width: 2))), validator: (value) => value!.isEmpty ? 'Campo requerido' : null);
}