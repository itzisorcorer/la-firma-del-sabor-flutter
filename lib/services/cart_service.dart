import 'dart:convert';

import 'package:app_firma_sabor/constants/api_constants.dart';
import 'package:app_firma_sabor/services/auth_service.dart';
import 'package:http/http.dart' as http;

class CartService {
  // Patrón Singleton: Crea una única instancia de este carrito para toda la app
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  // Agregar producto o sumar cantidad si ya existe
  void addToCart(Map<String, dynamic> product, int quantity) {
    final index = _items.indexWhere((item) => item['product_id'] == product['product_id']);

    if (index != -1) {
      _items[index]['quantity'] += quantity;
    } else {
      _items.add({
        'product_id': product['product_id'],
        'name': product['name'],
        'description': product['description'] ?? '',
        'price': double.tryParse(product['price'].toString().replaceAll('\$', '').replaceAll(' c/u', '')) ?? 0.0,
        'image': product['image_url'], // Usaremos la imagen real o el bypass en la vista
        'quantity': quantity,
      });
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      _items[index]['quantity'] = newQuantity;
    }
  }

  void removeItem(int index) {
    _items.removeAt(index);
  }

  void clearCart() {
    _items.clear();
  }

  double get totalPagar {
    return _items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }
  Future<bool> checkout() async{
    if(_items.isEmpty) return false;

    final token = await AuthService().getToken();
    final url =  Uri.parse('${ApiConstants.baseUrl}/checkout');

    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
          body: jsonEncode({
            'total' : totalPagar,
            'items' : _items.map((item) => {
          'product_id' : item['product_id'],
          'quantity' : item['quantity'],
          'price' : item['price'],
          }).toList(),
          }),
      );
      if (response.statusCode == 200){
        clearCart();
        return true;
      }else{
        print('Error de checkout: ${response.body}');
        return false;
      }
    }catch(e){
      print('Error de conexión: $e');
      return false;
    }
  }
}