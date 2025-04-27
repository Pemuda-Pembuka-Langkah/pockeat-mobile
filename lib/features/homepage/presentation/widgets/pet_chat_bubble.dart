// lib/features/homepage/presentation/widgets/pet_chat_bubble.dart
import 'package:flutter/material.dart';
import 'dart:async';
// coverage:ignore-start
enum ChatBubbleType {
  reminder,
  almostFinished,
  completed,
}

class PetChatBubble extends StatefulWidget {
  final String message;
  final ChatBubbleType type;
  final bool showDismiss;
  final VoidCallback? onDismiss;
  final Duration autoDismissAfter;

  const PetChatBubble({
    super.key,
    required this.message,
    required this.type,
    this.showDismiss = true,
    this.onDismiss,
    this.autoDismissAfter = const Duration(seconds: 5),
  });

  @override
  State<PetChatBubble> createState() => _PetChatBubbleState();
}

class _PetChatBubbleState extends State<PetChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _controller.forward();

    if (widget.autoDismissAfter != Duration.zero) {
      _autoDismissTimer = Timer(widget.autoDismissAfter, () {
        if (mounted) _dismissBubble();
      });
    }
  }

  void _dismissBubble() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Get color based on message type
  Color _getBubbleColor() {
    switch (widget.type) {
      case ChatBubbleType.reminder:
        return const Color(0xFFFFE893); // Yellow for reminders
      case ChatBubbleType.almostFinished:
        return const Color(0xFF4ECDC4); // Green for progress
      case ChatBubbleType.completed:
        return const Color(0xFFFF6B6B); // Pink for celebration
    }
  }

  // Get text color based on bubble color
  Color _getTextColor() {
    switch (widget.type) {
      case ChatBubbleType.reminder:
        return Colors.black87;
      case ChatBubbleType.almostFinished:
      case ChatBubbleType.completed:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16), // Increased vertical padding
          decoration: BoxDecoration(
            color: _getBubbleColor(),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            // Use IntrinsicHeight to ensure the row takes proper height
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top
              children: [
                // Expanded to ensure text wraps properly and uses available space
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 16, // Slightly larger text
                      height: 1.3, // Add line height for better readability
                      fontWeight: FontWeight.w500,
                      color: _getTextColor(),
                    ),
                    overflow:
                        TextOverflow.visible, // Ensure text doesn't get cut off
                  ),
                ),
                if (widget.showDismiss) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _dismissBubble,
                    child: Icon(
                      Icons.close,
                      size: 18, // Slightly larger close icon
                      color: _getTextColor().withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// coverage:ignore-end