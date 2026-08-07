import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'user_form.dart';

class AdminUserScreen extends StatelessWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1D6),
        title: const Text(
          "Gestión de usuarios",
          style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B29)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 1,
        shadowColor: const Color(0xFFFFD1D6).withOpacity(0.5),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF07070)));
          }
          final users = userProvider.users;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                color: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFFFFD1D6).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFFE4E6)),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFE4E6),
                    foregroundColor: const Color(0xFFF07070),
                    child: Text(
                      user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : "U",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    user.nombre,
                    style: const TextStyle(color: Color(0xFF4A0E17), fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Color(0xFF8A6B70), fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.rol == 'admin' 
                              ? const Color(0xFFFFD1D6).withOpacity(0.5) 
                              : const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: user.rol == 'admin' 
                                ? const Color(0xFFFFB6C1) 
                                : const Color(0xFFFFE4E6),
                          ),
                        ),
                        child: Text(
                          user.rol == 'admin' ? "ADMINISTRADOR" : "CLIENTE",
                          style: TextStyle(
                            color: user.rol == 'admin' ? const Color(0xFF6A1B29) : const Color(0xFF8D4B53),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF8D4B53)),
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => UserFormScreen(user: user),
                          ));
                          // Refresh after returning
                          userProvider.fetchUsers();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: const Color(0xFFFFF9FA),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text(
                                'Confirmar eliminación',
                                style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                '¿Estás seguro de que deseas eliminar al usuario "${user.nombre}"?',
                                style: const TextStyle(color: Color(0xFF8A6B70)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8A6B70))),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await userProvider.deleteUser(user.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF07070),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: const Text('Añadir usuario', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserFormScreen()));
          // Refresh list after adding
          if (context.mounted) {
            Provider.of<UserProvider>(context, listen: false).fetchUsers();
          }
        },
      ),
    );
  }
}
