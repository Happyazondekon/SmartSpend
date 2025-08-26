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
              ),
            );
          },
        ),

        // Effet de profondeur avec formes organiques


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


}





