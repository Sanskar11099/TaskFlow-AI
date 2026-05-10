import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_colors.dart';

class AiOrb extends StatelessWidget {
  final double size;
  final bool pulsing;

  const AiOrb({super.key, this.size = 80, this.pulsing = true});

  @override
  Widget build(BuildContext context) {
    Widget orb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.primary, AppColors.secondaryContainer, AppColors.surfaceContainerLowest],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primaryGlow, blurRadius: 24, spreadRadius: 4),
          BoxShadow(color: AppColors.purpleGlow, blurRadius: 40, spreadRadius: 8),
        ],
      ),
    );

    if (!pulsing) return orb;

    return orb
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.95, end: 1.05, duration: 2000.ms, curve: Curves.easeInOut)
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -4, end: 4, duration: 3000.ms, curve: Curves.easeInOut);
  }
}
