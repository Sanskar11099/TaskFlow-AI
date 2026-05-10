import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "../../core/theme/app_colors.dart";
import "../../data/models/task_model.dart";
import "../../data/providers/tasks_provider.dart";
import "../../data/providers/quote_provider.dart";
import "../components/ai_orb.dart";
import "../components/bottom_nav.dart";
import "../components/glass_card.dart";
import "../components/task_card.dart";
import "../task/task_creation_sheet.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length;
    final score = total == 0 ? 0 : ((completedCount / total) * 100).round();
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -80, right: -60,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.primary.withValues(alpha: 0.08), Colors.transparent])))),
          Positioned(bottom: 100, left: -80,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.tertiary.withValues(alpha: 0.05), Colors.transparent])))),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(context, score, displayName)),
                SliverToBoxAdapter(child: _buildQuoteCard(ref)),
                SliverToBoxAdapter(child: _buildAiInsightCard(context)),
                SliverToBoxAdapter(child: _buildStatsRow(context, tasks, completedCount, total)),
                SliverToBoxAdapter(child: _buildQuickActions(context, ref)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's Tasks", style: Theme.of(context).textTheme.titleLarge),
                        Text("${pending.length} pending",
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => TaskCard(
                        task: pending[i],
                        onTap: () => context.push("/task/${pending[i].id}", extra: pending[i]),
                        onToggle: (_) => ref.read(tasksProvider.notifier).toggleComplete(pending[i].id),
                        onDelete: () => ref.read(tasksProvider.notifier).deleteTask(pending[i].id),
                      ),
                      childCount: pending.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildTopBar(BuildContext context, int score, String displayName) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.secondaryContainer,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.onSecondaryContainer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Good morning, $displayName", style: Theme.of(context).textTheme.titleMedium)
                      .animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text("$score% Productivity",
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push("/search"),
              icon: const Icon(Icons.search_rounded, color: AppColors.onSurface),
            ),
            IconButton(
              onPressed: () => context.push("/notifications"),
              icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
            ),
          ],
        ),
      );

  Widget _buildQuoteCard(WidgetRef ref) {
    final quoteAsync = ref.watch(quoteProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: quoteAsync.when(
        data: (quote) => GlassCard(
          applyBlur: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.format_quote_rounded, color: AppColors.tertiary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('"${quote.content}"',
                        style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.onSurface,
                          fontStyle: FontStyle.italic, height: 1.5)),
                    const SizedBox(height: 4),
                    Text("— ${quote.author}",
                        style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppColors.tertiary)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
        loading: () => GlassCard(
          applyBlur: true,
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.format_quote_rounded, color: AppColors.tertiary, size: 20),
              ),
              const SizedBox(width: 12),
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tertiary),
              ),
              const SizedBox(width: 10),
              Text("Loading quote...",
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAiInsightCard(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GlassCard(
          applyBlur: true,
          child: Row(
            children: [
              const AiOrb(size: 48, pulsing: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome to TaskFlow AI",
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Text("Add your first task to get started.",
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push("/focus"),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text("Start",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);

  Widget _buildStatsRow(BuildContext context, List<TaskModel> tasks, int done, int total) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            _StatCard(value: "${tasks.length}", label: "Tasks", icon: Icons.task_alt_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            _StatCard(value: "0h", label: "Focus", icon: Icons.timer_outlined, color: AppColors.tertiary),
            const SizedBox(width: 8),
            _StatCard(
              value: "${total == 0 ? 0 : ((done / total) * 100).round()}%",
              label: "Score", icon: Icons.bolt_rounded, color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            _StatCard(value: "0d", label: "Streak", icon: Icons.local_fire_department_rounded, color: AppColors.error),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms);

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Row(
          children: [
            _QuickAction(icon: Icons.add_task_rounded, label: "Add Task", color: AppColors.primary,
              onTap: () => showModalBottomSheet(
                context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                builder: (_) => const TaskCreationSheet())),
            const SizedBox(width: 10),
            _QuickAction(icon: Icons.center_focus_strong_rounded, label: "Focus",
              color: AppColors.tertiary, onTap: () => context.push("/focus")),
            const SizedBox(width: 10),
            _QuickAction(icon: Icons.calendar_month_rounded, label: "Calendar",
              color: AppColors.secondary, onTap: () => context.push("/calendar")),
            const SizedBox(width: 10),
            _QuickAction(icon: Icons.auto_awesome_rounded, label: "AI",
              color: AppColors.primaryContainer, onTap: () => context.push("/ai-assistant")),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms);

  Widget _buildFab(BuildContext context) => GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => const TaskCreationSheet()),
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, spreadRadius: 2)],
          ),
          child: const Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 28),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
              ],
            ),
          ),
        ),
      );
}
