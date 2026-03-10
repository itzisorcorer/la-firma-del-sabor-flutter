import 'dart:convert';
import 'dart:io';
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
  //traer todos los productos para el admin
  Future<List<dynamic>> fetchAdminProducts() async{
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/admin/products');

    try{
      final response = await http.get(url,
      headers: {
        'Accept' : 'application/json',
        'Authorization' : 'Bearer $token',
      },
      );
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }else{
        print('Error del laravel: ${response.statusCode}');
        print('detalles de error: ${response.body}');
        return [];
      }
    }catch(e){
      print('Error de conexión: $e');
      return [];

    }
  }
  //traer las categorías para el buscador del admin
Future<List<dynamic>> fetchCategories()async{
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/categories-data');

    try{
      final response = await http.get(url,
      headers: {
        'Accept' : 'application/json',
        'Authorization' : 'Bearer $token',
      },
      );
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return data['data']['categories'] ?? [];
      }
      return [];


    }catch(e){
      print('error al traer las categorias: $e');
      return [];

    }
}
Future <bool> createCreator({
    required String name,
  required String biography,
  required String location,
  required File photo,
  required File coverPhoto,
  File? cvFile,

})async{
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/admin/creators');

    try{
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'Application/json';
      
      //campos de texto
      request.fields['name'] = name;
      request.fields['biography'] = biography;
      request.fields['location'] = location;
      
      //imagenes
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
      request.files.add(await http.MultipartFile.fromPath('cover_photo', coverPhoto.path));
      
      //pdf
      if(cvFile != null){
        request.files.add(await http.MultipartFile.fromPath('cv_file', cvFile.path));
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if(response.statusCode == 200 || response.statusCode == 201){
        return true;

      }else{
        print('Error en Laravel al crear creator: ${response.body}');
        return false;
      }
    }catch(e){
      print('Error al crear el creador: $e');
      return false;
    }
  }
  //Actualizar a un artesano o creador
Future<bool> updateCreator({
    required int id,
    required String name,
    required String biography,
    required String location,
    File? photo,
    File? coverPhoto,
    File? cvFile,
})async{
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/admin/creators/$id');

    try{
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'Application/json';

      request.fields['name'] = name;
      request.fields['biography'] = biography;
      request.fields['location'] = location;


      //validacion de fotos y pdf's
      if(photo != null){
        request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
      }
      if(coverPhoto != null){
        request.files.add(await http.MultipartFile.fromPath('cover_photo', coverPhoto.path));
      }
      if(cvFile != null){
        request.files.add(await http.MultipartFile.fromPath('cv_file', cvFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if(response.statusCode == 200 || response.statusCode==201){
        return true;
      }else{
        print('Error al actualizar creator: ${response.statusCode}');
        print('Motivo: ${response.body}');
        return false;
      }
    }catch(e){
      print('Error al actualizar: $e');
      return false;

    }


}
}