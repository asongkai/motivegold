import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/screen_utils.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, 
    this.hint,
    this.icon,
    this.maxLine,
    this.controller,
    this.focusNode,
    this.enable, this.prefixIcon
  });
  final String? hint;
  final Widget? icon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLine;
  final bool? enable;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      maxLines: maxLine,
      decoration: InputDecoration(
        enabled: enable ?? true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(8),
          ),
          borderSide: const BorderSide(
            color: kGreyShade3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(8),
          ),
          borderSide: const BorderSide(
            color: kGreyShade3,
          ),
        ),
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: kGreyShade3,
          fontWeight: FontWeight.w500,
          fontFamily: 'NotoSansLao',
            ),
        suffixIcon: icon,
        prefixIcon: prefixIcon
      ),
    );
  }
}
