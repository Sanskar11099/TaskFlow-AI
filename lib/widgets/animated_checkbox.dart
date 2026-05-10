import 'package:flutter/material.dart';
import '../app_colors.dart';

class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedCheckbox({super.key, required this.value, required this.onChanged});

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.3)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: widget.value ? AppColors.success : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.value ? AppColors.success : AppColors.outline,
                width: 1.5,
              ),
              boxShadow: widget.value
                  ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.4), blurRadius: 8)]
                  : null,
            ),
            child: widget.value
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
      );
}
