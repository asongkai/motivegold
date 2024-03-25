import 'dart:async';
import 'dart:io';
import 'dart:math';

//import 'package:connectivity/connectivity.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/screen_utils.dart';

import 'global.dart';

final formatter = NumberFormat("#,###.##");

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class Utils {
  static String formatDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }

  static Future<bool> checkConnection() async {
    return true;
    // ConnectivityResult connectivityResult =
    // await (Connectivity().checkConnectivity());
    // if ((connectivityResult == ConnectivityResult.mobile) ||
    //     (connectivityResult == ConnectivityResult.wifi)) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  static bool? isAndroidPlatform() {
    if (Platform.isAndroid) {
      return true;
      // Android-specific code
    } else if (Platform.isIOS) {
      // iOS-specific code
      return false;
    }
    return null;
  }

  static void showAlert(BuildContext context, String title, String text,
      VoidCallback onPressed, bool cancelable) {
    var alert = Utils.isAndroidPlatform()!
        ? const AlertDialog()
        : CupertinoAlertDialog(
            title: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(text),
                ],
              ),
            ),
            actions: <Widget>[
              Utils.isAndroidPlatform() != null
                  ? TextButton(
                      onPressed: () {},
                      child: Container(),
                    )
                  : CupertinoDialogAction(
                      onPressed: onPressed,
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Constants.clr_blue),
                      ))
            ],
          );

    showDialog(
        context: context,
        barrierDismissible: cancelable,
        builder: (_) {
          return alert;
        });
  }

  static void showOkCancelAlert(
      BuildContext context, String title, String text, VoidCallback onPressed) {
    var alert = AlertDialog(
      title: Text(title),
      content: Container(
        child: Row(
          children: <Widget>[Text(text)],
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: onPressed,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.black87),
            )),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.blue),
            ))
      ],
    );

    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  static int getColorHexFromStr(String colorStr) {
    colorStr = "FF$colorStr";
    colorStr = colorStr.replaceAll("#", "");
    int val = 0;
    int len = colorStr.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw const FormatException("An error occurred when converting a color");
      }
    }
    return val;
  }
}

String randomIdWithName(userName) {
  int randomNumber = Random().nextInt(100000);
  return '$userName$randomNumber';
}

String getImageFileName(id, timestamp) {
  return "$id-$timestamp";
}

class MaskedTextController extends TextEditingController {
  MaskedTextController(
      {String? text, this.mask, Map<String, RegExp>? translator})
      : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      var previous = _lastUpdatedText;
      if (beforeChange(previous, this.text)) {
        updateText(this.text);
        afterChange(previous, this.text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(this.text);
  }

  String? mask;

  Map<String, RegExp>? translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String? text) {
    if (text != null) {
      this.text = _applyMask(mask!, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    updateText(text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    var text = _lastUpdatedText;
    selection =
        TextSelection.fromPosition(TextPosition(offset: (text).length));
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return {
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String mask, String value) {
    String result = '';

    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      var maskChar = mask[maskCharIndex];
      var valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator!.containsKey(maskChar)) {
        if (translator![maskChar]!.hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}

/// Mask for monetary values.
class MoneyMaskedTextController extends TextEditingController {
  MoneyMaskedTextController(
      {double initialValue = 0.0,
      this.decimalSeparator = ',',
      this.thousandSeparator = '.',
      this.rightSymbol = '',
      this.leftSymbol = '',
      this.precision = 2}) {
    _validateConfig();

    addListener(() {
      updateValue(numberValue);
      afterChange(text, numberValue);
    });

    updateValue(initialValue);
  }

  final String decimalSeparator;
  final String thousandSeparator;
  final String rightSymbol;
  final String leftSymbol;
  final int precision;

  Function afterChange = (String maskedValue, double rawValue) {};

  double _lastValue = 0.0;

  void updateValue(double value) {
    double valueToUse = value;

    if (value.toStringAsFixed(0).length > 12) {
      valueToUse = _lastValue;
    } else {
      _lastValue = value;
    }

    String masked = _applyMask(valueToUse);

    if (rightSymbol.isNotEmpty) {
      masked += rightSymbol;
    }

    if (leftSymbol.isNotEmpty) {
      masked = leftSymbol + masked;
    }

    if (masked != text) {
      text = masked;

      var cursorPosition = super.text.length - rightSymbol.length;
      selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPosition));
    }
  }

  double get numberValue {
    if (text.isEmpty || ((text.length - 1) < leftSymbol.length)) {
      return 0.0;
    }
    List<String> parts =
        _getOnlyNumbers(text).split('').toList(growable: true);

    parts.insert(parts.length - precision, '.');

    return double.parse(parts.join());
  }

  _validateConfig() {
    bool rightSymbolHasNumbers = _getOnlyNumbers(rightSymbol).isNotEmpty;

    if (rightSymbolHasNumbers) {
      throw ArgumentError("rightSymbol must not have numbers.");
    }
  }

  String _getOnlyNumbers(String text) {
    String cleanedText = text;

    var onlyNumbersRegex = RegExp(r'[^\d]');

    cleanedText = cleanedText.replaceAll(onlyNumbersRegex, '');

    return cleanedText;
  }

  String _applyMask(double value) {
    List<String> textRepresentation = value
        .toStringAsFixed(precision)
        .replaceAll('.', '')
        .split('')
        .reversed
        .toList(growable: true);

    textRepresentation.insert(precision, decimalSeparator);

    for (var i = precision + 4; true; i = i + 4) {
      if (textRepresentation.length > i) {
        textRepresentation.insert(i, thousandSeparator);
      } else {
        break;
      }
    }

    return textRepresentation.reversed.join('');
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

Widget buildTextField(
    {String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    String? suffixText,
    TextInputType? inputType,
    line,
    Color? textColor,
    bool option = false,
    Function(String value)? onChanged,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      enabled: enabled,
      maxLines: line ?? 1,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.all(8),
        labelText: labelText,
        labelStyle: TextStyle(
            color: textColor ?? Colors.black, fontWeight: FontWeight.w900),
        suffixText: suffixText,
        filled: true,
        suffixIcon: option ? const Icon(Icons.arrow_drop_down_outlined) : null,
        fillColor: enabled ? Colors.white70 : Colors.white54,
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
      validator: validator,
      controller: controller,
      onChanged: onChanged,
    ),
  );
}

Widget buildTextFieldBig(
    {String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    String? suffixText,
    TextInputType? inputType,
    line,
    Color? textColor,
    bool option = false,
    Function(String value)? onChanged,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      enabled: enabled,
      maxLines: line ?? 1,
      style: const TextStyle(fontSize: 38),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        labelText: labelText,
        labelStyle: TextStyle(
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 32),
        suffixText: suffixText,
        filled: true,
        suffixIcon: option ? const Icon(Icons.arrow_drop_down_outlined) : null,
        fillColor: enabled ? Colors.white70 : Colors.white54,
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
      validator: validator,
      controller: controller,
      onChanged: onChanged,
    ),
  );
}

bool get isTablet {
  final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalShortestSide =
      firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
  return logicalShortestSide > 600;
}

String generateRandomString(int len) {
  var r = Random();
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
}

sumSellTotal() {
  Global.sellSubTotal = 0;
  Global.sellTax = 0;
  Global.sellTotal = 0;
  Global.sellWeightTotal = 0;

  for (int i = 0; i < Global.sellOrderDetail!.length; i++) {
    Global.sellSubTotal += Global.sellOrderDetail![i].price!;
    if (Global.sellOrderDetail![i].weight!.isNotEmpty) {
      Global.sellWeightTotal += double.parse(Global.sellOrderDetail![i].weight!);
    }
  }
  Global.sellTax =
      Global.taxAmount(Global.taxBase(Global.sellSubTotal, Global.sellWeightTotal));
  Global.sellTotal = Global.sellSubTotal + Global.sellTax;
}

sumBuyTotal() {
  Global.buySubTotal = 0;
  Global.buyTax = 0;
  Global.buyTotal = 0;
  Global.buyWeightTotal = 0;

  for (int i = 0; i < Global.buyOrderDetail!.length; i++) {
    Global.buySubTotal += Global.buyOrderDetail![i].price!;
    if (Global.buyOrderDetail![i].weight!.isNotEmpty) {
      Global.buyWeightTotal += double.parse(Global.buyOrderDetail![i].weight!);
    }
  }

    Global.buyTax = 0;
    Global.buyTotal = Global.buySubTotal + Global.buyTax;
}
