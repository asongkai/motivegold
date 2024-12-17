import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/screen_utils.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({super.key, required this.dateCtrl, required this.label, this.enable});

  final TextEditingController dateCtrl;
  final String label;
  final bool? enable;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: MaskedTextField(
        enabled: enable ?? true,
        controller: dateCtrl,
        mask: "##-##-####",
        maxLength: 10,
        keyboardType: TextInputType.number,
        //editing controller of this TextField
        style: const TextStyle(fontSize: 38),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today),
          labelStyle: TextStyle(
              fontSize: 38,
              color: Colors.blue[900],
              fontWeight: FontWeight.w900),
          //icon of text field
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          labelText: label,
          hintText: "##-##-####",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(2),
            ),
            borderSide: const BorderSide(
              color: kGreyShade3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(2),
            ),
            borderSide: const BorderSide(
              color: kGreyShade3,
            ),
          ),
        ),
        //set it true, so that user will not able to edit text
      ),
    );
  }
}
