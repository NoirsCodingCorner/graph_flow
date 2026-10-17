import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../src/grid_widget.dart';
import 'canvas_configuration.dart';
import 'data_connection_painter.dart';
import 'graph_manager.dart';

/// The main interactive canvas for the node graph.
///
/// Uses an [InteractiveViewer] to handle all panning and zooming natively.
/// Listens to the [GraphModel] to rebuild when nodes or connections are added/removed.
class GraphCanvas extends StatefulWidget {
  final GraphModel manager;
  final CanvasLayout canvasLayout;



  const GraphCanvas({
    super.key,
    required this.manager,
    required this.canvasLayout,
  });

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas>
    with SingleTickerProviderStateMixin {

  ValueNotifier<bool>canPan=ValueNotifier(true);


  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _dotController;

  Rect _calculateRect(Offset a, Offset b) {
    return Rect.fromLTRB(
      math.min(a.dx, b.dx),
      math.min(a.dy, b.dy),
      math.max(a.dx, b.dx),
      math.max(a.dy, b.dy),
    );
  }

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.manager,
      builder: (context, _) {
        return Container(
          color: widget.canvasLayout.gridBackgroundColor,
          child: ValueListenableBuilder(
            valueListenable: canPan,
            builder: (context, pan, child) {
              return InteractiveViewer(
                panEnabled: pan,
                transformationController: _transformationController,
                constrained: false,
                boundaryMargin: EdgeInsets.all(0),
                minScale: widget.canvasLayout.minScale,
                maxScale: widget.canvasLayout.maxScale,
                scaleFactor: widget.canvasLayout.scaleFactor,
                child: Listener(
                  onPointerDown: (details){
                    if(HardwareKeyboard.instance.isShiftPressed){
                      widget.manager.startMarquee(details.localPosition);
                      canPan.value=false;
                    }
                  },
                  onPointerMove: (details){
                    if(HardwareKeyboard.instance.isShiftPressed){
                      widget.manager.currentMarquee(details.localPosition);
                      //print("${widget.manager.marqueeStartPosition} : ${widget.manager.marqueeEndPosition}");
                    setState(() {

                    });}
                  },

                  onPointerUp: (details){
                    widget.manager.endMarquee();
                    canPan.value=true;
                  },

                  child: MouseRegion(
                    onHover: (event) {
                      widget.manager.updateMousePosition(event.localPosition);
                    },
                    child: SizedBox(
                      width: widget.canvasLayout.canvasWidth,
                      height: widget.canvasLayout.canvasHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: GridWidget(
                                gridSpacing: widget.canvasLayout.gridSpacing,
                                lineColor: widget.canvasLayout.gridLineColor,
                                backgroundColor: widget.canvasLayout.gridBackgroundColor,
                                lineWidth: 0.2,
                              ),
                            ),
                          ),
                          ...widget.manager.nodeVisuals,
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size(widget.canvasLayout.canvasWidth, widget.canvasLayout.canvasHeight),
                              painter: DataConnectionPainter(
                                  widget.manager, _dotController,
                                  lineColor: widget.canvasLayout.connectionLineColor,
                                  lineColorShadow: widget.canvasLayout.connectionLineColorShadow,
                                  dotColor: widget.canvasLayout.connectionDotColor,
                                  dotColorShadow: widget.canvasLayout.connectionDotColorShadow,
                                  highLightColor: widget.canvasLayout.highLightColor,
                                  enableAnimation: widget.canvasLayout.connectionEnableAnimation,
                                  enableLineGlow: widget.canvasLayout.connectionEnableLineGlow,
                                  enableDotGlow: widget.canvasLayout.connectionEnableDotGlow,
                                  connectionShape: widget.canvasLayout.connectionConnectionShape,
                              )
                            ),),
                          if (widget.manager.marqueeStartPosition != null&&widget.manager.marqueeEndPosition!=null)
                            Positioned.fromRect(
                              rect: _calculateRect(widget.manager.marqueeStartPosition!, widget.manager.marqueeEndPosition??Offset.zero),
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: Colors.blueAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        );
      },
    );
  }
}
