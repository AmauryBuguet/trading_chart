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
    TL(1, DateFormat.Hm()),
    TL(3, DateFormat.Hm()),
    TL(5, DateFormat.Hm()),
    TL(15, DateFormat.Hm()),
    TL(30, DateFormat.Hm()),
    TL(60, DateFormat.Hm()),
    TL(120, DateFormat.Hm()),
    TL(240, DateFormat.Md()),
    TL(360, DateFormat("d/M\nH:m")),
    TL(720, DateFormat("d/M\nH:m")),
    TL(1440, DateFormat("d/M")),
    TL(4320, DateFormat("d/M")),
    TL(10080, DateFormat("d/M")),
    TL(20160, DateFormat("d/M")),
    TL(43200, DateFormat("d/M")),
    TL(132480, DateFormat("d/M/y")),
    TL(525600, DateFormat("d/M/y")),
  ];

  static TL closestFromRange(int range) {
    return values.reduce((a, b) {
      return (a.nbMs() - range).abs() > (b.nbMs() - range).abs() ? b : a;
    });
  }
}

enum OldTimeLabel {
  m1(1),
  m3(3),
  m5(5),
  m15(15),
  m30(30),
  h1(60),
  h2(120),
  h4(240),
  h6(360),
  h12(720),
  daily(1440),
  days3(4320),
  weekly(10080),
  biweekly(20160),
  monthly(43200),
  month3(132480),
  yearly(525600);

  final int nbMin;
  const OldTimeLabel(this.nbMin);

  int nbMs() {
    return nbMin * 60000;
  }

  factory OldTimeLabel.closestFromRange(int range) {
    return OldTimeLabel.values.reduce((a, b) {
      return (a.nbMs() - range).abs() > (b.nbMs() - range).abs() ? b : a;
    });
  }
}
