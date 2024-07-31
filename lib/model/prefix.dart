// To parse this JSON data, do
//
//     final prefixModel = prefixModelFromJson(jsonString);

import 'dart:convert';

PrefixModel prefixModelFromJson(String str) => PrefixModel.fromJson(json.decode(str));

String prefixModelToJson(PrefixModel data) => json.encode(data.toJson());

class PrefixModel {
  int? companyId;
  String? settingMode;
  String? prefix;

  PrefixModel({
    this.companyId,
    this.settingMode,
    this.prefix,
  });

  factory PrefixModel.fromJson(Map<String, dynamic> json) => PrefixModel(
    companyId: json["companyId"],
    settingMode: json["settingMode"],
    prefix: json["prefix"],
  );

  Map<String, dynamic> toJson() => {
    "companyId": companyId,
    "settingMode": settingMode,
    "prefix": prefix,
  };
}
