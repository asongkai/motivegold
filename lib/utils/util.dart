import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//import 'package:connectivity/connectivity.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';

import '../model/order.dart';
import 'global.dart';

final formatter = NumberFormat("#,###.##");
const JsonEncoder encoder = JsonEncoder();

getPaymentType(String? paymentMethod) {
  return paymentTypes().where((e) => e.code == paymentMethod).first.name;
}

Future<String?> getDeviceId() {
  final mobileDeviceIdentifier = MobileDeviceIdentifier().getDeviceId();
  return mobileDeviceIdentifier;
}

int? filterChungVatById(int? id) {
  if (Global.provinceList.isNotEmpty) {
    var provinces = Global.provinceList.where((e) => e.id == id).toList();
    if (provinces.isNotEmpty) {
      Global.provinceModel = provinces.first;
      Global.provinceNotifier = ValueNotifier<ProvinceModel>(
          Global.provinceModel ?? ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
      return provinces.first.id;
    }
  }
  return 0;
}

int? filterChungVatByName(String? name) {
  if (Global.provinceList.isNotEmpty) {
    var provinces = Global.provinceList.where((e) => e.nameTh == name).toList();
    if (provinces.isNotEmpty) {
      Global.provinceModel = provinces.first;
      Global.provinceNotifier = ValueNotifier<ProvinceModel>(
          Global.provinceModel ?? ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
      return provinces.first.id;
    }
  }
  return 0;
}

int? filterAmpheryId(int? id) {
  var amphures = Global.amphureList.where((e) => e.id == id).toList();
  if (amphures.isNotEmpty) {
    Global.amphureModel = amphures.first;
    Global.amphureNotifier = ValueNotifier<AmphureModel>(
        Global.amphureModel ?? AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
    return amphures.first.id;
  }
  return 0;
}

int? filterAmpheryName(String? name) {
  var amphures = Global.amphureList.where((e) => e.nameTh == name).toList();
  if (amphures.isNotEmpty) {
    Global.amphureModel = amphures.first;
    Global.amphureNotifier = ValueNotifier<AmphureModel>(
        Global.amphureModel ?? AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
    return amphures.first.id;
  }
  return 0;
}

int? filterTambonById(int? id) {
  motivePrint(Global.tambonList.length);
  var tambons = Global.tambonList.where((e) => e.id == id).toList();
  if (tambons.isNotEmpty) {
    Global.tambonModel = tambons.first;
    Global.tambonNotifier = ValueNotifier<TambonModel>(
        Global.tambonModel ?? TambonModel(id: 0, nameTh: 'เลือกตำบล'));
    return tambons.first.id;
  }
  return 0;
}

int? filterTambonByName(String? name) {
  var tambons = Global.tambonList.where((e) => e.nameTh == name).toList();
  if (tambons.isNotEmpty) {
    Global.tambonModel = tambons.first;
    Global.tambonNotifier = ValueNotifier<TambonModel>(
        Global.tambonModel ?? TambonModel(id: 0, nameTh: 'เลือกตำบล'));
    return tambons.first.id;
  }
  return 0;
}

loadAmphureByProvince(int? id) async {
  try {
    var result = await ApiServices.post(
        '/customer/amphure/$id', Global.requestObj(null));
    if (result?.status == "success") {
      var data = jsonEncode(result?.data);
      List<AmphureModel> products = amphureModelFromJson(data);
      Global.amphureList = products;
    } else {
      Global.amphureList = [];
    }
  } catch (e) {
    motivePrint(e.toString());
  }
}

loadTambonByAmphure(int? id) async {
  try {
    var result =
        await ApiServices.post('/customer/tambon/$id', Global.requestObj(null));
    if (result?.status == "success") {
      var data = jsonEncode(result?.data);
      List<TambonModel> products = tambonModelFromJson(data);
      Global.tambonList = products;
    } else {
      Global.tambonList = [];
    }
  } catch (e) {
    motivePrint(e.toString());
  }
}

void resetPaymentData() {
  Global.currentPaymentMethod = null;
  Global.selectedPayment = null;
  Global.cardNameCtrl.text = "";
  Global.cardNumberCtrl.text = "";
  Global.cardExpireDateCtrl.text = "";
  Global.bankCtrl.text = "";
  Global.accountNoCtrl.text = "";
  Global.addressCtrl.text = "";
  Global.amountCtrl.text = "";
  Global.refNoCtrl.text = "";
  Global.paymentDateCtrl.text = Global.formatDateDD(DateTime.now().toString());
  Global.paymentAttachment = null;
  Global.selectedAccount = null;
  Global.selectedBank = null;
  Global.filterAccountList = [];
}

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
      content: Row(
        children: <Widget>[Text(text)],
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
        throw const FormatException(
            "An error occurred when converting a color");
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
      {super.text, this.mask, Map<String, RegExp>? translator}) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      var previous = _lastUpdatedText;
      if (beforeChange(previous, text)) {
        updateText(text);
        afterChange(previous, text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(text);
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
    selection = TextSelection.fromPosition(TextPosition(offset: (text).length));
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
      selection =
          TextSelection.fromPosition(TextPosition(offset: cursorPosition));
    }
  }

  double get numberValue {
    if (text.isEmpty || ((text.length - 1) < leftSymbol.length)) {
      return 0.0;
    }
    List<String> parts = _getOnlyNumbers(text).split('').toList(growable: true);

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
    List<TextInputFormatter>? inputFormat,
    line,
    Color? textColor,
    bool option = false,
    bool obscureText = false,
    Function(String value)? onChanged,
    Function(String value)? onSubmitted,
    String? placeholder,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      inputFormatters: inputFormat ?? [],
      obscureText: obscureText,
      enabled: enabled,
      maxLines: line ?? 1,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.all(8),
        labelText: labelText,
        labelStyle: TextStyle(
            fontSize: 20,
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w900),
        suffixText: suffixText,
        filled: true,
        hintText: placeholder,
        suffixIcon: option ? const Icon(Icons.arrow_drop_down_outlined) : null,
        fillColor: enabled ? Colors.white70 : Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(0),
          ),
          borderSide: const BorderSide(
            color: kGreyShade3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(0),
          ),
          borderSide: const BorderSide(
            color: kGreyShade3,
          ),
        ),
      ),
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    ),
  );
}

Widget buildTextFieldX(
    {String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    String? suffixText,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormat,
    line,
    Color? textColor,
    bool option = false,
    bool obscureText = false,
    Function(String value)? onChanged,
    Function(String value)? onSubmitted,
    String? placeholder,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      inputFormatters: inputFormat ?? [],
      obscureText: obscureText,
      enabled: enabled,
      maxLines: line ?? 1,
      style: const TextStyle(fontSize: 30),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.all(8),
        labelText: labelText,
        labelStyle: TextStyle(
            fontSize: 30,
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w900),
        suffixText: suffixText,
        filled: true,
        hintText: placeholder,
        suffixIcon: option ? const Icon(Icons.arrow_drop_down_outlined) : null,
        fillColor: enabled ? Colors.white70 : Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(0),
          ),
          borderSide: const BorderSide(
            color: kGreyShade3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(0),
          ),
          borderSide: const BorderSide(
            color: kGreyShade3,
          ),
        ),
      ),
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    ),
  );
}

Widget buildTextFieldBig(
    {String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    String? suffixText,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormat,
    line,
    Color? textColor,
    bool option = false,
    Function(String value)? onChanged,
    TextAlign? align,
    bool isPassword = false,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      inputFormatters: inputFormat ?? [],
      enabled: enabled,
      maxLines: line ?? 1,
      style: const TextStyle(fontSize: 40),
      textAlign: align ?? TextAlign.left,
      obscureText: isPassword,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        labelText: labelText,
        labelStyle: TextStyle(
            color: textColor ?? Colors.blue[900],
            fontWeight: FontWeight.w900,
            fontSize: 40),
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

Widget numberTextField(
    {String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    String? suffixText,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormat,
    line,
    Color? textColor,
    Function(String value)? onChanged,
    Function()? openCalc,
    Function()? onTap,
    Function()? clear,
    FocusNode? focusNode,
    bool isPassword = false,
    bool readOnly = false,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 0.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      inputFormatters: inputFormat ?? [],
      enabled: enabled,
      maxLines: line ?? 1,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 40,
        color: textColor ?? Colors.blue[900],
      ),
      obscureText: isPassword,
      onTap: onTap,
      readOnly: readOnly,
      // showCursor: readOnly ?? true,
      focusNode: focusNode,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        labelText: labelText,
        labelStyle: TextStyle(
            color: textColor ?? Colors.blue[900],
            fontWeight: FontWeight.w900,
            fontSize: 30),
        prefixIconConstraints:
            const BoxConstraints(minHeight: 90, minWidth: 90),
        prefixIcon: IconButton(
          icon: Icon(
            size: 80,
            Icons.calculate_outlined,
            color: readOnly ? Colors.teal : null,
          ),
          onPressed: openCalc,
        ),
        suffixText: suffixText,
        filled: true,
        suffixIconConstraints:
            const BoxConstraints(minHeight: 60, minWidth: 60),
        suffixIcon: IconButton(
          icon: const Icon(
            size: 50,
            Icons.close,
            color: Colors.red,
          ),
          onPressed: clear,
        ),
        fillColor: enabled ? Colors.white54 : Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(2),
          ),
          borderSide: BorderSide(
            color: readOnly ? Colors.teal : kGreyShade3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(2),
          ),
          borderSide: BorderSide(
            color: readOnly ? Colors.teal : kGreyShade3,
          ),
        ),
      ),
      validator: validator,
      controller: controller,
      onChanged: onChanged,
    ),
  );
}

Widget numberTextFieldBig(
    {String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    String? suffixText,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormat,
    line,
    Color? textColor,
    Function(String value)? onChanged,
    Function(bool)? onFocusChange,
    Function()? openCalc,
    Function()? onTap,
    Function()? clear,
    FocusNode? focusNode,
    bool isPassword = false,
    bool readOnly = false,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 0.0),
    child: Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        keyboardType: inputType ?? TextInputType.text,
        inputFormatters: inputFormat ?? [],
        enabled: enabled,
        maxLines: line ?? 1,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 50,
          color: textColor ?? Colors.blue[900],
        ),
        obscureText: isPassword,
        onTap: onTap,
        readOnly: readOnly,
        // showCursor: readOnly ?? true,
        focusNode: focusNode,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          labelText: labelText,
          labelStyle: TextStyle(
              color: textColor ?? Colors.blue[900],
              fontWeight: FontWeight.w900,
              fontSize: 50),
          prefixIconConstraints:
              const BoxConstraints(minHeight: 90, minWidth: 90),
          prefixIcon: IconButton(
            icon: Icon(
              size: 80,
              Icons.calculate_outlined,
              color: readOnly ? Colors.teal : null,
            ),
            onPressed: openCalc,
          ),
          suffixText: suffixText,
          filled: true,
          suffixIconConstraints:
              const BoxConstraints(minHeight: 60, minWidth: 60),
          suffixIcon: IconButton(
            icon: const Icon(
              size: 50,
              Icons.close,
              color: Colors.red,
            ),
            onPressed: clear,
          ),
          fillColor: enabled ? Colors.white54 : Colors.white54,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(2),
            ),
            borderSide: BorderSide(
              color: readOnly ? Colors.teal : kGreyShade3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(2),
            ),
            borderSide: BorderSide(
              color: readOnly ? Colors.teal : kGreyShade3,
            ),
          ),
        ),
        validator: validator,
        controller: controller,
        onChanged: onChanged,
      ),
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
  return List.generate(len, (index) => chars[r.nextInt(chars.length)])
      .join()
      .toUpperCase();
}

String generateProductCode(int len) {
  var r = Random();
  const chars = '1234567890';
  return 'P-${List.generate(len, (index) => chars[r.nextInt(chars.length)]).join().toUpperCase()}';
}

String generateOrderId(int len) {
  var r = Random();
  const chars = '1234567890';
  return 'P-${List.generate(len, (index) => chars[r.nextInt(chars.length)]).join().toUpperCase()}';
}

String dataType(OrderModel list) {
  switch (list.orderTypeId) {
    case 1:
      return "ขายทองใหม่";
    case 2:
      return "ซื้อทองเก่า";
    case 3:
      return "ขายทองแท่ง (จับคู่)";
    case 4:
      return "ขายทองแท่ง";
    case 33:
      return "ซื้อทองแท่ง (จับคู่)";
    case 44:
      return "ซื้อทองแท่ง";
    case 5:
      return "เติมทอง";
    case 6:
      return "ขายทองเก่า";
    case 8:
      return "ขายทองแท่งกับโบรกเกอร์";
    case 9:
      return "ซื้อทองแท่งกับโบรกเกอร์";
    default:
      return "";
  }
}

Color colorType(OrderModel list) {
  switch (list.orderTypeId) {
    case 1:
      return Colors.teal;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.brown;
    case 4:
      return Colors.deepPurple;
    case 33:
      return Colors.brown;
    case 44:
      return Colors.deepPurple;
    case 5:
      return Colors.green;
    case 6:
      return Colors.blueGrey;
    case 8:
      return Colors.green;
    case 9:
      return Colors.blueGrey;
    default:
      return Colors.transparent;
  }
}

sumSellTotal() {
  Global.sellSubTotal = 0;
  Global.sellTax = 0;
  Global.sellTotal = 0;
  Global.sellWeightTotal = 0;

  for (int i = 0; i < Global.sellOrderDetail!.length; i++) {
    Global.sellSubTotal += Global.sellOrderDetail![i].priceIncludeTax!;
    if (Global.sellOrderDetail![i].weight! != 0) {
      Global.sellWeightTotal += Global.sellOrderDetail![i].weight!;
    }
  }
  Global.sellTax = Global.taxAmount(
      Global.taxBase(Global.sellSubTotal, Global.sellWeightTotal));
  Global.sellTotal = Global.sellSubTotal + Global.sellTax;
}

sumBuyThengTotal() {
  Global.buyThengSubTotal = 0;
  Global.buyThengTax = 0;
  Global.buyThengTotal = 0;
  Global.buyThengWeightTotal = 0;

  for (int i = 0; i < Global.buyThengOrderDetail!.length; i++) {
    Global.buyThengSubTotal += Global.buyThengOrderDetail![i].priceIncludeTax!;
    if (Global.buyThengOrderDetail![i].weight! != 0) {
      Global.buyThengWeightTotal += Global.buyThengOrderDetail![i].weight!;
    }
  }
  Global.buyThengTax = Global.taxAmount(
      Global.taxBase(Global.buyThengSubTotal, Global.buyThengWeightTotal));
  Global.buyThengTotal = Global.buyThengSubTotal + Global.buyThengTax;
}

sumSellThengTotal() {
  Global.sellThengSubTotal = 0;
  Global.sellThengTax = 0;
  Global.sellThengTotal = 0;
  Global.sellThengWeightTotal = 0;

  for (int i = 0; i < Global.sellThengOrderDetail!.length; i++) {
    Global.sellThengSubTotal +=
        Global.sellThengOrderDetail![i].priceIncludeTax!;
    if (Global.sellThengOrderDetail![i].weight! != 0) {
      Global.sellThengWeightTotal += Global.sellThengOrderDetail![i].weight!;
    }
  }
  Global.sellThengTax = Global.taxAmount(
      Global.taxBase(Global.sellThengSubTotal, Global.sellThengWeightTotal));
  Global.sellThengTotal = Global.sellThengSubTotal + Global.sellThengTax;
}

sumBuyThengTotalBroker() {
  Global.buyThengSubTotalBroker = 0;
  Global.buyThengTaxBroker = 0;
  Global.buyThengTotalBroker = 0;
  Global.buyThengWeightTotalBroker = 0;

  for (int i = 0; i < Global.buyThengOrderDetailBroker!.length; i++) {
    Global.buyThengSubTotalBroker +=
        Global.buyThengOrderDetailBroker![i].priceIncludeTax!;
    if (Global.buyThengOrderDetailBroker![i].weight! != 0) {
      Global.buyThengWeightTotalBroker +=
          Global.buyThengOrderDetailBroker![i].weight!;
    }
  }
  Global.buyThengTaxBroker = Global.taxAmount(Global.taxBase(
      Global.buyThengSubTotalBroker, Global.buyThengWeightTotalBroker));
  Global.buyThengTotalBroker =
      Global.buyThengSubTotalBroker + Global.buyThengTaxBroker;
}

sumSellThengTotalBroker() {
  Global.sellThengSubTotalBroker = 0;
  Global.sellThengTaxBroker = 0;
  Global.sellThengTotalBroker = 0;
  Global.sellThengWeightTotalBroker = 0;

  for (int i = 0; i < Global.sellThengOrderDetailBroker!.length; i++) {
    Global.sellThengSubTotalBroker +=
        Global.sellThengOrderDetailBroker![i].priceIncludeTax!;
    if (Global.sellThengOrderDetailBroker![i].weight! != 0) {
      Global.sellThengWeightTotalBroker +=
          Global.sellThengOrderDetailBroker![i].weight!;
    }
  }
  Global.sellThengTaxBroker = Global.taxAmount(Global.taxBase(
      Global.sellThengSubTotalBroker, Global.sellThengWeightTotalBroker));
  Global.sellThengTotalBroker =
      Global.sellThengSubTotalBroker + Global.sellThengTaxBroker;
}

sumBuyThengTotalMatching() {
  Global.buyThengSubTotalMatching = 0;
  Global.buyThengTaxMatching = 0;
  Global.buyThengTotalMatching = 0;
  Global.buyThengWeightTotal = 0;

  for (int i = 0; i < Global.buyThengOrderDetailMatching!.length; i++) {
    Global.buyThengSubTotalMatching +=
        Global.buyThengOrderDetailMatching![i].priceIncludeTax!;
    if (Global.buyThengOrderDetailMatching![i].weight! != 0) {
      Global.buyThengWeightTotalMatching +=
          Global.buyThengOrderDetailMatching![i].weight!;
    }
  }
  Global.buyThengTaxMatching = Global.taxAmount(Global.taxBase(
      Global.buyThengSubTotalMatching, Global.buyThengWeightTotalMatching));
  Global.buyThengTotalMatching =
      Global.buyThengSubTotalMatching + Global.buyThengTaxMatching;
}

sumSellThengTotalMatching() {
  Global.sellThengSubTotalMatching = 0;
  Global.sellThengTaxMatching = 0;
  Global.sellThengTotalMatching = 0;
  Global.sellThengWeightTotalMatching = 0;

  for (int i = 0; i < Global.sellThengOrderDetailMatching!.length; i++) {
    Global.sellThengSubTotalMatching +=
        Global.sellThengOrderDetailMatching![i].priceIncludeTax!;
    if (Global.sellThengOrderDetailMatching![i].weight! != 0) {
      Global.sellThengWeightTotalMatching +=
          Global.sellThengOrderDetailMatching![i].weight!;
    }
  }
  Global.sellThengTaxMatching = Global.taxAmount(Global.taxBase(
      Global.sellThengSubTotalMatching, Global.sellThengWeightTotalMatching));
  Global.sellThengTotalMatching =
      Global.sellThengSubTotalMatching + Global.sellThengTaxMatching;
}

sumBuyTotal() {
  Global.buySubTotal = 0;
  Global.buyTax = 0;
  Global.buyTotal = 0;
  Global.buyWeightTotal = 0;

  for (int i = 0; i < Global.buyOrderDetail!.length; i++) {
    Global.buySubTotal += Global.buyOrderDetail![i].priceIncludeTax!;
    if (Global.buyOrderDetail![i].weight! != 0) {
      Global.buyWeightTotal += Global.buyOrderDetail![i].weight!;
    }
  }

  Global.buyTax = 0;
  Global.buyTotal = Global.buySubTotal + Global.buyTax;
}

getIdTitle(ProductTypeModel? selectedType) {
  return selectedType?.code == 'company'
      ? 'เลขบัตรประจำตัวภาษี'
      : 'เลขบัตรประจำตัวประชาชน';
}

getIdTitleCustomer(CustomerModel? selectedType) {
  return selectedType?.customerType == 'company'
      ? 'เลขบัตรประจำตัวภาษี'
      : 'เลขบัตรประจำตัวประชาชน';
}

getOrderListTitle(OrderModel order) {
  if (order.orderTypeId == 1) {
    return "ลูกค้าซื้อ - ร้านขาย";
  }
  if (order.orderTypeId == 2) {
    return "ลูกค้าขาย - ร้านซื้อ";
  }
  if (order.orderTypeId == 3) {
    return "ขายทองแท่ง (จับคู่)";
  }
  if (order.orderTypeId == 5) {
    return "เติมทอง";
  }
  if (order.orderTypeId == 6) {
    return "ขายทองเก่าร้านขายส่ง";
  }
  if (order.orderTypeId == 33) {
    return "ซื้อทองแท่ง (จับคู่)";
  }
  if (order.orderTypeId == 4) {
    return "ขายทองแท่ง";
  }
  if (order.orderTypeId == 44) {
    return "ซื้อทองแท่ง";
  }
  if (order.orderTypeId == 8) {
    return "ขายทองแท่งกับโบรกเกอร์";
  }
  if (order.orderTypeId == 9) {
    return "ซื้อทองแท่งกับโบรกเกอร์";
  }
  return "รายการสินค้า";
}

getDefaultProductMessage() {
  return "โปรดตั้งค่าสินค้าเริ่มต้นสำหรับหน้าจอก่อน";
}

getDefaultWarehouseMessage() {
  return "โปรดตั้งค่าคลังสินค้าเริ่มต้นสำหรับหน้าจอก่อน";
}

getVatValue() {
  if (Global.settingValueModel == null) {
    return 7.00 / 100.00;
  }
  var vat = Global.settingValueModel?.vatValue ?? 7.00;
  return vat / 100.00;
}

getUnitWeightValue() {
  if (Global.settingValueModel == null) {
    return 15.16;
  }
  return Global.settingValueModel?.unitWeight ?? 15.16;
}

getMaxKycValue() {
  if (Global.settingValueModel == null) {
    return 200000;
  }
  return Global.settingValueModel?.maxKycValue ?? 200000;
}

getTaxAmount(double? amount) {}

getTaxBase(double? amount) {}

enum ENV { PRO, DEV }
