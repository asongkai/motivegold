import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';

Widget posHeaderText(BuildContext context, Color color, String text) {
  Screen? size = Screen(MediaQuery.of(context).size);
  return Container(
    width: double.infinity,
    height: (MediaQuery.of(context).orientation == Orientation.portrait) ? 50 : 65,
    decoration: BoxDecoration(color: color),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize:
                (MediaQuery.of(context).orientation == Orientation.portrait)
                    ? size.getWidthPx(10)
                    : size.getWidthPx(8),
            color: Colors.white),
      ),
    ),
  );
}

Widget titleText(BuildContext context, String text) {
  Screen? size = Screen(MediaQuery.of(context).size);
  return Text(
    text,
    style: TextStyle(fontSize: (MediaQuery.of(context).orientation == Orientation.portrait) ? size.getWidthPx(10) : size.getWidthPx(8)),
  );
}