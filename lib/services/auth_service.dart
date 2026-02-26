import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_firma_sabor/constants/api_constants.dart';

class AuthService {
  // Función para Iniciar Sesión
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // login exitoso = guardar el token
        final String role = body['user']['role'] ?? 'comprador';
        await _saveAuthData(body['access_token'], role);
        return {'success': true, 'user': body['user']};
      } else {
        // Error
        return {'success': false, 'message': body['message'] ?? 'Error desconocido'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Guardar token y rol en memoria segura del teléfono
  Future<void> _saveAuthData(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('role', role);
  }
  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Cerrar sesión (Borrar token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('role');
  }

  //Función para que el usuario se registre
  Future<Map<String, dynamic>> register (String name, String email, String password) async{
    final url = Uri.parse('${ApiConstants.baseUrl}/register');

    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role' : 'comprador'
        }),
      );
      final Map<String, dynamic> body = jsonDecode(response.body);

      if(response.statusCode == 201 || response.statusCode == 200){
        if(body.containsKey('access_token')){
          await _saveAuthData(body['access_token'], 'comprador');

        }
        return {'success' : true, 'message': 'Usuario creado correctamente'};
      }else{
        return {'success' : false, 'message': body['message'] ?? 'Error al registrarse'};
      }

    }catch(e){
      return {'success' : false, 'message': 'Error de conexión: $e'};
    }

  }
}