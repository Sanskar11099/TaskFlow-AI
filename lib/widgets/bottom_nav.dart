import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', route: '/home'),
    _NavItem(icon: Icons.search_rounded, label: 'Search', route: '/search'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'Calendar', route: '/calendar'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics', route: '/analytics'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) => _buildItem(context, i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => context.go(item.route),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            if (selected)
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 6)],
                ),
              )
            else
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}
