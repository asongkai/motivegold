import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Alert {
  static error(BuildContext context, String title, String message, String buttonText, {Function()? action}) {
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
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red)
      ..show();
  }

  static warning(BuildContext context, String title, String message, String buttonText, {Function()? action}) {
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
        btnCancelOnPress: null,
        btnCancelText: buttonText,
        btnOkOnPress: action)
      ..show();
  }

  static info(BuildContext context, String title, String message, String buttonText, {Function()? action}) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        headerAnimationLoop: false,
        animType: AnimType.scale,
        showCloseIcon: true,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        closeIcon: const Icon(Icons.close),
        btnCancelText: 'Cancel'.tr(),
        btnOkText: buttonText,
        title: title,
        desc: message,
        btnCancelOnPress: () {},
        btnOkOnPress: action)
      ..show();
  }

  static success(BuildContext context, String title, String message, String buttonText, {Function()? action}) {
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
        btnOkIcon: Icons.check_circle)
      ..show();
  }
}
