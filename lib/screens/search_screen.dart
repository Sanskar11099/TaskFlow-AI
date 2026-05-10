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
import "../widgets/task_card.dart";

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = "";
  String _activeFilter = "All Results";

  static const _filters = ["All Results", "Priority", "Date", "Type"];

  static const _recentSearches = <String>[];

  static const _suggestions = <_Suggestion>[];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isNotEmpty
        ? ref.watch(tasksProvider.notifier).search(_query)
        : <TaskModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient orbs
          Positioned(top: 80, right: -40,
            child: _GlowOrb(color: AppColors.primary.withValues(alpha: 0.08), size: 200)),
          Positioned(bottom: 120, left: -60,
            child: _GlowOrb(color: AppColors.secondary.withValues(alpha: 0.06), size: 180)),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: _query.isEmpty
                      ? _buildIdleContent()
                      : _buildResults(results),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
          ),
          child: Center(
            child: Text("A",
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

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, spreadRadius: -4),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.inter(
                        fontSize: 16, color: AppColors.onSurface, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "Search for files, tasks, or AI insights...",
                      hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant, size: 18),
                    onPressed: () { _ctrl.clear(); setState(() => _query = ""); },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  const Icon(Icons.mic_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.1, curve: Curves.easeOut),
  );

  Widget _buildFilterChips() => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final active = _filters[i] == _activeFilter;
        return GestureDetector(
          onTap: () => setState(() => _activeFilter = _filters[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.outlineVariant,
              ),
              boxShadow: active
                  ? [BoxShadow(color: AppColors.primaryGlow, blurRadius: 10)]
                  : null,
            ),
            child: Row(
              children: [
                Text(_filters[i],
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    )),
                if (!active) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: AppColors.onSurfaceVariant),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _buildIdleContent() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart Suggestions
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Text("Smart Suggestions",
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600,
                    color: const Color(0xFFC4C0FF))),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_suggestions.length, (i) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SuggestionCard(suggestion: _suggestions[i])
                .animate(delay: Duration(milliseconds: 50 * i)).fadeIn().slideX(begin: 0.05),
          )),
        const SizedBox(height: 24),
        // Recent Searches
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Searches",
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            TextButton(
              onPressed: () {},
              child: Text("Clear All",
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _recentSearches.map((s) => GestureDetector(
            onTap: () { _ctrl.text = s; setState(() => _query = s); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(s, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    ),
  );

  Widget _buildResults(List<TaskModel> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text("No results for \"$_query\"",
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: results.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TaskCard(
          task: results[i],
          onTap: () => context.push("/task/${results[i].id}", extra: results[i]),
          onToggle: (_) => ref.read(tasksProvider.notifier).toggleComplete(results[i].id),
          onDelete: () => ref.read(tasksProvider.notifier).deleteTask(results[i].id),
        ).animate(delay: Duration(milliseconds: 40 * i)).fadeIn().slideY(begin: 0.05),
      ),
    );
  }
}

class _Suggestion {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _Suggestion({required this.icon, required this.title, required this.subtitle, required this.color});
}

class _SuggestionCard extends StatelessWidget {
  final _Suggestion suggestion;
  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: suggestion.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(suggestion.icon, color: suggestion.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(suggestion.title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
              const SizedBox(height: 2),
              Text(suggestion.subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.onSurfaceVariant),
      ],
    ),
  );
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: const SizedBox.expand(),
    ),
  );
}
