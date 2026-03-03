import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores para los campos de texto
  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _neighborhoodCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _postalCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _birthDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserProfile();
    if (userData != null && mounted) {
      setState(() {
        _streetCtrl.text = userData['street'] ?? '';
        _neighborhoodCtrl.text = userData['neighborhood'] ?? '';
        _cityCtrl.text = userData['city'] ?? '';
        _stateCtrl.text = userData['state'] ?? '';
        _postalCtrl.text = userData['postal_code'] ?? '';
        _phoneCtrl.text = userData['phone_number'] ?? '';
        _birthDateCtrl.text = userData['birth_date'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }
  // 👇 FUNCIÓN PARA MOSTRAR EL CALENDARIO
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Fecha por defecto al abrir
      firstDate: DateTime(1920),   // Lo más viejo que pueden seleccionar
      lastDate: DateTime.now(),    // No pueden nacer en el futuro
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.orangeBrand, // Color de la cabecera
              onPrimary: Colors.black, // Color del texto en la cabecera
              onSurface: AppTheme.navyBlue, // Color de los días
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formateamos para Laravel: YYYY-MM-DD
        _birthDateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }


  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final data = {
      'street': _streetCtrl.text,
      'neighborhood': _neighborhoodCtrl.text,
      'city': _cityCtrl.text,
      'state': _stateCtrl.text,
      'postal_code': _postalCtrl.text,
      'phone_number': _phoneCtrl.text,
      'birth_date': _birthDateCtrl.text,
    };

    final success = await _authService.updateProfile(data);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '¡Dirección guardada con éxito!' : 'Error al guardar'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) Navigator.pop(context); // Regresamos al Home si todo salió bien
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        title: const Text('Mi Perfil', style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.navyBlue),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información personal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.navyBlue)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextField(
                controller: _birthDateCtrl,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: const Icon(Icons.cake_outlined, color: AppTheme.navyBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.brandYellow, width: 2)),
                ),
              ),
            ),

            _buildTextField('Calle y número', _streetCtrl, Icons.home_outlined),
            _buildTextField('Colonia / Barrio', _neighborhoodCtrl, Icons.location_city_outlined),

            Row(
              children: [
                Expanded(child: _buildTextField('Ciudad', _cityCtrl, null)),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField('Estado', _stateCtrl, null)),
              ],
            ),

            Row(
              children: [
                Expanded(child: _buildTextField('C.P.', _postalCtrl, Icons.markunread_mailbox_outlined)),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField('Teléfono', _phoneCtrl, Icons.phone_outlined)),
              ],
            ),

            const SizedBox(height: 40),

            // Botón de Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orangeBrand,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Guardar Dirección', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: AppTheme.navyBlue) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.brandYellow, width: 2)),
        ),
      ),
    );
  }
}