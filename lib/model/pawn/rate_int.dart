import 'dart:convert';

List<RateIntModel> rateIntListModelFromJson(String str) =>
    List<RateIntModel>.from(json.decode(str).map((x) => RateIntModel.fromJson(x)));

String rateIntListModelToJson(List<RateIntModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

RateIntModel rateIntModelFromJson(String str) => RateIntModel.fromJson(json.decode(str));

String rateIntModelToJson(RateIntModel data) => json.encode(data.toJson());

class RateIntModel {
  int? id;
  String? name;
  double? amountFrom;
  double? amountTo;
  double? rate;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;
  int? companyId;
  int? branchId;

  RateIntModel({
    this.id,
    this.name,
    this.amountFrom,
    this.amountTo,
    this.rate,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.companyId,
    this.branchId,
  });

  factory RateIntModel.fromJson(Map<String, dynamic> json) => RateIntModel(
    id: json["id"],
    name: json["name"],
    amountFrom: json["amountFrom"]?.toDouble(),
    amountTo: json["amountTo"]?.toDouble(),
    rate: json["rate"]?.toDouble(),
    createdBy: json["createdBy"],
    createdDate: json["createdDate"] == null
        ? null
        : DateTime.parse(json["createdDate"]),
    updatedBy: json["updatedBy"],
    updatedDate: json["updatedDate"] == null
        ? null
        : DateTime.parse(json["updatedDate"]),
    companyId: json["companyId"],
    branchId: json["branchId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "amountFrom": amountFrom,
    "amountTo": amountTo,
    "rate": rate,
    "createdBy": createdBy,
    "createdDate": createdDate?.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedDate": updatedDate?.toIso8601String(),
    "companyId": companyId,
    "branchId": branchId,
  };
}