import 'package:flutter/material.dart';

import 'chart_painter.dart';

class ChartListener extends StatelessWidget {
  const ChartListener({
    super.key,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerSignal,
    required this.painter,
  });
  final ValueSetter<PointerEvent>? onPointerDown;
  final ValueSetter<PointerEvent>? onPointerMove;
  final ValueSetter<PointerUpEvent>? onPointerUp;
  final ValueSetter<PointerEvent>? onPointerSignal;
  final ChartPainter painter;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (onPointerDown != null) {
          final val = painter.transformEvent(event);
          if (val != null) {
            onPointerDown!(val);
          }
        }
      },
      onPointerMove: (event) {
        if (onPointerMove != null) {
          final val = painter.transformEvent(event);
          if (val != null) {
            onPointerMove!(val);
          }
        }
      },
      onPointerUp: onPointerUp,
      onPointerSignal: (event) {
        if (onPointerSignal != null) {
          final val = painter.transformEvent(event);
          if (val != null) {
            onPointerSignal!(val);
          }
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
