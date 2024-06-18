import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import 'classes/trading_chart_data.dart';
import 'classes/trading_chart_ranges.dart';
import 'classes/trading_chart_settings.dart';
import 'classes/utils.dart';

class ChartPainter extends CustomPainter {
  final TradingChartData data;
  final TradingChartSettings settings;
  final Range<int> xRange;
  final Offset? mousePosition;
  Range<double> yRange = const Range<double>(start: 0, end: 100);
  Size currentSize = const Size(100, 100);

  ChartPainter({
    super.repaint,
    required this.data,
    this.mousePosition,
    required this.xRange,
    this.settings = const TradingChartSettings(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    currentSize = size;
    final double chartHeight = size.height - settings.margins.top - settings.margins.bottom;
    final double chartWidth = size.width - settings.margins.left - settings.margins.right;

    // Compute yRange
    final firstIndex = data.candles.indexWhere((e) => e.timestamp >= xRange.start);
    final lastIndex = data.candles.indexWhere((e) => e.timestamp >= xRange.end, firstIndex);
    final displayedCandles = firstIndex != -1 ? data.candles.sublist(firstIndex, lastIndex != -1 ? lastIndex : null) : List<Candle>.empty();
    if (data.candles.isEmpty) {
      yRange = const Range<double>(start: 0, end: 100);
    } else if (displayedCandles.isEmpty) {
      // This should be avoided
      final double diff = (data.candles.last.high - data.candles.last.low) * settings.axisSettings.pricePctMargin / 100;
      yRange = Range<double>(start: data.candles.last.low - diff, end: data.candles.last.high + diff);
    } else {
      final maxY = displayedCandles.map((e) => e.high).reduce(max);
      final minY = displayedCandles.map((e) => e.low).reduce(min);
      final double diff = (maxY - minY) * settings.axisSettings.pricePctMargin / 100;
      yRange = Range<double>(start: minY - diff, end: maxY + diff);
    }

    // Draw Y grid and labels
    final framePaint = Paint()
      ..color = settings.gridSettings.frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = settings.gridSettings.frameWidth;
    final gridPaint = Paint()
      ..color = settings.gridSettings.gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = settings.gridSettings.gridWidth;
    final intervalData = yIntervalFromApprox(yRange.difference() / settings.axisSettings.nbYIntervals);
    double labelPrice = (yRange.start / intervalData.$1).ceil() * intervalData.$1;
    while (labelPrice < yRange.end) {
      // Draw grid line
      final y = topFromPrice(labelPrice, chartHeight);
      if (settings.gridSettings.show) {
        canvas.drawLine(
          Offset(
            settings.margins.left,
            y,
          ),
          Offset(
            size.width - settings.margins.right,
            y,
          ),
          gridPaint,
        );
      }

      // Draw tick
      canvas.drawLine(
        Offset(
          size.width - settings.margins.right,
          y,
        ),
        Offset(
          size.width - settings.margins.right + 5,
          y,
        ),
        framePaint,
      );

      // Draw label
      final textSpan = TextSpan(
        text: labelPrice.toStringAsFixed(intervalData.$2),
        style: settings.axisSettings.labelStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(
        maxWidth: settings.margins.right,
      );
      textPainter.paint(
        canvas,
        Offset(
          size.width - settings.margins.right + 10,
          y - 8,
        ),
      );

      labelPrice += intervalData.$1;
    }

    // Draw X grid and labels
    final timeLabel = TimeLabels.closestFromRange(xRange.difference() ~/ settings.axisSettings.nbXIntervals);
    int labelTimestamp = (xRange.start / (timeLabel.nbMs())).ceil() * timeLabel.nbMs();
    while (labelTimestamp < xRange.end) {
      final x = leftFromTimestamp(labelTimestamp, chartWidth);
      // Draw grid line
      if (settings.gridSettings.show) {
        canvas.drawLine(
          Offset(
            x,
            size.height - settings.margins.bottom,
          ),
          Offset(
            x,
            settings.margins.top,
          ),
          gridPaint,
        );
      }

      // Draw tick
      canvas.drawLine(
        Offset(
          x,
          size.height - settings.margins.bottom,
        ),
        Offset(
          x,
          size.height - settings.margins.bottom + 5,
        ),
        framePaint,
      );

      // Draw label
      final textSpan = TextSpan(
        text: timeLabel.formatter.format(DateTime.fromMillisecondsSinceEpoch(labelTimestamp)),
        style: settings.axisSettings.labelStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(
        minWidth: 60,
        maxWidth: 60,
      );
      textPainter.paint(
        canvas,
        Offset(
          x - 30,
          size.height - settings.margins.bottom + 10,
        ),
      );
      labelTimestamp += timeLabel.nbMs();
    }

    // Draw candles
    if (displayedCandles.isNotEmpty) {
      late final double candleDemiWidth;
      if (data.candles.length >= 2) {
        final diffTs = data.candles[1].timestamp - data.candles.first.timestamp;
        candleDemiWidth = chartWidth * 0.35 * diffTs / xRange.difference();
      } else {
        candleDemiWidth = chartWidth * 0.0035; // 0.7% of the chart width
      }
      for (final candle in displayedCandles) {
        final paint = Paint()
          ..color = colorFromCandle(candle)
          ..style = settings.candleSettings.style
          ..strokeWidth = settings.candleSettings.lineWidth;
        final x = leftFromTimestamp(candle.timestamp, chartWidth);
        // draw body
        final bodyTop = max(candle.close, candle.open);
        final bodyBot = min(candle.close, candle.open);
        canvas.drawRect(
          Rect.fromLTRB(
            max(x - candleDemiWidth, settings.margins.left),
            topFromPrice(bodyTop, chartHeight),
            min(x + candleDemiWidth, size.width - settings.margins.right),
            topFromPrice(bodyBot, chartHeight),
          ),
          paint,
        );
        if (x > settings.margins.left && x < (size.width - settings.margins.right)) {
          // Draw top wick
          canvas.drawLine(
            Offset(
              x,
              topFromPrice(bodyTop, chartHeight),
            ),
            Offset(
              x,
              topFromPrice(candle.high, chartHeight),
            ),
            paint,
          );
          // Draw bottom wick
          canvas.drawLine(
            Offset(
              x,
              topFromPrice(bodyBot, chartHeight),
            ),
            Offset(
              x,
              topFromPrice(candle.low, chartHeight),
            ),
            paint,
          );
        }
      }
    }

    // Draw unsent order filled lines
    if (data.unsentOrders != null) {
      for (final line in data.unsentOrders!) {
        final y = topFromPrice(line.price, chartHeight);
        if (y > settings.margins.top && y < (size.height - settings.margins.bottom)) {
          canvas.drawLine(
            Offset(
              settings.margins.left,
              y,
            ),
            Offset(
              size.width - settings.margins.right,
              y,
            ),
            Paint()
              ..color = line.color
              ..strokeWidth = line.width
              ..style = PaintingStyle.stroke,
          );
        }
      }
    }

    // Draw unfilled order dotted lines
    if (data.unfilledOrders != null) {
      for (final line in data.unfilledOrders!) {
        final y = topFromPrice(line.price, chartHeight);
        if (y > settings.margins.top && y < (size.height - settings.margins.bottom)) {
          var path = Path();
          path.moveTo(
            settings.margins.left,
            y,
          );
          path.lineTo(
            size.width - settings.margins.right,
            y,
          );
          canvas.drawPath(
            dashPath(
              path,
              dashArray: CircularIntervalList<double>(<double>[10.0, 10.0]),
            ),
            Paint()
              ..color = line.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = line.width,
          );
        }
      }
    }

    // Draw positions
    if (data.positions != null && displayedCandles.isNotEmpty) {
      for (final position in data.positions!) {
        if (position.open.timestamp < xRange.end) {
          // Draw entry point
          if (position.open.timestamp > xRange.start &&
              position.open.timestamp < xRange.end &&
              position.open.price > yRange.start &&
              position.open.price < yRange.end) {
            canvas.drawPoints(
              PointMode.points,
              [
                Offset(
                  leftFromTimestamp(position.open.timestamp, chartWidth),
                  topFromPrice(position.open.price, chartHeight),
                ),
              ],
              Paint()
                ..color = position.isLong ? settings.positionSettings.longColor : settings.positionSettings.shortColor
                ..strokeCap = StrokeCap.round
                ..strokeWidth = settings.positionSettings.pointSize,
            );
          }
          // Draw exit point
          if (position.close != null) {
            if (position.close!.timestamp > xRange.start &&
                position.close!.timestamp < xRange.end &&
                position.close!.price > yRange.start &&
                position.close!.price < yRange.end) {
              canvas.drawPoints(
                PointMode.points,
                [
                  Offset(
                    leftFromTimestamp(position.close!.timestamp, chartWidth),
                    topFromPrice(position.close!.price, chartHeight),
                  ),
                ],
                Paint()
                  ..color = position.isLong ? settings.positionSettings.shortColor : settings.positionSettings.longColor
                  ..strokeCap = StrokeCap.round
                  ..strokeWidth = settings.positionSettings.pointSize,
              );
            }
          }
          // Draw profit / loss
          if (position.open.timestamp < displayedCandles.last.timestamp) {
            var path = Path();
            path.moveTo(
              max(leftFromTimestamp(position.open.timestamp, chartWidth), settings.margins.left),
              topFromPrice(position.open.price, chartHeight),
            );
            // find first candle after timestamp
            final firstCandleIndex = displayedCandles.indexWhere((e) => e.timestamp > position.open.timestamp);
            int? lastCandleIndex;
            if (position.close != null) {
              final idx = displayedCandles.indexWhere((e) => e.timestamp > position.close!.timestamp);
              if (idx != -1) {
                lastCandleIndex = idx;
              }
            }
            for (final candle in displayedCandles.sublist(firstCandleIndex, lastCandleIndex)) {
              path.lineTo(
                leftFromTimestamp(candle.timestamp, chartWidth),
                topFromPrice(candle.close, chartHeight),
              );
            }
            late final int endTs;
            if (position.close != null) {
              endTs = min(displayedCandles.last.timestamp, position.close!.timestamp);
            } else {
              endTs = displayedCandles.last.timestamp;
            }
            path.lineTo(
              leftFromTimestamp(endTs, chartWidth),
              topFromPrice(position.open.price, chartHeight),
            );
            path.close();
            late final bool isAbove;
            if (position.close != null) {
              isAbove = position.close!.price > position.open.price;
            } else {
              isAbove = data.candles.last.close > position.open.price;
            }
            canvas.drawPath(
              path,
              Paint()
                ..color = ((position.isLong && isAbove) || (!position.isLong && !isAbove))
                    ? settings.positionSettings.profitColor
                    : settings.positionSettings.lossColor
                ..style = PaintingStyle.fill
                ..strokeWidth = 2,
            );
          }
        }
      }
    }

    // Draw crosshair
    if (settings.crossHairSettings.show && mousePosition != null) {
      if (mousePosition!.dx > settings.margins.left &&
          mousePosition!.dx < (size.width - settings.margins.right) &&
          mousePosition!.dy < (size.height - settings.margins.bottom) &&
          mousePosition!.dy > settings.margins.top) {
        Paint chPaint = Paint()
          ..color = settings.crossHairSettings.color
          ..strokeWidth = settings.crossHairSettings.width
          ..style = PaintingStyle.stroke;

        var path = Path();
        // horizontal line
        path.moveTo(
          mousePosition!.dx,
          settings.margins.top,
        );
        path.lineTo(
          mousePosition!.dx,
          size.height - settings.margins.bottom,
        );
        // vertical line
        path.moveTo(
          settings.margins.left,
          mousePosition!.dy,
        );
        path.lineTo(
          size.width - settings.margins.right,
          mousePosition!.dy,
        );
        canvas.drawPath(
          dashPath(
            path,
            dashArray: CircularIntervalList<double>(<double>[6.0, 6.0]),
          ),
          chPaint,
        );
        // Draw x label of crosshair
        final style = settings.axisSettings.labelStyle.copyWith(backgroundColor: settings.crossHairSettings.backgroundColor);
        final textSpan = TextSpan(
          text: "|  ${timeLabel.formatter.format(DateTime.fromMillisecondsSinceEpoch(timestampFromLeft(mousePosition!.dx, chartWidth)))}  |",
          style: style,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(
          minWidth: 80,
          maxWidth: 80,
        );
        textPainter.paint(
          canvas,
          Offset(
            mousePosition!.dx - 40,
            size.height - settings.margins.bottom + 10,
          ),
        );
        // Draw y label of crosshair
        final textSpanY = TextSpan(
          text: "|  ${priceFromTop(mousePosition!.dy, chartHeight).toStringAsFixed(intervalData.$2)}  |",
          style: style,
        );
        final textPainterY = TextPainter(
          text: textSpanY,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.end,
        );
        textPainterY.layout(
          maxWidth: settings.margins.right,
        );
        textPainterY.paint(
          canvas,
          Offset(
            size.width - settings.margins.right + 8,
            mousePosition!.dy - 8,
          ),
        );
      }
    }

    // Draw frame
    canvas.drawRect(
      Rect.fromLTRB(
        settings.margins.left,
        settings.margins.top,
        size.width - settings.margins.right,
        size.height - settings.margins.bottom,
      ),
      framePaint,
    );
  }

  PointerEvent? transformEvent(PointerEvent event) {
    final double chartHeight = (currentSize.height - settings.margins.top - settings.margins.bottom);
    final double chartWidth = (currentSize.width - settings.margins.left - settings.margins.right);
    final double price = (currentSize.height - event.localPosition.dy - settings.margins.top) * yRange.difference() / chartHeight + yRange.start;
    final double timestamp = (currentSize.width - event.localPosition.dx - settings.margins.left) * xRange.difference() / chartWidth + xRange.start;
    final double deltaY = -1 * event.delta.dy * yRange.difference() / chartHeight;
    final double deltaX = -1 * event.delta.dx * xRange.difference() / chartWidth;
    if (price >= yRange.start && price <= yRange.end && timestamp >= xRange.start && timestamp <= xRange.end) {
      return event.copyWith(
        position: Offset(timestamp, price),
        delta: Offset(deltaX, deltaY),
        distanceMax: yRange.difference(),
      );
    } else {
      return null;
    }
  }

  (double, int) yIntervalFromApprox(double range) {
    if (range == 0) {
      return (100, 0);
    }
    int logValue = (log(range) / log(10)).floor();
    double val = range / pow(10, logValue + 1);
    if (val < 0.12) {
      return (pow(10, logValue).toDouble(), max(-1 * logValue, 0));
    } else if (val < 0.30) {
      return (2 * pow(10, logValue).toDouble(), max(-1 * logValue, 0));
    } else if (val < 0.70) {
      return (5 * pow(10, logValue).toDouble(), max(-1 * logValue, 0));
    } else {
      return (pow(10, logValue + 1).toDouble(), max(-1 * logValue, 0));
    }
  }

  Color colorFromCandle(Candle candle) {
    if (candle.close > candle.open) {
      return settings.candleSettings.bullColor;
    } else if (candle.close < candle.open) {
      return settings.candleSettings.bearColor;
    } else {
      return settings.candleSettings.dojiColor;
    }
  }

  int timestampFromLeft(double left, double width) {
    return (((left - settings.margins.left) * xRange.difference() / width) + xRange.start).toInt();
  }

  double priceFromTop(double top, double height) {
    return yRange.end - ((top - settings.margins.top) * yRange.difference() / height);
  }

  double leftFromTimestamp(int ts, double width) {
    return settings.margins.left + (ts - xRange.start) * width / xRange.difference();
  }

  double topFromPrice(double price, double height) {
    return settings.margins.top + (yRange.end - price) * height / yRange.difference();
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    if (data.candles.length != oldDelegate.data.candles.length) {
      return true;
    } else if (data.candles.lastOrNull != oldDelegate.data.candles.lastOrNull) {
      return true;
    } else if ((xRange != oldDelegate.xRange) || (yRange != oldDelegate.yRange)) {
      return true;
    } else if (data.positions?.length != oldDelegate.data.positions?.length) {
      return true;
    }
    return false;
  }
}
