
import 'package:graph_flow/graph_flow.dart';
import 'package:material_ui/material_ui.dart';

/// Configuration of how a [GraphCanvas] should render Connections and its background.
/// Is used for [GraphCanvas] as its drawing style and does not affect how Nodes or Ports are drawn.
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
  final ConnectionShape connectionShape;

  /// Configuration of how a [GraphCanvas] should render Connections and its background.
  /// Canvas configurations:
  /// - [canvasWidth],[canvasHeight]: The width and height of the wanted drawing space, NOT Window or Widget size.
  /// - [minScale],[maxScale]: How far into and how far out a user is able to scroll.
  /// - [scaleFactor]: Controls how fast a user can zoom. Higher value means slower zoom.
  ///
  /// Grid configuration for the background grid:
  /// - [gridSpacing]: Controls how far the lines of the grid are apart.
  /// - [gridLineColor: Sets the color of the gridlines.
  /// - [gridBackgroundColor]: Background of the canvas/grid.
  /// - [gridLineWidth]: Sets how wide the grids lines are.
  ///
  /// Connection config to define Connections behaviour:
  /// - [connectionLineColor],[connectionLineColorShadow]: Defines a connections line color and when line glow is enable the glows color.
  /// - [connectionDotColor],[connectionDotColorShadow]: Defines a connections dot color when animation is enabled as well as its glow color.
  /// - [highLightColor]: Color of highlighted connections from fe. Node hovering.
  /// - [connectionEnableAnimation]: Enables animation of dots to indicate connection direction.
  /// - [connectionEnableLineGlow]: Enables line glow for connection lines.
  /// - [connectionEnableDotGlow]: Enables dot glow for dots on animated connections.
  /// - [connectionShape]: Define the shape of the connection either bezier or direct.

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
    this.connectionShape=ConnectionShape.bezier});


  /// A darkMode default Layout with orange lines, no animation and no glow.
  static CanvasLayout darkDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    highLightColor: Colors.yellow.shade100
  );
  /// A darkMode default Layout with orange lines, animation, white indicators and no glow.
  static CanvasLayout darkAnimatedDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.white,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.yellow.shade100,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: false,
    connectionEnableLineGlow: false,
  );

  /// A darkMode default Layout with orange lines, animation, white indicators and yellow indicator glow.
  static CanvasLayout darkAnimatedGlowDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.white,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.yellow.shade100,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: false,
  );

  /// A brightMode default Layout with orange lines, no animation, no indicators and no glow.
  static CanvasLayout brightDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade100,
    gridLineColor: Colors.grey.shade700,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.brown,
    connectionDotColorShadow: Colors.brown,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.red.shade900,
    connectionEnableAnimation: false,
    connectionEnableDotGlow: false,
    connectionEnableLineGlow: false,
  );

  /// A brightMode default Layout with orange lines, animation, brown indicators and no glow.
  static CanvasLayout brightAnimatedDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade100,
    gridLineColor: Colors.grey.shade700,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.brown,
    connectionDotColorShadow: Colors.brown,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.orange,
    highLightColor: Colors.red.shade900,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: false,
    connectionEnableLineGlow: false,
  );

  /// A brightMode default Layout with orange lines, animation, brown indicators and gray indicator glow.
  static CanvasLayout brightAnimatedGlowDefault= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade100,
    gridLineColor: Colors.grey.shade700,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.brown,
    connectionDotColorShadow: Colors.grey,
    connectionLineColor: Colors.orange,
    connectionLineColorShadow: Colors.blue,
    highLightColor: Colors.red.shade900,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: false,
  );

  /// A dartMode theme for futuristic neon pink canvas designs. Animated, with line glow, dot glow and white highlighting.
  static CanvasLayout darkAnimatedNeonPink= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.white,
    connectionLineColor: Colors.pinkAccent.shade100,
    connectionLineColorShadow: Colors.pinkAccent.shade700,
    highLightColor: Colors.white,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: true,
  );
  /// A dartMode theme for futuristic neon green/yellow canvas designs. Animated, with line glow, dot glow and white highlighting.
  static CanvasLayout darkAnimatedNeonYellow= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
    connectionDotColor: Colors.white,
    connectionDotColorShadow: Colors.cyan,
    connectionLineColor: Colors.lightGreenAccent.shade400,
    connectionLineColorShadow: Colors.limeAccent.shade700,
    highLightColor: Colors.white,
    connectionEnableAnimation: true,
    connectionEnableDotGlow: true,
    connectionEnableLineGlow: true,
  );
  /// A dartMode theme for futuristic neon cyan canvas designs. Animated, with line glow, dot glow and white highlighting.
  static CanvasLayout darkAnimatedNeonCyan= CanvasLayout(
    gridBackgroundColor: Colors.grey.shade900,
    gridLineColor: Colors.white,
    gridLineWidth: 0.5,
    connectionShape: ConnectionShape.bezier,
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

