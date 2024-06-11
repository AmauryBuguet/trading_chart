import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import 'classes/time_labels.dart';
import 'classes/trading_chart_data.dart';
import 'classes/trading_chart_ranges.dart';
import 'classes/trading_chart_settings.dart';

class ChartPainter extends CustomPainter {
  final TradingChartData data;
  final TradingChartSettings settings;
  final TradingChartRanges ranges;

  ChartPainter({
    super.repaint,
    required this.data,
    required this.ranges,
    this.settings = const TradingChartSettings(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint(size.toString());

    final double chartHeight = size.height - settings.margins.top - settings.margins.bottom;
    final double chartWidth = size.width - settings.margins.left - settings.margins.right;

    // Draw Y grid and labels
    final framePaint = Paint()
      ..color = settings.gridSettings.frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = settings.gridSettings.frameWidth;
    final gridPaint = Paint()
      ..color = settings.gridSettings.gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = settings.gridSettings.gridWidth;
    final yInterval = yIntervalFromApprox(ranges.yRange.difference() / settings.axisSettings.nbYIntervals);
    double labelPrice = (ranges.yRange.start / yInterval).ceil() * yInterval;
    while (labelPrice < ranges.yRange.end) {
      // Draw grid line
      final y = topFromPrice(labelPrice, chartHeight);
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
        text: labelPrice.toString(),
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
          size.width - settings.margins.right + 10,
          y - 8,
        ),
      );

      labelPrice += yInterval;
    }

    // Draw X grid and labels
    final timeLabel = TimeLabels.closestFromRange(ranges.xRange.difference() ~/ settings.axisSettings.nbXIntervals);
    int labelTimestamp = (ranges.xRange.start / (timeLabel.nbMs())).ceil() * timeLabel.nbMs();
    while (labelTimestamp < ranges.xRange.end) {
      final x = leftFromTimestamp(labelTimestamp, chartWidth);
      // Draw grid line
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
    final firstIndex = data.candles.indexWhere((e) => e.timestamp >= ranges.xRange.start);
    final lastIndex = data.candles.indexWhere((e) => e.timestamp >= ranges.xRange.end, firstIndex);
    final displayedCandles = firstIndex != -1 ? data.candles.sublist(firstIndex, lastIndex != -1 ? lastIndex : null) : List<Candle>.empty();
    if (displayedCandles.isNotEmpty) {
      late final double candleDemiWidth;
      if (data.candles.length >= 2) {
        final diffTs = data.candles[1].timestamp - data.candles.first.timestamp;
        candleDemiWidth = chartWidth * 0.35 * diffTs / ranges.xRange.difference();
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
        if (bodyTop > ranges.yRange.start && bodyBot < ranges.yRange.end) {
          canvas.drawRect(
            Rect.fromLTRB(
              max(x - candleDemiWidth, settings.margins.left),
              max(topFromPrice(bodyTop, chartHeight), settings.margins.top),
              min(x + candleDemiWidth, size.width - settings.margins.right),
              min(topFromPrice(bodyBot, chartHeight), size.height - settings.margins.bottom),
            ),
            paint,
          );
        }
        if (x > settings.margins.left && x < (size.width - settings.margins.right)) {
          if (candle.high > ranges.yRange.start && bodyTop < ranges.yRange.end) {
            // Draw top wick
            canvas.drawLine(
              Offset(
                x,
                min(topFromPrice(bodyTop, chartHeight), size.height - settings.margins.bottom),
              ),
              Offset(
                x,
                max(topFromPrice(candle.high, chartHeight), settings.margins.top),
              ),
              paint,
            );
          }
          if (bodyBot > ranges.yRange.start && candle.low < ranges.yRange.end) {
            // Draw bottom wick
            canvas.drawLine(
              Offset(
                x,
                max(topFromPrice(bodyBot, chartHeight), settings.margins.top),
              ),
              Offset(
                x,
                min(topFromPrice(candle.low, chartHeight), size.height - settings.margins.bottom),
              ),
              paint,
            );
          }
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
        if (position.timestamp < ranges.xRange.end) {
          // Draw entry point
          if (position.timestamp > ranges.xRange.start && position.entryPrice > ranges.yRange.start && position.entryPrice < ranges.yRange.end) {
            canvas.drawPoints(
              PointMode.points,
              [
                Offset(
                  leftFromTimestamp(position.timestamp, chartWidth),
                  topFromPrice(position.entryPrice, chartHeight),
                ),
              ],
              Paint()
                ..color = position.isLong ? settings.positionSettings.longColor : settings.positionSettings.shortColor
                ..strokeCap = StrokeCap.round
                ..strokeWidth = settings.positionSettings.entryPointSize,
            );
          }
          // Draw profit / loss
          if (position.timestamp < displayedCandles.last.timestamp) {
            var path = Path();
            path.moveTo(
              max(leftFromTimestamp(position.timestamp, chartWidth), settings.margins.left),
              topFromPrice(position.entryPrice, chartHeight),
            );
            // find first candle after timestamp
            final candleIndex = displayedCandles.indexWhere((e) => e.timestamp > position.timestamp);
            for (final candle in displayedCandles.sublist(candleIndex)) {
              debugPrint("path moved");
              path.lineTo(
                leftFromTimestamp(candle.timestamp, chartWidth),
                topFromPrice(candle.close, chartHeight),
              );
            }
            path.lineTo(
              leftFromTimestamp(displayedCandles.last.timestamp, chartWidth),
              topFromPrice(position.entryPrice, chartHeight),
            );
            path.close();
            bool isAbove = displayedCandles.last.close > position.entryPrice;
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

  double yIntervalFromApprox(double range) {
    if (range == 0) {
      return 100;
    }
    int logValue = (log(range) / log(10)).floor() + 1;
    double val = range / pow(10, logValue);
    if (val < 0.12) {
      return pow(10, logValue - 1).toDouble();
    } else if (val < 0.30) {
      return 2 * pow(10, logValue - 1).toDouble();
    } else if (val < 0.70) {
      return 5 * pow(10, logValue - 1).toDouble();
    } else {
      return pow(10, logValue).toDouble();
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

  double leftFromTimestamp(int ts, double width) {
    return settings.margins.left + (ts - ranges.xRange.start) * width / ranges.xRange.difference();
  }

  double topFromPrice(double price, double height) {
    return settings.margins.top + (ranges.yRange.end - price) * height / ranges.yRange.difference();
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    if (data.candles.length != oldDelegate.data.candles.length) {
      return true;
    } else if (data.candles.lastOrNull != oldDelegate.data.candles.lastOrNull) {
      return true;
    } else if ((ranges.xRange != oldDelegate.ranges.xRange) || (ranges.yRange != oldDelegate.ranges.yRange)) {
      return true;
    }
    return false;
  }
}
