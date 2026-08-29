import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/users_api_service.dart';

class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;

  UserProvider() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetched = await UsersApiService.fetchUsers();
      if (fetched.isNotEmpty) {
        _users = fetched;
      } else {
        _users = [
          User(id: "1", nombre: "Yani Admin", email: "admin@gmail.com", rol: "admin", activo: true),
          User(id: "2", nombre: "Carla Mendoza", email: "carla@gmail.com", rol: "client", activo: true),
        ];
      }
    } catch (e) {
      _users = [
        User(id: "1", nombre: "Yani Admin", email: "admin@gmail.com", rol: "admin", activo: true),
        User(id: "2", nombre: "Carla Mendoza", email: "carla@gmail.com", rol: "client", activo: true),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(User user) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await UsersApiService.createUser(user);
      _users.add(created);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updated) async {
  _isLoading = true;
  notifyListeners();
  try {
    await UsersApiService.updateUser(updated);
    final index = _users.indexWhere((u) => u.id == updated.id);
    if (index != -1) {
      _users[index] = updated;
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> deleteUser(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await UsersApiService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String id, String newPassword) async {
    // Mock implementation: just wait a moment
    await Future.delayed(const Duration(milliseconds: 300));
    // In real case, call API endpoint
  }
}
