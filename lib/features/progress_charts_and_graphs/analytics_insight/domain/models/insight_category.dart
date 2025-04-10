import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/insight_item.dart';

class InsightCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<InsightItem> insights;

  InsightCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.insights,
  });
}