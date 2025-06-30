import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget posHeaderText(BuildContext context, Color color, String text) {
  return Container(
    width: double.infinity,
    height:
        (MediaQuery.of(context).orientation == Orientation.portrait) ? 50 : 65,
    decoration: BoxDecoration(color: color),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize:
                (MediaQuery.of(context).orientation == Orientation.portrait)
                    ? 14.sp //size.getWidthPx(7)
                    : 14.sp, //size.getWidthPx(5),
            color: Colors.white),
      ),
    ),
  );
}

Widget titleText(BuildContext context, String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: (MediaQuery.of(context).orientation == Orientation.portrait)
          ? 16.sp
          : 14.sp,
    ),
  );
}
