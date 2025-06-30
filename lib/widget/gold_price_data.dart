import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';

class GoldPriceListTileData extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? value;
  final bool? single;

  const GoldPriceListTileData(
      {super.key, this.title, this.subTitle, this.value, this.single});

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Text(
                title!,
                style: TextStyle(
                    fontSize: 14.sp, //size.getWidthPx(10),
                    color: textColor,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                subTitle!,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 14.sp, //size.getWidthPx(10),
                    color: textColor,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                value!,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 14.sp, //size.getWidthPx(10),
                    color: textColor,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
