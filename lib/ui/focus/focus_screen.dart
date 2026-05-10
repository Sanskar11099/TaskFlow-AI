import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:google_fonts/google_fonts.dart";
import "../../core/theme/app_colors.dart";
import "../components/ai_orb.dart";

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with SingleTickerProviderStateMixin {
  static const _workDuration = 25 * 60;
  static const _breakDuration = 5 * 60;

  bool _running = false;
  bool _onBreak = false;
  int _secondsLeft = _workDuration;
  int _sessionsCompleted = 3;
  int _totalSessions = 4;
  String _ambientSound = "Deep Space";
  late AnimationController _timerAnim;

  static const _sounds = ["Deep Space", "Rain Forest", "White Noise", "Ocean Waves"];

  @override
  void initState() {
    super.initState();
    _timerAnim = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _timerAnim.dispose();
    super.dispose();
  }

  void _tick() {
    if (!_running) return;
    if (_secondsLeft > 0) {
      setState(() => _secondsLeft--);
      Future.delayed(const Duration(seconds: 1), _tick);
    } else {
      setState(() {
        if (_onBreak) {
          _onBreak = false;
          _secondsLeft = _workDuration;
        } else {
          _onBreak = true;
          _secondsLeft = _breakDuration;
          _sessionsCompleted++;
        }
        _running = false;
      });
    }
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) _tick();
  }

  void _reset() => setState(() {
    _running = false;
    _onBreak = false;
    _secondsLeft = _workDuration;
  });

  String get _timeString {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return "${m.toString().padLeft(2, "0")}:${s.toString().padLeft(2, "0")}";
  }

  double get _progress => _onBreak
      ? 1 - _secondsLeft / _breakDuration
      : 1 - _secondsLeft / _workDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background orb decorations
          Positioned(top: -100, right: -80,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.primary.withValues(alpha: 0.05), Colors.transparent])))),
          Positioned(bottom: 100, left: -60,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.secondary.withValues(alpha: 0.05), Colors.transparent])))),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(children: [
                            const Icon(Icons.close, size: 16, color: AppColors.onSurface),
                            const SizedBox(width: 6),
                            Text("Exit Focus", style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
                          ]),
                        ),
                      ),
                      const Spacer(),
                      Text(_onBreak ? "Break Time" : "Deep Work Session",
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                    ],
                  ),
                ),
                // Main timer
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 260, height: 260,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 3,
                              backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                              color: _onBreak ? AppColors.tertiary : AppColors.primary,
                            ),
                          ),
                          AiOrb(size: 200, pulsing: _running),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_timeString,
                                style: GoogleFonts.poppins(
                                  fontSize: 52, fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  shadows: [Shadow(color: AppColors.primaryGlow, blurRadius: 20)],
                                ),
                              ),
                              Text(_onBreak ? "BREAK" : "FOCUS",
                                style: GoogleFonts.inter(
                                  fontSize: 11, letterSpacing: 3,
                                  color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ).animate().scale(curve: Curves.elasticOut),
                      const SizedBox(height: 40),
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ControlButton(
                            icon: Icons.refresh_rounded,
                            onTap: _reset,
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: _toggle,
                            child: Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.secondary],
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 24, spreadRadius: 2)],
                              ),
                              child: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: AppColors.onPrimary, size: 36),
                            ),
                          ),
                          const SizedBox(width: 20),
                          _ControlButton(icon: Icons.skip_next_rounded, onTap: _reset),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Ambient sound
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_ambientSound,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                                  Row(children: List.generate(4, (i) => Container(
                                    margin: const EdgeInsets.only(right: 2),
                                    width: 3, height: [6.0, 12.0, 8.0, 14.0][i],
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scaleY(begin: 0.4, end: 1.0, delay: Duration(milliseconds: i * 150), duration: 600.ms))),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final idx = _sounds.indexOf(_ambientSound);
                                setState(() => _ambientSound = _sounds[(idx + 1) % _sounds.length]);
                              },
                              child: Text("Change",
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Session Progress",
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                  const SizedBox(height: 6),
                                  Text("$_sessionsCompleted of $_totalSessions Intervals",
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: List.generate(_totalSessions, (i) => Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      width: 24, height: 6,
                                      decoration: BoxDecoration(
                                        color: i < _sessionsCompleted ? AppColors.primary : AppColors.outlineVariant,
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Today's Total",
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                  const SizedBox(height: 6),
                                  Text("4h 12m Focused",
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text("+18% vs yesterday",
                                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.success)),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
        ),
      );
}
