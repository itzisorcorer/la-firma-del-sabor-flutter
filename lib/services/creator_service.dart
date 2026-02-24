import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/auth_service.dart';

class CreatorService {
  Future<Map<String, dynamic>?> fetchCreatorProfile(int creatorId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/creators/$creatorId');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Retorna la info del creador + sus productos
      }
      print('Error en API Creador: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error al obtener perfil del creador: $e');
      return null;
    }
  }
}