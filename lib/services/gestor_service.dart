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
  //Obtener lista de administradores
  Future<List<dynamic>> fetchAdmins() async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/gestor/admins');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error al obtener admins: $e');
      return [];
    }
  }

  //Actualizar estado de la orden o asignar admin
  Future<bool> updateOrder(int orderId, {String? status, int? adminId}) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/gestor/orders/$orderId');

    Map<String, dynamic> body = {};
    if (status != null) body['status'] = status;
    if (adminId != null) body['assigned_admin_id'] = adminId;

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar orden: $e');
      return false;
    }
  }
}