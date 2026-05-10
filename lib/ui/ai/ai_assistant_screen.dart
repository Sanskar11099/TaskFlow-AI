import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:google_fonts/google_fonts.dart";
import "../../core/theme/app_colors.dart";
import "../components/ai_orb.dart";

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _thinking = false;

  static const _suggestions = [
    "Summarize my day",
    "What should I focus on?",
    "Create a study plan",
    "Prioritize my tasks",
  ];

  final _messages = <_Message>[
    _Message(
      text: "Hi! I'm your AI productivity assistant. Ask me anything — I can help you plan tasks, prioritize your work, or create a focus schedule.",
      isAi: true,
      time: "Just now",
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send([String? preset]) async {
    final text = preset ?? _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isAi: false, time: "Just now"));
      _ctrl.clear();
      _thinking = true;
    });
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _thinking = false;
        _messages.add(_Message(
          text: "Based on your current tasks and productivity peak at 9AM, I recommend: Start with the critical bug fix (30 min), then the quarterly review (45 min). Take a 5-minute break and use Focus Mode. Want me to schedule this for you?",
          isAi: true,
          time: "Just now",
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const AiOrb(size: 28, pulsing: false),
            const SizedBox(width: 10),
            Text("AI Productivity Assistant", style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Suggestion chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _suggestions.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_suggestions[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: i == 0 ? AppColors.primary.withValues(alpha: 0.4) : AppColors.outlineVariant,
                    ),
                  ),
                  child: Text(_suggestions[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: i == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                      )),
                ),
              ),
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _thinking) return _TypingBubble();
                return _MessageBubble(message: _messages[i])
                    .animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
              },
            ),
          ),
          // Floating orb above input
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: AiOrb(size: 36, pulsing: _thinking),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(top: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic_outlined, color: AppColors.onSurfaceVariant, size: 20),
                  onPressed: () {},
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Ask anything...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  onPressed: () {},
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primaryGlow.withValues(alpha: 0.5), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.onPrimary, size: 16),
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


class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: message.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.isAi) ...[
              const AiOrb(size: 28, pulsing: false),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: message.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isAi ? AppColors.surfaceContainerHigh : AppColors.primaryContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(message.isAi ? 4 : 20),
                        bottomRight: Radius.circular(message.isAi ? 20 : 4),
                      ),
                    ),
                    child: Text(message.text,
                        style: GoogleFonts.inter(
                          fontSize: 14, height: 1.5,
                          color: message.isAi ? AppColors.onSurface : AppColors.onPrimaryContainer,
                        )),
                  ),
                  const SizedBox(height: 2),
                  Text(message.time,
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const AiOrb(size: 28, pulsing: true),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: AppColors.onSurfaceVariant, shape: BoxShape.circle),
                ).animate(delay: Duration(milliseconds: i * 200))
                    .then(delay: 200.ms)
                    .moveY(begin: 0, end: -4, duration: 300.ms, curve: Curves.easeOut)
                    .then()
                    .moveY(begin: -4, end: 0, duration: 300.ms)),
              ),
            ),
          ],
        ),
      );
}

class _Message {
  final String text, time;
  final bool isAi;
  const _Message({required this.text, required this.isAi, required this.time});
}
