import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "../../core/theme/app_colors.dart";

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background decorative blurs
          Positioned(bottom: -80, left: -60,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand()))),
          Positioned(top: -40, right: -60,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withValues(alpha: 0.05),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _sent ? _buildSuccessView(context) : _buildFormView(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(BuildContext context) => Column(
    key: const ValueKey("form"),
    children: [
      // Icon
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondaryContainer.withValues(alpha: 0.3),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
          boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 20)],
        ),
        child: const Icon(Icons.lock_reset_rounded, size: 32, color: AppColors.primary),
      ).animate().scale(curve: Curves.elasticOut),
      const SizedBox(height: 24),
      Text("Forgot Password",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          textAlign: TextAlign.center).animate().fadeIn(delay: 100.ms),
      const SizedBox(height: 8),
      Text("Enter your email and we'll send you instructions to reset your password.",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
          textAlign: TextAlign.center).animate().fadeIn(delay: 150.ms),
      const SizedBox(height: 32),
      // Email input
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    hintText: "name@company.com",
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.onSurfaceVariant, size: 18),
                  ),
                ),
                const SizedBox(height: 20),
                // Send button
                GestureDetector(
                  onTap: () async {
                    final email = _emailCtrl.text.trim();
                    if (email.isEmpty) return;
                    setState(() => _loading = true);
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      if (mounted) setState(() { _loading = false; _sent = true; });
                    } catch (_) {
                      if (mounted) {
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to send reset email. Check the address.',
                                style: GoogleFonts.inter(color: Colors.white)),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryGlow, blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_loading)
                          const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        else ...[
                          Text("Send Reset Link",
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => context.pop(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text("Back to Login",
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms),
    ],
  );

  Widget _buildSuccessView(BuildContext context) => Column(
    key: const ValueKey("success"),
    children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.2),
          boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 30)],
        ),
        child: const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.primary),
      ).animate().scale(curve: Curves.elasticOut),
      const SizedBox(height: 24),
      Text("Link Sent!",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          textAlign: TextAlign.center).animate().fadeIn(delay: 150.ms),
      const SizedBox(height: 8),
      Text("We've sent a password reset link to\n${_emailCtrl.text}",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
          textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 32),
      GestureDetector(
        onTap: () => setState(() => _sent = false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text("Resend Email",
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ).animate().fadeIn(delay: 250.ms),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => context.go("/login"),
        child: Text("Back to Login",
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
      ).animate().fadeIn(delay: 300.ms),
    ],
  );
}
