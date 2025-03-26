import 'package:flutter/material.dart';

class MetricItem {
  final String label;
  final String value;
  final String subtext;
  final Color color;

  MetricItem({
    required this.label,
    required this.value,
    required this.subtext,
    required this.color,
  });
}