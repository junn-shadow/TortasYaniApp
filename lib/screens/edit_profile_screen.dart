// edit_profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/session_service.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _notificaciones = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  bool _isLoading = false;
  Map<String, dynamic> _originalUser = {};


  Uint8List? _imageBytes;
  String _fotoPerfilBase64 = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Load user data and notification preference
  Future<void> _loadUser() async {
    final user = await SessionService.getUser();
    final notif = await SessionService.getNotificationPreference();
    setState(() {
      _nameController.text = user['nombreCompleto'] ?? '';
      _phoneController.text = user['telefono'] ?? '';
      _addressController.text = user['direccion'] ?? '';
      _fotoPerfilBase64 = user['fotoPerfil'] ?? '';
      _notificaciones = notif ?? true;
      if (_fotoPerfilBase64.isNotEmpty && !_fotoPerfilBase64.startsWith('http')) {
        _imageBytes = base64Decode(_fotoPerfilBase64);
      }
      // Store original user data for change detection
      _originalUser = {
        'nombreCompleto': user['nombreCompleto'] ?? '',
        'telefono': user['telefono'] ?? '',
        'direccion': user['direccion'] ?? '',
        'fotoPerfil': user['fotoPerfil'] ?? '',
      };
    });
  }

  // Save notification preference
  Future<void> _saveNotificationPreference() async {
    await SessionService.saveNotificationPreference(_notificaciones);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _fotoPerfilBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Determine which fields have changed compared to original data
    final String? nombre = _nameController.text.trim() != _originalUser['nombreCompleto']
        ? _nameController.text.trim()
        : null;
    final String? telefono = _phoneController.text.trim() != _originalUser['telefono']
        ? _phoneController.text.trim()
        : null;
    final String? direccion = _addressController.text.trim() != _originalUser['direccion']
        ? _addressController.text.trim()
        : null;
    final String? foto = _fotoPerfilBase64 != _originalUser['fotoPerfil']
        ? _fotoPerfilBase64
        : null;

    setState(() => _isLoading = true);

    final result = await AuthService.updateProfile(
      nombreCompleto: nombre,
      telefono: telefono,
      direccion: direccion,
      nuevaPassword: _passwordController.text.isNotEmpty ? _passwordController.text.trim() : null,
      fotoPerfil: foto,
    );

    // Save notification preference
    await _saveNotificationPreference();

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Update local session with the latest data
      await SessionService.saveUser(
        nombreCompleto: _nameController.text.trim(),
        email: (await SessionService.getUser())['email'] ?? '',
        telefono: _phoneController.text.trim(),
        direccion: _addressController.text.trim(),
        fotoPerfil: _fotoPerfilBase64.isNotEmpty ? _fotoPerfilBase64 : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente ✅'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool? showObscure,
    VoidCallback? onToggleObscure,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            prefixIcon: Icon(icon, color: const Color(0xFFF07070), size: 20),
            suffixIcon: showObscure != null
                ? IconButton(
                    icon: Icon(
                      showObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF07070), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 17, 41),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1035),
        title: const Text(
          "Editar perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO DE PERFIL
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF07070), width: 2),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: ClipOval(
                          child: _imageBytes != null
                              ? Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                              : (_fotoPerfilBase64.startsWith('http')
                                  ? Image.network(
                                      _fotoPerfilBase64,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                      size: 55,
                                    )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF07070),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Información personal",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF07070),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _nameController,
              label: "Nombre completo",
              icon: Icons.person_outline,
            ),
            _buildField(
              controller: _phoneController,
              label: "Teléfono",
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            _buildField(
              controller: _addressController,
              label: "Dirección",
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 8),
            const Text(
              "Cambiar contraseña",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF07070),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _passwordController,
              label: "Nueva contraseña",
              icon: Icons.lock_outline,
              obscure: _obscurePassword,
              showObscure: _obscurePassword,
              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            _buildField(
              controller: _confirmPasswordController,
              label: "Confirmar contraseña",
              icon: Icons.lock_outline,
              obscure: _obscureConfirm,
              showObscure: _obscureConfirm,
              onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 8),
            const Text(
              "Preferencias",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF07070),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined, color: Color(0xFFF07070)),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notificaciones",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        Text(
                          "Recibe ofertas y novedades",
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notificaciones,
                    onChanged: (val) => setState(() => _notificaciones = val),
                    activeThumbColor: const Color(0xFFF07070),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF07070),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Guardar cambios",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
