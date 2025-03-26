import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';

class AppBarWidget extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onCalendarPressed;

  const AppBarWidget({
    Key? key,
    required this.colors,
    required this.onCalendarPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: colors.primaryYellow,
      elevation: 0,
      toolbarHeight: 60,
      title: const Text(
        'Analytics',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.calendar, color: Colors.black87),
          onPressed: onCalendarPressed,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}