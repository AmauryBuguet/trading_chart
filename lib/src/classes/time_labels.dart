import 'package:intl/intl.dart';

class TL {
  final int nbMin;
  final DateFormat formatter;

  int nbMs() {
    return nbMin * 60000;
  }

  TL(this.nbMin, this.formatter);
}

class TimeLabels {
  static List<TL> values = [
    TL(1, DateFormat.Hm()), // m1
    TL(3, DateFormat.Hm()), // m3
    TL(5, DateFormat.Hm()), // m5
    TL(15, DateFormat.Hm()), // m15
    TL(30, DateFormat.Hm()), // m30
    TL(60, DateFormat.Hm()), // h1
    TL(120, DateFormat.Hm()), // h2
    TL(240, DateFormat.Md()), // h4
    TL(360, DateFormat("d/M\nH:m")), // h6
    TL(720, DateFormat("d/M\nH:m")), // h12
    TL(1440, DateFormat("d/M")), // d
    TL(4320, DateFormat("d/M")), // d3
    TL(10080, DateFormat("d/M")), // W
    TL(20160, DateFormat("d/M")), // W2
    TL(43200, DateFormat("d/M")), // M
    TL(132480, DateFormat("d/M/y")), // M3
    TL(525600, DateFormat("d/M/y")), // y
  ];

  static TL closestFromRange(int range) {
    return values.reduce((a, b) {
      return (a.nbMs() - range).abs() > (b.nbMs() - range).abs() ? b : a;
    });
  }
}
