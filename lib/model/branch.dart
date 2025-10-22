// To parse this JSON data, do
//
//     final branchModel = branchModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';

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
  String? oldGoldLicenseNumber;

  // Headquarter flag
  bool? isHeadquarter;

  // Show abbreviated name on receipt (for branch mode)
  bool? showAbbreviatedName;

  // New PP.01 address fields
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

  BranchModel({
    this.id,
    this.companyId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.village,
    this.district,
    this.province,
    this.branchId,
    this.branchCode,
    this.oldGoldLicenseNumber,
    this.isHeadquarter,
    this.showAbbreviatedName,
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
    oldGoldLicenseNumber: json["oldGoldLicenseNumber"],
    isHeadquarter: json["isHeadquarter"],
    showAbbreviatedName: json["showAbbreviatedName"],
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
    "oldGoldLicenseNumber": oldGoldLicenseNumber,
    "isHeadquarter": isHeadquarter,
    "showAbbreviatedName": showAbbreviatedName,
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
  operator ==(Object other) => other is BranchModel && other.id == id;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}