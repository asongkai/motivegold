// To parse this JSON data, do
//
//     final branchModel = branchModelFromJson(jsonString);

import 'dart:convert';

List<BranchModel> branchListModelFromJson(String str) => List<BranchModel>.from(
    json.decode(str).map((x) => BranchModel.fromJson(x)));

String branchListModelToJson(List<BranchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

BranchModel branchModelFromJson(String str) =>
    BranchModel.fromJson(json.decode(str));

String branchModelToJson(BranchModel data) => json.encode(data.toJson());

class BranchModel {
  int? id;
  int? companyId;
  String name;
  String? phone;
  String? email;
  String? address;
  String? village;
  String? district;
  String? province;
  String? branchCode;
  String? branchId;

  BranchModel(
      {this.id,
      this.companyId,
      required this.name,
      this.phone,
      this.email,
      this.address,
      this.village,
      this.district,
      this.province,
      this.branchId,
      this.branchCode});

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        id: json["id"],
        companyId: json["companyId"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        village: json["village"],
        district: json["district"],
        province: json["province"],
        branchId: json["branchId"],
        branchCode: json["branchCode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyId": companyId,
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "village": village,
        "district": district,
        "province": province,
        "branchCode": branchCode,
        "branchId": branchId,
      };

  @override
  String toString() => name;

  @override
  operator ==(o) => o is BranchModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
