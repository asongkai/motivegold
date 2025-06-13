import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double? height;
  final bool? hasChild;

  const CustomAppBar({
    super.key,
    required this.child,
    this.height,
    this.hasChild,
  });

  @override
  Size get preferredSize {
    // Calculate preferred size more reliably
    if (height != null) {
      return Size.fromHeight(height!);
    }

    // Default heights based on orientation and content
    return Size.fromHeight(hasChild == true ? 200 : 120);
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Calculate height more safely
    double calculatedHeight;
    if (height != null) {
      calculatedHeight = height!;
    } else {
      if (isPortrait && hasChild == false) {
        calculatedHeight = size.hp(13);
      } else if (isPortrait) {
        calculatedHeight = size.hp(18);
      } else if (!isPortrait && hasChild == false) {
        calculatedHeight = size.hp(18);
      } else {
        calculatedHeight = size.hp(25);
      }
    }

    // Ensure minimum and maximum heights to prevent overflow
    calculatedHeight = calculatedHeight.clamp(100.0, 300.0);

    return Container(
      height: calculatedHeight,
      color: Colors.teal,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: child,
        ),
      ),
    );
  }
}