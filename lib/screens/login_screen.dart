import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "../app_colors.dart";
import "../services/auth_provider.dart";
import "../widgets/glass_card.dart";
import "../widgets/premium_button.dart";

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(_emailCtrl.text, _passCtrl.text);
      if (mounted) context.go("/home");
    } catch (e) {
      if (mounted) {
        final authService = ref.read(authServiceProvider);
        _showError(authService.getFriendlyError(e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -60, right: -60,
            child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.primary.withValues(alpha: 0.1), Colors.transparent])))),
          Positioned(bottom: -60, left: -60,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.tertiary.withValues(alpha: 0.05), Colors.transparent])))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [AppColors.primary, AppColors.tertiary]).createShader(b),
                      child: Text("TaskFlow AI",
                        style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 6),
                    Text("Welcome back",
                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurfaceVariant))
                      .animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 40),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      applyBlur: true,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(color: AppColors.onSurface),
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.onSurfaceVariant, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!_isValidEmail(v.trim())) return 'Enter a valid email address';
                              return null;
                            },
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: GoogleFonts.inter(color: AppColors.onSurface),
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppColors.onSurfaceVariant, size: 20),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => context.push("/forgot-password"),
                              child: Text("Forgot password?",
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
                            ),
                          ).animate().fadeIn(delay: 350.ms),
                          const SizedBox(height: 24),
                          PremiumButton(label: "Sign In", isLoading: _loading, onPressed: _login)
                              .animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                        GestureDetector(
                          onTap: () => context.go("/signup"),
                          child: Text("Sign up",
                              style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 550.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
