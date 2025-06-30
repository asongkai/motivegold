// To parse this JSON data, do
//
//     final companyModel = companyModelFromJson(jsonString);

import 'dart:convert';

List<CompanyModel> companyListModelFromJson(String str) =>
    List<CompanyModel>.from(
        json.decode(str).map((x) => CompanyModel.fromJson(x)));

String companyListModelToJson(List<CompanyModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

CompanyModel companyModelFromJson(String str) =>
    CompanyModel.fromJson(json.decode(str));

String companyModelToJson(CompanyModel data) => json.encode(data.toJson());

class CompanyModel {
  int? id;
  String name;
  String? phone;
  String? email;
  String? address;
  String? village;
  String? district;
  String? province;
  String? taxNumber;
  String? logo;
  int? stock;

  CompanyModel({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.village,
    this.district,
    this.province,
    this.taxNumber,
    this.logo,
    this.stock,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        village: json["village"],
        district: json["district"],
        province: json["province"],
        taxNumber: json["taxNumber"],
        logo: json["logo"],
        stock: json["stock"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "village": village,
        "district": district,
        "province": province,
        "taxNumber": taxNumber,
        "logo": logo,
        "stock": stock,
      };

  @override
  String toString() => name;

  @override
  operator ==(o) => o is CompanyModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
