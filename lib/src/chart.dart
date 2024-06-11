// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'chart_painter.dart';
import 'classes/trading_chart_data.dart';
import 'classes/trading_chart_ranges.dart';
import 'classes/trading_chart_settings.dart';

class TradingChart extends StatelessWidget {
  const TradingChart({
    super.key,
    required this.data,
    required this.ranges,
    this.settings = const TradingChartSettings(),
  });
  final TradingChartData data;
  final TradingChartRanges ranges;
  final TradingChartSettings settings;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: ChartPainter(
          data: data,
          ranges: ranges,
          settings: settings,
        ),
      ),
    );
  }
}
