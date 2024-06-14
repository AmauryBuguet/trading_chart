import 'package:flutter/material.dart';

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
  MouseCursor _cursor = SystemMouseCursors.precise;

  @override
  Widget build(BuildContext context) {
    final painter = ChartPainter(
      data: widget.data,
      xRange: widget.xRange,
      settings: widget.settings,
      mousePosition: _mousePosition,
    );
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
      onEnter: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      cursor: _cursor,
      child: Listener(
        onPointerDown: (event) {
          if (widget.onPointerDown != null) {
            final val = painter.transformEvent(event);
            if (val != null) {
              widget.onPointerDown!(val);
            }
          }
          setState(() {
            _cursor = SystemMouseCursors.basic;
            _mousePosition = null;
          });
        },
        onPointerMove: (event) {
          if (widget.onPointerMove != null) {
            final val = painter.transformEvent(event);
            if (val != null) {
              widget.onPointerMove!(val);
            }
          }
        },
        onPointerUp: (event) {
          if (widget.onPointerUp != null) {
            widget.onPointerUp!(event);
          }
          setState(() {
            _cursor = SystemMouseCursors.precise;
            _mousePosition = event.localPosition;
          });
        },
        onPointerSignal: (event) {
          if (widget.onPointerSignal != null) {
            final val = painter.transformEvent(event);
            if (val != null) {
              widget.onPointerSignal!(val);
            }
          }
        },
        child: SizedBox.expand(
          child: CustomPaint(
            painter: painter,
          ),
        ),
      ),
    );
  }
}
