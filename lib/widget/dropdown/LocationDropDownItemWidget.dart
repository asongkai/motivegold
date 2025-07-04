
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class LocationDropDownItemWidget extends StatelessWidget {
  const LocationDropDownItemWidget({
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
                  '${project!.nameTh}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '${project!.nameEn}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}