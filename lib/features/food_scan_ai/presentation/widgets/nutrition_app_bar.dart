// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NutritionAppBar extends StatelessWidget {
  final bool isScrolledToTop;
  final String imagePath;
  final Color primaryYellow;

  const NutritionAppBar({
    super.key,
    required this.isScrolledToTop,
    required this.imagePath,
    required this.primaryYellow,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isScrolledToTop ? Colors.transparent : Colors.white,
      elevation: 0,
      title: Text(
        'Nutrition Analysis',
        style: TextStyle(
          color: isScrolledToTop ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: CupertinoButton(
        child: Icon(
          Icons.arrow_back_ios,
          color: isScrolledToTop ? Colors.white : Colors.black87,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
