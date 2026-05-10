import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "../../core/theme/app_colors.dart";
import "../../data/providers/theme_provider.dart";
import "../components/glass_card.dart";
import "../components/bottom_nav.dart";

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _predictiveAi = true;
  bool _cognitiveLoad = true;
  bool _smartReminders = true;
  bool _anonymizedTraining = false;
  int _accentIndex = 0;

  static const _accentColors = [AppColors.primary, AppColors.tertiary, AppColors.error];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

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
                SliverToBoxAdapter(child: _buildTopBar(context)),
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildAccountSection()),
                SliverToBoxAdapter(child: _buildAiSection()),
                SliverToBoxAdapter(child: _buildNotificationsSection()),
                SliverToBoxAdapter(child: _buildAppearanceSection(isDark)),
                SliverToBoxAdapter(child: _buildPrivacySection()),
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

  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
          ),
          child: Center(child: Text("A",
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

  Widget _buildAccountSection() => _Section(
    label: "Account",
    delay: 50,
    child: Column(
      children: [
        _MenuTile(
          icon: Icons.person_outline_rounded,
          title: "Profile Information",
          subtitle: "Alex Rivers · Professional Plan",
          onTap: () {},
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        _MenuTile(
          icon: Icons.lock_outline_rounded,
          title: "Security & Password",
          subtitle: "Last updated 2 months ago",
          onTap: () {},
        ),
      ],
    ),
  );

  Widget _buildAiSection() => _Section(
    label: "AI Preferences",
    delay: 100,
    child: Column(
      children: [
        _ToggleTile(
          icon: Icons.auto_awesome_rounded,
          title: "Predictive Task Creation",
          subtitle: "AI generates tasks based on your patterns",
          value: _predictiveAi,
          onChanged: (v) => setState(() => _predictiveAi = v),
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        _ToggleTile(
          icon: Icons.psychology_rounded,
          title: "Cognitive Load Analysis",
          subtitle: "Monitor mental bandwidth in real-time",
          value: _cognitiveLoad,
          onChanged: (v) => setState(() => _cognitiveLoad = v),
        ),
      ],
    ),
  );

  Widget _buildNotificationsSection() => _Section(
    label: "Notifications",
    delay: 150,
    child: Column(
      children: [
        _ToggleTile(
          icon: Icons.notifications_active_outlined,
          title: "Smart Reminders",
          subtitle: "AI-timed alerts at peak attention moments",
          value: _smartReminders,
          onChanged: (v) => setState(() => _smartReminders = v),
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        _MenuTile(
          icon: Icons.tune_rounded,
          title: "Notification Channels",
          subtitle: "Email, Push, Desktop alerts",
          onTap: () {},
        ),
      ],
    ),
  );

  Widget _buildAppearanceSection(bool isDark) => _Section(
    label: "Appearance",
    delay: 200,
    child: Column(
      children: [
        // Dark mode toggle
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
              // Segmented button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentBtn(label: "On", active: isDark, onTap: () =>
                        ref.read(themeProvider.notifier).state = ThemeMode.dark),
                    _SegmentBtn(label: "Off", active: !isDark, onTap: () =>
                        ref.read(themeProvider.notifier).state = ThemeMode.light),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
        // Accent color
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
                  onTap: () => setState(() => _accentIndex = e.key),
                  child: Container(
                    width: 26, height: 26,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e.value,
                      boxShadow: _accentIndex == e.key
                          ? [BoxShadow(color: e.value.withValues(alpha: 0.5), blurRadius: 10)]
                          : null,
                      border: _accentIndex == e.key
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

  Widget _buildPrivacySection() => _Section(
    label: "Privacy",
    delay: 250,
    child: _ToggleTile(
      icon: Icons.privacy_tip_outlined,
      title: "Anonymized Training",
      subtitle: "Help improve AI with anonymous usage data",
      value: _anonymizedTraining,
      onChanged: (v) => setState(() => _anonymizedTraining = v),
    ),
  );

  Widget _buildSignOut(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    child: GestureDetector(
      onTap: () => context.go("/login"),
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
        ? Text(subtitle!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant))
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
