import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';

class ListTileData extends StatelessWidget {
  final String? leftTitle;
  final String? leftValue;
  final String? rightTitle;
  final String? rightValue;
  final bool? single;

  const ListTileData({super.key, this.leftTitle, this.leftValue, this.rightTitle, this.rightValue, this.single});

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 0,
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
                          fontSize: 16.sp,
                          color: const Color(0xFF636564),
                        ),
                      ),
                      Text(
                        leftValue!,
                        style: TextStyle(fontSize: 16.sp, color: Colors.blue[700], fontWeight: FontWeight.w500),
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
                            fontSize: 16.sp,
                            color: const Color(0xFF636564),
                          ),
                        ),
                        Text(
                          rightValue!,
                          style: TextStyle(fontSize: 16.sp, color: Colors.blue[700], fontWeight: FontWeight.w500),
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
