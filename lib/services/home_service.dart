import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';

class HomeService{
  final AuthService _authService = AuthService();

  //primero vamos a obtener los datos del home
Future<Map<String, dynamic>> fetchHomeData() async {
  final token = await _authService.getToken();
  final url = Uri.parse('${ApiConstants.baseUrl}/home');

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
      return data['data'];
    } else {
      throw Exception('Error al cargar datos del home');
    }
  }catch(e) {
    print('Error al recuperar los productos de home: $e');
    return{};
  }

  }
  //BOTÓN DE GUARDAR (EL TOOGLE DE LARAVEL)
Future<bool> toggleFavorite(int productId) async{
  final token = await _authService.getToken();
  final url = Uri.parse('${ApiConstants.baseUrl}/favorites/toggle');
  
  try{
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'product_id': productId}),
    );
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return data['is_favorite'];
    }else{
      throw Exception('Error al actualizar el favorito');
    }
    }catch(e){
    print('error al cambiar de favoritos: $e');
    throw e;
  }
  }

  //funcion para ovtener producto por categoria
Future <List<dynamic>> fetchProductsByCategory(int categoryId) async{
  final token = await _authService.getToken();
  final url = Uri.parse('${ApiConstants.baseUrl}/categories/$categoryId/products');

  try{
    final response = await http.get(url, headers: {
      'Accept' : 'application/json',
      'Authorization' : 'Bearer $token',
    });
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }
    return[];
    }catch(e){
      print('Error al filtrar por categoria: $e');
      return[];
  }

  }
}
