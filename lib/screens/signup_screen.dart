import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "../app_colors.dart";
import "../services/auth_provider.dart";

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  bool _loading = false;

  int get _passwordStrength {
    final p = _passCtrl.text;
    if (p.length >= 12) return 3;
    if (p.length >= 8) return 2;
    if (p.length >= 4) return 1;
    return 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) {
      _showError('Please agree to the Terms of Service to continue.');
      return;
    }
    setState(() => _loading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUp(_emailCtrl.text, _passCtrl.text, _nameCtrl.text);
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
          Positioned(top: -80, right: -80,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand()))),
          Positioned(bottom: -60, left: -60,
            child: Container(width: 240, height: 240,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.tertiary.withValues(alpha: 0.06)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand()))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildLogo(),
                    const SizedBox(height: 32),
                    _buildGlassCard(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() => Column(
    children: [
      ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [AppColors.primary, AppColors.tertiary],
        ).createShader(bounds),
        child: Text("TaskFlow AI",
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      const SizedBox(height: 4),
      Text("Elevate your focus",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      const SizedBox(height: 6),
      Text("Join high-achieving professionals using AI-driven precision.",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center),
    ],
  ).animate().fadeIn().slideY(begin: -0.1);

  Widget _buildGlassCard(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: AppColors.purpleGlow, blurRadius: 32)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(controller: _nameCtrl, label: "Full Name",
              icon: Icons.person_outline_rounded, hint: "John Doe",
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 14),
            _buildField(controller: _emailCtrl, label: "Email Address",
              icon: Icons.mail_outline_rounded, hint: "name@company.com",
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!_isValidEmail(v.trim())) return 'Enter a valid email address';
                return null;
              },
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 14),
            _buildField(controller: _passCtrl, label: "Password",
              icon: Icons.lock_outline_rounded, hint: "••••••••",
              obscure: _obscurePass,
              onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ).animate().fadeIn(delay: 200.ms),
            if (_passCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ...List.generate(3, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i < _passwordStrength ? AppColors.primary : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: i < _passwordStrength
                            ? [BoxShadow(color: AppColors.primaryGlow, blurRadius: 8)]
                            : null,
                      ),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Text(
                    _passwordStrength == 3 ? "Strong" : _passwordStrength == 2 ? "Medium" : "Weak",
                    style: GoogleFonts.inter(fontSize: 11,
                        color: _passwordStrength >= 2 ? AppColors.primary : AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text("8+ characters recommended",
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
            const SizedBox(height: 14),
            _buildField(controller: _confirmCtrl, label: "Confirm Password",
              icon: Icons.verified_user_outlined, hint: "••••••••",
              obscure: _obscureConfirm,
              onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passCtrl.text) return 'Passwords do not match';
                return null;
              },
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: _agreed ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _agreed ? AppColors.primary : AppColors.outlineVariant, width: 2),
                    ),
                    child: _agreed
                        ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "I agree to ",
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                        children: [
                          TextSpan(text: "Terms of Service",
                              style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          const TextSpan(text: " and "),
                          TextSpan(text: "Privacy Policy",
                              style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _signUp,
              child: AnimatedOpacity(
                opacity: _agreed ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer]),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_loading)
                        const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      else ...[
                        Text("Create Account",
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => context.go("/login"),
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                    children: [
                      TextSpan(text: "Login",
                          style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    ),
  ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05);

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) =>
    TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 18),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.onSurfaceVariant, size: 18),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
}
