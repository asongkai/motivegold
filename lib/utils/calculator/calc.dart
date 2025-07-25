import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:sizer/sizer.dart';

// class Calc extends StatefulWidget {
//   Calc({super.key, this.currentValue, this.closeCal, this.onChanged});
//
//   double? currentValue;
//   final Function()? closeCal;
//   final Function(String? key, double? value, String? expression)? onChanged;
//
//   @override
//   State<Calc> createState() => _CalcState();
// }
//
// class _CalcState extends State<Calc> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return DragArea(
//       closeCal: widget.closeCal,
//       child: Container(
//         width: 350,
//         height: 500,
//         padding: const EdgeInsets.all(5),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               height: 50,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF0F766E),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         'เครื่องคิดเลข',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: widget.closeCal,
//                     child: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.close,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: RawKeyboardListener(
//                 focusNode: FocusNode(),
//                 autofocus: true,
//                 onKey: (RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     // Prevent ALL keyboard events from bubbling up
//                     // Let the SimpleCalculator handle them internally
//                     if (kDebugMode) {
//                       print('Key pressed: ${event.logicalKey}');
//                     }
//                   }
//                 },
//                 child: Focus(
//                   autofocus: true,
//                   onKeyEvent: (node, event) {
//                     if (event is KeyDownEvent) {
//                       // Handle digit 0 and numpad 0 - let calculator handle it
//                       if (event.logicalKey == LogicalKeyboardKey.digit0 ||
//                           event.logicalKey == LogicalKeyboardKey.numpad0) {
//                         return KeyEventResult.handled;
//                       }
//                       // Handle enter keys - let calculator handle it
//                       if (event.logicalKey == LogicalKeyboardKey.enter ||
//                           event.logicalKey == LogicalKeyboardKey.numpadEnter) {
//                         return KeyEventResult.handled;
//                       }
//                       // Handle all other calculator-related keys
//                       if (_isCalculatorKey(event.logicalKey)) {
//                         return KeyEventResult.handled;
//                       }
//                     }
//                     return KeyEventResult.ignored;
//                   },
//                   child: RepaintBoundary( // Add this to prevent unnecessary repaints
//                     child: SimpleCalculator(
//                       value: widget.currentValue ?? 0,
//                       hideExpression: false,
//                       hideSurroundingBorder: true,
//                       autofocus: true,
//                       closeCal: widget.closeCal,
//                       onChanged: widget.onChanged,
//                       onTappedDisplay: (value, details) {
//                         if (kDebugMode) {
//                           print('$value\t${details.globalPosition}');
//                         }
//                       },
//                       theme: const CalculatorThemeData(
//                         borderColor: Color(0xffcccccc),
//                         borderWidth: 4,
//                         displayColor: Color(0xffcccccc),
//                         displayStyle: TextStyle(fontSize: 80, color: Colors.black),
//                         expressionColor: Color(0xffcccccc),
//                         expressionStyle: TextStyle(fontSize: 20, color: Colors.black87),
//                         operatorColor: Colors.pink,
//                         operatorStyle: TextStyle(fontSize: 30, color: Colors.black87),
//                         commandColor: Colors.orange,
//                         commandStyle: TextStyle(fontSize: 30, color: Colors.black87),
//                         numColor: Colors.white70,
//                         numStyle: TextStyle(
//                             fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper function to identify calculator keys
//   bool _isCalculatorKey(LogicalKeyboardKey key) {
//     return [
//       // Number keys
//       LogicalKeyboardKey.digit0,
//       LogicalKeyboardKey.digit1,
//       LogicalKeyboardKey.digit2,
//       LogicalKeyboardKey.digit3,
//       LogicalKeyboardKey.digit4,
//       LogicalKeyboardKey.digit5,
//       LogicalKeyboardKey.digit6,
//       LogicalKeyboardKey.digit7,
//       LogicalKeyboardKey.digit8,
//       LogicalKeyboardKey.digit9,
//       // Numpad keys
//       LogicalKeyboardKey.numpad0,
//       LogicalKeyboardKey.numpad1,
//       LogicalKeyboardKey.numpad2,
//       LogicalKeyboardKey.numpad3,
//       LogicalKeyboardKey.numpad4,
//       LogicalKeyboardKey.numpad5,
//       LogicalKeyboardKey.numpad6,
//       LogicalKeyboardKey.numpad7,
//       LogicalKeyboardKey.numpad8,
//       LogicalKeyboardKey.numpad9,
//       // Operation keys
//       LogicalKeyboardKey.equal,
//       LogicalKeyboardKey.minus,
//       LogicalKeyboardKey.numpadAdd,
//       LogicalKeyboardKey.numpadSubtract,
//       LogicalKeyboardKey.numpadMultiply,
//       LogicalKeyboardKey.numpadDivide,
//       LogicalKeyboardKey.numpadEqual,
//       LogicalKeyboardKey.period,
//       LogicalKeyboardKey.numpadDecimal,
//       // Other calculator keys
//       LogicalKeyboardKey.backspace,
//       LogicalKeyboardKey.delete,
//       LogicalKeyboardKey.escape,
//       LogicalKeyboardKey.enter,
//       LogicalKeyboardKey.numpadEnter,
//     ].contains(key);
//   }
// }

class CalculatorWidget extends StatelessWidget {
  final VoidCallback? closeCal;
  final Function(String? key, double? value, String? expression)? onChanged;

  const CalculatorWidget({
    super.key,
    this.closeCal,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalDragArea(
      closeCal: closeCal,
      child: Container(
        width: 350,
        height: 500,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF0F766E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'เครื่องคิดเลข',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: closeCal,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) {
                    // Handle digit 0 and numpad 0 - let calculator handle it
                    if (event.logicalKey == LogicalKeyboardKey.digit0 ||
                        event.logicalKey == LogicalKeyboardKey.numpad0) {
                      return KeyEventResult.handled;
                    }
                    // Handle enter keys - let calculator handle it
                    if (event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                      return KeyEventResult.handled;
                    }
                    // Handle all other calculator-related keys
                    if (_isCalculatorKey(event.logicalKey)) {
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: Calculate(
                  closeCal: closeCal,
                  onChanged: (key, value, expression) {
                    if (key == 'ENT') {
                      FocusScope.of(context).requestFocus(FocusNode());
                      closeCal?.call();
                    }

                    // Call the provided onChanged callback
                    onChanged?.call(key, value, expression);

                    if (kDebugMode) {
                      print('$key\t$value\t$expression');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to identify calculator keys
  bool _isCalculatorKey(LogicalKeyboardKey key) {
    return [
      // Number keys
      LogicalKeyboardKey.digit0,
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
      // Numpad keys
      LogicalKeyboardKey.numpad0,
      LogicalKeyboardKey.numpad1,
      LogicalKeyboardKey.numpad2,
      LogicalKeyboardKey.numpad3,
      LogicalKeyboardKey.numpad4,
      LogicalKeyboardKey.numpad5,
      LogicalKeyboardKey.numpad6,
      LogicalKeyboardKey.numpad7,
      LogicalKeyboardKey.numpad8,
      LogicalKeyboardKey.numpad9,
      // Operation keys
      LogicalKeyboardKey.equal,
      LogicalKeyboardKey.minus,
      LogicalKeyboardKey.numpadAdd,
      LogicalKeyboardKey.numpadSubtract,
      LogicalKeyboardKey.numpadMultiply,
      LogicalKeyboardKey.numpadDivide,
      LogicalKeyboardKey.numpadEqual,
      LogicalKeyboardKey.period,
      LogicalKeyboardKey.numpadDecimal,
      // Other calculator keys
      LogicalKeyboardKey.backspace,
      LogicalKeyboardKey.delete,
      LogicalKeyboardKey.escape,
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.numpadEnter,
    ].contains(key);
  }
}

class Calculate extends StatefulWidget {
  Calculate({super.key, this.currentValue, this.closeCal, this.onChanged});

  double? currentValue;
  final Function()? closeCal;
  final Function(String? key, double? value, String? expression)? onChanged;

  @override
  State<Calculate> createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary( // Add this to prevent unnecessary repaints
      child: SimpleCalculator(
        value: widget.currentValue ?? 0,
        hideExpression: false,
        hideSurroundingBorder: true,
        autofocus: true,
        closeCal: widget.closeCal,
        onChanged: widget.onChanged,
        onTappedDisplay: (value, details) {
          if (kDebugMode) {
            print('$value\t${details.globalPosition}');
          }
        },
        theme: const CalculatorThemeData(
          borderColor: Color(0xffcccccc),
          borderWidth: 4,
          displayColor: Color(0xffcccccc),
          displayStyle: TextStyle(fontSize: 80, color: Colors.black),
          expressionColor: Color(0xffcccccc),
          expressionStyle: TextStyle(fontSize: 20, color: Colors.black87),
          operatorColor: Colors.pink,
          operatorStyle: TextStyle(fontSize: 30, color: Colors.black87),
          commandColor: Colors.orange,
          commandStyle: TextStyle(fontSize: 30, color: Colors.black87),
          numColor: Colors.white70,
          numStyle: TextStyle(
              fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}