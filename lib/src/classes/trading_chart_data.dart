import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TradingChartData {
  final List<Candle> candles;
  final List<TradingOrder>? unsentOrders;
  final List<TradingOrder>? unfilledOrders;
  final List<TradingPosition>? positions;

  const TradingChartData({
    required this.candles,
    this.unsentOrders,
    this.unfilledOrders,
    this.positions,
  });
}

class PositionOrder extends Equatable {
  final int timestamp;
  final double price;

  const PositionOrder({
    required this.timestamp,
    required this.price,
  })  : assert(timestamp > 0, "Timestamp must be > 0"),
        assert(price > 0, "price must be > 0");

  @override
  List<Object?> get props => [timestamp, price];
}

class TradingPosition extends Equatable {
  final PositionOrder open;
  final PositionOrder? close;
  final bool isLong;

  TradingPosition({
    required this.open,
    this.close,
    required this.isLong,
  }) : assert((close == null) || (open.timestamp < close.timestamp), "Close timestamp can't be earlier than open timestamp");
  @override
  List<Object?> get props => [open, close, isLong];
}

class TradingOrder extends Equatable {
  final double price;
  final Color color;
  final double width;

  const TradingOrder({
    required this.price,
    required this.color,
    this.width = 1,
  })  : assert(price > 0, "price can't be < 0"),
        assert(width > 0, "width can't be < 0");

  @override
  List<Object?> get props => [price, color, width];
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
        assert(timestamp > 0, "timestamp must be > 0");

  @override
  List<Object?> get props => [timestamp, open, high, close, volume];
}
