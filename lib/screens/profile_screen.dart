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
import "../services/user_profile_provider.dart";
import "../widgets/bottom_nav.dart";
import "../widgets/glass_card.dart";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure profile doc exists in Firestore on screen load
    Future.microtask(() =>
        ref.read(userProfileServiceProvider).ensureProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final tasks = ref.watch(tasksProvider);
    final scoreAsync = ref.watch(productivityScoreProvider);
    final completedCount = tasks.where((t) => t.isCompleted).length;

    // Fallback to Auth data while Firestore loads
    final user = FirebaseAuth.instance.currentUser;
    final fallbackName = user?.displayName ?? 'User';
    final fallbackEmail = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -80, right: -60,
            child: Container(width: 260, height: 260,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x18C4C0FF)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()))),
          Positioned(bottom: 100, left: -80,
            child: Container(width: 220, height: 220,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x12FFB785)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()))),
          SafeArea(
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (profile) {
                final displayName = profile?.displayName ?? fallbackName;
                final email = profile?.email ?? fallbackEmail;
                final initials = profile?.initials ??
                    fallbackName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                final focusHours = profile?.focusHoursFormatted ?? '0m';
                final streak = profile?.currentStreak ?? 0;
                final longestStreak = profile?.longestStreak ?? 0;
                final score = scoreAsync.valueOrNull ?? 0;
                final joinedAt = profile?.joinedAt ?? DateTime.now();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildAppBar(context, initials)),
                    SliverToBoxAdapter(child: _buildProfileHero(displayName, email, initials, joinedAt)),
                    SliverToBoxAdapter(child: _buildStatsGrid(completedCount, focusHours, score)),
                    SliverToBoxAdapter(child: _buildSubscriptionCard()),
                    SliverToBoxAdapter(child: _buildAchievements(completedCount, streak, longestStreak, profile?.totalFocusMinutes ?? 0)),
                    SliverToBoxAdapter(child: _buildPreferences(context, ref, displayName, email)),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildAppBar(BuildContext context, String initials) => Padding(
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
            child: Text(initials.isNotEmpty ? initials[0] : 'U',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
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

  Widget _buildProfileHero(String displayName, String email, String initials, DateTime joinedAt) => Padding(
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
        const SizedBox(height: 4),
        Text("Member since ${_formatJoinDate(joinedAt)}",
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut),
  );

  String _formatJoinDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildStatsGrid(int completedCount, String focusHours, int score) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.task_alt_rounded, value: '$completedCount', label: "Tasks Done", color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.timer_rounded, value: focusHours, label: "Focus Time", color: AppColors.tertiary)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.bolt_rounded, value: '$score', label: "Flow Score", color: AppColors.secondary)),
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
          Positioned(top: -20, right: -20,
            child: Container(width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const SizedBox.expand()))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text("TaskFlow Pro",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
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

  Widget _buildAchievements(int completed, int streak, int longestStreak, int focusMins) {
    final bool hasStreak7 = streak >= 7 || longestStreak >= 7;
    final bool hasDeepDiver = completed >= 50;
    final bool hasAiMaster = completed >= 100;
    final bool hasFocusGod = focusMins >= 600; // 10+ hours

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.tertiary, size: 18),
            const SizedBox(width: 8),
            Text("Achievements",
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BadgeCard(icon: Icons.local_fire_department_rounded, label: "7 Day\nStreak", color: AppColors.tertiary, unlocked: hasStreak7),
              _BadgeCard(icon: Icons.water_rounded, label: "Deep\nDiver", color: AppColors.primary, unlocked: hasDeepDiver),
              _BadgeCard(icon: Icons.psychology_rounded, label: "AI\nMaster", color: AppColors.secondary, unlocked: hasAiMaster),
              _BadgeCard(icon: Icons.center_focus_strong_rounded, label: "Focus\nGod", color: AppColors.onSurfaceVariant, unlocked: hasFocusGod),
            ],
          ),
        ],
      ).animate().fadeIn(delay: 300.ms),
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail) {
    final nameCtrl = TextEditingController(text: currentName);
    bool saving = false;

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
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text("Edit Profile",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              const SizedBox(height: 4),
              Text("Update your display name",
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 24),
              Text("Display Name", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  hintText: "Your name",
                  hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.email_outlined, color: AppColors.onSurfaceVariant, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(currentEmail,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant))),
                  const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant, size: 14),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    final newName = nameCtrl.text.trim();
                    if (newName.isEmpty) return;
                    setSheetState(() => saving = true);
                    try {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        await ref.read(userProfileServiceProvider).updateDisplayName(uid, newName);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile updated!', style: GoogleFonts.inter()),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } catch (e) {
                      setSheetState(() => saving = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                        );
                      }
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
                      : Text("Save Changes", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferences(BuildContext context, WidgetRef ref, String currentName, String currentEmail) => Padding(
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
              _PrefItem(icon: Icons.person_outline, label: "Edit Profile",
                  onTap: () => _showEditProfileDialog(context, currentName, currentEmail)),
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
