import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/responsive_screen.dart';

class ListTileData extends StatelessWidget {
  final String? leftTitle;
  final String? leftValue;
  final String? rightTitle;
  final String? rightValue;
  final bool? single;

  const ListTileData({Key? key, this.leftTitle, this.leftValue, this.rightTitle, this.rightValue, this.single}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: bgColor4,
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
                        leftTitle!,
                        style: TextStyle(
                          fontSize: size.getWidthPx(8),
                          color: const Color(0xFF636564),
                        ),
                      ),
                      Text(
                        leftValue!,
                        style: TextStyle(fontSize: size.getWidthPx(8), color: Colors.blue[700], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (single == null)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          rightTitle!,
                          style: TextStyle(
                            fontSize: size.getWidthPx(8),
                            color: const Color(0xFF636564),
                          ),
                        ),
                        Text(
                          rightValue!,
                          style: TextStyle(fontSize: size.getWidthPx(8), color: Colors.blue[700], fontWeight: FontWeight.w500),
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
