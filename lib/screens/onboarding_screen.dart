import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "dart:math" as math;
import "../app_colors.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _titles = [
    "Organize Your Tasks",
    "Focus Deeply",
    "AI Smart Planning",
    "Sync Everywhere",
    "Track Productivity",
  ];

  static const _subtitles = [
    "Streamline your high-performance workflow with AI-driven prioritization and a serene focus environment.",
    "Enter an immersive environment designed for deep work. TaskFlow AI silences the noise so you can achieve peak performance.",
    "Let TaskFlow AI prioritize and schedule your day based on your energy levels and deadlines.",
    "Your productivity flows across all your devices. Real-time updates ensure you never skip a beat, whether you're at your desk or on the move.",
    "Visualize your progress with AI-powered analytics and insights tailored to your unique work style.",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glows
          Positioned(top: -60, left: -60,
            child: Container(width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.07)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: const SizedBox.expand()))),
          Positioned(bottom: 100, right: -60,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: AppColors.tertiary.withValues(alpha: 0.05)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: const SizedBox.expand()))),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _titles.length,
                    itemBuilder: (_, i) => _buildPage(i),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
    child: Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.tertiary],
          ).createShader(bounds),
          child: Text("TaskFlow AI",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => context.go("/login"),
          child: Text("Skip",
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
        ),
      ],
    ),
  );

  Widget _buildPage(int index) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIllustration(index),
        const SizedBox(height: 40),
        Text(_titles[index],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700,
                color: AppColors.onSurface, letterSpacing: -0.5))
            .animate(key: ValueKey("title_$index")).fadeIn(delay: 100.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        Text(_subtitles[index],
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurfaceVariant, height: 1.6))
            .animate(key: ValueKey("sub_$index")).fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        _buildInfoCard(index),
      ],
    ),
  );

  Widget _buildIllustration(int index) {
    return SizedBox(
      height: 220,
      child: switch (index) {
        0 => _OrganizeIllustration(),
        1 => _FocusIllustration(),
        2 => _AiOrbIllustration(),
        3 => _SyncIllustration(),
        _ => _AnalyticsIllustration(),
      },
    ).animate(key: ValueKey("illus_$index")).fadeIn(duration: 500.ms).scale(
        begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
  }

  Widget _buildInfoCard(int index) {
    final cards = [
      ("Precision Priority", "Adaptive algorithms handle the complexity of your schedule automatically.", Icons.flag_rounded),
      ("Zero Distraction", "Immersive focus mode blocks interruptions and tracks deep work intervals.", Icons.center_focus_strong_rounded),
      ("AI Scheduling", "Neural time-blocking adapts to your cognitive peaks and energy patterns.", Icons.bolt_rounded),
      ("Real-Time Sync", "Changes propagate instantly across all connected devices and platforms.", Icons.sync_rounded),
      ("Flow Analytics", "Detailed insights reveal your productivity patterns and help optimize performance.", Icons.insights_rounded),
    ];
    final (title, desc, icon) = cards[index];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(key: ValueKey("card_$index")).fadeIn(delay: 300.ms);
  }

  Widget _buildFooter(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
    child: Column(
      children: [
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_titles.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _page ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == _page ? AppColors.primary : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
              boxShadow: i == _page
                  ? [BoxShadow(color: AppColors.primaryGlow, blurRadius: 8)]
                  : null,
            ),
          )),
        ),
        const SizedBox(height: 24),
        // Continue button
        GestureDetector(
          onTap: () {
            if (_page == _titles.length - 1) {
              context.go("/login");
            } else {
              _controller.nextPage(
                  duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(color: AppColors.primaryGlow, blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _page == _titles.length - 1 ? "Get Started" : "Continue",
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Illustrations ───────────────────────────────────────────────────────────

class _OrganizeIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      // Background circle dashed
      CustomPaint(size: const Size(200, 200), painter: _DashedCirclePainter()),
      // Floating task cards
      Positioned(top: 20, left: 20,
        child: Transform.rotate(angle: -0.1,
          child: _MiniTaskCard(title: "Design Review", completed: true, tag: "High"))),
      Positioned(bottom: 20, right: 20,
        child: Transform.rotate(angle: 0.08,
          child: _MiniTaskCard(title: "Sprint Planning", completed: false, tag: "Work"))),
      // Center orb
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
          boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, spreadRadius: 4)],
        ),
        child: const Icon(Icons.view_kanban_rounded, color: Colors.white, size: 28),
      ),
    ],
  );
}

class _FocusIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 200, height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.08),
          boxShadow: [BoxShadow(color: AppColors.purpleGlow, blurRadius: 40, spreadRadius: 10)],
        ),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: const SizedBox.expand()),
      ),
      Container(
        width: 160, height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        ),
      ),
      Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 24)],
        ),
        child: const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 48),
      ),
      // Floating timer chip
      Positioned(top: 16, right: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.timer_rounded, size: 12, color: AppColors.tertiary),
            const SizedBox(width: 4),
            Text("25:00", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          ]),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -6, duration: 2000.ms)),
      // FOCUS chip
      Positioned(bottom: 20, left: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Text("FOCUS MODE",
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: 1.5, color: AppColors.primary)),
        )),
    ],
  );
}

class _AiOrbIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      // Outer ring (pulsing)
      Container(
        width: 200, height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1),
        ),
      ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08),
          duration: 2000.ms, curve: Curves.easeInOut).then().scale(
          begin: const Offset(1.08, 1.08), end: const Offset(1, 1), duration: 2000.ms),
      Container(
        width: 160, height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
        ),
      ),
      // Core orb
      Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.primary, AppColors.primaryContainer, AppColors.secondaryContainer],
            stops: const [0.0, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(color: AppColors.primaryGlow, blurRadius: 30, spreadRadius: 8),
            BoxShadow(color: AppColors.purpleGlow, blurRadius: 50, spreadRadius: 4),
          ],
        ),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 44),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -12, duration: 3000.ms, curve: Curves.easeInOut),
      // Floating particles
      Positioned(top: 30, right: 40,
        child: Container(width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.8),
            boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 8)],
          )).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -8, duration: 2500.ms)),
      Positioned(bottom: 40, left: 40,
        child: Container(width: 7, height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.tertiary.withValues(alpha: 0.8),
          )).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -6, duration: 2000.ms)),
    ],
  );
}

class _SyncIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      // SVG-style dashed circle
      CustomPaint(size: const Size(180, 180), painter: _DashedCirclePainter(opacity: 0.3)),
      // Center sync orb
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [AppColors.primary, AppColors.secondaryContainer]),
          boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 24, spreadRadius: 4)],
        ),
        child: const Icon(Icons.sync_rounded, color: Colors.white, size: 36),
      ).animate(onPlay: (c) => c.repeat()).rotate(duration: 8000.ms),
      // Device cards
      Positioned(top: 10, right: 0,
        child: Transform.rotate(angle: 0.2,
          child: _DeviceCard(icon: Icons.phone_iphone_rounded, label: "Mobile"))),
      Positioned(bottom: 10, left: 0,
        child: Transform.rotate(angle: -0.15,
          child: _DeviceCard(icon: Icons.laptop_rounded, label: "Desktop"))),
      Positioned(top: 60, left: 10,
        child: Transform.rotate(angle: -0.25,
          child: _DeviceCard(icon: Icons.tablet_rounded, label: "Tablet"))),
    ],
  );
}

class _AnalyticsIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const bars = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 1.0];
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background orb
        Container(
          width: 160, height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
          child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox.expand()),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms),
        // Chart card
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Weekly Flow", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: bars.asMap().entries.map((e) => AnimatedContainer(
                      duration: Duration(milliseconds: 400 + e.key * 80),
                      width: 18,
                      height: 80 * e.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.3)],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _MiniTaskCard extends StatelessWidget {
  final String title, tag;
  final bool completed;
  const _MiniTaskCard({required this.title, required this.tag, required this.completed});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: AppColors.purpleGlow, blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Container(width: 14, height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? AppColors.primaryContainer : Colors.transparent,
                  border: Border.all(color: completed ? AppColors.primary : AppColors.outlineVariant, width: 1.5),
                ),
                child: completed ? const Icon(Icons.check_rounded, size: 8, color: Colors.white) : null),
              const SizedBox(width: 6),
              Expanded(child: Text(title,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      decoration: completed ? TextDecoration.lineThrough : null),
                  overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(tag, style: GoogleFonts.inter(fontSize: 9, color: AppColors.primary)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DeviceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DeviceCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant)),
        ]),
      ),
    ),
  );
}

class _DashedCirclePainter extends CustomPainter {
  final double opacity;
  const _DashedCirclePainter({this.opacity = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashLength = 8.0;
    const gapLength = 6.0;
    final circumference = 2 * math.pi * radius;
    final totalDashes = (circumference / (dashLength + gapLength)).floor();

    for (int i = 0; i < totalDashes; i++) {
      final startAngle = i * (dashLength + gapLength) / radius;
      final sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => false;
}
