import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "../app_colors.dart";
import "../services/auth_provider.dart";
import "../services/theme_provider.dart";
import "../services/settings_provider.dart";
import "../services/user_profile_provider.dart";
import "../widgets/glass_card.dart";
import "../widgets/bottom_nav.dart";

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _accentColors = [AppColors.primary, AppColors.tertiary, AppColors.error];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final settings = ref.watch(settingsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final user = FirebaseAuth.instance.currentUser;

    final displayName = profileAsync.valueOrNull?.displayName ?? user?.displayName ?? 'User';
    final email = profileAsync.valueOrNull?.email ?? user?.email ?? '';
    final initials = displayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -80, right: -60,
            child: Container(width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()))),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(context, initials)),
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildAccountSection(displayName, email)),
                SliverToBoxAdapter(child: _buildAiSection(settings)),
                SliverToBoxAdapter(child: _buildNotificationsSection(settings)),
                SliverToBoxAdapter(child: _buildAppearanceSection(isDark, settings)),
                SliverToBoxAdapter(child: _buildPrivacySection(settings)),
                SliverToBoxAdapter(child: _buildSignOut(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildTopBar(BuildContext context, String initials) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
          ),
          child: Center(child: Text(initials.isNotEmpty ? initials[0] : 'U',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onPrimary))),
        ),
        const SizedBox(width: 12),
        Text("TaskFlow AI",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const Spacer(),
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
        ),
      ],
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Settings",
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        const SizedBox(height: 4),
        Text("Customize your intellectual workspace",
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
      ],
    ).animate().fadeIn(),
  );

  Widget _buildAccountSection(String displayName, String email) => _Section(
    label: "Account",
    delay: 50,
    child: Column(
      children: [
        _MenuTile(
          icon: Icons.person_outline_rounded,
          title: "Profile Information",
          subtitle: "$displayName · $email",
          onTap: () => context.push("/profile"),
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        _MenuTile(
          icon: Icons.lock_outline_rounded,
          title: "Security & Password",
          subtitle: "Change your password",
          onTap: () => _showChangePasswordDialog(),
        ),
      ],
    ),
  );

  void _showChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool saving = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text("Change Password",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              const SizedBox(height: 4),
              Text("Enter your current and new password",
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 20),
              _SheetTextField(controller: currentPassCtrl, hint: "Current Password", obscure: true),
              const SizedBox(height: 12),
              _SheetTextField(controller: newPassCtrl, hint: "New Password", obscure: true),
              const SizedBox(height: 12),
              _SheetTextField(controller: confirmPassCtrl, hint: "Confirm New Password", obscure: true),
              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(errorMsg!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.error)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    final currentPass = currentPassCtrl.text;
                    final newPass = newPassCtrl.text;
                    final confirmPass = confirmPassCtrl.text;
                    if (currentPass.isEmpty || newPass.isEmpty) {
                      setSheetState(() => errorMsg = 'Please fill all fields');
                      return;
                    }
                    if (newPass.length < 6) {
                      setSheetState(() => errorMsg = 'Password must be at least 6 characters');
                      return;
                    }
                    if (newPass != confirmPass) {
                      setSheetState(() => errorMsg = 'Passwords do not match');
                      return;
                    }
                    setSheetState(() { saving = true; errorMsg = null; });
                    try {
                      final user = FirebaseAuth.instance.currentUser!;
                      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPass);
                      await user.reauthenticateWithCredential(cred);
                      await user.updatePassword(newPass);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Password updated successfully!', style: GoogleFonts.inter()),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ));
                      }
                    } on FirebaseAuthException catch (e) {
                      setSheetState(() {
                        saving = false;
                        errorMsg = ref.read(authServiceProvider).getFriendlyError(e);
                      });
                    } catch (e) {
                      setSheetState(() { saving = false; errorMsg = 'Something went wrong. Try again.'; });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                      : Text("Update Password", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiSection(SettingsState settings) => _Section(
    label: "AI Preferences",
    delay: 100,
    child: Column(
      children: [
        _ToggleTile(
          icon: Icons.auto_awesome_rounded,
          title: "Predictive Task Creation",
          subtitle: "AI generates tasks based on your patterns",
          value: settings.predictiveAi,
          onChanged: (v) => ref.read(settingsProvider.notifier).setPredictiveAi(v),
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        _ToggleTile(
          icon: Icons.psychology_rounded,
          title: "Cognitive Load Analysis",
          subtitle: "Monitor mental bandwidth in real-time",
          value: settings.cognitiveLoad,
          onChanged: (v) => ref.read(settingsProvider.notifier).setCognitiveLoad(v),
        ),
      ],
    ),
  );

  Widget _buildNotificationsSection(SettingsState settings) => _Section(
    label: "Notifications",
    delay: 150,
    child: Column(
      children: [
        _ToggleTile(
          icon: Icons.notifications_active_outlined,
          title: "Smart Reminders",
          subtitle: "AI-timed alerts at peak attention moments",
          value: settings.smartReminders,
          onChanged: (v) => ref.read(settingsProvider.notifier).setSmartReminders(v),
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        _MenuTile(
          icon: Icons.tune_rounded,
          title: "Notification Channels",
          subtitle: "Email, Push, Desktop alerts",
          onTap: () => context.push("/notifications"),
        ),
      ],
    ),
  );

  Widget _buildAppearanceSection(bool isDark, SettingsState settings) => _Section(
    label: "Appearance",
    delay: 200,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Dark Mode",
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentBtn(label: "On", active: isDark, onTap: () =>
                        ref.read(themeProvider.notifier).setTheme(ThemeMode.dark)),
                    _SegmentBtn(label: "Off", active: !isDark, onTap: () =>
                        ref.read(themeProvider.notifier).setTheme(ThemeMode.light)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.palette_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Accent Color",
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
              ),
              Row(
                children: _accentColors.asMap().entries.map((e) => GestureDetector(
                  onTap: () => ref.read(settingsProvider.notifier).setAccentIndex(e.key),
                  child: Container(
                    width: 26, height: 26,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e.value,
                      boxShadow: settings.accentIndex == e.key
                          ? [BoxShadow(color: e.value.withValues(alpha: 0.5), blurRadius: 10)]
                          : null,
                      border: settings.accentIndex == e.key
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildPrivacySection(SettingsState settings) => _Section(
    label: "Privacy",
    delay: 250,
    child: _ToggleTile(
      icon: Icons.privacy_tip_outlined,
      title: "Anonymized Training",
      subtitle: "Help improve AI with anonymous usage data",
      value: settings.anonymizedTraining,
      onChanged: (v) => ref.read(settingsProvider.notifier).setAnonymizedTraining(v),
    ),
  );

  Widget _buildSignOut(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    child: GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Sign Out", style: GoogleFonts.poppins(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            content: Text("Are you sure you want to sign out?",
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: Text("Cancel", style: GoogleFonts.inter(color: AppColors.onSurfaceVariant))),
              TextButton(onPressed: () => Navigator.pop(ctx, true),
                  child: Text("Sign Out", style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600))),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) context.go("/login");
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Text("Sign Out",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms),
  );
}

// --- Reusable helper widgets ---

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  const _SheetTextField({required this.controller, required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceContainerHigh,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  final int delay;
  const _Section({required this.label, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
        ),
        GlassCard(padding: EdgeInsets.zero, child: child),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay)),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 18),
    ),
    title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
    subtitle: subtitle != null
        ? Text(subtitle!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis)
        : null,
    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 18),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.title, required this.subtitle,
      required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primaryContainer,
        ),
      ],
    ),
  );
}

class _SegmentBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SegmentBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: active ? [BoxShadow(color: AppColors.primaryGlow, blurRadius: 8)] : null,
      ),
      child: Text(label,
          style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          )),
    ),
  );
}
