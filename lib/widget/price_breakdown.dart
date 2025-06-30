import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/constants/colors.dart';

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
            fontSize: size.getWidthPx(10),
            fontWeight: FontWeight.w500,
              ),
        ),
        const Spacer(),
        Text(
          price!,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: kTextColor,
                fontSize: size.getWidthPx(10),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
