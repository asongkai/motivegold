// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/utils/global.dart';

import 'order_detail.dart';

List<OrderModel> orderListModelFromJson(String str) => List<OrderModel>.from(json.decode(str).map((x) => OrderModel.fromJson(x)));

String orderListModelToJson(List<OrderModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  String? id;
  String orderId;
  String? orderDate;
  String? customerId;
  String? type;
  List<OrderDetailModel>? detail;

  OrderModel({
    this.id,
    required this.orderId,
    this.orderDate,
    this.customerId,
    this.type, this.detail,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json["id"],
    orderId: json["order_id"],
    orderDate: json["order_date"],
    customerId: json["customer_id"],
    type: json["type"],
    detail: json["detail"] == null ? null : orderDetailListModelFromJson(json["detail"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "order_date": orderDate,
    "customer_id": customerId,
    "type": type,
    "detail": orderDetailListModelToJson(detail!)
  };

  @override
  String toString() => orderId;

  @override
  operator ==(o) => o is OrderModel && o.id == id;

  @override
  int get hashCode => id.hashCode^orderId.hashCode^customerId.hashCode;
}
