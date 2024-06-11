import 'package:equatable/equatable.dart';

class Range<T extends num> extends Equatable {
  final T start;
  final T end;

  const Range({
    required this.start,
    required this.end,
  }) : assert(end > start, "Range end must be > range start");

  T difference() {
    return (end - start) as T;
  }

  @override
  List<Object?> get props => [start, end];
}

class TradingChartRanges {
  final Range<int> xRange;
  final Range<double> yRange;

  const TradingChartRanges({
    required this.xRange,
    required this.yRange,
  });
}
