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
  late Widget _childWidget; // Store the child widget
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _childWidget = widget.child; // Capture the child once
  }

  void updateScale(double zoom) => setState(() => scale = prevScale * zoom);
  void commitScale() => setState(() => prevScale = scale);
  void updatePosition(Offset newPosition) => setState(() => position = newPosition);

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
                  child: GestureDetector(
                    onPanStart: (_) => setState(() => _isDragging = true),
                    onPanUpdate: (details) {
                      setState(() {
                        position = Offset(
                          position.dx + details.delta.dx,
                          position.dy + details.delta.dy,
                        );
                      });
                    },
                    onPanEnd: (_) => setState(() => _isDragging = false),
                    child: Transform.scale(
                      scale: scale,
                      child: _childWidget, // Use the stored child widget
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

class GlobalDragArea extends StatefulWidget {
  final Widget child;
  final Function()? closeCal;

  const GlobalDragArea({super.key, required this.child, this.closeCal});

  @override
  State<GlobalDragArea> createState() => _GlobalDragAreaState();
}

class _GlobalDragAreaState extends State<GlobalDragArea> {
  Offset position = const Offset(50, 100);
  double prevScale = 1;
  double scale = 1;
  late Widget _childWidget; // Store the child widget
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _childWidget = widget.child; // Capture the child once
  }

  void updateScale(double zoom) => setState(() => scale = prevScale * zoom);
  void commitScale() => setState(() => prevScale = scale);
  void updatePosition(Offset newPosition) => setState(() => position = newPosition);

  @override
  Widget build(BuildContext context) {
    // FIX: Wrap Overlay with proper size constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get available size or default to screen size
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight : MediaQuery.of(context).size.height;

        return SizedBox(
          width: width,
          height: height,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                canSizeOverlay: true, // FIX: Allow this entry to size the overlay
                builder: (context) => GestureDetector(
                  onScaleUpdate: (details) => updateScale(details.scale),
                  onScaleEnd: (_) => commitScale(),
                  child: Stack(
                    children: [
                      Positioned(
                        left: position.dx,
                        top: position.dy,
                        child: GestureDetector(
                          onPanStart: (_) => setState(() => _isDragging = true),
                          onPanUpdate: (details) {
                            setState(() {
                              position = Offset(
                                position.dx + details.delta.dx,
                                position.dy + details.delta.dy,
                              );
                            });
                          },
                          onPanEnd: (_) => setState(() => _isDragging = false),
                          child: Transform.scale(
                            scale: scale,
                            child: _childWidget, // Use the stored child widget
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}