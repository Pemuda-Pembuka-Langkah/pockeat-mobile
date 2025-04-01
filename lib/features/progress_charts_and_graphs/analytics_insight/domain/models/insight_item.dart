import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InsightItem {
  final IconData icon;
  final String title;
  final String description;
  final String action;

  InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
  });
}