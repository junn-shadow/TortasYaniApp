import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'login_screen.dart';
import 'dart:ui'; // for glassmorphism blur
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loaderController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _loaderFade;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _loaderFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeOut),
    );

    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Secuencia de animaciones
    _logoController.forward().then((_) {
      _textController.forward().then((_) {
        _loaderController.forward();
      });
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loaderController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF0F5), // blush rosado
              Color(0xFFFFF8F0), // crema almendra
              Color(0xFFFFE4EC), // melocotón claro
            ],
          ),
        ),
        child: Stack(
          children: [
            // Glassmorphism overlay
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            // Original content
            Stack(
          alignment: Alignment.center,
          children: [
            // ── Círculos decorativos de fondo ──
            _buildBgCircle(
                top: -60,
                left: -60,
                size: 220,
                color: const Color(0xFFFFD6E7).withValues(alpha: 0.5)),
            _buildBgCircle(
                bottom: -80,
                right: -80,
                size: 280,
                color: const Color(0xFFFFCCE0).withValues(alpha: 0.4)),
            _buildBgCircle(
                top: 100,
                right: -40,
                size: 140,
                color: const Color(0xFFFFC8A0).withValues(alpha: 0.3)),
            _buildBgCircle(
                bottom: 160,
                left: -30,
                size: 100,
                color: const Color(0xFFFFB5C8).withValues(alpha: 0.35)),

            // ── Partículas decorativas flotantes ──
            AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) => Stack(
                children: [
                  _buildParticle(
                      top: 120,
                      left: 40,
                      offset: _floatAnim.value * 0.8,
                      icon: Iconsax.star5,
                      color: const Color(0xFFFFAEC0),
                      size: 16),
                  _buildParticle(
                      top: 200,
                      right: 50,
                      offset: -_floatAnim.value,
                      icon: Icons.favorite,
                      color: const Color(0xFFF7A0B0),
                      size: 13),
                  _buildParticle(
                      bottom: 220,
                      left: 60,
                      offset: _floatAnim.value * 0.6,
                      icon: Iconsax.star5,
                      color: const Color(0xFFFFCBA0),
                      size: 11),
                  _buildParticle(
                      bottom: 150,
                      right: 40,
                      offset: -_floatAnim.value * 0.7,
                      icon: Icons.spa_rounded,
                      color: const Color(0xFFFFB5C8),
                      size: 15),
                  _buildParticle(
                      top: 300,
                      left: 20,
                      offset: _floatAnim.value,
                      icon: Icons.circle,
                      color: const Color(0xFFF9C0D0).withValues(alpha: 0.6),
                      size: 8),
                  _buildParticle(
                      top: 250,
                      right: 25,
                      offset: -_floatAnim.value * 0.5,
                      icon: Icons.circle,
                      color: const Color(0xFFFFD4A0).withValues(alpha: 0.6),
                      size: 10),
                ],
              ),
            ),

            // ── Contenido central ──
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_logoController, _floatController]),
                  builder: (_, __) {
                    return FadeTransition(
                      opacity: _fadeAnim,
                      child: Transform.translate(
                        offset: Offset(0, _floatAnim.value * 0.4),
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: _buildLogo(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                // Nombre de la marca
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          "Tortas Yani",
                          style: GoogleFonts.inter(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF7A3A52),
                            letterSpacing: 1.2,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFFE88EA0)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Endulzando tus momentos",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFFB07888),
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE88EA0),
                                    Colors.transparent
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Indicador de carga
                FadeTransition(
                  opacity: _loaderFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFE88EA0).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Preparando algo especial...",
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFB07888).withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
);
}

  Widget _buildLogo() {
    // Display the generated splash icon asset
    return Image.asset(
      'assets/images/splash_icon.png',
      width: 150,
      height: 150,
    );
  }

  Widget _buildBgCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildParticle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double offset,
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top != null ? top + offset : null,
      bottom: bottom != null ? bottom + offset : null,
      left: left,
      right: right,
      child: Icon(icon, color: color, size: size),
    );
  }
}
