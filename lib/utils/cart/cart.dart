import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
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
}

void resetCart() {
  for (int i = 1; i < 6; i++) {
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
    default:
      return '';
  }
}
