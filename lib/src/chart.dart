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
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerSignal,
  });
  final TradingChartData data;
  final Range<int> xRange;
  final TradingChartSettings settings;
  final ValueSetter<Range<double>>? onYRangeUpdate;
  final ValueSetter<PointerEvent>? onPointerDown;
  final ValueSetter<PointerEvent>? onPointerMove;
  final ValueSetter<PointerUpEvent>? onPointerUp;
  final ValueSetter<PointerEvent>? onPointerSignal;

  @override
  Widget build(BuildContext context) {
    final ChartPainter painter = ChartPainter(
      data: data,
      xRange: xRange,
      settings: settings,
      onYRangeUpdate: onYRangeUpdate,
    );
    return Listener(
      onPointerDown: (event) {
        final val = painter.transformEvent(event);
        if (val != null) {
          onPointerDown!(val);
        }
      },
      onPointerMove: (event) {
        final val = painter.transformEvent(event);
        if (val != null) {
          onPointerMove!(val);
        }
      },
      onPointerUp: onPointerUp,
      onPointerSignal: (event) {
        final val = painter.transformEvent(event);
        if (val != null) {
          onPointerMove!(val);
        }
      },
      child: SizedBox.expand(
        child: CustomPaint(
          painter: painter,
        ),
      ),
    );
  }
}
