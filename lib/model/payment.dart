// To parse this JSON data, do
//
//     final paymentModel = paymentModelFromJson(jsonString);

import 'dart:convert';

List<PaymentModel> paymentListModelFromJson(String str) => List<PaymentModel>.from(json.decode(str).map((x) => PaymentModel.fromJson(x)));

String paymentListModelToJson(List<PaymentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

PaymentModel paymentModelFromJson(String str) => PaymentModel.fromJson(json.decode(str));

String paymentModelToJson(PaymentModel data) => json.encode(data.toJson());

class PaymentModel {
  int? id;
  int? pairId;
  String? paymentMethod;
  DateTime? paymentDate;
  String? bankName;
  String? referenceNumber;
  String? cardName;
  DateTime? cardExpiryDate;
  String? paymentDetail;
  String? attachement;
  DateTime? createdDate;
  DateTime? updatedDate;

  PaymentModel({
    this.id,
    this.pairId,
    this.paymentMethod,
    this.paymentDate,
    this.bankName,
    this.referenceNumber,
    this.cardName,
    this.cardExpiryDate,
    this.paymentDetail,
    this.attachement,
    this.createdDate,
    this.updatedDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json["id"],
    pairId: json["pairId"],
    paymentMethod: json["paymentMethod"],
    paymentDate: json["paymentDate"] == null ? null : DateTime.parse(json["paymentDate"]),
    bankName: json["bankName"],
    referenceNumber: json["referenceNumber"],
    cardName: json["cardName"],
    cardExpiryDate: json["cardExpiryDate"] == null ? null : DateTime.parse(json["cardExpiryDate"]),
    paymentDetail: json["paymentDetail"],
    attachement: json["attachement"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pairId": pairId,
    "paymentMethod": paymentMethod,
    "paymentDate": paymentDate?.toIso8601String(),
    "bankName": bankName,
    "referenceNumber": referenceNumber,
    "cardName": cardName,
    "cardExpiryDate": cardExpiryDate?.toIso8601String(),
    "paymentDetail": paymentDetail,
    "attachement": attachement,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
