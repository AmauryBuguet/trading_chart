import 'package:equatable/equatable.dart';

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
