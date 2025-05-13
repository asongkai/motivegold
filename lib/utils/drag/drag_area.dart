import 'package:flutter/material.dart';

class DragArea extends StatefulWidget {
  final Widget child;
  final Function()? closeCal;

  const DragArea({super.key, required this.child, this.closeCal});

  @override
  State<DragArea> createState() => _DragAreaState();
}

class _DragAreaState extends State<DragArea> {
  Offset position = const Offset(50, 100);
  double prevScale = 1;
  double scale = 1;

  void updateScale(double zoom) => setState(() => scale = prevScale * zoom);

  void commitScale() => setState(() => prevScale = scale);

  void updatePosition(Offset newPosition) =>
      setState(() => position = newPosition);

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => GestureDetector(
            onScaleUpdate: (details) => updateScale(details.scale),
            onScaleEnd: (_) => commitScale(),
            child: Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Draggable<Offset>(
                    data: position,
                    maxSimultaneousDrags: 1,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: scale,
                        child: widget.child,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: Transform.scale(
                        scale: scale,
                        child: widget.child,
                      ),
                    ),
                    onDragEnd: (details) {
                      final renderBox =
                      context.findRenderObject() as RenderBox;
                      final localOffset = renderBox.globalToLocal(
                        details.offset,
                      );

                      // Adjust position based on scale
                      final scaledOffset = Offset(
                        localOffset.dx / scale,
                        localOffset.dy / scale,
                      );

                      // Position widget relative to top-left
                      updatePosition(Offset(
                        scaledOffset.dx,
                        scaledOffset.dy,
                      ));
                    },
                    child: Transform.scale(
                      scale: scale,
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}