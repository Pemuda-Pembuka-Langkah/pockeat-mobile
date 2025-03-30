import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecommendationItem {
  final IconData icon;
  final String text;
  final String detail;
  final Color color;

  RecommendationItem({
    required this.icon,
    required this.text,
    required this.detail,
    required this.color,
  });
}