import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'session_service.dart';
import 'auth_service.dart';

class UsersApiService {
  static String get _baseUrl => '${AuthService.baseUrl}/Users';

  static Future<String?> _getToken() async => await SessionService.getToken();

  static Future<List<User>> fetchUsers() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => User.fromJson(e)).toList();
    }
    throw Exception('Error al obtener usuarios: ${response.statusCode}');
  }

  static Future<User> createUser(User user) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear usuario: ${response.statusCode}');
  }

  static Future<void> updateUser(User user) async {
    final token = await _getToken();
    final url = '$_baseUrl/${user.id}';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(user.toJson()),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al actualizar usuario: ${response.statusCode}');
    }
  }

  static Future<void> deleteUser(String id) async {
    final token = await _getToken();
    final url = '$_baseUrl/$id';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar usuario: ${response.statusCode}');
    }
  }

  static Future<void> changePassword(String id, String newPassword) async {
    // Si el backend tiene endpoint para cambiar la contraseña, implementarlo aquí.
    // Por ahora, solo simulamos un pequeño retardo.
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
