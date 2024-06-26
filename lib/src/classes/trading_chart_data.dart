import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TradingChartData {
  final List<Candle> candles;
  final List<TOrder>? orders;
  final List<TLine>? lines;
  final List<TTrade>? trades;
  final List<TIndicator>? indicators;
  final List<TPosition>? positions;

  const TradingChartData({
    required this.candles,
    this.orders,
    this.lines,
    this.trades,
    this.indicators,
    this.positions,
  });
}

class TLine extends Equatable {
  final double price;
  final double width;
  final String id;
  final Color color;

  const TLine({
    required this.price,
    this.width = 1,
    required this.color,
    required this.id,
  }) : assert(price >= 0, "price can't be < 0");

  @override
  List<Object?> get props => [price, color, id, width];
}

class TOrder extends Equatable {
  final double price;
  final String id;
  final Color color;

  const TOrder({
    required this.price,
    required this.color,
    required this.id,
  }) : assert(price >= 0, "price can't be < 0");

  @override
  List<Object?> get props => [price, color, id];
}

class TTrade extends Equatable {
  final double price;
  final double pointSize;
  final int timestamp;
  final String id;
  final Color color;

  const TTrade({
    required this.price,
    this.pointSize = 10,
    required this.timestamp,
    required this.color,
    required this.id,
  }) : assert(price >= 0, "price can't be < 0");

  @override
  List<Object?> get props => [price, color, id];
}

class TPoint extends Equatable {
  final int timestamp;
  final double price;

  const TPoint({
    required this.timestamp,
    required this.price,
  })  : assert(timestamp >= 0, "Timestamp must be > 0"),
        assert(price >= 0, "price must be >= 0");

  @override
  List<Object?> get props => [timestamp, price];
}

/// percent-base indicator points prices must be between 0 and 1
class TIndicator extends Equatable {
  final List<TPoint> points;
  final String id;
  final Color color;
  final bool percentBased;
  final double width;

  const TIndicator({
    required this.points,
    required this.id,
    this.color = Colors.orange,
    this.width = 1.0,
    this.percentBased = false,
  });

  @override
  List<Object?> get props => [points, id, color, width];
}

class TPosition extends Equatable {
  final TPoint open;
  final TPoint? close;
  final Color color;
  final String id;

  TPosition({
    required this.open,
    this.close,
    required this.color,
    required this.id,
  }) : assert((close == null) || (open.timestamp < close.timestamp), "Close timestamp can't be earlier than open timestamp");
  @override
  List<Object?> get props => [open, close, color, id];
}

class Candle extends Equatable {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  })  : assert(high >= open && high >= close && high >= low && low <= close && low <= open, "Must respect high >= (open and close) >= low"),
        assert(timestamp >= 0, "timestamp must be >= 0");

  @override
  List<Object?> get props => [timestamp, open, high, close, volume];
}
