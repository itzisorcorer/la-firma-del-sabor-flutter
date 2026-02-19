import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';

class ProductService {
  final AuthService _authService = AuthService();

  // GET /api/products/{id}
  Future<Map<String, dynamic>?> fetchProductDetails(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/products/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Contiene 'product' y 'is_favorite'
      } else {
        print('Error del servidor: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }
}