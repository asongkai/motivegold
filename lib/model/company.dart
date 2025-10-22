// To parse this JSON data, do
//
//     final companyModel = companyModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';

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

  // New PP.01 fields
  String? building;
  String? room;
  String? floor;
  String? villageNo;
  String? alley;
  String? road;
  String? subDistrict;
  String? postalCode;

  // Location IDs
  int? tambonId;
  int? amphureId;
  int? provinceId;

  // Navigation properties
  ProvinceModel? provinceNavigation;
  AmphureModel? amphureNavigation;
  TambonModel? tambonNavigation;

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
    this.building,
    this.room,
    this.floor,
    this.villageNo,
    this.alley,
    this.road,
    this.subDistrict,
    this.postalCode,
    this.tambonId,
    this.amphureId,
    this.provinceId,
    this.provinceNavigation,
    this.amphureNavigation,
    this.tambonNavigation,
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
    stock: json["stock"],
    building: json["building"],
    room: json["room"],
    floor: json["floor"],
    villageNo: json["villageNo"],
    alley: json["alley"],
    road: json["road"],
    subDistrict: json["subDistrict"],
    postalCode: json["postalCode"],
    tambonId: json["tambonId"],
    amphureId: json["amphureId"],
    provinceId: json["provinceId"],
    provinceNavigation: json["provinceNavigation"] == null
        ? null
        : ProvinceModel.fromJson(json["provinceNavigation"]),
    amphureNavigation: json["amphureNavigation"] == null
        ? null
        : AmphureModel.fromJson(json["amphureNavigation"]),
    tambonNavigation: json["tambonNavigation"] == null
        ? null
        : TambonModel.fromJson(json["tambonNavigation"]),
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
    "building": building,
    "room": room,
    "floor": floor,
    "villageNo": villageNo,
    "alley": alley,
    "road": road,
    "subDistrict": subDistrict,
    "postalCode": postalCode,
    "tambonId": tambonId,
    "amphureId": amphureId,
    "provinceId": provinceId,
    "provinceNavigation": provinceNavigation?.toJson(),
    "amphureNavigation": amphureNavigation?.toJson(),
    "tambonNavigation": tambonNavigation?.toJson(),
  };

  @override
  String toString() => name;

  @override
  operator ==(Object other) => other is CompanyModel && other.id == id;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}