import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motivegold/main.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';

class AppCalculatorManager {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;
  static String? _currentInputTarget; // Track which input is being edited

  /// Show calculator with specific input target
  static void showCalculator({
    VoidCallback? onClose,
    Function(String? key, double? value, String? expression)? onChanged,
    String? inputTarget, // NEW: Specify which input this calculator is for
  }) {
    if (_isVisible) return;

    _currentInputTarget = inputTarget; // Store the target

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('ERROR: Navigator context is null');
      return;
    }

    // Try to find the overlay - with better error handling
    OverlayState? overlayState;
    try {
      // First try to get the root overlay
      overlayState = Overlay.of(context, rootOverlay: true);
    } catch (e) {
      try {
        // If that fails, try the regular overlay
        overlayState = Overlay.of(context);
      } catch (e2) {
        print('ERROR: No overlay found - $e2');
        return;
      }
    }

    if (overlayState == null) {
      print('ERROR: Overlay state is null');
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Material(
        color: Colors.transparent,
        child: GlobalDragArea(
          closeCal: () {
            hideCalculator();
            onClose?.call();
          },
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
                            'เครื่องคิดเลข', // No input target text shown
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          hideCalculator();
                          onClose?.call();
                        },
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
                        // Handle all calculator keys properly
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Calculate(
                      closeCal: () {
                        hideCalculator();
                        onClose?.call();
                      },
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert into the overlay
    overlayState.insert(_overlayEntry!);
    _isVisible = true;
  }

  /// Get current input target
  static String? get currentInputTarget => _currentInputTarget;

  /// Hide calculator
  static void hideCalculator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
    _currentInputTarget = null; // Clear target when hiding
  }

  /// Check if calculator is currently visible
  static bool get isVisible => _isVisible;
}

// Your existing classes (kept for reference)
class PersistentCalculatorService {
  static bool _isPersistentMode = false;

  static void enablePersistentMode() {
    _isPersistentMode = true;
    if (!AppCalculatorManager.isVisible) {
      AppCalculatorManager.showCalculator(
        onClose: () {
          _isPersistentMode = false;
        },
      );
    }
  }

  static void disablePersistentMode() {
    _isPersistentMode = false;
    AppCalculatorManager.hideCalculator();
  }

  static bool get isPersistentMode => _isPersistentMode;
}