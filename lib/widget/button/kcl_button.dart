import 'package:flutter/material.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:getwidget/types/gf_button_type.dart';

class KclButton extends StatelessWidget {
  KclButton(
      {super.key,
      this.text,
      this.color,
      this.icon,
      this.fullWidth,
      this.block,
      required this.onTap});

  final String? text;
  Color? color = Colors.deepPurple[700]!;
  final IconData? icon;
  final bool? fullWidth;
  final bool? block;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GFButton(
      onPressed: onTap,
      textStyle: const TextStyle(
          fontFamily: 'NotoSansLao', fontSize: 18, color: Colors.white),
      text: "$text",
      padding: const EdgeInsets.all(8),
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      type: GFButtonType.solid,
      fullWidthButton: fullWidth ?? false,
      color: color ?? Colors.deepPurple[700]!,
      size: GFSize.LARGE,
      blockButton: block ?? false,
      shape: GFButtonShape.square,
    );
  }
}
