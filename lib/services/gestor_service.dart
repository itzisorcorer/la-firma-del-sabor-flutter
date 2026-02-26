import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';

class GestorService {
  final AuthService _authService = AuthService();

  // 1. Obtener todas las órdenes de la BD
  Future<List<dynamic>> fetchAllOrders() async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/gestor/orders');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error API Gestor: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión en GestorService: $e');
      return [];
    }
  }
}