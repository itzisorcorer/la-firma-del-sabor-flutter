import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/auth_service.dart';

class OrderService{
  Future<List<dynamic>> fetchMyOrders() async{
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/orders');
    try{
      final response = await http.get(
        url,
        headers: {
          'Accept' : 'application/json',
          'Authorization' : 'Bearer $token',
        },
      );
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    }catch(e){
      print('Error al obener los pedidos: $e');
      return [];
    }
  }
}