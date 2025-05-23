import 'package:flutter/material.dart';

class DragAreaOverlay extends StatefulWidget {
  final Widget child;
  final Function()? closeCal;

  const DragAreaOverlay({super.key, required this.child, this.closeCal});

  @override
  DragAreaStateStateful createState() => DragAreaStateStateful();
}

class DragAreaStateStateful extends State<DragAreaOverlay> {
  Offset position = const Offset(50, 100);
  double prevScale = 1;
  double scale = 1;

  void updateScale(double zoom) => setState(() => scale = prevScale * zoom);

  void commitScale() => setState(() => prevScale = scale);

  void updatePosition(Offset newPosition) =>
      setState(() => position = newPosition);

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) => GestureDetector(
          // onTap: widget.closeCal,
          onScaleUpdate: (details) => updateScale(details.scale),
          onScaleEnd: (_) => commitScale(),
          child: Stack(
            children: [
              // Positioned.fill(
              //     child: Container(color: Colors.transparent)),
              Positioned(
                left: position.dx,
                bottom: position.dy,
                child: Draggable(
                  maxSimultaneousDrags: 1,
                  feedback: widget.child,
                  childWhenDragging: Opacity(
                    opacity: .3,
                    child: widget.child,
                  ),
                  onDragEnd: (details) => updatePosition(details.offset),
                  child: Transform.scale(
                    scale: scale,
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    ]);
  }
}
