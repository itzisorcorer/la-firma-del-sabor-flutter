import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';

class AdminService {
  final AuthService _authService = AuthService();

  // 1. Obtener SOLO los pedidos asignados a este admin
  Future<List<dynamic>> fetchMyAssignedOrders() async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/admin/orders');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error API Admin: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión en AdminService: $e');
      return [];
    }
  }

  // 2. Actualizar el estado del pedido (a entregado o finalizado)
  Future<bool> updateOrderStatus(int orderId, String status) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/admin/orders/$orderId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar orden: $e');
      return false;
    }
  }
}