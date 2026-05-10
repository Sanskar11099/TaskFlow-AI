import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "../../core/theme/app_colors.dart";

enum EmptyStateType { tasks, search, offline, aiInsight }

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? query;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.type, this.query, this.onAction});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      EmptyStateType.tasks    => _AllCaughtUp(onAction: onAction),
      EmptyStateType.search   => _NoResults(query: query ?? ""),
      EmptyStateType.offline  => _Offline(onRetry: onAction),
      EmptyStateType.aiInsight => _AiInsight(),
    };
  }
}

class _AllCaughtUp extends StatelessWidget {
  final VoidCallback? onAction;
  const _AllCaughtUp({this.onAction});

  @override
  Widget build(BuildContext context) => _GlassCard(
    child: Column(
      children: [
        // Trophy illustration
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.2),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 2000.ms),
            const Icon(Icons.emoji_events_rounded, size: 56, color: AppColors.tertiary),
          ],
        ).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text("All Caught Up!",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
            textAlign: TextAlign.center).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          "Your workspace is pristine. Every task has been mastered. Why not take a moment to recharge or plan your next breakthrough?",
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Text("Get Started",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    ),
  );
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) => _GlassCard(
    child: Column(
      children: [
        const Icon(Icons.search_off_rounded, size: 56, color: AppColors.primary)
            .animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text("No Matches Found",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            textAlign: TextAlign.center).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          'We searched through every corner of your TaskFlow, but "${query.isEmpty ? "your query" : query}" isn\'t here. Try a different keyword?',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),
      ],
    ),
  );
}

class _Offline extends StatelessWidget {
  final VoidCallback? onRetry;
  const _Offline({this.onRetry});

  @override
  Widget build(BuildContext context) => _GlassCard(
    child: Column(
      children: [
        const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error)
            .animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text("Offline Mode",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            textAlign: TextAlign.center).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          "It seems the connection has drifted away. We'll keep your local changes safe until you're back online.",
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.refresh_rounded, color: AppColors.error, size: 16),
              const SizedBox(width: 6),
              Text("Retry",
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
            ]),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    ),
  );
}

class _AiInsight extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.05), Colors.transparent],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms),
              const SizedBox(width: 8),
              Text("AI Suggestion",
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
            const SizedBox(height: 10),
            Text(
              '"Your peak productivity window is 9–11 AM based on your task completion patterns. Schedule your most complex work now."',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface,
                  fontStyle: FontStyle.italic, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(children: [
              _Tag("High Impact"),
              const SizedBox(width: 6),
              _Tag("Peak Focus"),
            ]),
          ],
        ),
      ),
    ),
  ).animate().fadeIn(delay: 200.ms);
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
  );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [BoxShadow(color: AppColors.purpleGlow, blurRadius: 32)],
        ),
        child: child,
      ),
    ),
  );
}
