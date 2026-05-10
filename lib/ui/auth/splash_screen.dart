import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "../../core/theme/app_colors.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.go("/home");
    } else {
      context.go("/onboarding");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -100, right: -60,
            child: Container(width: 320, height: 320,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.secondaryContainer.withValues(alpha: 0.3), Colors.transparent])))),
          Positioned(bottom: -80, left: -60,
            child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.primaryContainer.withValues(alpha: 0.2), Colors.transparent])))),
          Positioned(top: 200, left: -40,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.tertiaryContainer.withValues(alpha: 0.15), Colors.transparent])))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [AppColors.primary, AppColors.secondaryContainer, AppColors.surfaceContainerLowest],
                          stops: [0.0, 0.6, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.primaryGlow, blurRadius: 30, spreadRadius: 6),
                          BoxShadow(color: AppColors.purpleGlow, blurRadius: 50, spreadRadius: 10),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.95, end: 1.05, duration: 2000.ms)
                        .then().scaleXY(begin: 1.05, end: 0.95, duration: 2000.ms),
                    Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                        .rotate(duration: 8000.ms),
                    const Icon(Icons.smart_toy_outlined, size: 40, color: Colors.white),
                  ],
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                const SizedBox(height: 36),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.tertiary],
                  ).createShader(bounds),
                  child: Text("TaskFlow AI",
                    style: GoogleFonts.poppins(
                      fontSize: 38, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: -0.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text("Precision Productivity with Intelligence",
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(width: 10),
                    Text("Synchronizing...",
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
