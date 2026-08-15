import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'app_main_screen.dart';
import 'register_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../providers/notifications_provider.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  static const String _googleSvg = '''
<svg viewBox="0 0 488 512" xmlns="http://www.w3.org/2000/svg">
  <path fill="#ffffff" d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"/>
</svg>
''';

  static const String _facebookSvg = '''
<svg viewBox="0 0 320 512" xmlns="http://www.w3.org/2000/svg">
  <path fill="#ffffff" d="M279.14 288l14.22-92.66h-88.91v-60.13c0-25.35 12.42-50.06 52.24-50.06h40.42V6.26S260.43 0 225.36 0c-73.22 0-121.08 44.38-121.08 124.72v70.62H22.89V288h81.39v224h100.17V288z"/>
</svg>
''';

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await SessionService.getUser();
    final token = user['token'] ?? '';
    final email = user['email'] ?? '';
    if (token.isNotEmpty && email.isNotEmpty) {
      final timedOut = await SessionService.shouldSessionTimeout();
      if (timedOut) {
        await SessionService.clearUser();
        return;
      }
      await SessionService.updateLastActiveTime();

      if (email.trim().toLowerCase() == 'admin@gmail.com') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppMainScreen()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
      notificationsProvider.addNotification(
        title: "¡Bienvenido de nuevo!",
        body: "Has iniciado sesión correctamente. Explora nuestras deliciosas tortas.",
        type: NotificationType.promo,
      );

      if (_emailController.text.trim().toLowerCase() == 'admin@gmail.com') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppMainScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF0F5), // Blush rosado
              Color(0xFFFFFDF8), // Crema
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 350),
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA2B6).withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: -15,
                            offset: const Offset(0, 20),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF6F7), // Soft pastel pink-white
                            Color(0xFFFFFDF9), // Warm soft cream
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Heading
                          Text(
                            "Iniciar Sesión",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFE56B8F),
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Email
                          _buildTextField(
                            controller: _emailController,
                            hint: "Correo Electrónico",
                            focusNode: _emailFocusNode,
                            isFocused: _isEmailFocused,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 15),

                          // Password
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Contraseña",
                            focusNode: _passwordFocusNode,
                            isFocused: _isPasswordFocused,
                            isPassword: true,
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "¿Olvidaste tu contraseña?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFFE56B8F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Login button
                          GestureDetector(
                            onTap: _isLoading ? null : _handleLogin,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFFFA2B6), // Soft pastel raspberry-pink
                                    Color(0xFFFFC3A0), // Warm pastel peach/gold
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFA2B6).withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    spreadRadius: -2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      "Iniciar Sesión",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Social logins section
                          Column(
                            children: [
                              Text(
                                "O ingresa con",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF8D7A70),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildPastelSocialButton(
                                    svgPath: _googleSvg,
                                    gradientColors: [
                                      const Color(0xFFFFAAA6),
                                      const Color(0xFFFFD3B6),
                                    ],
                                    onPressed: _handleGoogleLogin,
                                  ),
                                  const SizedBox(width: 15),
                                  _buildPastelSocialButton(
                                    svgPath: _facebookSvg,
                                    gradientColors: [
                                      const Color(0xFFA1C4FD),
                                      const Color(0xFFC2E9FB),
                                    ],
                                    onPressed: _handleFacebookLogin,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Agreement
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Acepto el acuerdo de licencia de usuario",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: const Color(0xFF8D7A70),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Sign Up
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿No tienes cuenta? ",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF8D7A70),
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  );
                                },
                                child: Text(
                                  "Regístrate",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFE56B8F),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required FocusNode focusNode,
    required bool isFocused,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: isFocused ? const Color(0xFFFFA2B6) : Colors.transparent,
            width: 2,
          ),
          right: BorderSide(
            color: isFocused ? const Color(0xFFFFA2B6) : Colors.transparent,
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFEBF0),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          color: const Color(0xFF5A4A42),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFFC4B4A9),
            fontSize: 14,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                    color: const Color(0xFFC4B4A9),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPastelSocialButton({
    required String svgPath,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA2B6).withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: -8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SvgPicture.string(
          svgPath,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  void _handleGoogleLogin() {
    _showGoogleLoginSheet();
  }

  void _handleFacebookLogin() {
    _showFacebookLoginSheet();
  }

  void _showGoogleLoginSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Google Logo
                SvgPicture.string(
                  '''<svg viewBox="0 0 24 24" width="32" height="32" xmlns="http://www.w3.org/2000/svg">
                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l3.66-2.85z"/>
                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.85c.87-2.6 3.3-4.53 6.16-4.53z"/>
                  </svg>''',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  "Elige una cuenta",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF202124),
                  ),
                ),
                Text(
                  "para continuar en Tortas Yani",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF5F6368),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Accounts List
                _buildGoogleAccountItem(
                  name: "Yani López",
                  email: "yanilopez@gmail.com",
                  avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80",
                  onTap: () {
                    Navigator.pop(context);
                    _handleGoogleRealAuth("Yani López", "yanilopez@gmail.com", "google123");
                  },
                ),
                const Divider(height: 1),
                _buildGoogleAccountItem(
                  name: "Juan Pérez",
                  email: "juanperez@gmail.com",
                  avatarUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80",
                  onTap: () {
                    Navigator.pop(context);
                    _handleGoogleRealAuth("Juan Pérez", "juanperez@gmail.com", "google123");
                  },
                ),
                const Divider(height: 1),
                _buildGoogleAccountItem(
                  name: "Usar otra cuenta",
                  email: "",
                  avatarIcon: Icons.account_circle_outlined,
                  onTap: () => _showGoogleCustomAuth(context),
                ),
                
                const SizedBox(height: 20),
                Text(
                  "Para continuar, Google compartirá tu nombre, dirección de correo electrónico, foto de perfil y preferencia de idioma con Tortas Yani. Consulta la Política de privacidad y las Condiciones del servicio.",
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF5F6368),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleAccountItem({
    required String name,
    required String email,
    String? avatarUrl,
    IconData? avatarIcon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: avatarUrl != null
          ? CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(avatarUrl),
            )
          : CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF1F3F4),
              child: Icon(avatarIcon ?? Icons.add, color: const Color(0xFF5F6368), size: 20),
            ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF3C4043),
        ),
      ),
      subtitle: email.isNotEmpty
          ? Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF5F6368),
              ),
            )
          : null,
    );
  }

  void _showGoogleCustomAuth(BuildContext parentContext) {
    Navigator.pop(parentContext); // Cerrar selector de cuentas
    
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController passCtrl = TextEditingController();
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SvgPicture.string(
                      '''<svg viewBox="0 0 24 24" width="32" height="32" xmlns="http://www.w3.org/2000/svg">
                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l3.66-2.85z"/>
                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.85c.87-2.6 3.3-4.53 6.16-4.53z"/>
                      </svg>''',
                      width: 32,
                      height: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Acceder con Google",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Correo
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Correo electrónico o teléfono",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Contraseña
                  TextField(
                    controller: passCtrl,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Iconsax.eye_slash : Iconsax.eye),
                        onPressed: () {
                          setModalState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor ingresa tus datos')),
                        );
                        return;
                      }
                      Navigator.pop(context); // Cerrar esta modal
                      _handleGoogleRealAuth(
                        emailCtrl.text.split('@').first,
                        emailCtrl.text,
                        passCtrl.text,
                      );
                    },
                    child: Text(
                      "Siguiente",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFacebookLoginSheet() {
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController passCtrl = TextEditingController();
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Facebook Header / Logo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 36),
                              const SizedBox(width: 8),
                              Text(
                                "facebook",
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1877F2),
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Inicia sesión en tu cuenta de Facebook para conectarte con Tortas Yani",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF606770),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Correo o celular
                      TextField(
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          hintText: "Número de celular o correo electrónico",
                          fillColor: const Color(0xFFF5F6F7),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCCD0D5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCCD0D5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1877F2), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Contraseña
                      TextField(
                        controller: passCtrl,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: "Contraseña",
                          fillColor: const Color(0xFFF5F6F7),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCCD0D5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCCD0D5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1877F2), width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFF606770)),
                            onPressed: () {
                              setModalState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ingresa tu correo/celular y contraseña')),
                            );
                            return;
                          }
                          Navigator.pop(context); // Cerrar modal
                          _handleFacebookRealAuth(
                            emailCtrl.text.split('@').first,
                            emailCtrl.text,
                            passCtrl.text,
                          );
                        },
                        child: Text(
                          "Iniciar sesión",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          "¿Olvidaste tu contraseña?",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF1877F2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Crear cuenta nueva",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF1877F2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleGoogleRealAuth(String name, String email, String password) async {
    setState(() => _isLoading = true);

    // 1. Intentar iniciar sesión en el backend real
    var result = await AuthService.login(email, password);
    
    // 2. Si el usuario no existe en la BD real, registrar automáticamente
    if (result['success'] != true) {
      final regResult = await AuthService.register(
        nombreCompleto: name,
        email: email,
        password: password,
        telefono: "+51 987 654 321",
        direccion: "Dirección de Google",
      );
      
      if (regResult['success'] == true) {
        // Volver a iniciar sesión tras el registro exitoso
        result = await AuthService.login(email, password);
      } else {
        result = regResult; // Devolver error si falló el registro
      }
    }

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido $name, inicio de sesión con Google exitoso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppMainScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al autenticar con Google'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleFacebookRealAuth(String name, String email, String password) async {
    setState(() => _isLoading = true);

    // 1. Intentar iniciar sesión en el backend real
    var result = await AuthService.login(email, password);
    
    // 2. Si el usuario no existe en la BD real, registrar automáticamente
    if (result['success'] != true) {
      final regResult = await AuthService.register(
        nombreCompleto: name,
        email: email,
        password: password,
        telefono: "+51 912 345 678",
        direccion: "Av. Larco 456, Miraflores",
      );
      
      if (regResult['success'] == true) {
        // Volver a iniciar sesión tras el registro exitoso
        result = await AuthService.login(email, password);
      } else {
        result = regResult; // Devolver error si falló el registro
      }
    }

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido $name, inicio de sesión con Facebook exitoso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppMainScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al autenticar con Facebook'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
