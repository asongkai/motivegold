import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motivegold/model/bank/bank.dart';
import 'package:motivegold/model/bank/bank_account.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/gold_data.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/model/master/setting_value.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/order_type.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/request.dart';
import 'package:motivegold/model/transfer_detail.dart';
import 'package:motivegold/screen/pos/storefront/paphun/bill/make_bill.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/util.dart';

import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/model/user.dart';
import 'package:path_provider/path_provider.dart';

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

  /*
  * 1 is use for sell new gold and buy use gold
  * 2 is use for buy and sell gold bar matching
  * 3 is use for buy and sell gold bar real
  * 4 is use for buy and sell gold bar with broker
  * 5 is use for buy new gold and sell used gold with wholesale
  * 6 is use for buy new and sell used gold bar with wholesale
  * 7 is use for redeem and sell gold
  * */
  static int currentOrderType = 1;

  /*
  * 1 is for redeem single
  * */
  static int currentRedeemType = 1;

  static String? checkOutMode = "";

  static List<OrderModel> orders = [];
  static OrderModel? order;

  static List<OrderModel>? ordersPapun = [];
  static OrderModel? orderPapun;

  static List<OrderModel>? ordersThengMatching = [];
  static OrderModel? orderThengMatching;

  static List<OrderModel>? ordersTheng = [];
  static OrderModel? orderTheng;

  static List<OrderModel>? ordersBroker = [];
  static OrderModel? orderBroker;

  static List<OrderModel>? ordersWholesale = [];
  static OrderModel? orderWholesale;

  static List<OrderModel>? ordersThengWholesale = [];
  static OrderModel? orderThengWholesale;

  static List<OrderModel>? ordersTransfer = [];
  static OrderModel? orderTransfer;

  static List<RedeemModel> redeems = [];
  static RedeemModel? redeem;

  static List<String>? orderIds = [];
  static int? pairId;
  static String? trackingNumber;

  static File? refillAttach;
  static String? refillAttachWeb;
  static File? sellUsedAttach;
  static String? sellUsedAttachWeb;

  static File? refillThengAttach;
  static File? sellUsedThengAttach;
  static String? refillThengAttachWeb;
  static String? sellUsedThengAttachWeb;

  // PAYMENT
  static String? currentPaymentMethod;

  static File? paymentAttachment;
  static String? paymentAttachmentWeb;

  static ProductTypeModel? selectedPayment;
  static TextEditingController bankCtrl = TextEditingController();
  static TextEditingController accountNoCtrl = TextEditingController();
  static TextEditingController refNoCtrl = TextEditingController();
  static TextEditingController cardNameCtrl = TextEditingController();
  static TextEditingController cardNumberCtrl = TextEditingController();
  static TextEditingController cardExpireDateCtrl = TextEditingController();
  static TextEditingController paymentDetailCtrl = TextEditingController();
  static TextEditingController paymentDateCtrl = TextEditingController();
  static TextEditingController amountCtrl = TextEditingController();
  static BankModel? selectedBank;
  static BankAccountModel? selectedAccount;

  // POS
  static List<OrderDetailModel>? sellOrderDetail = [];
  static List<OrderDetailModel>? buyOrderDetail = [];

  static List<OrderDetailModel>? buyThengOrderDetail = [];
  static List<OrderDetailModel>? sellThengOrderDetail = [];

  static List<OrderDetailModel>? buyThengOrderDetailMatching = [];
  static List<OrderDetailModel>? sellThengOrderDetailMatching = [];

  static List<OrderDetailModel>? buyThengOrderDetailBroker = [];
  static List<OrderDetailModel>? sellThengOrderDetailBroker = [];

  static List<OrderDetailModel>? refillOrderDetail = [];
  static List<OrderDetailModel>? usedSellDetail = [];
  static List<TransferDetailModel>? transferDetail = [];
  static TransferModel? transfer;

  static List<OrderDetailModel>? refillThengOrderDetail = [];
  static List<OrderDetailModel>? sellUsedThengOrderDetail = [];

  // Redeem
  static List<RedeemDetailModel>? redeemSingleDetail = [];

  static OrderModel? posOrder;
  static int posIndex = 0;

  static double sellSubTotal = 0;
  static double sellWeightTotal = 0;
  static double sellTax = 0;
  static double sellTotal = 0;

  static double buySubTotal = 0;
  static double buyWeightTotal = 0;
  static double buyTax = 0;
  static double buyTotal = 0;

  static double buyThengSubTotal = 0;
  static double buyThengWeightTotal = 0;
  static double buyThengTax = 0;
  static double buyThengTotal = 0;

  static double sellThengSubTotal = 0;
  static double sellThengWeightTotal = 0;
  static double sellThengTax = 0;
  static double sellThengTotal = 0;

  static double buyThengSubTotalMatching = 0;
  static double buyThengWeightTotalMatching = 0;
  static double buyThengTaxMatching = 0;
  static double buyThengTotalMatching = 0;

  static double sellThengSubTotalMatching = 0;
  static double sellThengWeightTotalMatching = 0;
  static double sellThengTaxMatching = 0;
  static double sellThengTotalMatching = 0;

  static double buyThengSubTotalBroker = 0;
  static double buyThengWeightTotalBroker = 0;
  static double buyThengTaxBroker = 0;
  static double buyThengTotalBroker = 0;

  static double sellThengSubTotalBroker = 0;
  static double sellThengWeightTotalBroker = 0;
  static double sellThengTaxBroker = 0;
  static double sellThengTotalBroker = 0;

  static double addPrice = 0;
  static double discount = 0;
  static CustomerModel? customer;
  static CompanyModel? company;
  static BranchModel? branch;

  static ValueNotifier<dynamic>? branchNotifier = ValueNotifier<BranchModel>(
      branch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
  static ValueNotifier<dynamic>? companyNotifier = ValueNotifier<CompanyModel>(
      company ?? CompanyModel(id: 0, name: 'เลือกบริษัท'));

  // DEVICE
  static String? brand;
  static String? model;
  static String? deviceId;
  static String? platform;
  static String? platformVersion;
  static dynamic deviceDetail;

  static PaymentModel? payment;
  static List<PaymentModel>? paymentList = [];
  static List<BankModel> bankList = [];
  static List<BankAccountModel> accountList = [];
  static List<BankAccountModel> filterAccountList = [];
  static List<OrderTypeModel> orderTypes = [];

  static List<ProvinceModel> provinceList = [];
  static List<AmphureModel> amphureList = [];
  static List<TambonModel> tambonList = [];

  static ProvinceModel? provinceModel;
  static AmphureModel? amphureModel;
  static TambonModel? tambonModel;

  static ValueNotifier<dynamic>? provinceNotifier;
  static ValueNotifier<dynamic>? amphureNotifier;
  static ValueNotifier<dynamic>? tambonNotifier;
  static TextEditingController addressCtrl = TextEditingController();
  static TextEditingController villageCtrl = TextEditingController();

  static Color? appBarColor;

  static List<BranchModel> branchList = [];
  static List<CompanyModel> companyList = [];

  static PosIdModel? posIdModel;

  static SettingsValueModel? settingValueModel;

  static ifInt(dynamic value) {
    if (value is int) {
      return true;
    }
    return false;
  }

  static formatInt(dynamic value) {
    String number = formatter.format(value);
    return number;
  }

  static format(dynamic value) {
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

  static format4(dynamic value) {
    String number = formatter4.format(value);
    var part = number.split('.');
    if (part.length > 1) {
      if (part[1].length == 1) {
        return '${number}000';
      }
      if (part[1].length == 2) {
        return '${number}00';
      }
      if (part[1].length == 3) {
        return '${number}0';
      }
      return number;
    } else {
      return '$number.0000';
    }
  }

  static format6(dynamic value) {
    String number = formatter6.format(value);
    var part = number.split('.');
    if (part.length > 1) {
      if (part[1].length == 1) {
        return '${number}00000';
      }
      if (part[1].length == 2) {
        return '${number}0000';
      }
      if (part[1].length == 3) {
        return '${number}000';
      }
      if (part[1].length == 4) {
        return '${number}00';
      }
      if (part[1].length == 5) {
        return '${number}0';
      }
      return number;
    } else {
      return '$number.000000';
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
    return taxRate / getUnitWeightValue();
  }

  static double getSellPriceTotal(double weight, double commission) {
    if (goldDataModel == null) {
      return 0;
    }
    return (toNumber(goldDataModel!.theng!.sell!) *
            weight /
            getUnitWeightValue()) +
        commission;
  }

  static double taxBase(double grandTotal, double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return (grandTotal - (weight * bathPerGram())) * 100 / 107;
  }

  static double taxAmount(double taxBase) {
    return taxBase * getVatValue();
  }

  static double getSellPrice(double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.theng!.sell!) *
        weight /
        getUnitWeightValue();
  }

  static double getSellPriceUsePrice(double weight, double price) {
    if (goldDataModel == null) {
      return 0;
    }
    return price * weight / getUnitWeightValue();
  }

  static double getBuyPrice(double weight, dynamic goldDataModel) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.paphun!.buy!) *
        weight /
        getUnitWeightValue();
  }

  static double getBuyPriceUsePrice(double weight, double price) {
    if (goldDataModel == null) {
      return 0;
    }
    return price * weight / getUnitWeightValue();
  }

  static double getBuyThengPrice(double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.theng!.buy!) * weight / getUnitWeightValue();
  }

  static double getSellThengPrice(double weight) {
    if (goldDataModel == null) {
      return 0;
    }
    return toNumber(goldDataModel!.theng!.sell!) *
        weight /
        getUnitWeightValue();
  }

  static double getOrderSubTotalAmount() {
    if (ordersPapun!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < ordersPapun!.length; i++) {
      for (int j = 0; j < ordersPapun![i].details!.length; j++) {
        amount += ordersPapun![i].details![j].priceIncludeTax!;
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

  static double getOrderSubTotalAmountApiWholeSale(
      int orderTypeId, List<OrderDetailModel>? details) {
    if (details!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < details.length; j++) {
      amount += orderTypeId == 5
          ? details[j].priceExcludeTax!
          : details[j].priceIncludeTax!;
    }
    return amount;
  }

  static double getOrderWeightTotalAmount() {
    if (ordersPapun!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < ordersPapun!.length; i++) {
      for (int j = 0; j < ordersPapun![i].details!.length; j++) {
        amount += ordersPapun![i].details![j].weight!;
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

  static double getOrderGrantTotalAmountApi(double subTotal, double? discount, double addPrice) {
    discount ??= 0;
    return subTotal - discount + addPrice;
  }

  static double getPriceIncludeTaxTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double price = order.details![j].priceIncludeTax!;
      amount += price;
    }
    return amount;
  }

  static double getPriceExcludeTaxTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double price = order.details![j].priceExcludeTax!;
      amount += price;
    }
    return amount;
  }

  static double getPurchasePriceTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double price = order.details![j].purchasePrice!;
      amount += price;
    }
    return amount;
  }

  static double getPriceDiffTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double price = order.details![j].priceDiff!;
      amount += price;
    }
    return amount;
  }

  static double getTaxBaseTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double price = order.details![j].taxBase!;
      amount += price;
    }
    return amount;
  }

  static double getTaxAmountTotal(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      double price = order.details![j].taxAmount!;
      amount += price;
    }
    return amount;
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

    amount = getBuyPrice(amount, order.goldDataModel);
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

  static dynamic payToCustomerOrShop(
      List<OrderModel>? orders, double discount, double addPrice) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = payToCustomerOrShopValue(orders, discount, addPrice);
    return amount > 0
        ? '${format(amount)} บาท'
        : amount == 0
            ? 0
            : '${format(-amount)} บาท';
  }

  static dynamic payToCustomerOrShopWholeSale(dynamic orders, double discount, double addPrice) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = payToCustomerOrShopValueWholeSale(orders, discount, addPrice);
    return amount > 0
        ? '${format(amount)} บาท'
        : amount == 0
            ? 0
            : '${format(-amount)} บาท';
  }

  static dynamic payToCustomerOrShopValue(
      List<OrderModel>? orders, double discount, double addPrice) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    double buy = 0;
    double sell = 0;
    for (int i = 0; i < orders.length; i++) {
      for (int j = 0; j < orders[i].details!.length; j++) {
        int type = orders[i].orderTypeId!;
        double price = orders[i].details![j].priceIncludeTax!;

        if (type == 2 || type == 5 || type == 44 || type == 33 || type == 9) {
          buy += -price;
        }
        if (type == 1 || type == 6 || type == 4 || type == 3 || type == 8) {
          sell += price;
        }
      }
    }
    amount = sell + buy;
    amount = amount < 0 ? -amount : amount;
    amount += addPrice;
    amount = discount != 0 ? amount - discount : amount;
    amount = (sell + buy) < 0 ? -amount : amount;
    // motivePrint(amount);
    return amount;
  }

  static dynamic payToCustomerOrShopValueWholeSale(
      List<OrderModel>? orders, double discount, double addPrice) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    double buy = 0;
    double sell = 0;
    for (int i = 0; i < orders.length; i++) {
      int type = orders[i].orderTypeId!;
      // double price = type == 5 ? orders[i].priceExcludeTax ?? 0 : orders[i].priceIncludeTax ?? 0;
      double price = orders[i].priceIncludeTax ?? 0;

      if (type == 2 ||
          type == 5 ||
          type == 44 ||
          type == 33 ||
          type == 9 ||
          type == 10) {
        buy += -price;
      }
      if (type == 1 ||
          type == 6 ||
          type == 4 ||
          type == 3 ||
          type == 8 ||
          type == 11) {
        sell += price;
      }
    }
    amount = sell + buy;
    amount = amount < 0 ? -amount : amount;
    amount += addPrice;
    amount = discount != 0 ? amount - discount : amount;
    amount = (sell + buy) < 0 ? -amount : amount;
    // motivePrint(sell + buy);
    return amount;
  }

  static dynamic getPayTittle(double amount) {
    return amount > 0
        ? 'ลูกค้าจ่าย - ร้านรับเงิน (สุทธิ)'
        : amount == 0
            ? ""
            : 'ลูกค้ารับ - ร้านจ่ายเงิน (สุทธิ)';
  }

  static dynamic getRefillPayTittle(double amount) {
    // motivePrint(amount);
    return amount > 0
        ? 'ร้านค้าส่งจ่าย - ร้านรับเงิน (สุทธิ)'
        : amount == 0
            ? ""
            : 'ร้านค้าส่งรับ - ร้านจ่ายเงิน (สุทธิ)';
  }

  static dynamic payToBrokerOrShop(double discount, double addPrice) {
    if (ordersPapun!.isEmpty) {
      return 0;
    }
    double amount = 0;
    double buy = 0;
    double sell = 0;
    for (int i = 0; i < ordersPapun!.length; i++) {
      for (int j = 0; j < ordersPapun![i].details!.length; j++) {
        double price = ordersPapun![i].details![j].priceIncludeTax!;
        int type = ordersPapun![i].orderTypeId!;
        if (type == 2 || type == 5 || type == 44 || type == 33 || type == 9) {
          buy += -price;
        }
        if (type == 1 || type == 6 || type == 4 || type == 3 || type == 8) {
          sell += price;
        }
      }
    }
    amount = sell + buy;
    amount += addPrice;
    amount = discount != 0 ? amount - discount : amount;
    return amount > 0
        ? 'โบรกเกอร์จ่ายเงินให้กับเรา ${formatter.format(amount)} บาท'
        : amount == 0
            ? 0
            : 'เราจ่ายเงินให้กับโบรกเกอร์ ${formatter.format(-amount)} บาท';
  }

  static double getPaymentTotal(List<OrderModel>? orders, double discount, double addPrice) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders.length; i++) {
      for (int j = 0; j < orders[i].details!.length; j++) {
        double price = orders[i].details![j].priceIncludeTax!;
        motivePrint(price);
        int type = orders[i].orderTypeId!;
        if (type == 2 || type == 5 || type == 44 || type == 33 || type == 9) {
          price = -price;
        }
        amount += price;
      }
    }
    // motivePrint(discount);
    amount = amount < 0 ? -amount : amount;
    amount += addPrice;
    amount = discount != 0 ? amount - discount : amount;
    // motivePrint(amount);
    return amount < 0 ? -amount : amount;
  }

  static double getPaymentTotalB(List<OrderModel>? orders, double discount, double addPrice) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders.length; i++) {
      for (int j = 0; j < orders[i].details!.length; j++) {
        double price = orders[i].details![j].priceIncludeTax!;
        motivePrint(price);
        int type = orders[i].orderTypeId!;
        if (type == 2 || type == 5 || type == 44 || type == 33 || type == 9) {
          price = -price;
        }
        amount += price;
      }
    }
    // motivePrint(discount);
    // amount = amount < 0 ? -amount : amount;
    amount += addPrice;
    amount = discount != 0 ? amount - discount : amount;
    motivePrint(amount);
    return amount; // < 0 ? -amount : amount;
  }

  static double getPaymentListTotal() {
    if (Global.paymentList!.isEmpty) {
      return 0;
    }

    double amount = 0;
    for (int j = 0; j < Global.paymentList!.length; j++) {
      double price = Global.paymentList![j].amount ?? 0;
      amount += price;
    }
    return amount;
  }

  static double getPaymentTotalWholeSale(List<OrderModel>? orders, double discount, double addPrice) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders.length; i++) {
      int type = orders[i].orderTypeId!;
      // double price =
      //     type == 5 ? orders[i].priceExcludeTax ?? 0 : orders[i].priceIncludeTax ?? 0;
      double price = orders[i].priceIncludeTax ?? 0;
      if (type == 5 || type == 10) {
        price = -price;
      }
      amount += price;
    }
    // motivePrint(discount);
    amount = amount < 0 ? -amount : amount;
    amount += addPrice;
    amount = discount != 0 ? amount - discount : amount;
    // motivePrint(amount);
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
      if (type == 2 || type == 5 || type == 44 || type == 33 || type == 9) {
        price = -price;
      }
      amount += price;
    }

    return amount < 0 ? -amount : amount;
  }

  static double getOrderTotalWholeSale(OrderModel? order) {
    if (order == null) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < order.details!.length; j++) {
      int type = order.orderTypeId!;
      double price = type == 5
          ? order.details![j].priceExcludeTax!
          : order.details![j].priceIncludeTax!;
      if (type == 2 || type == 5 || type == 44 || type == 33 || type == 9) {
        price = -price;
      }
      amount += price;
    }

    return amount < 0 ? -amount : amount;
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

  static double getOrderTotalAmountWholeSale(
      int orderTypeId, List<OrderDetailModel> data) {
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

  static double getOrderTotalWeightBaht(List<OrderDetailModel> data) {
    if (data.isEmpty) {
      return 0;
    }
    double sum = 0;
    for (var e in data) {
      sum += e.weightBath!;
    }
    return sum;
  }

  /// PAWN
  ///
  static double getRedeemTotalWeight(List<RedeemDetailModel> data) {
    if (data.isEmpty) {
      return 0;
    }
    double sum = 0;
    for (var e in data) {
      sum += e.weight ?? 0;
    }
    return sum;
  }

  static double getRedeemTotalPayment(List<RedeemDetailModel> data) {
    if (data.isEmpty) {
      return 0;
    }
    double sum = 0;
    for (var e in data) {
      motivePrint(e.paymentAmount);
      sum += e.paymentAmount ?? 0;
    }
    return sum;
  }

  static double getRedeemSubPaymentTotal(List<RedeemDetailModel>? details,
      {double discount = 0}) {
    if (details!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int j = 0; j < details.length; j++) {
      double price = details[j].paymentAmount ?? 0;
      amount += price;
    }
    return amount - discount;
  }

  static double getRedeemPaymentTotal(List<RedeemModel>? orders,
      {double discount = 0}) {
    if (orders!.isEmpty) {
      return 0;
    }
    double amount = 0;
    for (int i = 0; i < orders.length; i++) {
      for (int j = 0; j < orders[i].details!.length; j++) {
        double price = orders[i].details![j].paymentAmount ?? 0;
        amount += price;
      }
    }
    return amount - discount;
  }

  /// END PAWN

  static Future<File> createFileFromString(encodedStr) async {
    Uint8List bytes = base64.decode(encodedStr);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File("$dir/${DateTime.now().millisecondsSinceEpoch}.png");
    await file.writeAsBytes(bytes);
    return file;
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

  static double toNumber(String? num) {
    return num == null || num == '' ? 0 : double.parse(num.replaceAll(",", ""));
  }

  static int toInt(String? num) {
    return num == null || num == '' ? 0 : int.parse(num.replaceAll(",", ""));
  }

  static DateTime convertDate(String date) {
    List<String> parts = date.split("-");
    DateTime tempDate =
        DateTime.parse("${parts[2]}-${parts[1]}-${parts[0]}").toLocal();
    return tempDate;
  }

  static DateTime apiDate(String date) {
    return DateTime.parse(date).toLocal();
  }

  static String formatDate(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(tempDate);
  }

  static String formatDateNT(String date) {
    // motivePrint(date);
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('dd/MM/yyyy').format(tempDate);
  }

  static String formatDateD(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('dd-MM-yyyy').format(tempDate);
  }

  static String formatDateM(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('dd-MMM-yyyy').format(tempDate);
  }

  static String formatDateMF(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('dd MMM yyyy').format(tempDate);
  }

  static String formatDateThai(String date) {
    DateFormat format = DateFormat("d MMM yyyy", "en");
    DateTime tempDate = format.parse(date).toLocal();
    return DateFormat('yyyy-MM-dd').format(tempDate);
  }

  static String formatDateDD(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('yyyy-MM-dd').format(tempDate);
  }

  static String formatDateDT(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(tempDate);
  }

  static String formattedDateTH(String dt) {
    try {
      DateTime dateTime = DateTime.parse(dt).toLocal();
      String formattedDate = DateFormat.yMMMMd('th_TH').format(dateTime);
      return formattedDate;
    } catch (e) {
      return dt.split('').toString() + e.toString();
    }
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static Color? checkMatchingOrder(DateTime dt) {
    DateTime now = DateTime.now();
    DateTime order = dt.add(const Duration(days: 7));
    int difference = daysBetween(now, order);

    if (difference <= 2 && difference > 0) {
      return Colors.amber;
    }

    if (difference == 0) {
      return Colors.orangeAccent;
    }

    if (difference < 0) {
      return Colors.red;
    }

    return Colors.green;
  }

  static int? getMatchingOrderDays(DateTime dt) {
    DateTime now = DateTime.now();
    DateTime order = dt.add(const Duration(days: 7));
    int difference = daysBetween(now, order);
    return difference;
  }

  static String formatDateT(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(tempDate);
  }

  static String monthYear(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('MMM yyyy').format(tempDate);
  }

  static String dateOnly(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('dd/MM/yyyy').format(tempDate);
  }

  static String dateOnlyT(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('yyyy-MM-dd').format(tempDate);
  }

  static String timeAndSec(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('HH:mm:ss').format(tempDate);
  }

  static String timeOnly(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    return DateFormat('HH:mm').format(tempDate);
  }

  static String timeOnlyF(String date) {
    DateTime tempDate = DateTime.parse(date).toLocal();
    // return DateFormat('HH:mm a').format(tempDate);
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

  static List<int> genMonthDays() {
    List<int> days = [];
    for (int i = 1; i <= 31; i++) {
      days.add(i);
    }
    return days;
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
            r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
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
        companyId: company?.id ?? user?.companyId,
        branchId: branch?.id ?? user?.branchId,
        userId: user?.id,
        data: data,
        status: status,
        token: token,
        message: message));
  }

  static String reportRequestObj(dynamic data,
      {status = "", message = "", token = ""}) {
    return encoder.convert(RequestModel(
        companyId: company?.id,
        branchId: branch?.id,
        userId: user?.id,
        data: data,
        status: status,
        token: token,
        message: message));
  }

  static getOrderTypeCode(int? id) {
    switch (id) {
      case 1:
        return 'NEW';
      case 2:
        return 'USED';
      case 3:
        return 'BARM';
      case 33:
        return 'BARM';
      case 4:
        return 'BAR';
      case 44:
        return 'BAR';
      case 5:
        return 'NEW';
      case 6:
        return 'USED';
      case 7:
        return 'ALL';
      case 8:
        return 'BARM';
      case 9:
        return 'BARM';
      case 10:
        return 'RFB';
      case 11:
        return 'SUB';
      default:
        return 'NEW';
    }
  }
}
