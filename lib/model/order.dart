// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';


import 'package:motivegold/model/customer.dart';

import 'order_detail.dart';

List<OrderModel> orderListModelFromJson(String str) => List<OrderModel>.from(json.decode(str).map((x) => OrderModel.fromJson(x)));

String orderListModelToJson(List<OrderModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  int? id;
  String orderId;
  DateTime? orderDate;
  int? customerId;
  int? status;
  int? orderTypeId;
  String? orderTypeName;
  double? priceIncludeTax;
  double? purchasePrice;
  double? priceDiff;
  double? taxAmount;
  double? taxBase;
  double? priceExcludeTax;
  double? discount;
  String? attachement;
  List<OrderDetailModel>? details;
  CustomerModel? customer;
  DateTime? createdDate;
  DateTime? updatedDate;

  OrderModel({
    this.id,
    required this.orderId,
    this.orderDate,
    this.customerId,
    this.status,
    this.orderTypeId,
    this.orderTypeName,
    this.priceIncludeTax,
    this.purchasePrice,
    this.priceDiff,
    this.taxAmount,
    this.taxBase,
    this.priceExcludeTax,
    this.discount,
    this.attachement,
    this.details,
    this.customer,
    this.createdDate,
    this.updatedDate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json["id"],
    orderId: json["orderId"],
    orderDate: json["orderDate"] == null ? null : DateTime.parse(json["orderDate"]),
    customerId: json["customerId"],
    status: json["status"],
    orderTypeId: json["orderTypeId"],
    orderTypeName: json["orderTypeName"],
    priceIncludeTax: json["priceIncludeTax"],
    purchasePrice: json["purchasePrice"],
    priceDiff: json["priceDiff"],
    taxAmount: json["taxAmount"],
    taxBase: json["taxBase"],
    priceExcludeTax: json["priceExcludeTax"],
    discount: json["discount"],
    attachement: json['attachement'],
    details: json["details"] == null ? [] : List<OrderDetailModel>.from(json["details"]!.map((x) => OrderDetailModel.fromJson(x))),
    customer: json["customer"] == null ? null : CustomerModel.fromJson(json["customer"]),
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderId": orderId,
    "orderDate": orderDate?.toIso8601String(),
    "customerId": customerId,
    "status": status,
    "orderTypeId": orderTypeId,
    "orderTypeName": orderTypeName,
    "priceIncludeTax": priceIncludeTax,
    "purchasePrice": purchasePrice,
    "priceDiff": priceDiff,
    "taxAmount": taxAmount,
    "taxBase": taxBase,
    "priceExcludeTax": priceExcludeTax,
    "discount": discount,
    "attachement": attachement,
    "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
    "customer": customer?.toJson(),
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };

  @override
  String toString() => orderId;

  @override
  operator ==(o) => o is OrderModel && o.id == id;

  @override
  int get hashCode => id.hashCode^orderId.hashCode^customerId.hashCode;
}
