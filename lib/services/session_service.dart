import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<void> saveUser({
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String direccion,
    String? fotoPerfil,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombreCompleto', nombreCompleto);
    await prefs.setString('email', email);
    await prefs.setString('telefono', telefono);
    await prefs.setString('direccion', direccion);
    if (fotoPerfil != null) {
      await prefs.setString('fotoPerfil', fotoPerfil);
    }
    if (token != null) {
      await prefs.setString('token', token);
    }
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nombreCompleto': prefs.getString('nombreCompleto') ?? '',
      'email': prefs.getString('email') ?? '',
      'telefono': prefs.getString('telefono') ?? '',
      'direccion': prefs.getString('direccion') ?? '',
      'fotoPerfil': prefs.getString('fotoPerfil') ?? '',
      'token': prefs.getString('token') ?? '',
    };
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Notification preference
  static Future<void> saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationPreference', value);
  }

  static Future<bool?> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationPreference');
  }
}
