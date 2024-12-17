import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class KclIconButton extends StatelessWidget {
  KclIconButton({super.key, this.icon, required this.onTap, this.color});

  Color? color = Colors.deepPurple[700]!;
  final IconData? icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GFIconButton(
      onPressed: onTap,
      padding: const EdgeInsets.all(8),
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      color: color ?? Colors.deepPurple[700]!,
      size: GFSize.LARGE,
      shape: GFIconButtonShape.square,

    );
  }
}
