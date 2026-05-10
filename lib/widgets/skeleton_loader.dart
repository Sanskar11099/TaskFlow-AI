import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "../app_colors.dart";

/// A shimmer-animated skeleton box. Use [SkeletonLoader] for pre-built layouts.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  ).animate(onPlay: (c) => c.repeat(reverse: true))
      .shimmer(
        duration: 1500.ms,
        color: AppColors.primary.withValues(alpha: 0.08),
      );
}

/// Pre-built skeleton layouts for common screens.
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  const SkeletonLoader({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      SkeletonType.taskList => _TaskListSkeleton(),
      SkeletonType.analytics => _AnalyticsSkeleton(),
      SkeletonType.profile => _ProfileSkeleton(),
    };
  }
}

enum SkeletonType { taskList, analytics, profile }

class _TaskListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: 5,
    itemBuilder: (_, i) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 22, height: 22, borderRadius: 999),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity * 0.6 + 120, height: 14),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 100, height: 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SkeletonBox(width: 52, height: 22, borderRadius: 999),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn(),
    ),
  );
}

class _AnalyticsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(children: [
          SkeletonBox(width: 140, height: 20),
          const Spacer(),
          SkeletonBox(width: 80, height: 14),
        ]),
        const SizedBox(height: 20),
        // Chart card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 120, height: 16),
              const SizedBox(height: 6),
              SkeletonBox(width: 80, height: 12),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0.6, 0.8, 0.5, 1.0, 0.7, 0.9, 0.75].map((h) =>
                  SkeletonBox(width: 28, height: 120 * h)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 0.95), end: const Offset(1, 1.0),
                          duration: 2000.ms, curve: Curves.easeInOut),
                ).toList(),
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        // Stat cards row
        Row(children: [
          Expanded(child: _StatCardSkeleton()),
          const SizedBox(width: 12),
          Expanded(child: _StatCardSkeleton()),
        ]),
        const SizedBox(height: 16),
        // Progress lines
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    SkeletonBox(width: 80, height: 12),
                    const Spacer(),
                    SkeletonBox(width: 30, height: 12),
                  ]),
                  const SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 6, borderRadius: 999),
                ],
              ),
            )),
          ),
        ).animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 20),
        // AI loading indicator
        _AiLoadingCard(),
      ],
    ),
  );
}

class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // Avatar
        SkeletonBox(width: 120, height: 120, borderRadius: 999),
        const SizedBox(height: 16),
        SkeletonBox(width: 160, height: 20),
        const SizedBox(height: 8),
        SkeletonBox(width: 200, height: 14),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: _StatCardSkeleton()),
          const SizedBox(width: 12),
          Expanded(child: _StatCardSkeleton()),
          const SizedBox(width: 12),
          Expanded(child: _StatCardSkeleton()),
        ]),
        const SizedBox(height: 16),
        SkeletonBox(width: double.infinity, height: 80, borderRadius: 20),
      ],
    ),
  );
}

class _StatCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 20, height: 20, borderRadius: 6),
        const SizedBox(height: 10),
        SkeletonBox(width: 60, height: 18),
        const SizedBox(height: 6),
        SkeletonBox(width: 80, height: 10),
      ],
    ),
  ).animate().fadeIn();
}

class _AiLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: Column(
      children: [
        Row(children: [
          SkeletonBox(width: 40, height: 40, borderRadius: 999),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SkeletonBox(width: 120, height: 14),
            const SizedBox(height: 6),
            SkeletonBox(width: 80, height: 10),
          ]),
        ]),
        const SizedBox(height: 16),
        // Progress ring
        Center(
          child: SizedBox(
            width: 60, height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary.withValues(alpha: 0.5),
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2000.ms),
        ),
        const SizedBox(height: 12),
        SkeletonBox(width: 180, height: 12),
        const SizedBox(height: 6),
        SkeletonBox(width: 140, height: 10),
      ],
    ),
  ).animate(delay: 150.ms).fadeIn();
}
