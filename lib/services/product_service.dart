import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:image_picker/image_picker.dart';

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
  //FUNCIÓN DEL BUSCADOR:
  Future<List<dynamic>> searchProducts(String query) async {
    final token = await _authService.getToken();
    // Armamos la URL con el texto de búsqueda
    final url = Uri.parse('${ApiConstants.baseUrl}/search?q=$query');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error en búsqueda: $e');
      return [];
    }
  }
  Future<bool> createProduct({
    required Map<String, dynamic> productData,
    required List<XFile> images,
    required List<String> videos,
}) async{
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/products');

    try{
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'Application/json';

      //insertamos los datos normales como nombre, precio, stock, etc
      productData.forEach((key, value) {
        if(value != null && value.toString().isNotEmpty){
          request.fields[key] = value.toString();
      }
      });
      //insertamos los videos que el admin insertó
      for(int i = 0; i < videos.length; i++){
        request.fields['videos[$i]'] = videos[i];
      }
      //acomodamos las fotos:
      for(int i = 0; i < images.length; i++){
        request.files.add(await http.MultipartFile.fromPath('images[]', images[i].path));
      }
      //mandamos los datos a laravel
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if(response.statusCode == 201){
        return true;
      }else{
        print('Error por laravel: ${response.statusCode}');
        print('Detalles: ${response.body}');
        return false;
      }

    }catch(e){
      print('Error en la conexión: $e');
      return false;
    }
  }
}