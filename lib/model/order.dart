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
  String? status;
  int? orderTypeId;
  String? orderTypeName;
  double? weight;
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
  int? pairId;
  String? paymentMethod;
  DateTime? bookDate;
  String? orderStatus;

  OrderModel({
    this.id,
    required this.orderId,
    this.orderDate,
    this.customerId,
    this.status,
    this.orderTypeId,
    this.orderTypeName,
    this.weight,
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
    this.pairId,
    this.paymentMethod,
    this.bookDate,
    this.orderStatus
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json["id"],
    orderId: json["orderId"],
    orderDate: json["orderDate"] == null ? null : DateTime.parse(json["orderDate"]),
    customerId: json["customerId"],
    status: json["status"] is int ? json['status'].toString() : json['status'],
    orderTypeId: json["orderTypeId"],
    orderTypeName: json["orderTypeName"],
    weight: json["weight"],
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
    pairId: json['pairId'],
    paymentMethod: json['paymentMethod'],
    bookDate: json["bookDate"] == null ? null : DateTime.parse(json["bookDate"]),
    orderStatus: json['orderStatus'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderId": orderId,
    "orderDate": orderDate?.toIso8601String(),
    "customerId": customerId,
    "status": status,
    "orderTypeId": orderTypeId,
    "orderTypeName": orderTypeName,
    "weight": weight,
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
    "pairId": pairId,
    "paymentMethod": paymentMethod,
    "bookDate": bookDate?.toIso8601String(),
    "orderStatus": orderStatus,
  };

  @override
  String toString() => orderId;

  @override
  operator ==(o) => o is OrderModel && o.id == id;

  @override
  int get hashCode => id.hashCode^orderId.hashCode^customerId.hashCode;
}
