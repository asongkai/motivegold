
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:motivegold/utils/app_theme.dart';
import 'package:sizer/sizer.dart';


class LocationDropDownObjectChildWidget extends StatelessWidget {
  const LocationDropDownObjectChildWidget({
    super.key,
    required this.projectValueNotifier,
    this.firstSpace = 12,
    this.secondSpace = 16,
    this.padding,
    this.fontSize,
    this.coloredContainerSize,
    this.height,
  });

  final ValueNotifier<dynamic> projectValueNotifier;
  final double firstSpace;
  final double secondSpace;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final double? coloredContainerSize;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: GlobalKey(),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: const Color(0xFFECECEC),
          width: 1.0,
        ),
      ),
      height: height ?? 40,
      child: ValueListenableBuilder<dynamic>(
        valueListenable: projectValueNotifier,
        builder: (_, dynamic project, __) {
          return Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      '${project.nameTh}',
                      key: ValueKey<String>('${project.nameTh}'.trim()),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.keyTextBlackColor,
                        fontSize: 14.sp,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: secondSpace),
              const FaIcon(
                FontAwesomeIcons.chevronDown,
                color: AppTheme.keyAppColor,
                size: 12,
              ),
            ],
          );
        },
      ),
    );
  }
}