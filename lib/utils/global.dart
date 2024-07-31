import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/gold_data.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/request.dart';
import 'package:motivegold/model/transfer_detail.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/util.dart';

import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/model/user.dart';

enum UserState {
  Offline,
  Online,
  Waiting,
}

class Global {
  static final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
  static String phonePrefix = "856";
  static final List<int> _startWith = [2, 4, 5, 7, 9];
  static String? profileUrl;
  static UserModel? user;
  static String? userId;
  static bool isLoggedIn = false;
  static int? lang;
  static GoldDataModel? goldDataModel;
  static List<OrderDetailModel>? orderDetail = [];
  static List<OrderModel>? orders = [];
  static OrderModel? order;
  static List<String>? orderIds = [];
  static int? pairId;
  static String? trackingNumber;

  // POS
  static List<OrderDetailModel>? sellOrderDetail = [];
  static List<OrderDetailModel>? buyThengOrderDetail = [];
  static List<OrderDetailModel>? sellThengOrderDetail = [];
  static List<OrderDetailModel>? buyOrderDetail = [];
  static OrderModel? posOrder;
  static int posIndex = 0;

  static List<OrderDetailModel>? refillOrderDetail = [];
  static List<OrderDetailModel>? usedSellDetail = [];
  static List<TransferDetailModel>? transferDetail = [];
  static TransferModel? transfer;

  static double sellSubTotal = 0;
  static double sellWeightTotal = 0;
  static double sellTax = 0;
  static double sellTotal = 0;

  static double buyThengSubTotal = 0;
  static double buyThengWeightTotal = 0;
  static double buyThengTax = 0;
  static double buyThengTotal = 0;

  static double sellThengSubTotal = 0;
  static double sellThengWeightTotal = 0;
  static double sellThengTax = 0;
  static double sellThengTotal = 0;

  static double buySubTotal = 0;
  static double buyWeightTotal = 0;
  static double buyTax = 0;
  static double buyTotal = 0;

  static double discount = 0;
  static CustomerModel? customer;
  static CompanyModel? company;
  static BranchModel? branch;

  // DEVICE
  static String? brand;
  static String? model;
  static String? deviceId;
  static String? platform;
  static String? platformVersion;
  static dynamic deviceDetail;

  static format(double value) {
    String number = formatter.format(value);
    var part = number.split('.');
    if (part.length > 1) {
      if (part[1].length == 1) {
        return '${number}0';
      }
      return number;
    } else {
      return '$number.00';
    }
  }

  static holdOrder(OrderModel orderModel) async {
    String? json = await LocalStorage.sharedInstance.readValue('holds');
    List<OrderModel>? holds = json == null ? [] : orderListModelFromJson(json);
    holds.add(orderModel);
    LocalStorage.sharedInstance
        .writeValue(key: 'holds', value: orderListModelToJson(holds));
    if (kDebugMode) {
      print(orderModel.toJson());
    }
  }

  static clearHold() async {
    LocalStorage.sharedInstance
        .writeValue(key: 'holds', value: orderListModelToJson([]));
  }

  static Future<List<OrderModel>> getHoldList() async {
    String? json = await LocalStorage.sharedInstance.readValue('holds');
    List<OrderModel>? orders = json == null ? [] : orderListModelFromJson(json);
    return orders;
  }

  static removeHold(int i) async {
    String? json = await LocalStorage.sharedInstance.readValue('holds');
    List<OrderModel>? orders = json == null ? [] : orderListModelFromJson(json);
    orders.removeAt(i);
    LocalStorage.sharedInstance
        .writeValue(key: 'holds', value: orderListModelToJson(orders));
  }

  // GET BATH/GRAM
  static double bathPerGram() {
    if (goldDataModel == null) {
      return 0;
    }
    double taxRate = toNumber(goldDataModel!.paphun!.buy!);
    return taxRate / 15.16;
  }

  static double getSellPriceTotal(double weight, double commission) {
    if (goldDataModel == null) {
      return 0;
    }
    return (toNumber(goldDataModel!.theng!.sell!) * weight / 15.16) +
        commission;
  }

  static double taxBase(double grandTotal, double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return (grandTotal - (weight * bathPerGram())) * 100 / 107;
  }

  static double taxAmount(double taxBase) {
    return taxBase * 0.07;
  }

  static double getSellPrice(double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.theng!.sell!) * weight / 15.16;
  }

  static double getBuyPrice(double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.paphun!.buy!) * weight / 15.16;
  }

  static double getBuyThengPrice(double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.theng!.buy!) * weight / 15.16;
  }

  static double getSellThengPrice(double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.theng!.sell!) * weight / 15.16;
  }

  static double getOrderSubTotalAmount() {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders!.length; i++) {
      for (int j = 0; j < orders![i].details!.length; j++) {
        amount += orders![i].details![j].priceIncludeTax!;
      }
    }
    return amount;
  }

  static double getOrderSubTotalAmountApi(List<OrderDetailModel>? details) {
    if (details!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < details.length; j++) {
      amount += details[j].priceIncludeTax!;
    }
    return amount;
  }

  static double getOrderWeightTotalAmount() {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders!.length; i++) {
      for (int j = 0; j < orders![i].details!.length; j++) {
        amount += orders![i].details![j].weight!;
      }
    }
    return amount;
  }

  static double getOrderWeightTotalAmountApi(List<OrderDetailModel>? details) {
    if (details!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < details.length; j++) {
      amount += details[j].weight!;
    }
    return amount;
  }

  static double getRefillWeightTotalAmount() {
    if (refillOrderDetail!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < refillOrderDetail!.length; i++) {
      amount += refillOrderDetail![i].weight!;
    }
    return amount;
  }

  static double getUsedSellWeightTotalAmount() {
    if (usedSellDetail!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < usedSellDetail!.length; i++) {
      amount += usedSellDetail![i].weight!;
    }
    return amount;
  }

  static double getUsedSellWeightTotalAmountApi(
      List<OrderDetailModel>? details) {
    if (details!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < details.length; i++) {
      amount += details[i].weight!;
    }
    return amount;
  }

  static double getTransferWeightTotalAmount() {
    if (transferDetail!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < transferDetail!.length; i++) {
      amount += transferDetail![i].weight!;
    }
    return amount;
  }

  static double getOrderGrantTotalAmount(double subTotal, double weightTotal) {
    return subTotal + weightTotal;
  }

  static double getOrderGrantTotalAmountApi(double subTotal, double? discount) {
    discount ??= 0;
    return subTotal - discount;
  }

  static double getPaymentTotal() {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders!.length; i++) {
      for (int j = 0; j < orders![i].details!.length; j++) {
        double price = orders![i].details![j].priceIncludeTax!;
        int type = orders![i].orderTypeId!;
        if (type == 2) {
          price = -price;
        }
        amount += price;
      }
    }
    amount = discount != 0 ? amount - discount : amount;
    return amount < 0 ? -amount : amount;
  }

  static double getOrderTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double price = order.details![j].priceIncludeTax!;
      int type = order.orderTypeId!;
      if (type == 2) {
        price = -price;
      }
      amount += price;
    }

    // amount = discount != 0 ? amount - discount : amount;
    return amount < 0 ? -amount : amount;
  }

  static double getPapunTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double weight = order.details![j].weight!;
      amount += weight;
    }

    amount = getBuyPrice(amount);
    return amount;
  }

  static double getThengTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double weight = order.details![j].weight!;
      amount += weight;
    }

    amount = getBuyThengPrice(amount);
    return amount;
  }

  static dynamic payToCustomerOrShop() {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    double buy = 0;
    double sell = 0;
    for (int i = 0; i < orders!.length; i++) {
      for (int j = 0; j < orders![i].details!.length; j++) {
        double price = orders![i].details![j].priceIncludeTax!;
        int type = orders![i].orderTypeId!;
        if (type == 2 || type == 5) {
          buy += -price;
        }
        if (type == 1 || type == 6) {
          sell += price;
        }
      }
    }
    amount = sell + buy;

    amount = discount != 0 ? amount - discount : amount;
    return amount > 0
        ? 'ลูกค้าจ่ายเงินให้กับเรา ${formatter.format(amount)} THB'
        : amount == 0 ? 0 : 'เราจ่ายเงินให้กับลูกค้า ${formatter.format(-amount)} THB';
  }

  static dynamic payToBrokerOrShop() {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    double buy = 0;
    double sell = 0;
    for (int i = 0; i < orders!.length; i++) {
      for (int j = 0; j < orders![i].details!.length; j++) {
        double price = orders![i].details![j].priceIncludeTax!;
        int type = orders![i].orderTypeId!;
        if (type == 2 || type == 5) {
          buy += -price;
        }
        if (type == 1 || type == 6) {
          sell += price;
        }
      }
    }
    amount = sell + buy;

    amount = discount != 0 ? amount - discount : amount;
    return amount > 0
        ? 'โบรกเกอร์จ่ายเงินให้กับเรา ${formatter.format(amount)} THB'
        : amount == 0 ? 0 : 'เราจ่ายเงินให้กับโบรกเกอร์ ${formatter.format(-amount)} THB';
  }

  static double getOrderTotalAmount(List<OrderDetailModel> data) {
    if (data.isEmpty) {
      return 0;
    }
    double sum = 0;
    for (var e in data) {
      sum += e.priceIncludeTax!;
    }
    return sum;
  }

  static double getOrderTotalWeight(List<OrderDetailModel> data) {
    if (data.isEmpty) {
      return 0;
    }
    double sum = 0;
    for (var e in data) {
      sum += e.weight!;
    }
    return sum;
  }

  static convertImageListToBase64(List<File> files) {
    List<dynamic> result;
    result = files.map((e) => imageToBase64(e)).toList();
    return result;
  }

  static imageToBase64(File file) {
    final bytes = File(file.path).readAsBytesSync();
    return base64Encode(bytes);
  }

  static u8ListToBase64(Uint8List image) {
    // base64 encode the bytes
    String base64String = base64.encode(image);
    return base64String;
  }

  static getServiceBackgroundColor(String color) {
    final object = color.split('#');
    return object[1].toUpperCase();
  }

  static String getProductName(lang, name) {
    if (lang == null || lang == "") return name;
    return lang;
  }

  static getProductPrice(price, discount, deliveryFee, qty) {
    if (toNumber(discount) > 0) {
      return ((toNumber(price) * toNumber(qty))) -
          (toNumber(discount) * toNumber(qty));
    }
    return (toNumber(price) * toNumber(qty));
  }

  static getLanguageName({value = ''}) {
    switch (lang) {
      case 0:
        return value;
      case 1:
        return value + '_lao';
      case 2:
        return value + '_chinese';
      case 3:
        return value + '_vietnamese';
      default:
        return value + '_lao';
    }
  }

  static getProvinceDistrictName(String name) {
    var name0 = name.split('(');
    if (lang == 0) {
      return name0[0];
    } else {
      return name0[1].split(')')[0];
    }
  }

  static getFullName(String firstName, String lastName) {
    return '$firstName $lastName';
  }

  static String prettyPrint(Map json) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  static printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(text)
        .forEach((RegExpMatch match) => motivePrint(match.group(0)));
  }

  static renderWorkDay(List<bool> workday) {
    List<String> weekDay = [];
    for (var i = 0; i < workday.length; i++) {
      if (workday[i] == true) {
        weekDay.add(weekday(i));
      }
    }
    return weekDay.map((e) => e).join(', ');
  }

  static weekday(int i) {
    switch (i) {
      case 0:
        return 'Mon';
      case 1:
        return 'Tue';
      case 2:
        return 'Wed';
      case 3:
        return 'Thu';
      case 4:
        return 'Fri';
      case 5:
        return 'Sat';
      case 6:
        return 'Sun';
    }
  }

  static String? renderStatus(String status) {
    return null;
  }

  static String firePhone(String phone) {
    return "+${getPhone(phone)}";
  }

  static String getPhone(String phone) {
    if (phone.startsWith("020") || phone.startsWith("030")) {
      return phonePrefix + phone.substring(1);
    } else if (phone.startsWith("85620") || phone.startsWith("85630")) {
      return phone;
    } else if (phone.startsWith("20") || phone.startsWith("30")) {
      if (phone.length == 8) {
        return "${phonePrefix}20$phone";
      } else if (phone.length == 7) {
        return "${phonePrefix}30$phone";
      } else {
        return phonePrefix + phone;
      }
    } else if (phone.startsWith("2") ||
        phone.startsWith("4") ||
        phone.startsWith("5") ||
        phone.startsWith("7") ||
        phone.startsWith("9")) {
      if (phone.length == 8) {
        return "${phonePrefix}20$phone";
      } else if (phone.length == 7) {
        return "${phonePrefix}30$phone";
      } else {
        return phonePrefix;
      }
    }
    return phone;
  }

  static bool validatePhone(String phone) {
    if (!checkPhone(phone)) {
      if (phone.startsWith("20")) {
        return phone.length == 8
            ? startWiths(phone)
            : phone.length == 10
                ? startWiths(phone.substring(2))
                : checkPhone(phone);
      } else if (phone.startsWith("020")) {
        return phone.length == 11 ? checkPhone(phone) : false;
      } else if (phone.startsWith("85620")) {
        return phone.length == 13 ? checkPhone(phone) : false;
      } else if (phone.length != 8 ||
          phone.length != 11 ||
          phone.length != 13) {
        return false;
      } else {
        return checkPhone(phone);
      }
    } else {
      return true;
    }
  }

  static bool checkPhone(String phone) {
    if (phone.length == 8) {
      return startWiths(phone);
    } else if (phone.length == 10) {
      if (phone.startsWith("20")) {
        return startWiths(phone.substring(2));
      } else {
        // Check 030
        if (phone.startsWith("030")) {
          return startWiths(phone.substring(3));
        }
        return false;
      }
    } else if (phone.length == 11) {
      return phone.startsWith("020") ? startWiths(phone.substring(3)) : false;
    } else if (phone.length == 13) {
      return phone.startsWith("85620") ? startWiths(phone.substring(5)) : false;
    } else {
      // Check 030 Phone Number
      if (phone.length == 12) {
        return phone.startsWith("85630")
            ? startWiths(phone.substring(5))
            : false;
      }
      if (phone.length == 9) {
        if (phone.startsWith("30")) return startWiths(phone.substring(2));
      }
      if (phone.length == 7) {
        return startWiths(phone);
      }
      return false;
    }
  }

  static bool startWiths(String phone) {
    final data = int.parse(phone.substring(0, 1));
    for (var i = 0; i < _startWith.length; i++) {
      if (_startWith[i] == data) {
        return true;
      }
    }
    return false;
  }

  static int getStartWith(String phone) {
    final data = int.parse(phone.substring(0, 1));
    for (var i = 0; i < _startWith.length; i++) {
      if (_startWith[i] == data) {
        return _startWith[i];
      }
    }
    return 0;
  }

  static String showPhone(String phone) {
    return getPhone(phone).substring(3);
  }

  static String displayPhone(String phone) {
    return '0${getPhone(phone).substring(3)}';
  }

  static double toNumber(String num) {
    return double.parse(num.replaceAll(",", ""));
  }

  static String formatDate(String date) {
    DateTime tempDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(tempDate);
  }

  static String formatDateT(String date) {
    DateTime tempDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(tempDate);
  }

  static String monthYear(String date) {
    DateTime tempDate = DateTime.parse(date);
    return DateFormat('MMM yyyy').format(tempDate);
  }

  static String dateOnly(String date) {
    DateTime tempDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(tempDate);
  }

  static String timeAndSec(String date) {
    DateTime tempDate = DateTime.parse(date);
    return DateFormat('HH:mm:ss').format(tempDate);
  }

  static String timeOnly(String date) {
    DateTime tempDate = DateTime.parse(date);
    return DateFormat('HH:mm').format(tempDate);
  }

  static double removeDecimalZeroFormat(int n) {
    return double.parse(n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1));
  }

  static List<int> genYear() {
    List<int> years = [];
    int currentYear = DateTime.now().year;
    years.add(currentYear);
    for (int i = 0; i < 10; i++) {
      currentYear = currentYear - 1;
      years.add(currentYear);
    }
    return years;
  }

  static List<int> genMonth() {
    List<int> months = [];
    for (int i = 1; i <= 12; i++) {
      months.add(i);
    }
    return months;
  }

  static String genId() {
    Random rnd = Random();
    // Define min and max value
    int min = 1000000, max = 99999999;
    //Getting range
    int num = min + rnd.nextInt(max - min);
    return num.toString();
  }

  static bool validateEmail(email) {
    bool emailValid = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
    if (emailValid) {
      return true;
    } else {
      return false;
    }
  }

  static bool checkBool(value) {
    if (value != null) return value;
    return false;
  }

  static getDiscountPercentage(double price, double discount) {
    return (100 * discount / price).round();
  }

  static getDeliveryFee(double deliveryFee, int qty) {
    double totalDeliveryFee = 0;
    for (var i = 1; i <= qty; i++) {
      totalDeliveryFee += deliveryFee * (1 / i);
    }
    return totalDeliveryFee.roundToDouble();
  }

  static double getTotalWeightByLocation(
      List<QtyLocationModel> qtyLocationList) {
    double total = 0;
    for (var i = 0; i < qtyLocationList.length; i++) {
      total += qtyLocationList[i].weight!;
    }
    return total;
  }

  static String prefixName(int index) {
    switch (index) {
      case 1:
        return "Month";
      case 2:
        return "Year";
      default:
        return "Year";
    }
  }

  static int prefixIndex(String name) {
    switch (name) {
      case "Month":
        return 1;
      case "Year":
        return 2;
      default:
        return 2;
    }
  }

  static String requestObj(dynamic data,
      {status = "", message = "", token = ""}) {
    return encoder.convert(RequestModel(
        companyId: user == null ? 0 : user!.companyId,
        branchId: user == null ? 0 : user!.branchId,
        userId: user == null ? 0.toString() : user!.id,
        data: data,
        status: status,
        token: token,
        message: message));
  }
}
