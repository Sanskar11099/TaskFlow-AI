import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "../app_colors.dart";
import "../models/task_model.dart";
import "../services/tasks_provider.dart";
import "../widgets/bottom_nav.dart";

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selected;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
    _focusedMonth = DateTime.now();
  }

  List<DateTime> get _weekDays {
    final now = _selected;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider.notifier).forDate(_selected);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background orbs
          Positioned(bottom: 80, left: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()),
            )),
          Positioned(top: 200, right: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand()),
            )),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildDayPicker(),
                const Divider(color: AppColors.outlineVariant, height: 1),
                Expanded(
                  child: tasks.isEmpty
                      ? _buildEmptyAgenda()
                      : _buildAgenda(tasks),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        IconButton(
          onPressed: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            _selected = DateTime(_focusedMonth.year, _focusedMonth.month, _selected.day);
          }),
          icon: const Icon(Icons.chevron_left, color: AppColors.onSurface),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Text(_monthLabel(_focusedMonth),
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        const Spacer(),
        IconButton(
          onPressed: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            _selected = DateTime(_focusedMonth.year, _focusedMonth.month, _selected.day);
          }),
          icon: const Icon(Icons.chevron_right, color: AppColors.onSurface),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );

  Widget _buildDayPicker() => SizedBox(
    height: 82,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      itemCount: _weekDays.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final day = _weekDays[i];
        final isSelected = isSameDay(day, _selected);
        final isToday = isSameDay(day, DateTime.now());
        return GestureDetector(
          onTap: () => setState(() => _selected = day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                width: isSelected ? 0 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.primaryGlow, blurRadius: 12)]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_dayLabel(day),
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    )),
                const SizedBox(height: 4),
                Text("${day.day}",
                    style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.onPrimary : (isToday ? AppColors.primary : AppColors.onSurface),
                    )),
                const SizedBox(height: 4),
                // Event dot
                Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.onPrimary.withValues(alpha: 0.6)
                        : AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _buildEmptyAgenda() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.event_note_rounded, size: 56, color: AppColors.outlineVariant),
        const SizedBox(height: 16),
        Text("No events for this day",
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Text("Tap + to add a task",
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline)),
      ],
    ),
  );

  Widget _buildAgenda(List<TaskModel> tasks) {
    final timeSlots = ["08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          // Static deep work block
          _DeepWorkBlock().animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 8),
          // Task items
          ...List.generate(tasks.length, (i) {
            final task = tasks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AgendaTaskCard(task: task, onTap: () => context.push("/task/${task.id}", extra: task))
                  .animate(delay: Duration(milliseconds: 100 + 60 * i)).fadeIn().slideY(begin: 0.05),
            );
          }),
          // Time grid filler
          ...List.generate(timeSlots.length, (i) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(timeSlots[i],
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.right),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];
    return "${months[d.month - 1]} ${d.year}";
  }

  String _dayLabel(DateTime d) {
    const days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    return days[d.weekday - 1];
  }
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _DeepWorkBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryContainer.withValues(alpha: 0.2),
          AppColors.secondaryContainer.withValues(alpha: 0.2),
        ],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.center_focus_strong_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Deep Work: UI Architecture",
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 2),
              Text("High concentration work block",
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text("2h",
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ],
    ),
  );
}

class _AgendaTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  const _AgendaTaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUrgent = task.priority == TaskPriority.urgent;
    final isCompleted = task.isCompleted;
    final borderColor = isUrgent ? AppColors.error : AppColors.tertiary;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isCompleted ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: borderColor, width: 4)),
            boxShadow: isUrgent
                ? [BoxShadow(color: AppColors.error.withValues(alpha: 0.1), blurRadius: 16)]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primaryContainer : Colors.transparent,
                  border: isCompleted ? null : Border.all(color: AppColors.outlineVariant, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, size: 14, color: AppColors.onPrimary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        )),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 2),
                      Text("Due ${_formatDate(task.dueDate!)}",
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUrgent ? AppColors.error : AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(task.priority.name,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  Icon(Icons.drag_indicator_rounded, size: 18,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[d.month - 1]} ${d.day}";
  }
}
