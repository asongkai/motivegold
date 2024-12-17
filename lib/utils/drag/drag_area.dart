import 'package:flutter/material.dart';

class DragArea extends StatefulWidget {
  final Widget child;
  final Function()? closeCal;

  const DragArea({super.key, required this.child, this.closeCal});

  @override
  DragAreaStateStateful createState() => DragAreaStateStateful();
}

class DragAreaStateStateful extends State<DragArea> {
  Offset position = const Offset(50, 200);
  double prevScale = 1;
  double scale = 1;

  void updateScale(double zoom) => setState(() => scale = prevScale * zoom);
  void commitScale() => setState(() => prevScale = scale);
  void updatePosition(Offset newPosition) =>
      setState(() => position = newPosition);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: widget.closeCal,
      onScaleUpdate: (details) => updateScale(details.scale),
      onScaleEnd: (_) => commitScale(),
      child: Stack(
        children: [
          // Positioned.fill(
          //     child: Container(color: Colors.transparent)),
          Positioned(
            left: position.dx,
            top: position.dy,
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
    );
  }
}