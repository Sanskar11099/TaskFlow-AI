import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "../app_colors.dart";
import "../services/auth_provider.dart";
import "../services/tasks_provider.dart";
import "../widgets/bottom_nav.dart";
import "../widgets/glass_card.dart";

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final completed = tasks.where((t) => t.isCompleted).length;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initials = displayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background blobs
          Positioned(top: -80, right: -60,
            child: Container(width: 260, height: 260,
              decoration: const BoxDecoration(shape: BoxShape.circle,
                color: Color(0x18C4C0FF)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()))),
          Positioned(bottom: 100, left: -80,
            child: Container(width: 220, height: 220,
              decoration: const BoxDecoration(shape: BoxShape.circle,
                color: Color(0x12FFB785)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()))),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar(context)),
                SliverToBoxAdapter(child: _buildProfileHero(displayName, email, initials)),
                SliverToBoxAdapter(child: _buildStatsGrid(completed)),
                SliverToBoxAdapter(child: _buildSubscriptionCard()),
                SliverToBoxAdapter(child: _buildAchievements()),
                SliverToBoxAdapter(child: _buildPreferences(context, ref)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
          ),
          child: Center(
            child: Text("A", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
          ),
        ),
        const SizedBox(width: 12),
        Text("TaskFlow AI",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const Spacer(),
        IconButton(
          onPressed: () => context.push("/settings"),
          icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
        ),
      ],
    ),
  );

  Widget _buildProfileHero(String displayName, String email, String initials) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 30, spreadRadius: 4)],
              ),
            ),
            Container(
              width: 128, height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
              ),
              child: Center(
                child: Text(initials.isNotEmpty ? initials : 'U',
                    style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(displayName,
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        const SizedBox(height: 4),
        Text(email,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut),
  );

  Widget _buildStatsGrid(int completedCount) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.task_alt_rounded, value: "1,284", label: "Tasks Done", color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.timer_rounded, value: "42.5h", label: "Focus Hours", color: AppColors.tertiary)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.bolt_rounded, value: "982", label: "Flow Score", color: AppColors.secondary)),
      ],
    ).animate().fadeIn(delay: 150.ms),
  );

  Widget _buildSubscriptionCard() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondaryContainer],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          // Decorative blur
          Positioned(top: -20, right: -20,
            child: Container(width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const SizedBox.expand()))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text("TaskFlow Pro",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("All features unlocked",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 0,
                ),
                child: Text("Manage Plan",
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms),
  );

  Widget _buildAchievements() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.tertiary, size: 18),
            const SizedBox(width: 8),
            Text("Achievements",
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BadgeCard(icon: Icons.local_fire_department_rounded, label: "7 Day\nStreak", color: AppColors.tertiary, unlocked: true),
            _BadgeCard(icon: Icons.water_rounded, label: "Deep\nDiver", color: AppColors.primary, unlocked: true),
            _BadgeCard(icon: Icons.psychology_rounded, label: "AI\nMaster", color: AppColors.secondary, unlocked: true),
            _BadgeCard(icon: Icons.center_focus_strong_rounded, label: "Focus\nGod", color: AppColors.onSurfaceVariant, unlocked: false),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms),
  );

  Widget _buildPreferences(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Preferences",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _PrefItem(icon: Icons.person_outline, label: "Edit Profile", onTap: () {}),
              const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
              _PrefItem(icon: Icons.notifications_outlined, label: "Notifications", onTap: () => context.push("/notifications")),
              const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
              _PrefItem(icon: Icons.bar_chart_rounded, label: "Analytics", onTap: () => context.push("/analytics")),
              const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
              _PrefItem(icon: Icons.settings_outlined, label: "Settings", onTap: () => context.push("/settings")),
              const Divider(color: AppColors.outlineVariant, height: 1, indent: 56),
              _PrefItem(
                icon: Icons.logout_rounded,
                label: "Sign Out",
                color: AppColors.error,
                onTap: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go("/login");
                },
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      boxShadow: [BoxShadow(color: AppColors.purpleGlow, blurRadius: 16)],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    ),
  );
}

class _BadgeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool unlocked;
  const _BadgeCard({required this.icon, required this.label, required this.color, required this.unlocked});

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: unlocked ? 1.0 : 0.4,
    child: Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            boxShadow: unlocked ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12)] : null,
          ),
          child: Icon(icon, color: unlocked ? color : AppColors.onSurfaceVariant, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, height: 1.3),
            textAlign: TextAlign.center),
      ],
    ),
  );
}

class _PrefItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _PrefItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color ?? AppColors.primary, size: 18),
    ),
    title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? AppColors.onSurface)),
    trailing: Icon(Icons.chevron_right, color: color ?? AppColors.onSurfaceVariant, size: 20),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}
