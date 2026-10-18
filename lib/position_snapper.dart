

import 'dart:ui';

class PositionSnapper {
  static double granularity=10;

  static Offset snapOffset(Offset position) {
    double snappedX = (position.dx / granularity).round() * granularity;
    double snappedY = (position.dy / granularity).round() * granularity;
    return Offset(snappedX, snappedY);
  }
}