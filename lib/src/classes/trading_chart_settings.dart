import 'package:flutter/material.dart';

class TradingChartSettings {
  final EdgeInsets margins;
  final CandleSettings candleSettings;
  final GridSettings gridSettings;
  final AxisSettings axisSettings;
  final DisplaySettings displaySettings;
  final CrossHairSettings crossHairSettings;
  final Color backgroundColor;

  const TradingChartSettings({
    this.margins = const EdgeInsets.fromLTRB(50, 50, 100, 50),
    this.candleSettings = const CandleSettings(),
    this.gridSettings = const GridSettings(),
    this.axisSettings = const AxisSettings(),
    this.crossHairSettings = const CrossHairSettings(),
    this.displaySettings = const DisplaySettings(),
    this.backgroundColor = Colors.black,
  });
}
// this.profitColor = const Color(0x324CAF50),
// this.lossColor = const Color(0x32F44336),

class DisplaySettings {
  final double percentBasedIndicatorsMaxHeight;
  final double orderLinesWidth;
  final int positionAreaOpacity;

  const DisplaySettings({
    this.percentBasedIndicatorsMaxHeight = 0.25,
    this.orderLinesWidth = 1.0,
    this.positionAreaOpacity = 150,
  })  : assert(percentBasedIndicatorsMaxHeight > 0 && percentBasedIndicatorsMaxHeight <= 1, "must be between 0 and 1"),
        assert(positionAreaOpacity >= 0 && positionAreaOpacity <= 255, "must be between 0 and 255");
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
