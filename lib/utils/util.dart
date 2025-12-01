import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//import 'package:connectivity/connectivity.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:sizer/sizer.dart';

import '../model/order.dart';
import 'global.dart';

final formatterInt = NumberFormat("#,###");
final formatter = NumberFormat("#,###.##");
final formatter3 = NumberFormat("#,###.###");
final formatter4 = NumberFormat("#,###.####");
final formatter6 = NumberFormat("#,###.######");
const JsonEncoder encoder = JsonEncoder();

void resetAtLogout() {
  Global.isLoggedIn = false;
  Global.user = UserModel();
  Global.company = null;
  Global.branch = null;
  Global.orders.clear();
  Global.order = null;
  Global.ordersPapun?.clear();
  Global.orderPapun = null;
  Global.ordersThengMatching?.clear();
  Global.orderThengMatching = null;
  Global.ordersTheng?.clear();
  Global.orderTheng = null;
  Global.ordersBroker?.clear();
  Global.orderBroker = null;
  Global.ordersWholesale?.clear();
  Global.orderWholesale = null;
  Global.orderDetail?.clear();
  Global.sellOrderDetail = [];
  Global.buyOrderDetail = [];
  Global.buyThengOrderDetail = [];
  Global.sellThengOrderDetail = [];
  Global.buyThengOrderDetailMatching = [];
  Global.sellThengOrderDetailMatching = [];
  Global.buyThengOrderDetailBroker = [];
  Global.sellThengOrderDetailBroker = [];
  Global.refillOrderDetail = [];
  Global.usedSellDetail = [];
  Global.transferDetail = [];
  Global.branchList = [];
  Global.redeemSingleDetail = [];
  Global.redeems = [];
  resetCart();
  resetRedeemCart();
}

getPaymentType(String? paymentMethod) {
  List<ProductTypeModel> data =
      paymentTypes().where((e) => e.code == paymentMethod).toList();
  if (data.isNotEmpty) {
    return data.first.name;
  }
  return null;
}

Future<String?> getDeviceId() async {
  if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return null; // or generate a UUID, etc.
  }
  final mobileDeviceIdentifier = MobileDeviceIdentifier().getDeviceId();
  return mobileDeviceIdentifier;
}

int? filterChungVatById(int? id) {
  if (Global.provinceList.isNotEmpty) {
    var provinces = Global.provinceList.where((e) => e.id == id).toList();
    if (provinces.isNotEmpty) {
      Global.provinceModel = provinces.first;
      // Update the value of existing notifier instead of creating a new one
      Global.provinceNotifier?.value = provinces.first;
      return provinces.first.id;
    } else {
      Global.provinceModel = null;
      // Update to placeholder value
      Global.provinceNotifier?.value = ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด');
    }
  }
  return 0;
}

int? filterChungVatByName(String? name) {
  if (Global.provinceList.isNotEmpty) {
    var provinces = Global.provinceList.where((e) => e.nameTh == name).toList();
    if (provinces.isNotEmpty) {
      Global.provinceModel = provinces.first;
      // Update the value of existing notifier instead of creating a new one
      Global.provinceNotifier?.value = provinces.first;
      return provinces.first.id;
    } else {
      Global.provinceModel = null;
      // Update to placeholder value
      Global.provinceNotifier?.value = ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด');
    }
  }
  return 0;
}

int? filterAmpheryId(int? id) {
  var amphures = Global.amphureList.where((e) => e.id == id).toList();
  if (amphures.isNotEmpty) {
    Global.amphureModel = amphures.first;
    // Update the value of existing notifier instead of creating a new one
    Global.amphureNotifier?.value = amphures.first;
    return amphures.first.id;
  } else {
    Global.amphureModel = null;
    // Update to placeholder value
    Global.amphureNotifier?.value = AmphureModel(id: 0, nameTh: 'เลือกอำเภอ');
  }
  return 0;
}

int? filterAmpheryName(String? name) {
  var amphures = Global.amphureList.where((e) => e.nameTh == name).toList();
  if (amphures.isNotEmpty) {
    Global.amphureModel = amphures.first;
    // Update the value of existing notifier instead of creating a new one
    Global.amphureNotifier?.value = amphures.first;
    return amphures.first.id;
  } else {
    Global.amphureModel = null;
    // Update to placeholder value
    Global.amphureNotifier?.value = AmphureModel(id: 0, nameTh: 'เลือกอำเภอ');
  }
  return 0;
}

int? filterTambonById(int? id) {
  motivePrint(Global.tambonList.length);
  var tambons = Global.tambonList.where((e) => e.id == id).toList();
  if (tambons.isNotEmpty) {
    Global.tambonModel = tambons.first;
    // Update the value of existing notifier instead of creating a new one
    Global.tambonNotifier?.value = tambons.first;
    return tambons.first.id;
  } else {
    Global.tambonModel = null;
    // Update to placeholder value
    Global.tambonNotifier?.value = TambonModel(id: 0, nameTh: 'เลือกตำบล');
  }
  return 0;
}

int? filterTambonByName(String? name) {
  var tambons = Global.tambonList.where((e) => e.nameTh == name).toList();
  if (tambons.isNotEmpty) {
    Global.tambonModel = tambons.first;
    // Update the value of existing notifier instead of creating a new one
    Global.tambonNotifier?.value = tambons.first;
    return tambons.first.id;
  } else {
    Global.tambonModel = null;
    // Update to placeholder value
    Global.tambonNotifier?.value = TambonModel(id: 0, nameTh: 'เลือกตำบล');
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
    Global.amphureList = [];
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
    Color? labelColor,
    bool option = false,
    bool obscureText = false,
    Function(String value)? onChanged,
    Function(String value)? onSubmitted,
    String? placeholder,
    double fontSize = 25.00,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      inputFormatters: inputFormat ?? [],
      obscureText: obscureText,
      enabled: enabled,
      maxLines: line ?? 1,
      style: TextStyle(
        fontSize: 14.sp, //fontSize,
        color: labelColor ?? textColor,
      ),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.all(18),
        labelText: labelText,
        labelStyle: TextStyle(
            fontSize: 14.sp, //fontSize,
            color: labelColor ?? textColor,
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
    Color? labelColor,
    bool option = false,
    bool obscureText = false,
    Function(String value)? onChanged,
    Function(String value)? onSubmitted,
    String? placeholder,
    double fontSize = 30.00,
    Color? bgColor,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      inputFormatters: inputFormat ?? [],
      obscureText: obscureText,
      enabled: enabled,
      maxLines: line ?? 1,
      style: TextStyle(
        fontSize: 16.sp, //fontSize,
        color: labelColor ?? textColor,
      ),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.all(8),
        labelText: labelText,
        labelStyle: TextStyle(
            fontSize: 16.sp, //fontSize,
            color: labelColor ?? textColor,
            fontWeight: FontWeight.w900),
        suffixText: suffixText,
        filled: true,
        hintText: placeholder,
        suffixIcon: option ? const Icon(Icons.arrow_drop_down_outlined) : null,
        fillColor: enabled ? bgColor ?? Colors.white70 : Colors.grey.shade50,
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
    Color? labelColor,
    bool option = false,
    Function(String value)? onChanged,
    TextAlign? align,
    bool isPassword = false,
    double fontSize = 40.00,
    Color? bgColor,
    String? hintText,
    enabled = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      keyboardType: inputType ?? TextInputType.text,
      inputFormatters: inputFormat ?? [],
      enabled: enabled,
      maxLines: line ?? 1,
      style: TextStyle(
        fontSize: 18.sp, //fontSize,
        color: labelColor ?? textColor,
      ),
      textAlign: align ?? TextAlign.left,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText ?? '',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        labelText: labelText,
        labelStyle: TextStyle(
          color: labelColor ?? textColor,
          fontWeight: FontWeight.w900,
          fontSize: 18.sp, //fontSize,
        ),
        suffixText: suffixText,
        filled: true,
        suffixIcon: option ? const Icon(Icons.arrow_drop_down_outlined) : null,
        fillColor: enabled ? bgColor ?? Colors.white70 : Colors.grey.shade50,
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
    Color? labelColor,
    Function(String value)? onChanged,
    Function(bool)? onFocusChange,
    Function()? openCalc,
    Function()? onTap,
    Function()? clear,
    FocusNode? focusNode,
    bool isPassword = false,
    bool readOnly = false,
    double? fontSize,
    Color? bgColor,
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
          fontSize: fontSize ?? 16.sp, //fontSize,
          color: labelColor ?? textColor,
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
            color: labelColor ?? textColor,
            fontWeight: FontWeight.w900,
            fontSize: fontSize ?? 16.sp, //fontSize,
          ),
          prefixIconConstraints:
              const BoxConstraints(minHeight: 50, minWidth: 50),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  border: Border.all(
                width: 0.5,
                color: readOnly ? Colors.teal : Colors.orange.shade900,
              )),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/icons8-plus-slash-minus-50.png',
                  color: readOnly ? Colors.teal : Colors.orange.shade500,
                  width: 50,
                ),
                onPressed: openCalc,
              ),
            ),
          ),
          suffixText: suffixText,
          filled: true,
          suffixIconConstraints:
              const BoxConstraints(minHeight: 60, minWidth: 60),
          suffixIcon: IconButton(
            icon: Image.asset(
              'assets/icons/icons8-sort-left-50.png',
              color: Colors.red.shade500,
            ),
            onPressed: clear,
          ),
          fillColor: enabled ? bgColor ?? Colors.white70 : Colors.grey.shade50,
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

Widget numberTextFieldBig(
    {String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    String? suffixText,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormat,
    line,
    Color? labelColor,
    Function(String value)? onChanged,
    Function(bool)? onFocusChange,
    Function()? openCalc,
    Function()? onTap,
    Function()? clear,
    FocusNode? focusNode,
    bool isPassword = false,
    bool readOnly = false,
    double fontSize = 50.00,
    Color? bgColor,
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
          fontSize: 18.sp, //fontSize,
          color: labelColor ?? textColor,
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
            color: labelColor ?? textColor,
            fontWeight: FontWeight.w900,
            fontSize: 18.sp, //fontSize,
          ),
          prefixIconConstraints:
              const BoxConstraints(minHeight: 50, minWidth: 50),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: readOnly ? Colors.teal : Colors.red.shade500)),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/icons8-plus-slash-minus-50.png',
                  color: readOnly ? Colors.teal : Colors.red.shade500,
                  width: 16.sp, //50,
                ),
                onPressed: openCalc,
              ),
            ),
          ),
          suffixText: suffixText,
          filled: true,
          suffixIconConstraints:
              const BoxConstraints(minHeight: 60, minWidth: 60),
          suffixIcon: IconButton(
            icon: Image.asset(
              'assets/icons/icons8-sort-left-50.png',
              color: Colors.red.shade500,
            ),
            onPressed: clear,
          ),
          fillColor: enabled ? bgColor ?? Colors.white70 : Colors.grey.shade50,
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
    case 10:
      return "เติมทองคำแท่งกับร้านค้าส่ง";
    case 11:
      return "ขายทองคำแท่งเก่าให้ร้านค้าส่ง";
    default:
      return "";
  }
}

Color colorType(OrderModel list) {
  switch (list.orderTypeId) {
    case 1:
      return snBgColor; // sell new gold
    case 2:
      return buBgColor; // buy used gold
    case 3:
      return stmBgColor; // sell theng gold matching
    case 4:
      return stBgColor; // sell theng gold real
    case 33:
      return Colors.teal; // buy theng gold matching
    case 44:
      return btBgColor; // buy theng gold real
    case 5:
      return rfBgColor; // refill new gold to wholesale
    case 6:
      return suBgColor; // sell used gold to wholesale
    case 8:
      return Colors.teal[900]!; // sell theng gold to broker
    case 9:
      return Colors.orange[900]!; // buy theng gold from broker
    case 10:
      return snBgColor; // refill theng gold from wholesale
    case 11:
      return buBgColor; // sell old theng gold to wholesale
    default:
      return Colors.transparent;
  }
}

String dataTypeRedeem(RedeemModel list) {
  switch (list.redeemTypeId) {
    case 1:
      return "ไถ่ถอน - ขายฝาก";
    default:
      return "";
  }
}

Color colorTypeRedeem(RedeemModel list) {
  switch (list.redeemTypeId) {
    case 1:
      return stmBgColor;
    default:
      return Colors.transparent;
  }
}

sumSellTotal(int productId) {
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
      Global.taxBase(Global.sellSubTotal, Global.sellWeightTotal, productId));
  Global.sellTotal = Global.sellSubTotal + Global.sellTax;
}

sumBuyThengTotal(int productId) {
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
  Global.buyThengTax = Global.taxAmount(Global.taxBase(
      Global.buyThengSubTotal, Global.buyThengWeightTotal, productId));
  Global.buyThengTotal = Global.buyThengSubTotal + Global.buyThengTax;
}

sumSellThengTotal(int productId) {
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
  Global.sellThengTax = Global.taxAmount(Global.taxBase(
      Global.sellThengSubTotal, Global.sellThengWeightTotal, productId));
  Global.sellThengTotal = Global.sellThengSubTotal + Global.sellThengTax;
}

sumBuyThengTotalBroker(int productId) {
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
      Global.buyThengSubTotalBroker,
      Global.buyThengWeightTotalBroker,
      productId));
  Global.buyThengTotalBroker =
      Global.buyThengSubTotalBroker + Global.buyThengTaxBroker;
}

sumSellThengTotalBroker(int productId) {
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
      Global.sellThengSubTotalBroker,
      Global.sellThengWeightTotalBroker,
      productId));
  Global.sellThengTotalBroker =
      Global.sellThengSubTotalBroker + Global.sellThengTaxBroker;
}

sumBuyThengTotalMatching(int productId) {
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
      Global.buyThengSubTotalMatching,
      Global.buyThengWeightTotalMatching,
      productId));
  Global.buyThengTotalMatching =
      Global.buyThengSubTotalMatching + Global.buyThengTaxMatching;
}

sumSellThengTotalMatching(int productId) {
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
      Global.sellThengSubTotalMatching,
      Global.sellThengWeightTotalMatching,
      productId));
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
  motivePrint(selectedType?.toJson());
  return selectedType?.code == 'company'
      ? 'เลขบัตรประจำตัวภาษี'
      : 'เลขบัตรประจำตัวประชาชน';
}

/// Get branch address for bills/reports - Line 1: Building details
String getBillAddressLine1() {
  if (Global.branch == null) {
    return "";
  }

  String address = "";

  // Line 1: เลขที่, อาคาร, เลขที่ห้อง, ชั้นที่, หมู่บ้าน, ตรอก/ซอย, ถนน
  if (Global.branch?.address != null && Global.branch!.address!.isNotEmpty) {
    address += 'เลขที่ ${Global.branch!.address}';
  }
  if (Global.branch?.building != null && Global.branch!.building!.isNotEmpty) {
    address += ' อาคาร${Global.branch!.building}';
  }
  if (Global.branch?.room != null && Global.branch!.room!.isNotEmpty) {
    address += ' เลขที่ห้อง${Global.branch!.room}';
  }
  if (Global.branch?.floor != null && Global.branch!.floor!.isNotEmpty) {
    address += ' ชั้นที่${Global.branch!.floor}';
  }
  if (Global.branch?.village != null && Global.branch!.village!.isNotEmpty) {
    address += ' หมู่บ้าน${Global.branch!.village}';
  }
  if (Global.branch?.villageNo != null &&
      Global.branch!.villageNo!.isNotEmpty) {
    address += ' หมู่ที่${Global.branch!.villageNo}';
  }
  if (Global.branch?.alley != null && Global.branch!.alley!.isNotEmpty) {
    address += ' ตรอก/ซอย${Global.branch!.alley}';
  }
  if (Global.branch?.road != null && Global.branch!.road!.isNotEmpty) {
    address += ' ถนน${Global.branch!.road}';
  }

  return address.trim();
}

/// Get branch address for bills/reports - Line 2: District details
String getBillAddressLine2() {
  if (Global.branch == null) {
    return "";
  }

  String address = "";

  // Line 2: ตำบล, อำเภอ, จังหวัด, รหัสไปรษณีย์
  // Special handling for Bangkok (provinceId == 1)
  if (Global.branch?.provinceId == 1) {
    if (Global.branch?.tambonNavigation != null) {
      address += 'แขวง${Global.branch!.tambonNavigation?.nameTh}';
    }
    if (Global.branch?.amphureNavigation != null) {
      address += ' เขต${Global.branch!.amphureNavigation?.nameTh}';
    }
    if (Global.branch?.provinceNavigation != null) {
      address += ' ${Global.branch!.provinceNavigation?.nameTh}';
    }
  } else {
    if (Global.branch?.tambonNavigation != null) {
      address += 'ตำบล${Global.branch!.tambonNavigation?.nameTh}';
    }
    if (Global.branch?.amphureNavigation != null) {
      address += ' อำเภอ${Global.branch!.amphureNavigation?.nameTh}';
    }
    if (Global.branch?.provinceNavigation != null) {
      address += ' จังหวัด${Global.branch!.provinceNavigation?.nameTh}';
    }
  }

  if (Global.branch?.postalCode != null &&
      Global.branch!.postalCode!.isNotEmpty) {
    address += ' ${Global.branch!.postalCode}';
  }

  return address.trim();
}

/// Get customer address for bills/reports - Line 1: Street address only (no district details)
/// Check if customer has any address line 1 fields filled
/// (เลขที่, อาคาร, ห้องเลขที่, ชั้น, หมู่บ้าน, หมู่ที่, ตรอก/ซอย, ถนน)
bool hasAddressLine1Fields(CustomerModel customer) {
  return (customer.address != null && customer.address!.isNotEmpty) ||
      (customer.building != null && customer.building!.isNotEmpty) ||
      (customer.roomNo != null && customer.roomNo!.isNotEmpty) ||
      (customer.floor != null && customer.floor!.isNotEmpty) ||
      (customer.village != null && customer.village!.isNotEmpty) ||
      (customer.moo != null && customer.moo!.isNotEmpty) ||
      (customer.soi != null && customer.soi!.isNotEmpty) ||
      (customer.road != null && customer.road!.isNotEmpty);
}

/// Check if customer has location fields filled (province/amphure/tambon)
bool hasLocationFields(CustomerModel customer) {
  String? tambonName = customer.tambonName;
  String? amphureName = customer.amphureName;
  String? provinceName = customer.provinceName;

  // Check if location is excluded (ไม่ระบุ)
  bool isExcluded = customer.tambonId != null &&
      (customer.tambonId == 3023 ||
          customer.amphureId == 9614 ||
          customer.provinceId == 78);

  if (isExcluded) {
    return false;
  }

  return (tambonName != null && tambonName.isNotEmpty) ||
      (amphureName != null && amphureName.isNotEmpty) ||
      (provinceName != null && provinceName.isNotEmpty);
}

String getCustomerBillAddressLine1(CustomerModel customer) {
  if (customer.defaultWalkIn == 1) {
    return '';
  }

  String addressLine1 = "";

  // Build complete address line 1: เลขที่ อาคาร ห้องเลขที่ ชั้น หมู่บ้าน หมู่ที่ ตรอก/ซอย ถนน
  if (customer.address != null && customer.address!.isNotEmpty) {
    addressLine1 += 'เลขที่ ${customer.address} ';
  }

  if (customer.building != null && customer.building!.isNotEmpty) {
    addressLine1 += 'อาคาร${customer.building} ';
  }

  if (customer.roomNo != null && customer.roomNo!.isNotEmpty) {
    addressLine1 += 'เลขที่ห้อง${customer.roomNo} ';
  }

  if (customer.floor != null && customer.floor!.isNotEmpty) {
    addressLine1 += 'ชั้นที่${customer.floor} ';
  }

  if (customer.village != null && customer.village!.isNotEmpty) {
    addressLine1 += 'หมู่บ้าน${customer.village} ';
  }

  if (customer.moo != null && customer.moo!.isNotEmpty) {
    addressLine1 += 'หมู่ที่${customer.moo} ';
  }

  if (customer.soi != null && customer.soi!.isNotEmpty) {
    addressLine1 += 'ตรอก/ซอย${customer.soi} ';
  }

  if (customer.road != null && customer.road!.isNotEmpty) {
    addressLine1 += 'ถนน${customer.road} ';
  }

  return addressLine1.trim();
}

/// Get customer address for bills/reports - Line 2: District, phone, tax ID
String getCustomerBillAddressLine2(CustomerModel customer,
    {bool includePhone = true}) {
  if (customer.defaultWalkIn == 1) {
    return '';
  }

  String address = "";

  // Line 2: ตำบล, อำเภอ, จังหวัด, รหัสไปรษณีย์, เบอร์โทร
  // Use location names from API (already populated in CustomerDto)

  String? tambonName = customer.tambonName;
  String? amphureName = customer.amphureName;
  String? provinceName = customer.provinceName;

  // Build location with proper Thai prefixes
  if (customer.provinceId == 1) {
    // Bangkok: แขวง + เขต
    if (tambonName != null && tambonName.isNotEmpty) {
      address += 'แขวง$tambonName ';
    }
    if (amphureName != null && amphureName.isNotEmpty) {
      // Check if "เขต" prefix already exists in the name
      if (amphureName.startsWith('เขต')) {
        address += '$amphureName ';
      } else {
        address += 'เขต$amphureName ';
      }
    }
    if (provinceName != null && provinceName.isNotEmpty) {
      address += '$provinceName ';
    }
  } else {
    // Other provinces: ตำบล + อำเภอ + จังหวัด
    if (customer.tambonId != null &&
        (customer.tambonId == 3023 ||
            customer.amphureId == 9614 ||
            customer.provinceId == 78)) {
      // Excluded address case
    } else {
      if (tambonName != null && tambonName.isNotEmpty) {
        address += 'ตำบล$tambonName ';
      }
      if (amphureName != null && amphureName.isNotEmpty) {
        address += 'อำเภอ$amphureName ';
      }
      if (provinceName != null && provinceName.isNotEmpty) {
        address += 'จังหวัด$provinceName ';
      }
    }
  }

  // Only show postal code when location fields are selected
  // (to avoid showing "0" when province/amphure/tambon not selected)
  if (hasLocationFields(customer)) {
    if (customer.postalCode != null &&
        customer.postalCode!.isNotEmpty &&
        customer.postalCode != '0') {
      address += '${customer.postalCode} ';
    }
  }

  if (includePhone) {
    if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty) {
      address += 'โทร ${customer.phoneNumber}';
    }
  }

  // Note: Tax ID/Citizen ID is NOT included in address line 2
  // It's already shown in a separate line below the address

  return address.trim();
}

/// Get smart customer address that returns lines in correct order
/// When only location fields are filled (no address line 1 fields),
/// returns address2 as first line (ตำบล อำเภอ จังหวัด รหัสไปรษณีย์ เบอร์โทร)
/// Returns a list of address lines to display [firstLine, secondLine]
List<String> getCustomerAddressLines(CustomerModel customer,
    {bool includePhone = true}) {
  if (customer.defaultWalkIn == 1) {
    return [];
  }

  String line1 = getCustomerBillAddressLine1(customer);
  String line2 =
      getCustomerBillAddressLine2(customer, includePhone: includePhone);

  // When only location fields are filled (no address line 1 fields),
  // show address2 as the first/only line
  if (!hasAddressLine1Fields(customer) && hasLocationFields(customer)) {
    // Only location fields filled - show line2 as first line
    if (line2.isNotEmpty) {
      return [line2];
    }
    return [];
  }

  // Normal case: line1 first, then line2
  List<String> lines = [];
  if (line1.isNotEmpty) {
    lines.add(line1);
  }
  if (line2.isNotEmpty) {
    lines.add(line2);
  }
  return lines;
}

/// Check if customer has any address to display
bool hasCustomerAddress(CustomerModel customer) {
  if (customer.defaultWalkIn == 1) {
    return false;
  }
  return hasAddressLine1Fields(customer) || hasLocationFields(customer);
}

getIdTitleName(String? selectedType) {
  return selectedType == 'company'
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
  if (Global.vatSettingModel == null) {
    return 7.00 / 100.00;
  }
  var vat = Global.vatSettingModel?.vatValue ?? 7.00;
  return vat / 100.00;
}

getUnitWeightValue(int? productId) {
  // if (Global.settingValueModel == null) {
  //   return 15.16;
  // }
  // return Global.settingValueModel?.unitWeight ?? 15.16;
  if (productId == null) {
    return 15.16; // Default value for null productId
  }
  return getUnitWeightByProductId(Global.productList, productId);
}

getMaxKycValue() {
  if (Global.kycSettingModel == null) {
    return 200000.00;
  }
  return Global.kycSettingModel?.maxKycValue ?? 200000.00;
}

getTaxAmount(double? amount) {}

getTaxBase(double? amount) {}

enum ENV { PRO, DEV, UAT }

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day - 1;
  }
}

DateFormat dateFormat = DateFormat("dd-MM-yyyy");

checkDate(String date) {
  try {
    dateFormat.parseStrict(date);
    return true;
  } catch (e) {
    motivePrint(e.toString());
    return false;
  }
}

bool isCustomerAddressExcluded(CustomerModel customer) {
  return customer.tambonId == 3023 ||
      customer.amphureId == 9614 ||
      customer.provinceId == 78;
}

// Updated function to check if work ID should be shown
bool shouldShowWorkId(CustomerModel customer) {
  // Show work ID if customer is not walk-in (regardless of address)
  return customer.defaultWalkIn != 1;
}

// Updated function to get work ID value when it should be shown
String getCustomerWorkIdValue(CustomerModel customer) {
  if (!shouldShowWorkId(customer)) {
    return '';
  }

  // Always show work ID for non-walk-in customers (regardless of address)
  if (customer.nationality == 'Foreigner') {
    String permit = customer.workPermit ?? "";
    String passport = customer.passportId ?? "";
    String tax = customer.taxNumber ?? "";
    List<String> parts = [];
    if (permit.isNotEmpty) parts.add('Work permit: $permit');
    if (passport.isNotEmpty) parts.add('Passport: $passport');
    if (tax.isNotEmpty) parts.add('Tax ID: $tax');
    return parts.join(' ');
  } else {
    if (customer.customerType == 'company') {
      String companyId = customer.taxNumber ?? customer.idCard ?? "";
      return companyId.isNotEmpty ? companyId : "";
    }
    return customer.idCard ?? "";
  }
}

// Updated getWorkId function (if this exists elsewhere)
String getWorkId(CustomerModel customer, {bool forOldGoldGov = false}) {
  if (!shouldShowWorkId(customer)) {
    return getWorkIdTitleOnly(customer, forOldGoldGov: forOldGoldGov);
  }

  if (customer.nationality != 'Thai') {
    // For foreigners (any nationality that is not Thai), show all fields on single line if available
    List<String> ids = [];
    bool isCompany = customer.customerType == 'company';

    if (customer.taxNumber != null && customer.taxNumber!.isNotEmpty) {
      // For foreigner companies, use Thai label "เลขประจำตัวผู้เสียภาษี"
      // For foreigner individuals, use "Tax ID"
      String taxLabel = isCompany ? 'เลขประจำตัวผู้เสียภาษี' : 'Tax ID';
      ids.add('$taxLabel : ${customer.taxNumber}');
    }

    if (customer.workPermit != null && customer.workPermit!.isNotEmpty) {
      ids.add('Work Permit : ${customer.workPermit}');
    }

    if (customer.passportId != null && customer.passportId!.isNotEmpty) {
      ids.add('Passport ID : ${customer.passportId}');
    }

    // If no IDs, return empty title
    if (ids.isEmpty) {
      return getWorkIdTitleOnly(customer, forOldGoldGov: forOldGoldGov);
    }

    // Join with space for single line display
    return forOldGoldGov ? ids.join('\n') : ids.join(' ');
  } else {
    String workId = getCustomerWorkIdValue(customer);
    if (workId.isEmpty) {
      return getWorkIdTitleOnly(customer, forOldGoldGov: forOldGoldGov);
    }

    if (customer.customerType == 'company') {
      // For companies, show Tax ID and Branch Code
      String result =
          '${forOldGoldGov ? "Tax ID" : "เลขประจำตัวผู้เสียภาษี"} : $workId';

      // if (forOldGoldGov == false) {
      //   // Add branch code if available
      //   if (customer.branchCode != null && customer.branchCode!.isNotEmpty) {
      //     result += ' สาขา ${customer.branchCode}';
      //   } else {
      //     // Default to "00000" for head office if no branch code
      //     result += ' สาขา 00000';
      //   }
      // }

      return result;
    }
    return '${forOldGoldGov ? "Tax ID" : "เลขประจำตัวประชาชน"} : $workId';
  }
}

// Keep the existing getWorkIdTitleOnly function as is
String getWorkIdTitleOnly(CustomerModel customer,
    {bool forOldGoldGov = false}) {
  if (customer.nationality != 'Thai') {
    // For foreigners (any nationality that is not Thai)
    bool isCompany = customer.customerType == 'company';
    // For foreigner companies, use Thai label "เลขประจำตัวผู้เสียภาษี"
    String taxLabel = isCompany ? 'เลขประจำตัวผู้เสียภาษี' : 'Tax ID';
    return forOldGoldGov
        ? '$taxLabel : \nWork Permit : \nPassport ID : '
        : '$taxLabel : Work Permit : Passport ID : ';
  } else {
    if (customer.customerType == 'company') {
      return '${forOldGoldGov ? "Tax ID" : "เลขประจำตัวผู้เสียภาษี"} : ';
    }
    return '${forOldGoldGov ? "Tax ID" : "เลขประจำตัวประชาชน"} : ';
  }
}

// Updated function to get customer display address
String getCustomerDisplayAddress(CustomerModel customer) {
  if (customer.defaultWalkIn == 1 ||
      customer.address == null ||
      customer.address!.isEmpty) {
    return '';
  }
  return customer.address!;
}

getCustomerName(CustomerModel customer, {bool forReport = false}) {
  if (customer.customerType == 'company') {
    // For companies
    String companyName = customer.companyName ?? '';
    bool hasBranchCode = customer.branchCode != null &&
        customer.branchCode!.isNotEmpty &&
        customer.branchCode != '00000';
    bool hasEstablishmentName = customer.establishmentName != null &&
        customer.establishmentName!.isNotEmpty;

    // Check if this is head office using the headquartersOrBranch field
    bool isHeadOffice = customer.headquartersOrBranch == 'head';

    // HEAD OFFICE: Always show (สำนักงานใหญ่)
    if (isHeadOffice) {
      return '$companyName (สำนักงานใหญ่)';
    }

    // BRANCH: Check if has branch code
    if (hasBranchCode) {
      // Branch with code: "บริษัท ห้างทองมนวาท จำกัด สาขาที่(00004) "ร้านทองสกุลพงษ์""
      String branchName = customer.establishmentName ?? "";
      if (!hasEstablishmentName) {
        return '$companyName สาขาที่(${customer.branchCode})';
      }
      return '$companyName สาขาที่(${customer.branchCode}) ${forReport ? '' : '"$branchName"'}';
    } else {
      // Branch without code: Show company name with establishment name in quotes (if available)
      if (hasEstablishmentName) {
        return '$companyName "${customer.establishmentName}"';
      }
      // Branch without code and no establishment name: show only company name
      return companyName;
    }
  }

  // For individuals
  String name = '';

  // Add title if available
  if (customer.titleName != null && customer.titleName!.isNotEmpty) {
    name += '${customer.titleName}';
  }

  // Add first name
  if (customer.firstName != null && customer.firstName!.isNotEmpty) {
    name += '${customer.firstName} ';
  }

  // Add middle name if available
  if (customer.middleName != null && customer.middleName!.isNotEmpty) {
    name += '${customer.middleName} ';
  }

  // Add last name
  if (customer.lastName != null && customer.lastName!.isNotEmpty) {
    name += '${customer.lastName}';
  }

  return name.trim();
}

getCustomerNameForBillSign(CustomerModel customer, {bool forReport = false}) {
  if (customer.customerType == 'company') {
    // For companies: Always show company name (ชื่อผู้ประกอบการ) because signature area is small
    return customer.companyName ?? '';
  }

  // For individuals
  String name = '';

  // Add title if available
  if (customer.titleName != null && customer.titleName!.isNotEmpty) {
    name += '${customer.titleName}';
  }

  // Add first name
  if (customer.firstName != null && customer.firstName!.isNotEmpty) {
    name += '${customer.firstName} ';
  }

  // Add middle name if available
  if (customer.middleName != null && customer.middleName!.isNotEmpty) {
    name += '${customer.middleName} ';
  }

  // Add last name
  if (customer.lastName != null && customer.lastName!.isNotEmpty) {
    name += '${customer.lastName}';
  }

  return name.trim();
}

// Get customer name for wholesale reports that have branch code column
// For companies: returns ONLY companyName (ชื่อผู้ประกอบการ)
// For individuals: returns full name as normal
String getCustomerNameForWholesaleReports(CustomerModel customer) {
  if (customer.customerType == 'company') {
    // For companies: Show only company name (ชื่อผู้ประกอบการ)
    // Do NOT show สำนักงานใหญ่ or ชื่อสถานประกอบการ
    return customer.companyName ?? '';
  }

  // For individuals, return full name
  String name = '';
  if (customer.titleName != null && customer.titleName!.isNotEmpty) {
    name += '${customer.titleName}';
  }
  if (customer.firstName != null && customer.firstName!.isNotEmpty) {
    name += '${customer.firstName} ';
  }
  if (customer.lastName != null && customer.lastName!.isNotEmpty) {
    name += customer.lastName!;
  }
  return name.trim();
}

// Get customer name for reports (specific to 6 reports that need establishment name only)
// For companies: returns establishment name only
// For individuals: returns full name as normal
String getCustomerNameForReports(CustomerModel customer) {
  if (customer.customerType == 'company') {
    // For companies
    String companyName = customer.companyName ?? '';
    bool hasBranchCode = customer.branchCode != null &&
        customer.branchCode!.isNotEmpty &&
        customer.branchCode != '00000';
    bool hasEstablishmentName = customer.establishmentName != null &&
        customer.establishmentName!.isNotEmpty;

    // Check if this is head office using the headquartersOrBranch field
    bool isHeadOffice = customer.headquartersOrBranch == 'head';

    // HEAD OFFICE: Always show (สำนักงานใหญ่)
    if (isHeadOffice) {
      return '$companyName (สำนักงานใหญ่)';
    }

    // BRANCH: Check if has branch code
    if (hasBranchCode) {
      // Branch with code: "บริษัท ห้างทองมนวาท จำกัด สาขาที่(00004) "ร้านทองสกุลพงษ์""
      String branchName = customer.establishmentName ?? "";
      if (!hasEstablishmentName) {
        return '$companyName สาขาที่(${customer.branchCode})';
      }
      return '$companyName สาขาที่(${customer.branchCode}) "$branchName"';
    } else {
      // Branch without code: Show company name with establishment name in quotes (if available)
      if (hasEstablishmentName) {
        return '$companyName "${customer.establishmentName}"';
      }
      // Branch without code and no establishment name: show only company name
      return companyName;
    }
  }

  // For individuals, use same logic as getCustomerName
  String name = '';

  if (customer.titleName != null && customer.titleName!.isNotEmpty) {
    name += '${customer.titleName}';
  }

  if (customer.firstName != null && customer.firstName!.isNotEmpty) {
    name += '${customer.firstName} ';
  }

  if (customer.middleName != null && customer.middleName!.isNotEmpty) {
    name += '${customer.middleName} ';
  }

  if (customer.lastName != null && customer.lastName!.isNotEmpty) {
    name += '${customer.lastName}';
  }

  return name.trim();
}

// Get customer branch code for reports
// Returns branch code or "00000" for head office
String getCustomerBranchCode(CustomerModel customer) {
  if (customer.customerType == 'company') {
    if (customer.branchCode != null &&
        customer.branchCode!.isNotEmpty &&
        customer.branchCode != '00000') {
      return customer.branchCode!;
    } else {
      if (customer.headquartersOrBranch == 'branch' &&
          (customer.branchCode != null || customer.branchCode!.isNotEmpty)) {
        return ''; // Branch without code
      }
      return '00000'; // Head office
    }
  }
  return ''; // Not applicable for individuals
}

getRefillAttachment() {
  if (!kIsWeb && Global.refillAttach != null) {
    return Global.imageToBase64(Global.refillAttach!);
  }

  if (kIsWeb && Global.refillAttachWeb != null) {
    return Global.refillAttachWeb;
  }
}

getSellUsedAttachment() {
  if (!kIsWeb && Global.sellUsedAttach != null) {
    return Global.imageToBase64(Global.sellUsedAttach!);
  }

  if (kIsWeb && Global.sellUsedAttachWeb != null) {
    return Global.sellUsedAttachWeb;
  }
}

getRefillThengAttachment() {
  if (!kIsWeb && Global.refillThengAttach != null) {
    return Global.imageToBase64(Global.refillThengAttach!);
  }

  if (kIsWeb && Global.refillThengAttachWeb != null) {
    return Global.refillThengAttachWeb;
  }
}

getSellUsedThengAttachment() {
  if (!kIsWeb && Global.sellUsedThengAttach != null) {
    return Global.imageToBase64(Global.sellUsedThengAttach!);
  }

  if (kIsWeb && Global.sellUsedThengAttachWeb != null) {
    return Global.sellUsedThengAttachWeb;
  }
}

double addDisValue(double discount, double addPrice) {
  return addPrice - discount;
}

Widget buildMiniButton(String text) {
  return Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 1,
          offset: Offset(0, 0.5),
        ),
      ],
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 6,
          fontWeight: FontWeight.bold,
          color: Color(0xFF667eea),
        ),
      ),
    ),
  );
}
