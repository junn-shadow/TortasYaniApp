import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsProvider = Provider.of<NotificationsProvider>(context);
    final list = notificationsProvider.notifications;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 17, 41),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 17, 41),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notificaciones",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (notificationsProvider.unreadCount > 0)
            TextButton(
              onPressed: () {
                notificationsProvider.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Todas las notificaciones marcadas como leídas"),
                    backgroundColor: Color(0xFFF07070),
                  ),
                );
              },
              child: const Text(
                "Leer todas",
                style: TextStyle(
                  color: Color(0xFFF07070),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: list.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final notification = list[index];
                return _buildNotificationItem(context, notification, notificationsProvider, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161F3D),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF07070).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: const Icon(
              Iconsax.notification_status,
              size: 80,
              color: Color(0xFFF07070),
            ),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .shake(delay: 500.ms, duration: 400.ms),
          const SizedBox(height: 24),
          const Text(
            "Todo limpio por aquí ✨",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "No tienes ninguna notificación pendiente. ¡Te avisaremos cuando tengamos deliciosas novedades!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notification,
    NotificationsProvider provider,
    int index,
  ) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (notification.type) {
      case NotificationType.promo:
        icon = Iconsax.ticket_discount5;
        iconColor = Colors.orangeAccent;
        iconBgColor = Colors.orangeAccent.withOpacity(0.15);
        break;
      case NotificationType.orderStatus:
        icon = Iconsax.box_tick5;
        iconColor = const Color(0xFFF07070);
        iconBgColor = const Color(0xFFF07070).withOpacity(0.15);
        break;
      case NotificationType.system:
        icon = Iconsax.info_circle5;
        iconColor = Colors.blueAccent;
        iconBgColor = Colors.blueAccent.withOpacity(0.15);
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notificación eliminada"),
            backgroundColor: Color(0xFF161F3D),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          provider.markAsRead(notification.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? const Color(0xFF161F3D) : const Color(0xFF1E294B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead ? Colors.transparent : const Color(0xFFF07070).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: notification.isRead
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFFF07070).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de Tipo
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              // Contenido de la Notificación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        // Punto indicador no leído
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF07070),
                              shape: BoxShape.circle,
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .fade(duration: 600.ms),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 400.ms, delay: (100 * index).ms)
        .slideX(begin: 0.1, duration: 400.ms, delay: (100 * index).ms, curve: Curves.easeOutQuad);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return "Hace ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "Hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}";
    } else {
      return "Hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}";
    }
  }
}
