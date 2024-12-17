import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final Widget text;
  final String? value;
  final Color? fillColor;
  final Color? textColor;
  final Function callback;

  const CalcButton({
    super.key,
    required this.text,
    this.fillColor,
    this.textColor = Colors.white,
    required this.callback,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: SizedBox(
        width: 85,
        height: 85,
        child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          onPressed: () {
            callback(value);
          },
          color: const Color(0xFF414141),
          textColor: textColor,
          child: text,
        ),
      ),
    );
  }
}
