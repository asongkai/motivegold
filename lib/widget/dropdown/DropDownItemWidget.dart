/*
* Created By Mirai Devs.
* On 24/6/2022.
*/
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/product_type.dart';

import 'MiraiContainerWidget.dart';

class DropDownItemWidget extends StatelessWidget {
  const DropDownItemWidget({
    super.key,
    required this.project,
    required this.isItemSelected,
    this.firstSpace = 30,
    this.padding,
    this.fontSize,
  });

  final dynamic project;
  final bool isItemSelected;
  final double firstSpace;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    if (project == null) return const SizedBox.shrink();
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 16.0,
          ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${project!.name}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black,
                    fontSize: fontSize,
                  ),
                ),
                // Text(
                //   '${project!.code}',
                //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                //     color: textColor,
                //     fontSize: fontSize,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}