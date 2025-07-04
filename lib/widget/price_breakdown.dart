import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:sizer/sizer.dart';

class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({
    Key? key,
    this.title,
    this.price,
  }) : super(key: key);

  final String? title;
  final String? price;

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Row(
      children: [
        Text(
          title!,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: kTextColorAccent,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
              ),
        ),
        const Spacer(),
        Text(
          price!,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: kTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
