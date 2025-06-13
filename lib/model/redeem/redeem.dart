import 'dart:convert';

import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';

List<RedeemModel> redeemListModelFromJson(String str) =>
    List<RedeemModel>.from(json.decode(str).map((x) => RedeemModel.fromJson(x)));

String redeemListModelToJson(List<RedeemModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

RedeemModel redeemModelFromJson(String str) =>
    RedeemModel.fromJson(json.decode(str));

String redeemModelToJson(RedeemModel data) => json.encode(data.toJson());

class RedeemModel {
  /// PK Key
  int? id;

  /// Generate transaction number with pre-define prefix
  String? redeemId;

  /// Linked company ID: FK
  int? companyId;

  /// Linked branch ID: FK
  int? branchId;

  /// Transaction date
  DateTime? redeemDate;

  /// Linked customer ID, customer whom take the order: FK
  int? customerId;

  CustomerModel? customer;

  /// Transaction state
  int? status;

  /// Transaction status, e.g: PENDING, COMPLETE...
  String? redeemStatus; // PENDING, CANCEL, COMPLETE

  /// Transaction document type, value depends on transaction type, e.g: SN, BU, ....
  String? docType;

  /// Transaction from which screen or order type ID
  int? redeemTypeId;

  /// น้ำหนักกรัม
  double? weight;

  /// น้ำหนักบาททอง
  double? weightBath;

  /// จำนวน
  int? qty;

  /// ราคาตามจำนวนสินไถ่ รวมภาษีมูลค่าเพิ่ม(บาท)
  double? redemptionVat;

  /// ราคาตามจำนวน สินไถ่ (บาท)
  double? redemptionValue;

  /// ราคาตามจำนวน ขายฝาก (บาท)
  double? depositAmount;

  /// ฐานภาษี (บาท)
  double? taxBase;

  /// ภาษีมูลค่าเพิ่ม (บาท)
  double? taxAmount;

  /// ผลประโยชน์ (บาท)
  double? benefitAmount;

  /// จำนวนเงินรวมที่ลูกค้าต้องชำระ (บาท)
  double? paymentAmount;

  /// Pair/link
  int? pairId;

  /// Remark
  String? remark;

  /// เลขที่ขายฝาก
  String? referenceNo;

  /// Attachment document
  String? attachment;

  /// Created user ID
  String? createdBy;

  /// Date creation
  DateTime? createdDate;

  /// Updated user ID
  String? updatedBy;

  /// Date updated
  DateTime? updatedDate;

  /// Detail
  List<RedeemDetailModel>? details;

  double? discount;


  RedeemModel({
    this.id,
    this.redeemId,
    this.companyId,
    this.branchId,
    this.redeemDate,
    this.customerId,
    this.customer,
    this.status,
    this.redeemStatus,
    this.docType,
    this.redeemTypeId,
    this.weight,
    this.weightBath,
    this.qty,
    this.redemptionVat,
    this.redemptionValue,
    this.depositAmount,
    this.taxBase,
    this.taxAmount,
    this.benefitAmount,
    this.paymentAmount,
    this.pairId,
    this.remark,
    this.referenceNo,
    this.attachment,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.details,
    this.discount,
  });

  // From JSON method
  factory RedeemModel.fromJson(Map<String, dynamic> json) {
    return RedeemModel(
      id: json['id'],
      redeemId: json['redeemId'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      redeemDate: json['redeemDate'] != null ? DateTime.parse(json['redeemDate']).toLocal() : null,
      customerId: json['customerId'],
      customer: json["customer"] == null
          ? null
          : CustomerModel.fromJson(json["customer"]),
      status: json['status'],
      redeemStatus: json['redeemStatus'],
      docType: json['docType'],
      redeemTypeId: json['redeemTypeId'],
      weight: json['weight'],
      weightBath: json['weightBath'],
      qty: json['qty'],
      redemptionVat: json['redemptionVat'],
      redemptionValue: json['redemptionValue'],
      depositAmount: json['depositAmount'],
      taxBase: json['taxBase'],
      taxAmount: json['taxAmount'],
      benefitAmount: json['benefitAmount'],
      paymentAmount: json['paymentAmount'],
      pairId: json['pairId'],
      remark: json['remark'] ?? '',
      referenceNo: json['referenceNo'],
      attachment: json['attachment'] ?? '',
      createdBy: json['createdBy'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']).toLocal() : null,
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate']).toLocal() : null,
      details: json["details"] == null
          ? []
          : List<RedeemDetailModel>.from(
          json["details"]!.map((x) => RedeemDetailModel.fromJson(x))),
      discount: json["discount"] ?? 0,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'redeemId': redeemId,
      'companyId': companyId,
      'branchId': branchId,
      'redeemDate': redeemDate?.toIso8601String(),
      'customerId': customerId,
      "customer": customer?.toJson(),
      'status': status,
      'redeemStatus': redeemStatus,
      'docType': docType,
      'redeemTypeId': redeemTypeId,
      'weight': weight,
      'weightBath': weightBath,
      'qty': qty,
      'redemptionVat': redemptionVat,
      'redemptionValue': redemptionValue,
      'depositAmount': depositAmount,
      'taxBase': taxBase,
      'taxAmount': taxAmount,
      'benefitAmount': benefitAmount,
      'paymentAmount': paymentAmount,
      'pairId': pairId,
      'remark': remark,
      'referenceNo': referenceNo,
      'attachment': attachment,
      'createdBy': createdBy,
      'createdDate': createdDate?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedDate': updatedDate?.toIso8601String(),
      "details": details == null
          ? []
          : List<dynamic>.from(details!.map((x) => x.toJson())),
      "discount": discount
    };
  }

  // Copy with method for immutability
  RedeemModel copyWith({
    int? id,
    String? redeemId,
    int? companyId,
    int? branchId,
    DateTime? redeemDate,
    int? customerId,
    int? status,
    String? redeemStatus,
    String? docType,
    int? redeemTypeId,
    double? weight,
    double? weightBath,
    int? qty,
    double? redemptionVat,
    double? redemptionValue,
    double? depositAmount,
    double? taxBase,
    double? taxAmount,
    double? benefitAmount,
    double? paymentAmount,
    int? pairId,
    String? remark,
    String? referenceNo,
    String? attachment,
    String? createdBy,
    DateTime? createdDate,
    String? updatedBy,
    DateTime? updatedDate,
    List<RedeemDetailModel>? details,
    double? discount,
  }) {
    return RedeemModel(
      id: id ?? this.id,
      redeemId: redeemId ?? this.redeemId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      redeemDate: redeemDate ?? this.redeemDate,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      redeemStatus: redeemStatus ?? this.redeemStatus,
      docType: docType ?? this.docType,
      redeemTypeId: redeemTypeId ?? this.redeemTypeId,
      weight: weight ?? this.weight,
      weightBath: weightBath ?? this.weightBath,
      qty: qty ?? this.qty,
      redemptionVat: redemptionVat ?? this.redemptionVat,
      redemptionValue: redemptionValue ?? this.redemptionValue,
      depositAmount: depositAmount ?? this.depositAmount,
      taxBase: taxBase ?? this.taxBase,
      taxAmount: taxAmount ?? this.taxAmount,
      benefitAmount: benefitAmount ?? this.benefitAmount,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      pairId: pairId ?? this.pairId,
      remark: remark ?? this.remark,
      referenceNo: referenceNo ?? this.referenceNo,
      attachment: attachment ?? this.attachment,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedDate: updatedDate ?? this.updatedDate,
      details: details ?? this.details,
      discount: discount ?? this.discount
    );
  }
}
