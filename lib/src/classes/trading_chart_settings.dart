import 'package:flutter/material.dart';

class TradingChartSettings {
  final EdgeInsets margins;
  final CandleColorSettings candleColors;
  final GridColorSettings gridColors;
  final AxisSettings axisSettings;
  final Color backgroundColor;

  const TradingChartSettings({
    this.margins = const EdgeInsets.fromLTRB(50, 50, 100, 50),
    this.candleColors = const CandleColorSettings(),
    this.gridColors = const GridColorSettings(),
    this.axisSettings = const AxisSettings(),
    this.backgroundColor = Colors.black,
  });
}

class GridColorSettings {
  final Color frameColor;
  final Color gridColor;
  final double frameWidth;
  final double gridWidth;
  final bool showGrid;

  const GridColorSettings({
    this.frameColor = Colors.white,
    this.gridColor = const Color(0x72ffffff),
    this.frameWidth = 1,
    this.gridWidth = 0.2,
    this.showGrid = true,
  });
}

class CandleColorSettings {
  final Color bull;
  final Color bear;
  final Color doji;
  final PaintingStyle style;
  final double lineWidth;

  const CandleColorSettings({
    this.bull = Colors.green,
    this.bear = Colors.red,
    this.doji = Colors.white,
    this.style = PaintingStyle.stroke,
    this.lineWidth = 1,
  });
}

class AxisSettings {
  final int nbXIntervals;
  final int nbYIntervals;
  final TextStyle labelStyle;

  const AxisSettings({
    this.nbXIntervals = 10,
    this.nbYIntervals = 15,
    this.labelStyle = const TextStyle(),
  });
}
