
import 'dart:ui';

class PositionSnapper {
  static double granularity=0;

  static Offset? snapOffset(Offset? position) {
    if(position==null){return null;}
    if(granularity==0){return position;}
    double snappedX = (position.dx / granularity).round() * granularity;
    double snappedY = (position.dy / granularity).round() * granularity;
    return Offset(snappedX, snappedY);
  }
  static double snapDouble(double value){
    if(granularity==0){return value;}
    return (value / granularity).round() * granularity;
  }
}