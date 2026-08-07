import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Interactive3DRobot extends StatefulWidget {
  final double size;
  final Offset globalPointerOffset;
  final bool isSpeaking;

  const Interactive3DRobot({
    super.key,
    this.size = 100,
    required this.globalPointerOffset,
    this.isSpeaking = false,
  });

  @override
  State<Interactive3DRobot> createState() => _Interactive3DRobotState();
}

class _Interactive3DRobotState extends State<Interactive3DRobot> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _pulseController;

  bool _isLoved = false;
  Timer? _loveTimer;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    // Floating hover animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Blinking animation controller
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    // Antenna pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Setup periodic blinking
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    final randomSeconds = 3 + math.Random().nextInt(3); // Every 3-5 seconds
    _blinkTimer = Timer(Duration(seconds: randomSeconds), () {
      if (mounted && !_isLoved) {
        _blinkController.reverse().then((_) {
          _blinkController.forward();
          _scheduleNextBlink();
        });
      } else {
        _scheduleNextBlink();
      }
    });
  }

  void _onTap() {
    if (_isLoved) return;
    setState(() {
      _isLoved = true;
    });

    _loveTimer?.cancel();
    _loveTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoved = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _pulseController.dispose();
    _loveTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  Offset _getRelativeLookOffset() {
    if (!mounted) return Offset.zero;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;

    final widgetPosition = renderBox.localToGlobal(Offset(widget.size / 2, widget.size / 2));
    final diff = widget.globalPointerOffset - widgetPosition;
    final distance = diff.distance;

    if (distance == 0) return Offset.zero;

    // Standardize distance calculation
    const maxDistance = 400.0;
    final strength = math.min(distance / maxDistance, 1.0);
    final direction = diff / distance;

    return Offset(direction.dx * strength, direction.dy * strength);
  }

  @override
  Widget build(BuildContext context) {
    final lookOffset = _getRelativeLookOffset();

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _blinkController, _pulseController]),
        builder: (context, child) {
          // Floating vertical offset math
          final double floatOffsetY = math.sin(_floatController.value * math.pi * 2) * (widget.size * 0.05);

          return Transform.translate(
            offset: Offset(0, floatOffsetY),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: Robot3DPainter(
                  lookOffset: lookOffset,
                  blinkProgress: _blinkController.value,
                  pulseProgress: _pulseController.value,
                  isLoved: _isLoved,
                  isSpeaking: widget.isSpeaking,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Robot3DPainter extends CustomPainter {
  final Offset lookOffset;
  final double blinkProgress;
  final double pulseProgress;
  final bool isLoved;
  final bool isSpeaking;

  Robot3DPainter({
    required this.lookOffset,
    required this.blinkProgress,
    required this.pulseProgress,
    required this.isLoved,
    required this.isSpeaking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Look coordinates (lerped offsets)
    final double lookX = lookOffset.dx;
    final double lookY = lookOffset.dy;

    // --- 1. DIBUJAR OREJAS (Detrás del chasis, efecto parallax invertido) ---
    final earPaintBase = Paint()..color = const Color(0xFFC4C4C4);
    final earPaintRim = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    final earPaintHole = Paint()..color = const Color(0xFFAAAAAA);

    final earRadius = radius * 0.25;

    // Oreja Izquierda
    final leftEarCenter = Offset(
      center.dx - radius - (lookX * size.width * 0.03),
      center.dy + (lookY * size.width * 0.02),
    );
    canvas.drawCircle(leftEarCenter, earRadius, earPaintBase);
    canvas.drawCircle(leftEarCenter, earRadius, earPaintRim);
    canvas.drawCircle(leftEarCenter, earRadius * 0.6, earPaintHole);

    // Oreja Derecha
    final rightEarCenter = Offset(
      center.dx + radius - (lookX * size.width * 0.03),
      center.dy + (lookY * size.width * 0.02),
    );
    canvas.drawCircle(rightEarCenter, earRadius, earPaintBase);
    canvas.drawCircle(rightEarCenter, earRadius, earPaintRim);
    canvas.drawCircle(rightEarCenter, earRadius * 0.6, earPaintHole);

    // --- 2. DIBUJAR ANTENA (Detrás/Encima de la cabeza) ---
    final antennaStickPaint = Paint()
      ..color = const Color(0xFFDCDCDC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    final antennaBaseCenter = Offset(
      center.dx - (lookX * size.width * 0.02),
      center.dy - radius + (lookY * size.width * 0.01),
    );
    final antennaTipCenter = Offset(
      center.dx - (lookX * size.width * 0.06),
      center.dy - radius - (size.height * 0.22) + (lookY * size.width * 0.01),
    );

    // Dibujar palito de la antena
    canvas.drawLine(antennaBaseCenter, antennaTipCenter, antennaStickPaint);

    // Dibujar punta brillante de la antena
    final double pulseRate = isSpeaking ? 1.5 : 1.0;
    final glowRadius = (size.width * 0.04) * (1.0 + (pulseProgress * 0.25 * pulseRate));
    final glowPaint = Paint()
      ..color = isLoved
          ? const Color(0xFFFF3366).withValues(alpha: 0.8)
          : const Color(0xFF00FFC6).withValues(alpha: 0.8)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.04);
    
    final tipColor = isLoved ? const Color(0xFFFF3366) : const Color(0xFF00FFC6);
    final antennaTipPaint = Paint()..color = tipColor;

    canvas.drawCircle(antennaTipCenter, glowRadius * 2, glowPaint);
    canvas.drawCircle(antennaTipCenter, glowRadius, antennaTipPaint);

    // --- 3. DIBUJAR CHASIS DE LA CABEZA (Sombreado 3D Radial) ---
    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFE8E8E8),
          Color(0xFFC0C0C0),
          Color(0xFF909090),
        ],
        center: const Alignment(-0.25, -0.25),
        radius: 0.85,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.03);

    // Sombra del robot
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.1), radius, shadowPaint);

    // Cuerpo principal
    canvas.drawCircle(center, radius, headPaint);

    // --- 4. DIBUJAR PANTALLA VISOR (Efecto parallax hacia adelante) ---
    final double screenDx = lookX * size.width * 0.06;
    final double screenDy = lookY * size.height * 0.04;
    final screenCenter = Offset(center.dx + screenDx, center.dy + screenDy);
    final screenWidth = radius * 1.5;
    final screenHeight = radius * 0.95;

    final screenRect = Rect.fromCenter(
      center: screenCenter,
      width: screenWidth,
      height: screenHeight,
    );
    final screenRRect = RRect.fromRectAndRadius(screenRect, Radius.circular(screenHeight / 2));

    // Fondo del visor (Vidrio obscuro)
    final screenBgPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFF282828),
          Color(0xFF101010),
          Color(0xFF020202),
        ],
        center: const Alignment(0, 0),
        radius: 1.0,
      ).createShader(screenRect);

    canvas.drawRRect(screenRRect, screenBgPaint);

    // Brillo/Reflejo Neon Teal de los bordes (Glassmorphism)
    final double power = isSpeaking ? 3.0 : 1.5;
    final glassColor = isLoved ? const Color(0xFFFF3366) : const Color(0xFF00FFC6);
    final screenBorderPaint = Paint()
      ..color = glassColor.withValues(alpha: 0.35 + (pulseProgress * 0.15 * power))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.01);

    canvas.drawRRect(screenRRect, screenBorderPaint);

    // --- 5. DIBUJAR OJOS DIGITALES (Parallax interior adicional) ---
    final double eyesDx = screenCenter.dx + (lookX * size.width * 0.03);
    final double eyesDy = screenCenter.dy + (lookY * size.height * 0.02);

    final double eyeSpacing = size.width * 0.14;
    final double eyeWidth = size.width * 0.065;
    final double eyeHeight = isLoved ? size.width * 0.065 : size.width * 0.09 * blinkProgress;

    final eyeGlowPaint = Paint()
      ..color = glassColor.withValues(alpha: 0.7)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.025);

    final eyeSolidPaint = Paint()..color = glassColor;

    // Dibujar ojo izquierdo y derecho
    _drawEye(canvas, Offset(eyesDx - eyeSpacing, eyesDy), eyeWidth, eyeHeight, eyeGlowPaint, eyeSolidPaint);
    _drawEye(canvas, Offset(eyesDx + eyeSpacing, eyesDy), eyeWidth, eyeHeight, eyeGlowPaint, eyeSolidPaint);
  }

  void _drawEye(Canvas canvas, Offset position, double width, double height, Paint glowPaint, Paint solidPaint) {
    if (height < 1.0) return; // Parpadeando (cerrado por completo)

    if (isLoved) {
      // Dibujar corazones
      final path = Path();
      final double s = width * 1.5;
      path.moveTo(position.dx, position.dy - s * 0.2);
      path.cubicTo(position.dx - s / 2, position.dy - s * 0.8, position.dx - s, position.dy - s * 0.2, position.dx, position.dy + s * 0.5);
      path.cubicTo(position.dx + s, position.dy - s * 0.2, position.dx + s / 2, position.dy - s * 0.8, position.dx, position.dy - s * 0.2);

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, solidPaint);
    } else {
      // Dibujar ojos redondeados normales
      final rect = Rect.fromCenter(center: position, width: width, height: height);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(width / 2));
      canvas.drawRRect(rrect, glowPaint);
      canvas.drawRRect(rrect, solidPaint);
    }
  }

  @override
  bool shouldRepaint(covariant Robot3DPainter oldDelegate) {
    return oldDelegate.lookOffset != lookOffset ||
        oldDelegate.blinkProgress != blinkProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.isLoved != isLoved ||
        oldDelegate.isSpeaking != isSpeaking;
  }
}
