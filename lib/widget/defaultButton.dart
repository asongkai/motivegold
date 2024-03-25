
import 'package:flutter/material.dart';
import 'package:motivegold/utils/constants.dart';

class DefaultButton extends StatelessWidget {
  final String btnText;
  final Function() onPressed;
  const DefaultButton({
    Key? key, required this.btnText, required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: kLessPadding),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kShape)),
        color: kPrimaryColor,
        textColor: kWhiteColor,
        highlightColor: kTransparent,
        onPressed: onPressed,
        child: Text(btnText.toUpperCase()),
      ),
    );
  }
}