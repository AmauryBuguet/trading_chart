import 'package:flutter/material.dart';

import 'chart_listener.dart';
import 'chart_painter.dart';
import 'classes/trading_chart_data.dart';
import 'classes/trading_chart_ranges.dart';
import 'classes/trading_chart_settings.dart';

class TradingChart extends StatefulWidget {
  const TradingChart({
    super.key,
    required this.data,
    required this.xRange,
    this.settings = const TradingChartSettings(),
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerSignal,
  });
  final TradingChartData data;
  final Range<int> xRange;
  final TradingChartSettings settings;
  final ValueSetter<PointerEvent>? onPointerDown;
  final ValueSetter<PointerEvent>? onPointerMove;
  final ValueSetter<PointerUpEvent>? onPointerUp;
  final ValueSetter<PointerEvent>? onPointerSignal;

  @override
  State<TradingChart> createState() => _TradingChartState();
}

class _TradingChartState extends State<TradingChart> {
  Offset? _mousePosition;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (event) {
        setState(() {
          _mousePosition = null;
        });
      },
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      cursor: SystemMouseCursors.precise,
      child: SizedBox.expand(
        child: ChartListener(
          onPointerDown: widget.onPointerDown,
          onPointerMove: widget.onPointerMove,
          onPointerSignal: widget.onPointerSignal,
          onPointerUp: widget.onPointerUp,
          painter: ChartPainter(
            data: widget.data,
            xRange: widget.xRange,
            settings: widget.settings,
            mousePosition: _mousePosition,
          ),
        ),
      ),
    );
  }
}
