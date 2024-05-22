// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

List<CustomerModel> customerListModelFromJson(String str) => List<CustomerModel>.from(json.decode(str).map((x) => CustomerModel.fromJson(x)));

String customerListModelToJson(List<CustomerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

CustomerModel customerModelFromJson(String str) => CustomerModel.fromJson(json.decode(str));

String customerModelToJson(CustomerModel data) => json.encode(data.toJson());

class CustomerModel {
  int? id;
  String? companyName;
  String? firstName;
  String? lastName;
  String? email;
  DateTime? doB;
  String? phoneNumber;
  String? username;
  String? password;
  String? address;
  String? district;
  String? province;
  String? nationality;
  String? postalCode;
  String? photoUrl;
  String? idCard;
  String? taxNumber;
  DateTime? createdDate;
  DateTime? updatedDate;

  CustomerModel({
    this.id,
    this.companyName,
    this.firstName,
    this.lastName,
    this.email,
    this.doB,
    this.phoneNumber,
    this.username,
    this.password,
    this.address,
    this.district,
    this.province,
    this.nationality,
    this.postalCode,
    this.photoUrl,
    this.idCard,
    this.taxNumber,
    this.createdDate,
    this.updatedDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json["id"],
    companyName: json["companyName"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    doB: json["doB"] == null ? null : DateTime.parse(json["doB"]),
    phoneNumber: json["phoneNumber"],
    username: json["username"],
    password: json["password"],
    address: json["address"],
    district: json["district"],
    province: json["province"],
    nationality: json["nationality"],
    postalCode: json["postalCode"],
    photoUrl: json["photoUrl"],
    idCard: json["idCard"],
    taxNumber: json["taxNumber"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyName": companyName,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "doB": doB?.toIso8601String(),
    "phoneNumber": phoneNumber,
    "username": username,
    "password": password,
    "address": address,
    "district": district,
    "province": province,
    "nationality": nationality,
    "postalCode": postalCode,
    "photoUrl": photoUrl,
    "idCard": idCard,
    "taxNumber": taxNumber,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
