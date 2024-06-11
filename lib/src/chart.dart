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
    required this.xRange,
    this.settings = const TradingChartSettings(),
    this.onYRangeUpdate,
  });
  final TradingChartData data;
  final Range<int> xRange;
  final TradingChartSettings settings;
  final ValueSetter<Range<double>>? onYRangeUpdate;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: ChartPainter(
          data: data,
          xRange: xRange,
          settings: settings,
          onYRangeUpdate: onYRangeUpdate,
        ),
      ),
    );
  }
}
