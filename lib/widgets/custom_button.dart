import 'package:flutter/material.dart';

// Button custom dengan desain modern, responsif, dan mendukung state loading
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 54.0,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFD0D47A1); // Deep Campus Blue (#0D47A1)
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isSecondary ? themeColor : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: 20,
            color: widget.isSecondary ? themeColor : Colors.white,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: widget.isSecondary ? themeColor : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => _controller.forward(),
        onTapUp: isDisabled ? null : (_) => _controller.reverse(),
        onTapCancel: isDisabled ? null : () => _controller.reverse(),
        onTap: isDisabled ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.shade300
                  : (widget.isSecondary ? Colors.transparent : themeColor),
              borderRadius: BorderRadius.circular(16),
              border: widget.isSecondary && !isDisabled
                  ? Border.all(color: themeColor, width: 2)
                  : null,
              boxShadow: !widget.isSecondary && !isDisabled
                  ? [
                      BoxShadow(
                        color: themeColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }
}
