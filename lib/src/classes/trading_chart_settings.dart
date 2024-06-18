import 'package:flutter/material.dart';

class TradingChartSettings {
  final EdgeInsets margins;
  final CandleSettings candleSettings;
  final GridSettings gridSettings;
  final AxisSettings axisSettings;
  final PositionSettings positionSettings;
  final CrossHairSettings crossHairSettings;
  final Color backgroundColor;

  const TradingChartSettings({
    this.margins = const EdgeInsets.fromLTRB(50, 50, 100, 50),
    this.candleSettings = const CandleSettings(),
    this.gridSettings = const GridSettings(),
    this.axisSettings = const AxisSettings(),
    this.positionSettings = const PositionSettings(),
    this.crossHairSettings = const CrossHairSettings(),
    this.backgroundColor = Colors.black,
  });
}

class PositionSettings {
  final Color profitColor;
  final Color lossColor;
  final Color longColor;
  final Color shortColor;
  final double pointSize;

  const PositionSettings({
    this.profitColor = const Color(0x324CAF50),
    this.lossColor = const Color(0x32F44336),
    this.longColor = Colors.green,
    this.shortColor = Colors.red,
    this.pointSize = 10,
  });
}

class GridSettings {
  final Color frameColor;
  final Color gridColor;
  final double frameWidth;
  final double gridWidth;
  final bool show;

  const GridSettings({
    this.frameColor = Colors.white,
    this.gridColor = const Color(0x72ffffff),
    this.frameWidth = 1,
    this.gridWidth = 0.2,
    this.show = true,
  });
}

class CandleSettings {
  final Color bullColor;
  final Color bearColor;
  final Color dojiColor;
  final PaintingStyle style;
  final double lineWidth;

  const CandleSettings({
    this.bullColor = Colors.green,
    this.bearColor = Colors.red,
    this.dojiColor = Colors.white,
    this.style = PaintingStyle.stroke,
    this.lineWidth = 1,
  }) : assert(lineWidth > 0);
}

class AxisSettings {
  final int nbXIntervals;
  final int nbYIntervals;
  final TextStyle labelStyle;
  final double pricePctMargin;

  const AxisSettings({
    this.nbXIntervals = 10,
    this.nbYIntervals = 15,
    this.pricePctMargin = 10,
    this.labelStyle = const TextStyle(),
  })  : assert(pricePctMargin > 0, "pricePctMargin must be > 1"),
        assert(nbXIntervals > 0 && nbYIntervals > 0, "intervals must be > 0");
}

class CrossHairSettings {
  final bool show;
  final double width;
  final Color color;
  final Color backgroundColor;

  const CrossHairSettings({
    this.show = true,
    this.width = 0.5,
    this.color = Colors.white,
    this.backgroundColor = Colors.blue,
  }) : assert(width > 0);
}
