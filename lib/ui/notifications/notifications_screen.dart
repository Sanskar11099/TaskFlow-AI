import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:google_fonts/google_fonts.dart";
import "../../core/theme/app_colors.dart";
import "../components/bottom_nav.dart";

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineGroup(
                      label: "TODAY",
                      items: _todayNotifs,
                    ),
                    const SizedBox(height: 28),
                    _buildTimelineGroup(
                      label: "EARLIER",
                      items: _earlierNotifs,
                      dimmed: true,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.onSurfaceVariant),
                        label: Text("Mark all as read",
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Notifications",
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        const SizedBox(height: 4),
        Text("Stay updated with your flow and AI insights",
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    ),
  );

  Widget _buildTimelineGroup({required String label, required List<_NotifData> items, bool dimmed = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        SizedBox(
          width: 28,
          child: Column(
            children: [
              // Dot
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 6, spreadRadius: 1)],
                ),
              ),
              // Line
              Container(
                width: 2,
                height: (items.length * 120.0).clamp(60, 9999),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0)],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  )),
              const SizedBox(height: 12),
              ...List.generate(items.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Opacity(
                  opacity: dimmed ? 0.7 : 1.0,
                  child: _NotifCard(data: items[i])
                      .animate(delay: Duration(milliseconds: 60 * i))
                      .fadeIn()
                      .slideX(begin: 0.05),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  static final _todayNotifs = [
    _NotifData(
      type: _NotifType.ai,
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.primary,
      title: "AI Productivity Insight",
      body: "You've been in deep work for 90 minutes. Consider a 10-minute break to maintain peak performance.",
      time: "2 min ago",
      actions: ["Start break", "Dismiss"],
    ),
    _NotifData(
      type: _NotifType.reminder,
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.tertiary,
      title: "Task Due Soon",
      body: "\"Finalize Q3 Roadmap\" is due in 2 hours. You're 60% complete.",
      time: "45 min ago",
    ),
    _NotifData(
      type: _NotifType.achievement,
      icon: Icons.workspace_premium_rounded,
      iconColor: AppColors.secondary,
      title: "Achievement Unlocked",
      body: "🏆 Deep Focus Master — You completed 5 focus sessions today!",
      time: "1h ago",
      isAchievement: true,
    ),
  ];

  static final _earlierNotifs = [
    _NotifData(
      type: _NotifType.reminder,
      icon: Icons.group_rounded,
      iconColor: AppColors.primary,
      title: "Team Update",
      body: "Sarah commented on \"Design System V2\" — 3 new replies.",
      time: "Yesterday",
    ),
    _NotifData(
      type: _NotifType.reminder,
      icon: Icons.event_available_rounded,
      iconColor: AppColors.tertiary,
      title: "Weekly Recap",
      body: "You completed 23 tasks this week. Flow Score: 982 (+12%).",
      time: "2 days ago",
    ),
  ];
}

enum _NotifType { ai, reminder, achievement }

class _NotifData {
  final _NotifType type;
  final IconData icon;
  final Color iconColor;
  final String title, body, time;
  final List<String>? actions;
  final bool isAchievement;

  const _NotifData({
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.actions,
    this.isAchievement = false,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotifData data;
  const _NotifCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.isAchievement
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.isAchievement
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: data.isAchievement
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 16)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: data.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: data.isAchievement
                      ? [BoxShadow(color: data.iconColor.withValues(alpha: 0.2), blurRadius: 12)]
                      : null,
                ),
                child: Icon(data.icon, color: data.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title,
                        style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: data.isAchievement ? AppColors.secondary : AppColors.onSurface,
                        )),
                    const SizedBox(height: 4),
                    Text(data.body,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface.withValues(alpha: 0.85), height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(data.time,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
          if (data.actions != null) ...[
            const SizedBox(height: 12),
            Row(
              children: data.actions!.asMap().entries.map((e) {
                final isPrimary = e.key == 0;
                return Padding(
                  padding: EdgeInsets.only(right: isPrimary ? 8 : 0),
                  child: isPrimary
                      ? ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                          child: Text(e.value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                        )
                      : OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outlineVariant),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(e.value,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
