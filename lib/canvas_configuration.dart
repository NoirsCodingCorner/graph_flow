
import 'package:material_ui/material_ui.dart';
import 'data_connection_painter.dart';


class CanvasLayout {
  // canvas config
  final double canvasWidth;
  final double canvasHeight;
  final double minScale;
  final double maxScale;
  final double scaleFactor;

  // grid config
  final double gridSpacing;
  final Color gridLineColor;
  final Color gridBackgroundColor;
  final double gridLineWidth;

  // connection config
  final Color connectionLineColor;
  final Color connectionLineColorShadow;
  final Color connectionDotColor;
  final Color connectionDotColorShadow;
  final Color highLightColor;
  final bool connectionEnableAnimation;
  final bool connectionEnableLineGlow;
  final bool connectionEnableDotGlow;
  final ConnectionShape connectionConnectionShape;

  CanvasLayout({
    this.canvasWidth = 10000,
    this.canvasHeight = 10000,
    this.minScale = 0.1,
    this.maxScale =10,
    this.scaleFactor = 2048,
    this.gridSpacing = 100,
    this.gridLineColor=Colors.white,
    this.gridBackgroundColor= Colors.grey,
    this.gridLineWidth = 0.2,
    this.connectionLineColor= Colors.orange,
    this.connectionLineColorShadow=Colors.pink,
    this.connectionDotColor=Colors.white,
    this.connectionDotColorShadow=Colors.pinkAccent,
    this.highLightColor=Colors.red,
    this.connectionEnableAnimation=false,
    this.connectionEnableLineGlow=false,
    this.connectionEnableDotGlow=false,
    this.connectionConnectionShape=ConnectionShape.bezier});


  static CanvasLayout darkDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    highLightColor: Colors.yellow.shade100
  );
  static CanvasLayout darkAnimatedDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.white,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.yellow.shade100,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: false,
    connectionEnableLineGlow: false,
  );
  static CanvasLayout darkAnimatedGlowDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.white,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.yellow.shade100,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: false,
  );

  static CanvasLayout brightDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade100,
    gridLineColor: Colors.grey.shade700,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.brown,
    connectionDotColorShadow: Colors.brown,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.red.shade900,
    connectionEnableAnimation: false,
    connectionEnableDotGlow: false,
    connectionEnableLineGlow: false,
  );
  static CanvasLayout brightAnimatedDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade100,
    gridLineColor: Colors.grey.shade700,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.brown,
    connectionDotColorShadow: Colors.brown,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.red.shade900,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: false,
    connectionEnableLineGlow: false,
  );
  static CanvasLayout brightAnimatedGlowDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade100,
    gridLineColor: Colors.grey.shade700,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.brown,
    connectionDotColorShadow: Colors.grey,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.blue,
    highLightColor: Colors.red.shade900,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: false,
  );

  static CanvasLayout darkAnimatedNeonPink= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.white,
    connectionLineColor: Colors.pinkAccent.shade100,
    connectionLineColorShadow: Colors.pinkAccent.shade700,
    highLightColor: Colors.white,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: true,
  );
  static CanvasLayout darkAnimatedNeonYellow= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.cyan,
    connectionLineColor: Colors.lightGreenAccent.shade400,
    connectionLineColorShadow: Colors.limeAccent.shade700,
    highLightColor: Colors.green.shade900,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: true,
  );
  static CanvasLayout darkAnimatedNeonCyan= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionConnectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.cyan,
    connectionLineColor: Colors.cyanAccent,
    connectionLineColorShadow: Colors.blue,
    highLightColor: Colors.white,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: true,
  );




}

