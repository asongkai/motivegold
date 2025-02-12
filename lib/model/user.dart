// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

List<UserModel> userListModelFromJson(String str) => List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));

String userListModelToJson(List<UserModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? id;
  int? companyId;
  int? branchId;
  String? email;
  String? firstName;
  String? lastName;
  String? username;
  String? phoneNumber;
  dynamic state;
  String? deviceToken;
  DateTime? lastLogin;
  DateTime? lastLogout;
  String? userRole;
  String? userType;

  UserModel({
    this.id,
    this.companyId,
    this.branchId,
    this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.phoneNumber,
    this.state,
    this.deviceToken,
    this.lastLogin,
    this.lastLogout,
    this.userRole,
    this.userType
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    email: json["email"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    username: json["username"],
    phoneNumber: json["phoneNumber"],
    state: json["state"],
    deviceToken: json["deviceToken"],
    lastLogin: json["lastLogin"] == null ? null : DateTime.parse(json["lastLogin"]).toLocal(),
    lastLogout: json["lastLogout"] == null ? null : DateTime.parse(json["lastLogout"]).toLocal(),
    userRole: json["userRole"],
    userType: json["userType"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "branchId": branchId,
    "email": email,
    "firstName": firstName,
    "lastName": lastName,
    "username": username,
    "phoneNumber": phoneNumber,
    "state": state,
    "deviceToken": deviceToken,
    "lastLogin": lastLogin?.toIso8601String(),
    "lastLogout": lastLogout?.toIso8601String(),
    "userRole": userRole,
    "userType": userType,
  };
}
