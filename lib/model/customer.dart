// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

List<CustomerModel> customerListModelFromJson(String str) =>
    List<CustomerModel>.from(
        json.decode(str).map((x) => CustomerModel.fromJson(x)));

String customerListModelToJson(List<CustomerModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

CustomerModel customerModelFromJson(String str) =>
    CustomerModel.fromJson(json.decode(str));

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
  String? village;
  int? tambonId;
  String? tambonName;
  int? amphureId;
  String? amphureName;
  int? provinceId;
  String? provinceName;
  String? nationality;
  String? postalCode;
  String? photoUrl;
  String? idCard;
  String? taxNumber;
  DateTime? createdDate;
  DateTime? updatedDate;
  int? isSeller;
  int? isCustomer;
  int? isBuyer;
  String? customerType;
  String? remark;
  String? workPermit;
  String? passportId;
  String? branchCode;
  int? defaultWalkIn;

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
    this.village,
    this.tambonId,
    this.tambonName,
    this.amphureId,
    this.amphureName,
    this.provinceId,
    this.provinceName,
    this.nationality,
    this.postalCode,
    this.photoUrl,
    this.idCard,
    this.taxNumber,
    this.createdDate,
    this.updatedDate,
    this.isSeller,
    this.isCustomer,
    this.isBuyer,
    this.customerType,
    this.remark,
    this.workPermit,
    this.passportId,
    this.branchCode,
    this.defaultWalkIn,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json["id"],
        companyName: json["companyName"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        doB: json["doB"] == null ? null : DateTime.parse(json["doB"]).toLocal(),
        phoneNumber: json["phoneNumber"],
        username: json["username"],
        password: json["password"],
        address: json["address"],
        village: json["village"],
        tambonId: json["tambonId"],
        tambonName: json["tambonName"],
        amphureId: json["amphureId"],
        amphureName: json["amphureName"],
        provinceId: json["provinceId"],
        provinceName: json["provinceName"],
        nationality: json["nationality"],
        postalCode: json["postalCode"],
        photoUrl: json["photoUrl"],
        idCard: json["idCard"],
        taxNumber: json["taxNumber"],
        isSeller: json["isSeller"],
        isCustomer: json["isCustomer"],
        isBuyer: json["isBuyer"],
        customerType: json["customerType"],
        remark: json["remark"],
        workPermit: json["workPermit"],
        passportId: json["passportId"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]).toLocal(),
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]).toLocal(),
        branchCode: json["branchCode"],
        defaultWalkIn: json["defaultWalkIn"],
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
        "village": village,
        "tambonId": tambonId,
        "tambonName": tambonName,
        "amphureId": amphureId,
        "amphureName": amphureName,
        "provinceId": provinceId,
        "provinceName": provinceName,
        "nationality": nationality,
        "postalCode": postalCode,
        "photoUrl": photoUrl,
        "idCard": idCard,
        "taxNumber": taxNumber,
        "isSeller": isSeller,
        "isCustomer": isCustomer,
        "isBuyer": isBuyer,
        "customerType": customerType,
        "remark": remark,
        "workPermit": workPermit,
        "passportId": passportId,
        "createdDate": createdDate?.toIso8601String(),
        "updatedDate": updatedDate?.toIso8601String(),
        "branchCode": branchCode,
        "defaultWalkIn": defaultWalkIn,
      };

  @override
  String toString() {
    return 'CustomerModel{id: $id, firstName: $firstName, lastName: $lastName, companyName: $companyName, idCard: $idCard, taxNumber: $taxNumber}';
  }

  @override
  operator ==(o) => o is CustomerModel && o.id == id;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      companyName.hashCode & idCard.hashCode ^
      taxNumber.hashCode;

  @override
  bool filter(String query) {
    return firstName!.toLowerCase().contains(query.toLowerCase()) ||
        lastName!.toLowerCase().contains(query.toLowerCase()) ||
        companyName!.toLowerCase().contains(query.toLowerCase()) ||
        idCard!.toLowerCase().contains(query.toLowerCase()) ||
        taxNumber!.toLowerCase().contains(query.toLowerCase());
  }
}
