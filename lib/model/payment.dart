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
  int? paymentId;
  String? paymentMethod;
  DateTime? paymentDate;
  int? bankId;
  String? bankName;
  String? accountName;
  String? accountNo;
  String? referenceNumber;
  String? cardName;
  String? cardNo;
  DateTime? cardExpiryDate;
  String? paymentDetail;
  String? attachement;
  double? amount;
  DateTime? createdDate;
  DateTime? updatedDate;

  PaymentModel({
    this.id,
    this.pairId,
    this.paymentId,
    this.paymentMethod,
    this.paymentDate,
    this.bankId,
    this.bankName,
    this.accountName,
    this.accountNo,
    this.referenceNumber,
    this.cardName,
    this.cardNo,
    this.cardExpiryDate,
    this.paymentDetail,
    this.attachement,
    this.amount,
    this.createdDate,
    this.updatedDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json["id"],
    pairId: json["pairId"],
    paymentId: json["paymentId"],
    paymentMethod: json["paymentMethod"],
    paymentDate: json["paymentDate"] == null ? null : DateTime.parse(json["paymentDate"]),
    bankId: json["bankId"],
    bankName: json["bankName"],
    accountName: json["accountName"],
    accountNo: json["accountNo"],
    referenceNumber: json["referenceNumber"],
    cardName: json["cardName"],
    cardNo: json["cardNo"],
    cardExpiryDate: json["cardExpiryDate"] == null ? null : DateTime.parse(json["cardExpiryDate"]),
    paymentDetail: json["paymentDetail"],
    attachement: json["attachement"],
    amount: json["amount"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pairId": pairId,
    "paymentId": paymentId,
    "paymentMethod": paymentMethod,
    "paymentDate": paymentDate?.toIso8601String(),
    "bankId": bankId,
    "bankName": bankName,
    "referenceNumber": referenceNumber,
    "cardName": cardName,
    "cardNo": cardNo,
    "accountName": accountName,
    "accountNo": accountNo,
    "cardExpiryDate": cardExpiryDate?.toIso8601String(),
    "paymentDetail": paymentDetail,
    "attachement": attachement,
    "amount": amount,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
