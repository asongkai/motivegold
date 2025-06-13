import 'dart:convert';

List<RedeemDetailModel> redeemDetailListModelFromJson(String str) =>
    List<RedeemDetailModel>.from(
        json.decode(str).map((x) => RedeemDetailModel.fromJson(x)));

String redeemDetailListModelToJson(List<RedeemDetailModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RedeemDetailModel {
  /// Primary Key
  int? id;

  /// Linked redeem ID: FK
  int? redeemId;

  /// Linked company ID: FK
  int? companyId;

  /// Linked branch ID: FK
  int? branchId;

  /// Linked product ID: FK
  int? productId;

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

  String? customerName;

  String? taxNumber;

  DateTime? redeemDate;

  RedeemDetailModel({
    this.id,
    this.redeemId,
    this.companyId,
    this.branchId,
    this.productId,
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
    this.referenceNo,
    this.attachment,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.customerName,
    this.taxNumber,
    this.redeemDate,
  });

  // From JSON method
  factory RedeemDetailModel.fromJson(Map<String, dynamic> json) {
    return RedeemDetailModel(
      id: json['id'],
      redeemId: json['redeemId'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      productId: json['productId'],
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
      referenceNo: json['referenceNo'],
      attachment: json['attachment'] ?? '',
      createdBy: json['createdBy'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
      customerName: json["customerName"],
      taxNumber: json["taxNumber"],
      redeemDate: json['redeemDate'] != null
          ? DateTime.parse(json['redeemDate'])
          : null,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'redeemId': redeemId,
      'companyId': companyId,
      'branchId': branchId,
      'productId': productId,
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
      'referenceNo': referenceNo,
      'attachment': attachment,
      'createdBy': createdBy,
      'createdDate': createdDate?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedDate': updatedDate?.toIso8601String(),
      'customerName': customerName,
      'taxNumber': taxNumber,
      'redeemDate': redeemDate?.toIso8601String(),
    };
  }

  // Copy with method for immutability
  RedeemDetailModel copyWith({
    int? id,
    int? redeemId,
    int? companyId,
    int? branchId,
    int? productId,
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
    String? referenceNo,
    String? attachment,
    String? createdBy,
    DateTime? createdDate,
    String? updatedBy,
    DateTime? updatedDate,
    String? customerName,
    String? taxNumber,
    DateTime? redeemDate,
  }) {
    return RedeemDetailModel(
      id: id ?? this.id,
      redeemId: redeemId ?? this.redeemId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
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
      referenceNo: referenceNo ?? this.referenceNo,
      attachment: attachment ?? this.attachment,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedDate: updatedDate ?? this.updatedDate,
      customerName: customerName ?? this.customerName,
      taxNumber: taxNumber ?? this.taxNumber,
      redeemDate: redeemDate ?? this.redeemDate,
    );
  }
}
