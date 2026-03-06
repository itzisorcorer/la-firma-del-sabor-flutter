import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
// Asegúrate de importar el servicio donde pusiste la función createCreator
import 'package:app_firma_sabor/services/admin_service.dart';

class CreateCreatorScreen extends StatefulWidget {
  const CreateCreatorScreen({super.key});

  @override
  State<CreateCreatorScreen> createState() => _CreateCreatorScreenState();
}

class _CreateCreatorScreenState extends State<CreateCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controladores de texto
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();

  // Archivos
  File? _profilePhoto;
  File? _coverPhoto;
  File? _cvFile;
  String? _cvFileName;

  final ImagePicker _picker = ImagePicker();

  // Función para seleccionar fotos
  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery,
    imageQuality: 50,
      maxWidth: 1200
    );
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profilePhoto = File(image.path);
        } else {
          _coverPhoto = File(image.path);
        }
      });
    }
  }

  // Función para seleccionar el PDF
  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // 👈 Restringimos a solo PDFs
    );

    if (result != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
        _cvFileName = result.files.single.name;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _bioCtrl.dispose();
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
            Text('Alta de Artesano', style: TextStyle(color: AppTheme.navyBlue, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SECCIÓN DE FOTOS (Estilo Red Social) ---
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Foto de Portada
                    GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          image: _coverPhoto != null
                              ? DecorationImage(image: FileImage(_coverPhoto!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _coverPhoto == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey.shade400),
                            Text('Toca para agregar foto de portada', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold))
                          ],
                        )
                            : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(backgroundColor: Colors.black54, child: const Icon(Icons.edit, color: Colors.white, size: 20)),
                          ),
                        ),
                      ),
                    ),

                    // Foto de Perfil (Posicionada a la mitad de la portada)
                    Positioned(
                      top: 110,
                      child: GestureDetector(
                        onTap: () => _pickImage(true),
                        child: Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                            image: _profilePhoto != null
                                ? DecorationImage(image: FileImage(_profilePhoto!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _profilePhoto == null
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 50, color: Colors.grey.shade300),
                              const Text('Perfil', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))
                            ],
                          )
                              : null,
                        ),
                      ),
                    ),
                    // Icono de editar perfil
                    if (_profilePhoto != null)
                      Positioned(
                        top: 200,
                        right: MediaQuery.of(context).size.width / 2 - 65,
                        child: const CircleAvatar(radius: 15, backgroundColor: AppTheme.orangeBrand, child: Icon(Icons.edit, color: Colors.white, size: 16)),
                      )
                  ],
                ),
              ),

              // --- 2. FORMULARIO DE TEXTOS ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Nombre del Artesano'),
                    _buildTextField(_nameCtrl, 'Ej. Doña María Elena'),

                    _buildInputLabel('Ubicación / Ciudad'),
                    _buildTextField(_locationCtrl, 'Ej. Oaxaca, Oax.', icon: Icons.location_on_outlined),

                    _buildInputLabel('Biografía e Historia'),
                    _buildTextField(_bioCtrl, 'Cuéntanos la historia detrás de sus recetas...', maxLines: 4),
                    const SizedBox(height: 10),

                    // --- 3. SECCIÓN DEL CURRÍCULUM (PDF) ---
                    _buildInputLabel('Currículum o Documento (Opcional)'),
                    GestureDetector(
                      onTap: _pickCV,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _cvFile != null ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _cvFile != null ? Colors.green : Colors.grey.shade300, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: _cvFile != null ? Colors.green : Colors.redAccent, size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _cvFile != null ? 'Documento cargado' : 'Subir archivo PDF',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: _cvFile != null ? Colors.green : AppTheme.navyBlue),
                                  ),
                                  if (_cvFileName != null)
                                    Text(_cvFileName!, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            if (_cvFile != null)
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => setState(() { _cvFile = null; _cvFileName = null; }),
                              )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- 4. BOTÓN DE GUARDAR ---
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
                            if (_profilePhoto == null || _coverPhoto == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La foto de perfil y portada son obligatorias.'), backgroundColor: Colors.red));
                              return;
                            }

                            setState(() => _isSaving = true);

                            // 👈 LLAMADA AL SERVICIO
                            final success = await AdminService().createCreator(
                              name: _nameCtrl.text,
                              biography: _bioCtrl.text,
                              location: _locationCtrl.text,
                              photo: _profilePhoto!,
                              coverPhoto: _coverPhoto!,
                              cvFile: _cvFile, // Opcional
                            );

                            setState(() => _isSaving = false);

                            if (success) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Artesano registrado con éxito! 🎉'), backgroundColor: Colors.green));
                                Navigator.pop(context); // Regresa al menú
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al registrar artesano.'), backgroundColor: Colors.red));
                              }
                            }
                          }
                        },
                        icon: _isSaving
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                            : const Icon(Icons.save, color: Colors.black),
                        label: Text(
                            _isSaving ? 'Guardando...' : 'Dar de alta artesano',
                            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
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

  // Helpers de diseño para que se vea igual que el resto de tu app
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 15),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 16)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, IconData? icon}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.orangeBrand) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.navyBlue, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.orangeBrand, width: 2)),
      ),
      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
    );
  }
}