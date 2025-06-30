import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final Widget child;
//   final double? height;
//   final bool? hasChild;
//
//   const CustomAppBar({
//     super.key,
//     required this.child,
//     this.height,
//     this.hasChild,
//   });
//
//   @override
//   Size get preferredSize {
//     // Calculate preferred size more reliably
//     if (height != null) {
//       return Size.fromHeight(height!);
//     }
//
//     // Default heights based on orientation and content
//     return Size.fromHeight(hasChild == true ? 200 : 120);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Screen? size = Screen(MediaQuery.of(context).size);
//     final isPortrait =
//         MediaQuery.of(context).orientation == Orientation.portrait;
//
//     // Calculate height more safely
//     double calculatedHeight;
//     // if (height != null) {
//     //   calculatedHeight = height!;
//     // } else {
//     if (isPortrait && hasChild == false) {
//       calculatedHeight = 16.h; //size.hp(16);
//     } else if (isPortrait) {
//       calculatedHeight = 18.h; //size.hp(20);
//     } else if (!isPortrait && hasChild == false) {
//       calculatedHeight = 16.h; //size.hp(16);
//     } else {
//       calculatedHeight = 20.h; //size.hp(22);
//     }
//     // }
//
//     // Ensure minimum and maximum heights to prevent overflow
//     calculatedHeight = calculatedHeight.clamp(100.0, 300.0);
//
//     return Container(
//       height: calculatedHeight,
//       color: Colors.teal,
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//           child: child,
//         ),
//       ),
//     );
//   }
// }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double? height;
  final bool? hasChild;

  const CustomAppBar({
    super.key,
    required this.child,
    this.height, this.hasChild,
  });

  @override
  Size get preferredSize {
    // If height is explicitly provided, use it; otherwise, let the content decide.
    return Size.fromHeight(height ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      color: Colors.teal,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: IntrinsicHeight( // Allow content to determine height
            child: child,
          ),
        ),
      ),
    );
  }
}