import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/util.dart';

class CustomerDropDownItemWidget extends StatelessWidget {
  const CustomerDropDownItemWidget({
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
                  '${project != null ? getCustomerName(project) : ''}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: textColor,
                        fontSize: fontSize,
                      ),
                ),
                if (project != null && project.toJson().containsKey("idCard"))
                  Text(
                    '${project?.idCard}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: textColor,
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
