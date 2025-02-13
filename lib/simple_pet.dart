
import 'package:flutter/material.dart';

class SimplePet extends StatefulWidget {
  const SimplePet({super.key});

  @override
  _SimplePetState createState() => _SimplePetState();
}

class _SimplePetState extends State<SimplePet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isHappy = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: PetPainter(
              animation: _controller.value,
              isHappy: isHappy,
            ),
          ),
        );
      },
    );
  }
}class PetPainter extends CustomPainter {
  final double animation;
  final bool isHappy;

  PetPainter({required this.animation, required this.isHappy});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Colors
    const hamsterColor = Color(0xFFE6C59E);
    const darkBrown = Color(0xFF8B7355);
    const pink = Color(0xFFFFB6C1);
    const sportswearColor = Color(0xFFFF6B6B);  // Pink tank top
    const shortsColor = Color(0xFF4A4A4A);      // Dark shorts
    
    // Simple legs (like Patrick's)
    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - 15, centerY + 45),
          width: 12,
          height: 20,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = hamsterColor,
    );

    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + 15, centerY + 45),
          width: 12,
          height: 20,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = hamsterColor,
    );

    // Body with clothes
    // Tank top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 30, centerY - 5, 60, 40),
        const Radius.circular(20),
      ),
      Paint()..color = sportswearColor,
    );

    // Shorts
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 25, centerY + 25, 50, 20),
        const Radius.circular(10),
      ),
      Paint()..color = shortsColor,
    );

    // Simple arms (like Patrick's)
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - 35, centerY + 10),
          width: 12,
          height: 25,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = hamsterColor,
    );

    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + 35, centerY + 10),
          width: 12,
          height: 25,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = hamsterColor,
    );

    // Head
    canvas.drawCircle(
      Offset(centerX, centerY - 5),
      25,
      Paint()..color = hamsterColor,
    );

    // Ears
    // Left ear
    canvas.drawCircle(
      Offset(centerX - 15, centerY - 25),
      8,
      Paint()..color = hamsterColor,
    );
    canvas.drawCircle(
      Offset(centerX - 15, centerY - 25),
      4,
      Paint()..color = pink.withOpacity(0.7),
    );

    // Right ear
    canvas.drawCircle(
      Offset(centerX + 15, centerY - 25),
      8,
      Paint()..color = hamsterColor,
    );
    canvas.drawCircle(
      Offset(centerX + 15, centerY - 25),
      4,
      Paint()..color = pink.withOpacity(0.7),
    );

    // Sweatband
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 20, centerY - 25, 40, 6),
        const Radius.circular(3),
      ),
      Paint()..color = sportswearColor,
    );

    // Eyes
    canvas.drawCircle(
      Offset(centerX - 8, centerY - 8),
      3,
      Paint()..color = darkBrown,
    );
    canvas.drawCircle(
      Offset(centerX + 8, centerY - 8),
      3,
      Paint()..color = darkBrown,
    );

    // Eye shine
    canvas.drawCircle(
      Offset(centerX - 9, centerY - 9),
      1,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(centerX + 7, centerY - 9),
      1,
      Paint()..color = Colors.white,
    );

    // Nose
    canvas.drawCircle(
      Offset(centerX, centerY - 3),
      2.5,
      Paint()..color = pink,
    );

    // Cheeks
    canvas.drawCircle(
      Offset(centerX - 15, centerY - 2),
      5,
      Paint()..color = pink.withOpacity(0.3),
    );
    canvas.drawCircle(
      Offset(centerX + 15, centerY - 2),
      5,
      Paint()..color = pink.withOpacity(0.3),
    );

    // Happy mouth
    final mouthPath = Path()
      ..moveTo(centerX - 5, centerY + 2)
      ..quadraticBezierTo(
        centerX,
        centerY + 5,
        centerX + 5,
        centerY + 2,
      );
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = darkBrown.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(PetPainter oldDelegate) => true;
}