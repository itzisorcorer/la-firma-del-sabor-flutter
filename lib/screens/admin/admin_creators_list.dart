import 'dart:convert';
import 'package:app_firma_sabor/screens/admin/edit_creator_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/auth_service.dart';

class AdminCreatorsListScreen extends StatefulWidget {
  const AdminCreatorsListScreen({super.key});

  @override
  State<AdminCreatorsListScreen> createState() => _AdminCreatorsListScreenState();
}

class _AdminCreatorsListScreenState extends State<AdminCreatorsListScreen> {
  bool _isLoading = true;
  List<dynamic> _creators = [];

  @override
  void initState() {
    super.initState();
    _loadCreators();
  }

  // 📡 Descargamos la lista de creadores directamente desde Laravel
  Future<void> _loadCreators() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/creators'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _creators = jsonDecode(response.body)['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error cargando creadores: $e");
      setState(() => _isLoading = false);
    }
  }

  //Traductor de rutas para las fotos
  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'assets/images/not_available.png';
    }
    if (path.startsWith('http')) return path;
    final serverUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    return '$serverUrl/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0), // Color cremita de fondo
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
            Text('Gestión de Artesanos', style: TextStyle(color: AppTheme.navyBlue, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand))
          : _creators.isEmpty
          ? const Center(
        child: Text("Aún no hay artesanos registrados...", style: TextStyle(color: Colors.grey, fontSize: 16)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: _creators.length,
        itemBuilder: (context, index) {
          final creator = _creators[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.backgroundLight,
                backgroundImage: CachedNetworkImageProvider(_getFullImageUrl(creator['photo_url'])),
              ),
              title: Text(
                creator['name'] ?? 'Sin nombre',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(creator['location'] ?? 'Ubicación desconocida', style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
              trailing: CircleAvatar(
                backgroundColor: AppTheme.orangeBrand.withOpacity(0.1),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.orangeBrand),
                  onPressed: () async{
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditCreatorScreen(creatorData: creator),
                    ),
                    );
                    //si se actualiza, recargamos la pagina
                    if(result == true){
                      _loadCreators();
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}