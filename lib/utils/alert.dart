import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Alert {
  static error(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        headerAnimationLoop: false,
        title: title,
        desc: message,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        btnOkOnPress: action,
        btnOkText: buttonText,
        btnOkColor: Colors.redAccent,
        btnCancelColor: Colors.redAccent,
        btnOkIcon: Icons.cancel,
        width: MediaQuery.of(context).size.width > 1300
            ? MediaQuery.of(context).size.width * 1 / 4
            : MediaQuery.of(context).size.width * 2 / 4)
      ..show();
  }

  static warning(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        headerAnimationLoop: true,
        animType: AnimType.scale,
        showCloseIcon: true,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        closeIcon: const Icon(Icons.close),
        title: title,
        desc: message,
        btnOkText: buttonText,
        btnOkColor: Colors.orange,
        btnCancelColor: Colors.orange,
        btnCancelOnPress: null,
        btnCancelText: buttonText,
        width: MediaQuery.of(context).size.width > 1300
            ? MediaQuery.of(context).size.width * 1 / 4
            : MediaQuery.of(context).size.width * 2 / 4,
        btnOkOnPress: action)
      ..show();
  }

  static info(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        headerAnimationLoop: false,
        animType: AnimType.scale,
        showCloseIcon: true,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        closeIcon: const Icon(Icons.close),
        btnCancelText: 'ยกเลิก',
        btnOkText: buttonText,
        btnOkColor: Colors.deepPurple[700],
        btnCancelColor: Colors.blue,
        title: title,
        desc: message,
        btnCancelOnPress: () {},
        width: MediaQuery.of(context).size.width > 1300
            ? MediaQuery.of(context).size.width * 1 / 4
            : MediaQuery.of(context).size.width * 2 / 4,
        btnOkOnPress: action)
      ..show();
  }

  static success(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return AwesomeDialog(
        context: context,
        animType: AnimType.scale,
        headerAnimationLoop: false,
        dialogType: DialogType.success,
        title: title,
        desc: message,
        btnOkOnPress: action,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        btnOkText: buttonText,
        btnOkColor: const Color(0xFF00CA71),
        btnCancelColor: Colors.orange,
        width: MediaQuery.of(context).size.width > 1300
            ? MediaQuery.of(context).size.width * 1 / 4
            : MediaQuery.of(context).size.width * 2 / 4,
        btnOkIcon: Icons.check_circle)
      ..show();
  }
}
