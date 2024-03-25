// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';


List<OrderDetailModel> orderDetailListModelFromJson(String str) => List<OrderDetailModel>.from(json.decode(str).map((x) => OrderDetailModel.fromJson(x)));

String orderDetailListModelToJson(List<OrderDetailModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

OrderDetailModel orderDetailModelFromJson(String str) => OrderDetailModel.fromJson(json.decode(str));

String orderDetailModelToJson(OrderDetailModel data) => json.encode(data.toJson());

class OrderDetailModel {
  String? id;
  String? orderId;
  String? productCode;
  String productName;
  String? weight;
  double? commission;
  double? price;
  double? salePrice;
  String? type;
  double? taxBase;

  OrderDetailModel({
    this.id,
    this.orderId,
    this.productCode,
    required this.productName,
    this.weight,
    this.commission,
    this.price,
    this.salePrice,
    this.type,
    this.taxBase
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) => OrderDetailModel(
    id: json["id"],
    orderId: json["order_id"],
    productCode: json["product_code"],
    productName: json["product_name"],
    weight: json["weight"],
    commission: json["commission"],
    price: json["price"],
    salePrice: json["sale_price"],
    type: json["type"],
    taxBase: json["tax_base"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_code": productCode,
    "product_name": productName,
    "weight": weight,
    "commission": commission,
    "price": price,
    "sale_price": salePrice,
    "type": type,
    "tax_base": taxBase
  };

  @override
  String toString() => productName;

  @override
  operator ==(o) => o is OrderDetailModel && o.id == id;

  @override
  int get hashCode => id.hashCode^productName.hashCode^productCode.hashCode;
}
