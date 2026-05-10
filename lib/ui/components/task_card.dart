import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';
import 'animated_checkbox.dart';
import 'priority_chip.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      background: _swipeBackground(Colors.green, Icons.check, Alignment.centerLeft),
      secondaryBackground: _swipeBackground(Colors.red, Icons.delete, Alignment.centerRight),
      onDismissed: (dir) {
        if (dir == DismissDirection.startToEnd) onToggle?.call(!task.isCompleted);
        if (dir == DismissDirection.endToStart) onDelete?.call();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: task.isOverdue
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: AnimatedCheckbox(
                  value: task.isCompleted,
                  onChanged: onToggle ?? (_) {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PriorityChip(priority: task.priority, compact: true),
                        const SizedBox(width: 8),
                        if (task.dueDate != null) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: task.isOverdue ? AppColors.error : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            DateFormat('MMM d').format(task.dueDate!),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: task.isOverdue ? AppColors.error : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (task.tags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ...task.tags.take(2).map((tag) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  '#$tag',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.primary.withValues(alpha: 0.7),
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  Widget _swipeBackground(Color color, IconData icon, Alignment alignment) => Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(icon, color: color),
      );
}
