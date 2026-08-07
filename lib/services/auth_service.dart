import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'session_service.dart';

class AuthService {
  // -----------------------------------------------------------------
  // CONFIGURACIÓN DE URL DINÁMICA SEGÚN PLATAFORMA
  // -----------------------------------------------------------------
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    if (Platform.isIOS) {
      return 'http://localhost:8080/api';
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:8080/api';
    }
    return 'http://192.168.1.X:8080/api'; // Fallback
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        await SessionService.saveUser(
          nombreCompleto: result['nombreCompleto'] ?? '',
          email: email,
          telefono: result['telefono'] ?? '',
          direccion: result['direccion'] ?? '',
          fotoPerfil: result['fotoUrl'] ?? '',
          token: result['token'],
        );
      }

      return result;
    } catch (e) {
      print('=== ERROR EN LOGIN ===: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreCompleto': nombreCompleto,
          'email': email,
          'password': password,
          'telefono': telefono,
          'direccion': direccion,
        }),
      );
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        await SessionService.saveUser(
          nombreCompleto: nombreCompleto,
          email: email,
          telefono: result['telefono'] ?? telefono,
          direccion: result['direccion'] ?? direccion,
          fotoPerfil: result['fotoUrl'] ?? '',
          token: result['token'],
        );
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  static Future<String> getCurrentUserRole() async {
    final user = await SessionService.getUser();
    final email = user['email']?.toString().toLowerCase() ?? '';
    // Simple mock logic: admin email is admin@gmail.com
    if (email == 'admin@gmail.com') {
      return 'admin';
    }
    return 'client';
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? direccion,
    String? nuevaPassword,
    String? fotoPerfil,
  }) async {
    try {
      final user = await SessionService.getUser();
      final token = await SessionService.getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      // Build request body dynamically, only include non‑null fields
      final Map<String, dynamic> body = {};
      if (user['email'] != null) body['email'] = user['email'];
      if (nombreCompleto != null) body['nombreCompleto'] = nombreCompleto;
      if (telefono != null) body['telefono'] = telefono;
      if (direccion != null) body['direccion'] = direccion;
      if (nuevaPassword != null && nuevaPassword.isNotEmpty) body['nuevaPassword'] = nuevaPassword;
      if (fotoPerfil != null && fotoPerfil.isNotEmpty) body['fotoUrl'] = fotoPerfil;

      final response = await http.put(
        Uri.parse('$baseUrl/Auth/update'),
        headers: headers,
        body: jsonEncode(body),
      );
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        // Session update is handled in the UI after a successful response
      }

      // Return the result to the caller
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
