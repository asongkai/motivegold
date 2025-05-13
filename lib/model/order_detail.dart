// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/gold_data.dart';

List<OrderDetailModel> orderDetailListModelFromJson(String str) =>
    List<OrderDetailModel>.from(
        json.decode(str).map((x) => OrderDetailModel.fromJson(x)));

String orderDetailListModelToJson(List<OrderDetailModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

OrderDetailModel orderDetailModelFromJson(String str) =>
    OrderDetailModel.fromJson(json.decode(str));

String orderDetailModelToJson(OrderDetailModel data) =>
    json.encode(data.toJson());

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
  double? sellTPrice;
  double? buyTPrice;
  double? sellPrice;
  double? buyPrice;
  double? commission;
  double? weight;
  double? weightBath;
  double? weightAdj;
  double? weightBathAdj;
  double? unitCost;
  double? priceIncludeTax;
  double? purchasePrice;
  double? priceDiff;
  double? taxAmount;
  double? taxBase;
  double? priceExcludeTax;
  DateTime? createdDate;
  DateTime? updatedDate;
  DateTime? bookDate;
  String? transferType;
  GoldDataModel? goldDataModel;
  int? packageId;
  int? packageQty;
  double? packagePrice;
  String? vatOption;

  OrderDetailModel(
      {this.id,
      this.orderId,
      this.productId,
      required this.productName,
      this.binLocationId,
      this.toBinLocationId,
      this.binLocationName,
      this.toBinLocationName,
      this.sellTPrice,
      this.buyTPrice,
      this.sellPrice,
      this.buyPrice,
      this.commission,
      this.weight,
      this.weightBath,
      this.weightAdj,
      this.weightBathAdj,
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
      this.bookDate,
      this.transferType,
      this.goldDataModel,
      this.packageId,
      this.packageQty,
      this.packagePrice, this.vatOption,});

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailModel(
        id: json["id"],
        orderId: json["orderId"],
        productId: json["productId"],
        productName: json["productName"],
        binLocationId: json["binLocationId"],
        toBinLocationId: json["toBinLocationId"],
        binLocationName: json["binLocationName"],
        toBinLocationName: json["toBinLocationName"],
        sellTPrice: json["sellTPrice"],
        buyTPrice: json["buyTPrice"],
        sellPrice: json["sellPrice"],
        buyPrice: json["buyPrice"],
        commission: json["commission"],
        weight: json["weight"],
        weightBath: json["weightBath"],
        weightAdj: json["weightAdj"],
        weightBathAdj: json["weightBathAdj"],
        unitCost: json["unitCost"],
        priceIncludeTax: json["priceIncludeTax"],
        purchasePrice: json["purchasePrice"],
        priceDiff: json["priceDiff"],
        taxAmount: json["taxAmount"],
        taxBase: json["taxBase"],
        priceExcludeTax: json["priceExcludeTax"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]).toLocal(),
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]).toLocal(),
        bookDate: json["reserveDate"] == null
            ? null
            : DateTime.parse(json["reserveDate"]).toLocal(),
        toBranchId: json["toBranchId"],
        toBranchName: json["toBranchName"],
        transferType: json["transferType"],
        goldDataModel: json["goldDataModel"] == null
            ? null
            : GoldDataModel.fromJson(json["goldDataModel"]),
        packageId: json["packageId"],
        packageQty: json["packageQty"] != null ? json["packageQty"].toInt() : 0,
        packagePrice: json["packagePrice"],
        vatOption: json["vatOption"],
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
        "sellTPrice": sellTPrice,
        "buyTPrice": buyTPrice,
        "sellPrice": sellPrice,
        "buyPrice": buyPrice,
        "commission": commission,
        "weight": weight,
        "weightBath": weightBath,
        "weightAdj": weightAdj,
        "weightBathAdj": weightBathAdj,
        "unitCost": unitCost,
        "priceIncludeTax": priceIncludeTax,
        "purchasePrice": purchasePrice,
        "priceDiff": priceDiff,
        "taxAmount": taxAmount,
        "taxBase": taxBase,
        "priceExcludeTax": priceExcludeTax,
        "createdDate": createdDate?.toIso8601String(),
        "updatedDate": updatedDate?.toIso8601String(),
        "reserveDate": bookDate?.toIso8601String(),
        "toBranchId": toBranchId,
        "toBranchName": toBranchName,
        "transferType": transferType,
        "goldDataModel": goldDataModel?.toJson(),
        "packageId": packageId,
        "packageQty": packageQty,
        "packagePrice": packagePrice,
        "vatOption": vatOption,
      };

  @override
  String toString() => productName;

  @override
  operator ==(o) => o is OrderDetailModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ productName.hashCode ^ productId.hashCode;
}
