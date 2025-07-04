import 'package:flutter/material.dart';
import 'package:motivegold/utils/util.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({super.key, required this.onTap});
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Stack(
              children: [
                // Calculator body
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
                // Display area
                Positioned(
                  top: 6,
                  left: 6,
                  right: 6,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Button grid
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildMiniButton("+"),
                          buildMiniButton("−"),
                          buildMiniButton("×"),
                          buildMiniButton("÷"),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildMiniButton("7"),
                          buildMiniButton("8"),
                          buildMiniButton("9"),
                          buildMiniButton("="),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
