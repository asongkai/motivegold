// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

List<CustomerModel> customerListModelFromJson(String str) => List<CustomerModel>.from(json.decode(str).map((x) => CustomerModel.fromJson(x)));

String customerListModelToJson(List<CustomerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

CustomerModel customerModelFromJson(String str) => CustomerModel.fromJson(json.decode(str));

String customerModelToJson(CustomerModel data) => json.encode(data.toJson());

class CustomerModel {
  String? id;
  String? idCard;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? dob;
  String? province;
  String? district;
  String? village;
  String? address;

  CustomerModel({
    this.id,
    this.idCard,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.dob,
    this.province,
    this.district,
    this.village,
    this.address,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json["id"],
    idCard: json["id_card"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    dob: json["dob"],
    province: json["province"],
    district: json["district"],
    village: json["village"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_card": idCard,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "dob": dob,
    "province": province,
    "district": district,
    "village": village,
    "address": address,
  };
}
