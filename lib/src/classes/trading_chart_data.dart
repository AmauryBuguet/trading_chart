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

class TradingPosition extends Equatable {
  final int timestamp;
  final double entryPrice;
  final bool isLong;

  const TradingPosition({
    required this.timestamp,
    required this.entryPrice,
    required this.isLong,
  });
  @override
  List<Object?> get props => [timestamp, entryPrice, isLong];
}

class TradingOrder extends Equatable {
  final double price;
  final Color color;
  final double width;

  const TradingOrder({
    required this.price,
    required this.color,
    this.width = 1,
  });

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
  });

  @override
  List<Object?> get props => [timestamp, open, high, close, volume];
}
