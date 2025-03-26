import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

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
      backgroundColor: isScrolledToTop ? Colors.transparent : primaryYellow,
      elevation: 0,
      title: Text(
        'Nutrition Analysis',
        style: TextStyle(
          color: isScrolledToTop ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
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