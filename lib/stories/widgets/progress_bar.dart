import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.percentageCovered});

  final double percentageCovered;

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(lineHeight: 15, percent: percentageCovered);
  }
}
