import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double height;
  final bool? hasChild;

  const CustomAppBar(
      {super.key,
      required this.child,
      this.height = 250,
      this.hasChild //kToolbarHeight,
      });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).orientation == Orientation.portrait &&
                hasChild == false
            ? size.hp(13)
            : MediaQuery.of(context).orientation == Orientation.portrait
                ? size.hp(18)
                : MediaQuery.of(context).orientation == Orientation.landscape &&
                        hasChild == false
                    ? size.hp(18)
                    : size.hp(25),
        //preferredSize.height,
        color: Colors.teal,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
