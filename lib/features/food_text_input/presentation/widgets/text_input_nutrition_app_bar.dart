import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TextInputNutritionAppBar extends StatelessWidget {
  final bool isScrolledToTop;
  final Color primaryYellow;

  const TextInputNutritionAppBar({
    super.key,
    required this.isScrolledToTop,
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
    );
  }
}
