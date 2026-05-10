import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";
import "dart:ui";
import "../../core/theme/app_colors.dart";
import "../../data/models/task_model.dart";
import "../../data/providers/tasks_provider.dart";

class TaskCreationSheet extends ConsumerStatefulWidget {
  final TaskModel? editTask;
  const TaskCreationSheet({super.key, this.editTask});

  @override
  ConsumerState<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

class _TaskCreationSheetState extends ConsumerState<TaskCreationSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.high;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  final _selectedTags = <String>{};

  static const _presetTags = ["Work", "Personal", "Design", "Dev", "Urgent"];

  static const _aiSuggestions = [
    _AiHint(icon: Icons.timer_rounded, text: "Based on task complexity, this might take 45 minutes"),
    _AiHint(icon: Icons.bolt_rounded, text: "Optimal focus time: 9:00 AM (Peak alertness)"),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editTask != null) {
      final t = widget.editTask!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? "";
      _priority = t.priority;
      _dueDate = t.dueDate;
      _selectedTags.addAll(t.tags);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final notifier = ref.read(tasksProvider.notifier);
    if (widget.editTask != null) {
      notifier.updateTask(widget.editTask!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        tags: _selectedTags.toList(),
      ));
    } else {
      notifier.addTask(TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        tags: _selectedTags.toList(),
        createdAt: DateTime.now(),
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: AppColors.purpleGlow.withValues(alpha: 0.5), blurRadius: 32, offset: const Offset(0, -8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  _buildTitleField(),
                  _buildDescriptionField(),
                  _buildPrioritySection(),
                  _buildDateTimeRow(context),
                  _buildAiSuggestions(),
                  _buildTagsSection(),
                  _buildCreateButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 48, height: 5,
        decoration: BoxDecoration(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    ),
  );

  Widget _buildTitleField() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          autofocus: widget.editTask == null,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: "What's the mission?",
            hintStyle: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.5), Colors.transparent],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(),
  );

  Widget _buildDescriptionField() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: TextField(
      controller: _descCtrl,
      maxLines: 3,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: "Add context or notes...",
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
        filled: true,
        fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    ),
  );

  Widget _buildPrioritySection() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded, size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text("Priority", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: TaskPriority.values.map((p) {
            final active = _priority == p;
            final color = _priorityColor(p);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? color.withValues(alpha: 0.2) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? color : AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                      boxShadow: active
                          ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 10)]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(p.name[0].toUpperCase() + p.name.substring(1),
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: active ? color : AppColors.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );

  Widget _buildDateTimeRow(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _dueDate = picked);
            },
            child: _DateTimeChip(
              icon: Icons.calendar_today_outlined,
              label: _dueDate == null ? "Due date" : DateFormat("MMM d").format(_dueDate!),
              active: _dueDate != null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _dueTime ?? TimeOfDay.now(),
              );
              if (picked != null) setState(() => _dueTime = picked);
            },
            child: _DateTimeChip(
              icon: Icons.schedule_outlined,
              label: _dueTime == null ? "10:00 AM" : _dueTime!.format(context),
              active: _dueTime != null,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildAiSuggestions() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_rounded,
                  size: 16, color: AppColors.primary)
                  .animate(onPlay: (c) => c.repeat())
                  .then(delay: 1500.ms)
                  .fadeIn(duration: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
              const SizedBox(width: 6),
              Text("AI Suggestions",
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          ..._aiSuggestions.map((hint) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(hint.icon, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(hint.text,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4)),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms),
  );

  Widget _buildTagsSection() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Categorize",
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            ..._presetTags.map((tag) {
              final selected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) _selectedTags.remove(tag);
                  else _selectedTags.add(tag);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryContainer.withValues(alpha: 0.25) : AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? AppColors.primaryContainer : AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(Icons.done_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                      ],
                      Text(tag,
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
              );
            }),
            // Add custom tag button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4), style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text("Add",
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildCreateButton() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    child: GestureDetector(
      onTap: _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.purpleGlow.withValues(alpha: 0.8),
              blurRadius: 24, offset: const Offset(0, 12), spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(widget.editTask == null ? "Create Task" : "Save Changes",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms),
  );

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low: return AppColors.outline;
      case TaskPriority.medium: return AppColors.tertiary;
      case TaskPriority.high: return AppColors.primary;
      case TaskPriority.urgent: return AppColors.error;
    }
  }
}

class _DateTimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _DateTimeChip({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: active ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.4),
      ),
    ),
    child: Row(
      children: [
        Icon(icon, size: 15, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: active ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );
}

class _AiHint {
  final IconData icon;
  final String text;
  const _AiHint({required this.icon, required this.text});
}
