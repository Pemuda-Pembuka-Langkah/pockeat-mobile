// Flutter imports:
import 'package:flutter/material.dart';

class CircularIndicatorWidget extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CircularIndicatorWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<CircularIndicatorWidget> createState() =>
      _CircularIndicatorWidgetState();
}

class _CircularIndicatorWidgetState extends State<CircularIndicatorWidget> {
  bool _isPressed = false;
  bool _isHovering = false;

  // coverage:ignore-start
  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown:
          isInteractive ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isInteractive ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel:
          isInteractive ? () => setState(() => _isPressed = false) : null,
      child: MouseRegion(
        onEnter:
            isInteractive ? (_) => setState(() => _isHovering = true) : null,
        onExit:
            isInteractive ? (_) => setState(() => _isHovering = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed
                    ? 0.01
                    : _isHovering
                        ? 0.08
                        : 0.05),
                blurRadius: _isPressed
                    ? 4
                    : _isHovering
                        ? 12
                        : 10,
                offset: _isPressed
                    ? const Offset(0, 1)
                    : _isHovering
                        ? const Offset(0, 6)
                        : const Offset(0, 4),
                spreadRadius: _isPressed
                    ? 0
                    : _isHovering
                        ? 1
                        : 0,
              ),
            ],
            border: isInteractive
                ? Border.all(
                    color: _isHovering ? widget.color : Colors.transparent,
                    width: 1.5,
                  )
                : null,
            // Subtle gradient background
            gradient: isInteractive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _isPressed ? Colors.grey.shade100 : Colors.white,
                      _isPressed ? Colors.grey.shade200 : Colors.white,
                    ],
                  )
                : null,
          ),
          transform: _isPressed
              ? Matrix4.translationValues(0, 2, 0)
              : _isHovering
                  ? Matrix4.translationValues(0, -2, 0)
                  : Matrix4.identity(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(_isPressed
                          ? 0.2
                          : _isHovering
                              ? 0.15
                              : 0.1),
                      shape: BoxShape.circle,
                      boxShadow: isInteractive && _isHovering
                          ? [
                              BoxShadow(
                                color: widget.color.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: _isHovering ? 35 : 32,
                    ),
                  ),
                  // Small edit icon in the corner (always visible for interactive widgets)
                  if (isInteractive)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Value text
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isHovering ? widget.color : Colors.black87,
                    ),
                  ),

                  // Edit icon that appears on hover
                  if (isInteractive && _isHovering)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.edit,
                        size: 14,
                        color: widget.color,
                      ),
                    ),
                ],
              ),

              // Animated indicator line at bottom
              if (isInteractive)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(top: 8),
                  height: 2,
                  width: _isHovering ? 40 : 0,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  // coverage:ignore-end
}
