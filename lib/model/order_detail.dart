// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';


List<OrderDetailModel> orderDetailListModelFromJson(String str) => List<OrderDetailModel>.from(json.decode(str).map((x) => OrderDetailModel.fromJson(x)));

String orderDetailListModelToJson(List<OrderDetailModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

OrderDetailModel orderDetailModelFromJson(String str) => OrderDetailModel.fromJson(json.decode(str));

String orderDetailModelToJson(OrderDetailModel data) => json.encode(data.toJson());

class OrderDetailModel {
  int? id;
  int? orderId;
  int? productId;
  String productName;
  int? binLocationId;
  String? binLocationName;
  int? toBinLocationId;
  String? toBinLocationName;
  int? toBranchId;
  String? toBranchName;
  double? commission;
  double? weight;
  double? weightBath;
  double? unitCost;
  double? priceIncludeTax;
  double? purchasePrice;
  double? priceDiff;
  double? taxAmount;
  double? taxBase;
  double? priceExcludeTax;
  DateTime? createdDate;
  DateTime? updatedDate;
  String? transferType;

  OrderDetailModel({
    this.id,
    this.orderId,
    this.productId,
    required this.productName,
    this.binLocationId,
    this.toBinLocationId,
    this.binLocationName,
    this.toBinLocationName,
    this.commission,
    this.weight,
    this.weightBath,
    this.unitCost,
    this.priceIncludeTax,
    this.purchasePrice,
    this.priceDiff,
    this.taxAmount,
    this.taxBase,
    this.priceExcludeTax,
    this.createdDate,
    this.updatedDate,
    this.toBranchId,
    this.toBranchName,
    this.transferType
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) => OrderDetailModel(
    id: json["id"],
    orderId: json["orderId"],
    productId: json["productId"],
    productName: json["productName"],
    binLocationId: json["binLocationId"],
    toBinLocationId: json["toBinLocationId"],
    binLocationName: json["binLocationName"],
    toBinLocationName: json["toBinLocationName"],
    commission: json["commission"],
    weight: json["weight"],
    weightBath: json["weightBath"],
    unitCost: json["unitCost"],
    priceIncludeTax: json["priceIncludeTax"],
    purchasePrice: json["purchasePrice"],
    priceDiff: json["priceDiff"],
    taxAmount: json["taxAmount"],
    taxBase: json["taxBase"],
    priceExcludeTax: json["priceExcludeTax"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
    toBranchId: json["toBranchId"],
    toBranchName: json["toBranchName"],
      transferType: json["transferType"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderId": orderId,
    "productId": productId,
    "productName": productName,
    "binLocationId": binLocationId,
    "toBinLocationId": toBinLocationId,
    "binLocationName": binLocationName,
    "toBinLocationName": toBinLocationName,
    "commission": commission,
    "weight": weight,
    "weightBath": weightBath,
    "unitCost": unitCost,
    "priceIncludeTax": priceIncludeTax,
    "purchasePrice": purchasePrice,
    "priceDiff": priceDiff,
    "taxAmount": taxAmount,
    "taxBase": taxBase,
    "priceExcludeTax": priceExcludeTax,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "toBranchId": toBranchId,
    "toBranchName": toBranchName,
    "transferType": transferType
  };

  @override
  String toString() => productName;

  @override
  operator ==(o) => o is OrderDetailModel && o.id == id;

  @override
  int get hashCode => id.hashCode^productName.hashCode^productId.hashCode;
}
