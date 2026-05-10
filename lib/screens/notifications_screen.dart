import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../app_colors.dart";
import "../widgets/bottom_nav.dart";

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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, size: 36, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text("No notifications yet",
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    const SizedBox(height: 6),
                    Text("Your AI insights and reminders\nwill appear here.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5)),
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

}
