import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../models/task_model.dart';

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityChip({super.key, required this.priority, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final config = _config[priority]!;
    Widget chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: config.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: config.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: GoogleFonts.inter(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: config.text,
            ),
          ),
        ],
      ),
    );

    if (priority == TaskPriority.urgent) {
      chip = chip
          .animate(onPlay: (c) => c.repeat())
          .fadeIn(duration: 800.ms)
          .then()
          .fadeOut(duration: 800.ms);
    }
    return chip;
  }

  static final _config = {
    TaskPriority.low: _ChipConfig(
      label: 'Low',
      bg: AppColors.priorityLow.withValues(alpha: 0.3),
      border: AppColors.priorityLow,
      dot: AppColors.onSurfaceVariant,
      text: AppColors.onSurfaceVariant,
    ),
    TaskPriority.medium: _ChipConfig(
      label: 'Medium',
      bg: AppColors.priorityMedium.withValues(alpha: 0.3),
      border: AppColors.priorityMedium,
      dot: AppColors.warning,
      text: AppColors.warning,
    ),
    TaskPriority.high: _ChipConfig(
      label: 'High',
      bg: AppColors.priorityHigh.withValues(alpha: 0.4),
      border: AppColors.priorityHigh,
      dot: AppColors.primary,
      text: AppColors.primary,
    ),
    TaskPriority.urgent: _ChipConfig(
      label: 'Urgent',
      bg: AppColors.priorityUrgent.withValues(alpha: 0.3),
      border: AppColors.priorityUrgent,
      dot: AppColors.error,
      text: AppColors.error,
    ),
  };
}

class _ChipConfig {
  final String label;
  final Color bg, border, dot, text;
  const _ChipConfig({
    required this.label,
    required this.bg,
    required this.border,
    required this.dot,
    required this.text,
  });
}
