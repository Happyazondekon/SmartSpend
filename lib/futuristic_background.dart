import 'package:flutter/material.dart';
import 'dart:math' as math;

class FuturisticBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;

  const FuturisticBackground({
    Key? key,
    required this.child,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _FuturisticBackgroundState createState() => _FuturisticBackgroundState();
}

class _FuturisticBackgroundState extends State<FuturisticBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Animation douce pour les transitions de couleurs
    _colorController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOutSine,
    ));

    _colorController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond principal avec gradient fluide
        Container(
          decoration: BoxDecoration(
            gradient: _buildFluidGradient(),
          ),
        ),

        // Transition douce des couleurs
        AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: _buildTransitionGradient(),
              ),
            );
          },
        ),

        // Effet de profondeur avec formes organiques
        CustomPaint(
          painter: FluidShapesPainter(
            animation: _colorAnimation,
            isDarkMode: widget.isDarkMode,
          ),
          size: Size.infinite,
        ),

        // Contenu principal
        widget.child,
      ],
    );
  }

  RadialGradient _buildFluidGradient() {
    if (widget.isDarkMode) {
      return RadialGradient(
        center: const Alignment(-0.8, -0.6),
        radius: 1.8,
        colors: [
          const Color(0xFF0F1414), // Primary cyan
    const Color(0xFF0F1414).withOpacity(0.8), // Primary container
    const Color(0xFF0F1414).withOpacity(0.9), // Darker variant
          const Color(0xFF0F1414), // Background
          const Color(0xFF0F1414), // Background
        ],
        stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
      );
    } else {
      return RadialGradient(
        center: const Alignment(-0.7, -0.5),
        radius: 1.6,
        colors: [
          const Color(0xFFF4FAFA), // Primary blue
          const Color(0xFFF4FAFA), // Medium blue
          const Color(0xFFF4FAFA), // Primary container
          const Color(0xFFF4FAFA), // Background
          const Color(0xFFF4FAFA), // Background
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      );
    }
  }

  RadialGradient _buildTransitionGradient() {
    final animValue = _colorAnimation.value;

    if (widget.isDarkMode) {
      return RadialGradient(
        center: Alignment(0.8 + math.sin(animValue * math.pi) * 0.2,
            0.4 + math.cos(animValue * math.pi) * 0.3),
        radius: 1.4 + animValue * 0.4,
        colors: [

          const Color(0xFF4CDADA).withOpacity(0.7 * (1 - animValue)), // Secondary
          const Color(0xFF4CDADA).withOpacity(0.7 * animValue), // Primary container
          const Color(0xFF4CDADA).withOpacity(0.7 * (1 - animValue)), // Primary
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.4, 0.7, 1.0],
      );
    } else {
      return RadialGradient(
        center: Alignment(0.7 + math.sin(animValue * math.pi) * 0.2,
            0.3 + math.cos(animValue * math.pi) * 0.3),
        radius: 1.2 + animValue * 0.3,
        colors: [
          const Color(0xFFFFFFFF).withOpacity(0.25 * (1 - animValue)),
          Colors.blue[300]!..withOpacity(0.04 * animValue),
          const Color(0xFFFFFFFF).withOpacity(0.15 * (1 - animValue)),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      );
    }
  }
}

class FluidShapesPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;

  FluidShapesPainter({
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    // Grande forme fluide principale (style blob)
    _drawFluidBlob(
        canvas,
        paint,
        canvasSize,
        Offset(canvasSize.width * 0.3, canvasSize.height * 0.2),
        200 + animation.value * 50,
        isDarkMode
            ? const Color(0xFF4CDADA).withOpacity(0.2)
            : const Color(0xFFFFFFFF).withOpacity(0.15),
        animation.value
    );

    // Forme fluide secondaire
    _drawFluidBlob(
        canvas,
        paint,
        canvasSize,
        Offset(canvasSize.width * 0.8, canvasSize.height * 0.7),
        150 + (1 - animation.value) * 40,
        isDarkMode
            ? const Color(0xFF4CDADA).withOpacity(0.15)
            : Colors.blue[400]!.withOpacity(0.12),
        1 - animation.value
    );

    // Petite forme d'accent
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    _drawFluidBlob(
        canvas,
        paint,
        canvasSize,
        Offset(canvasSize.width * 0.6, canvasSize.height * 0.4),
        80 + math.sin(animation.value * math.pi) * 20,
        isDarkMode
            ? const Color(0xFF0F1414).withOpacity(0.1)
            : const Color(0xFF70F7F7).withOpacity(0.2),
        animation.value * 0.5
    );
  }

  void _drawFluidBlob(Canvas canvas, Paint paint, Size canvasSize,
      Offset center, double baseRadius, Color color, double morphValue) {
    paint.color = color;

    final path = Path();
    final points = <Offset>[];

    // Créer des points pour une forme organique
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi * 2 / 8;
      final radiusVariation = math.sin(angle * 3 + morphValue * math.pi * 2) * 0.3 + 0.7;
      final radius = baseRadius * radiusVariation;

      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius * 0.8; // Légèrement aplati

      points.add(Offset(x, y));
    }

    // Dessiner une courbe douce entre les points
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length; i++) {
        final current = points[i];
        final next = points[(i + 1) % points.length];
        final controlPoint1 = Offset(
          current.dx + (next.dx - current.dx) * 0.5,
          current.dy,
        );
        final controlPoint2 = Offset(
          current.dx + (next.dx - current.dx) * 0.5,
          next.dy,
        );

        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          next.dx, next.dy,
        );
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget pour grille minimaliste (optionnel)
class FuturisticGrid extends StatelessWidget {
  final bool isDarkMode;

  const FuturisticGrid({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MinimalGridPainter(isDarkMode: isDarkMode),
      size: Size.infinite,
    );
  }
}

class MinimalGridPainter extends CustomPainter {
  final bool isDarkMode;

  MinimalGridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

    final gridColor = isDarkMode
        ? const Color(0xFF4CDADA).withOpacity(0.04)
        : Colors.blue[700]!.withOpacity(0.04);

    paint.color = gridColor;

    const spacing = 80.0;

    // Grille subtile
    for (double x = 0; x <= canvasSize.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, canvasSize.height), paint);
    }

    for (double y = 0; y <= canvasSize.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(canvasSize.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}