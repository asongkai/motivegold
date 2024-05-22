import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/responsive_screen.dart';

class GoldPriceListTileData extends StatelessWidget {
  final String? title;
  final String? buy;
  final String? sell;
  final bool? single;

  const GoldPriceListTileData(
      {Key? key,
      this.title,
      this.buy,
      this.sell,
      this.single})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: bgColor2,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE9E9E9),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: size.getWidthPx(8),
                          color: const Color(0xFF636564),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        buy!,
                        style: TextStyle(
                            fontSize: size.getWidthPx(8),
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        sell!,
                        style: TextStyle(
                            fontSize: size.getWidthPx(8),
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
