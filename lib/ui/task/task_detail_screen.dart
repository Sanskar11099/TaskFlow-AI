import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";
import "dart:ui";
import "../../core/theme/app_colors.dart";
import "../../data/models/task_model.dart";
import "../../data/providers/tasks_provider.dart";
import "../components/ai_orb.dart";
import "../components/glass_card.dart";
import "task_creation_sheet.dart";

class TaskDetailScreen extends ConsumerWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(tasksProvider).firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow
          Positioned(top: -60, right: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.07),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()),
            )),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, ref, live),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroTitle(context, ref, live),
                        const SizedBox(height: 20),
                        _buildMetaRow(live),
                        if (live.description != null) ...[
                          const SizedBox(height: 20),
                          _buildDescription(live),
                        ],
                        const SizedBox(height: 20),
                        _buildSubtasksSection(live),
                        const SizedBox(height: 20),
                        _buildAiInsightCard(),
                        const SizedBox(height: 20),
                        _buildActivityTimeline(live),
                        if (live.tags.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildTags(live),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sticky bottom button
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildCompleteButton(context, ref, live),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, TaskModel live) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.surface.withValues(alpha: 0.1),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.onSurface),
              ),
              Expanded(
                child: Text("Task Details",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurfaceVariant),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => TaskCreationSheet(editTask: live),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTitle(BuildContext context, WidgetRef ref, TaskModel live) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(live.title,
              style: GoogleFonts.poppins(
                fontSize: 26, fontWeight: FontWeight.w700,
                color: AppColors.primary,
                decoration: live.isCompleted ? TextDecoration.lineThrough : null,
              )).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mark Complete",
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500,
                        color: AppColors.onSurface)),
                Switch(
                  value: live.isCompleted,
                  onChanged: (_) => ref.read(tasksProvider.notifier).toggleComplete(live.id),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primaryContainer,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms),
        ],
      ),
    );
  }

  Widget _buildMetaRow(TaskModel live) {
    return Row(
      children: [
        _PriorityBadge(priority: live.priority),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Text(live.status.name,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ),
        if (live.dueDate != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: live.isOverdue
                  ? AppColors.error.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: live.isOverdue ? AppColors.error.withValues(alpha: 0.5) : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 12,
                    color: live.isOverdue ? AppColors.error : AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(DateFormat("MMM d").format(live.dueDate!),
                    style: GoogleFonts.inter(fontSize: 11,
                        color: live.isOverdue ? AppColors.error : AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildDescription(TaskModel live) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DESCRIPTION",
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                letterSpacing: 1.2, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        GlassCard(
          child: Text(live.description!,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface, height: 1.6)),
        ),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildSubtasksSection(TaskModel live) {
    const subtasks = [
      _SubTask("Define system architecture scope", true),
      _SubTask("Review current bottlenecks", true),
      _SubTask("Draft scaling proposal", true),
      _SubTask("Stakeholder alignment meeting", true),
      _SubTask("Finalize tech stack decision", false),
      _SubTask("Document final recommendations", false),
    ];
    final done = subtasks.where((s) => s.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("SUBTASKS",
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                    letterSpacing: 1.2, color: AppColors.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text("$done of ${subtasks.length} Completed",
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: subtasks.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.done ? AppColors.primaryContainer : Colors.transparent,
                            border: Border.all(
                              color: s.done ? AppColors.primaryContainer : AppColors.outlineVariant,
                              width: 2,
                            ),
                            boxShadow: s.done
                                ? [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.5), blurRadius: 8)]
                                : null,
                          ),
                          child: s.done
                              ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(s.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: s.done ? AppColors.onSurfaceVariant : AppColors.onSurface,
                              decoration: s.done ? TextDecoration.lineThrough : null,
                            )),
                      ],
                    ),
                  ),
                  if (i < subtasks.length - 1)
                    const Divider(color: AppColors.outlineVariant, height: 1, indent: 48),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildAiInsightCard() {
    return GlassCard(
      child: Row(
        children: [
          const AiOrb(size: 48, pulsing: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Insight",
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppColors.primary, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text("Project Velocity: 68% — You're ahead of schedule. Consider wrapping up by Thursday to exceed targets.",
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildActivityTimeline(TaskModel live) {
    final events = [
      _Activity(icon: Icons.add_circle_outline, color: AppColors.outlineVariant,
          text: "Task created", time: DateFormat("MMM d, y").format(live.createdAt)),
      _Activity(icon: Icons.auto_awesome_rounded, color: AppColors.primary,
          text: "AI adjusted priority to ${live.priority.name}", time: "2h ago"),
      _Activity(icon: Icons.calendar_today_outlined, color: AppColors.outlineVariant,
          text: live.dueDate != null
              ? "Due date set to ${DateFormat("MMM d").format(live.dueDate!)}"
              : "No due date set",
          time: "4h ago"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ACTIVITY",
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                letterSpacing: 1.2, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 12),
        ...events.asMap().entries.map((e) {
          final i = e.key;
          final a = e.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: a.color.withValues(alpha: 0.15),
                      border: Border.all(color: a.color.withValues(alpha: 0.5)),
                      boxShadow: a.color == AppColors.primary
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: Icon(a.icon, size: 14, color: a.color),
                  ),
                  if (i < events.length - 1)
                    Container(width: 1, height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.outlineVariant, AppColors.outlineVariant.withValues(alpha: 0)],
                          ),
                        )),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(a.text,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
                      ),
                      Text(a.time,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTags(TaskModel live) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TAGS",
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                letterSpacing: 1.2, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: live.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text("#$tag",
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
          )).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildCompleteButton(BuildContext context, WidgetRef ref, TaskModel live) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(tasksProvider.notifier).toggleComplete(live.id),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: live.isCompleted
                        ? [AppColors.surfaceContainerHigh, AppColors.surfaceContainerHigh]
                        : [AppColors.primary, AppColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: live.isCompleted ? null : [
                    BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      live.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      live.isCompleted ? "Mark Incomplete" : "Complete Task",
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              ref.read(tasksProvider.notifier).deleteTask(live.id);
              context.pop();
            },
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubTask {
  final String label;
  final bool done;
  const _SubTask(this.label, this.done);
}

class _Activity {
  final IconData icon;
  final Color color;
  final String text, time;
  const _Activity({required this.icon, required this.color, required this.text, required this.time});
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (priority) {
      TaskPriority.low    => (AppColors.outline, AppColors.surfaceContainerHigh),
      TaskPriority.medium => (AppColors.tertiary, AppColors.tertiary.withValues(alpha: 0.15)),
      TaskPriority.high   => (AppColors.onPrimary, AppColors.primaryContainer),
      TaskPriority.urgent => (AppColors.error, AppColors.errorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text("${priority.name[0].toUpperCase()}${priority.name.substring(1)} Priority",
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
