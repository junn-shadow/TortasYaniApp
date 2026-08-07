import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'notifications_provider.g.dart';

@HiveType(typeId: 0)
class AppNotification extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String body;
  @HiveField(3)
  final NotificationType type;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

enum NotificationType { promo, orderStatus, system }

class NotificationsProvider extends ChangeNotifier {
  static const String _boxName = 'notifications';
  late Box<AppNotification> _box;
  final List<AppNotification> _notifications = [];

  NotificationsProvider() {
    _loadFromBox();
  }

  Future<void> _loadFromBox() async {
    _box = await Hive.openBox<AppNotification>(_boxName);
    _notifications.clear();
    _notifications.addAll(_box.values);
    notifyListeners();
  }

  Future<void> _saveToBox() async {
    await _box.clear();
    await _box.addAll(_notifications);
  }

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _saveToBox();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      _saveToBox();
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveToBox();
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    );
    _notifications.insert(0, notification);
    _saveToBox();
    notifyListeners();
  }
}
