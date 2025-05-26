import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/global.dart';

bool writeCart() {
  try {
    if (Global.currentOrderType == 1) {
      Global.orders = Global.ordersPapun ?? [];
      LocalStorage.sharedInstance.writeValue(
          key: getCartKey(Global.currentOrderType),
          value: jsonEncode(Global.ordersPapun ?? []));
    }
    if (Global.currentOrderType == 2) {
      Global.orders = Global.ordersThengMatching ?? [];
      LocalStorage.sharedInstance.writeValue(
          key: getCartKey(Global.currentOrderType),
          value: jsonEncode(Global.ordersThengMatching ?? []));
    }
    if (Global.currentOrderType == 3) {
      Global.orders = Global.ordersTheng ?? [];
      LocalStorage.sharedInstance.writeValue(
          key: getCartKey(Global.currentOrderType),
          value: jsonEncode(Global.ordersTheng ?? []));
    }
    if (Global.currentOrderType == 4) {
      Global.orders = Global.ordersBroker ?? [];
      LocalStorage.sharedInstance.writeValue(
          key: getCartKey(Global.currentOrderType),
          value: jsonEncode(Global.ordersBroker ?? []));
    }
    if (Global.currentOrderType == 5) {
      Global.orders = Global.ordersWholesale ?? [];
      LocalStorage.sharedInstance.writeValue(
          key: getCartKey(Global.currentOrderType),
          value: jsonEncode(Global.ordersWholesale ?? []));
    }
    if (Global.currentOrderType == 6) {
      Global.orders = Global.ordersThengWholesale ?? [];
      LocalStorage.sharedInstance.writeValue(
          key: getCartKey(Global.currentOrderType),
          value: jsonEncode(Global.ordersThengWholesale ?? []));
    }
    return true;
  } catch (e) {
    return false;
  }
}

void removeCart() {
  if (Global.currentOrderType == 1) {
    Global.ordersPapun = Global.orders;
    LocalStorage.sharedInstance.writeValue(
        key: getCartKey(Global.currentOrderType),
        value: jsonEncode(Global.ordersPapun ?? []));
  }
  if (Global.currentOrderType == 2) {
    Global.ordersThengMatching = Global.orders;
    LocalStorage.sharedInstance.writeValue(
        key: getCartKey(Global.currentOrderType),
        value: jsonEncode(Global.ordersThengMatching ?? []));
  }
  if (Global.currentOrderType == 3) {
    Global.ordersTheng = Global.orders;
    LocalStorage.sharedInstance.writeValue(
        key: getCartKey(Global.currentOrderType),
        value: jsonEncode(Global.ordersTheng ?? []));
  }
  if (Global.currentOrderType == 4) {
    Global.ordersBroker = Global.orders;
    LocalStorage.sharedInstance.writeValue(
        key: getCartKey(Global.currentOrderType),
        value: jsonEncode(Global.ordersBroker ?? []));
  }
  if (Global.currentOrderType == 5) {
    Global.ordersWholesale = Global.orders;
    LocalStorage.sharedInstance.writeValue(
        key: getCartKey(Global.currentOrderType),
        value: jsonEncode(Global.ordersWholesale ?? []));
  }
  if (Global.currentOrderType == 6) {
    Global.ordersThengWholesale = Global.orders;
    LocalStorage.sharedInstance.writeValue(
        key: getCartKey(Global.currentOrderType),
        value: jsonEncode(Global.ordersThengWholesale ?? []));
  }
}

void resetCart() {
  for (int i = 1; i < 7; i++) {
    LocalStorage.sharedInstance
        .writeValue(key: getCartKey(i), value: jsonEncode([]));
  }
}

Future<int> getCartCount() async {
  var data = await LocalStorage.sharedInstance
      .readValue(getCartKey(Global.currentOrderType));
  if (data != null) {
    List<OrderModel>? orders = orderListModelFromJson(data);
    setCart(orders, Global.currentOrderType);
    return orders.length;
  }
  return 0;
}

void getCart() async {
  var data = await LocalStorage.sharedInstance
      .readValue(getCartKey(Global.currentOrderType));
  if (data != null) {
    List<OrderModel>? orders = orderListModelFromJson(data);
    setCart(orders, Global.currentOrderType);
  }
  if (Global.currentOrderType == 1) {
    Global.orders = Global.ordersPapun ?? [];
  }
  if (Global.currentOrderType == 2) {
    Global.orders = Global.ordersThengMatching ?? [];
  }
  if (Global.currentOrderType == 3) {
    Global.orders = Global.ordersTheng ?? [];
  }
  if (Global.currentOrderType == 4) {
    Global.orders = Global.ordersBroker ?? [];
  }
  if (Global.currentOrderType == 5) {
    Global.orders = Global.ordersWholesale ?? [];
  }
  if (Global.currentOrderType == 6) {
    Global.orders = Global.ordersThengWholesale ?? [];
  }
}

void setCart(List<OrderModel> orders, int orderType) {
  switch (orderType) {
    case 1:
      Global.ordersPapun = orders;
      break;
    case 2:
      Global.ordersThengMatching = orders;
      break;
    case 3:
      Global.ordersTheng = orders;
      break;
    case 4:
      Global.ordersBroker = orders;
      break;
    case 5:
      Global.ordersWholesale = orders;
      break;
    case 6:
      Global.ordersThengWholesale = orders;
      break;
    default:
      break;
  }
}

String getCartKey(int orderType) {
  switch (orderType) {
    case 1:
      return 'papun_cart';
    case 2:
      return 'theng_matching_cart';
    case 3:
      return 'theng_cart';
    case 4:
      return 'broker_cart';
    case 5:
      return 'wholesale_cart';
    case 6:
      return 'theng_wholesale_cart';
    default:
      return '';
  }
}

/// Redeem
bool writeRedeemCart() {
  try {
    if (Global.currentRedeemType == 1) {
      LocalStorage.sharedInstance.writeValue(
          key: getRedeemCartKey(Global.currentRedeemType),
          value: jsonEncode(Global.redeems));
    }
    return true;
  } catch (e) {
    return false;
  }
}

void getRedeemCart() async {
  var data = await LocalStorage.sharedInstance
      .readValue(getRedeemCartKey(Global.currentRedeemType));
  if (data != null) {
    List<RedeemModel>? orders = redeemListModelFromJson(data);
    setRedeemCart(orders, Global.currentRedeemType);
  }
}

void setRedeemCart(List<RedeemModel> orders, int orderType) {
  switch (orderType) {
    case 1:
      Global.redeems = orders;
      break;
    default:
      break;
  }
}

void removeRedeemCart() {
  if (Global.currentRedeemType == 1) {
    LocalStorage.sharedInstance.writeValue(
        key: getRedeemCartKey(Global.currentRedeemType),
        value: jsonEncode(Global.redeems ?? []));
  }
}

void resetRedeemCart() {
  for (int i = 1; i < 7; i++) {
    LocalStorage.sharedInstance
        .writeValue(key: getRedeemCartKey(i), value: jsonEncode([]));
  }
}

Future<int> getRedeemCartCount() async {
  var data = await LocalStorage.sharedInstance
      .readValue(getRedeemCartKey(Global.currentRedeemType));
  if (data != null) {
    List<RedeemModel>? orders = redeemListModelFromJson(data);
    setRedeemCart(orders, Global.currentRedeemType);
    return orders.length;
  }
  return 0;
}

String getRedeemCartKey(int orderType) {
  switch (orderType) {
    case 1:
      return 'redeem_cart';
    default:
      return '';
  }
}