import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double height;

  const CustomAppBar({super.key,
    required this.child,
    this.height = 250 //kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return SafeArea(
      child: Container(
        height: size.hp(22), //preferredSize.height,
        color: Colors.teal,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}