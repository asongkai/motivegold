// To parse this JSON data, do
//
//     final tambonModel = tambonModelFromJson(jsonString);

import 'dart:convert';

List<TambonModel> tambonModelFromJson(String str) => List<TambonModel>.from(json.decode(str).map((x) => TambonModel.fromJson(x)));

String tambonModelToJson(List<TambonModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TambonModel {
  int? id;
  int? zipCode;
  String? nameTh;
  String? nameEn;
  int? amphureId;

  TambonModel({
    this.id,
    this.zipCode,
    this.nameTh,
    this.nameEn,
    this.amphureId,
  });

  factory TambonModel.fromJson(Map<String, dynamic> json) => TambonModel(
    id: json["id"],
    zipCode: json["zipCode"],
    nameTh: json["nameTH"],
    nameEn: json["nameEN"],
    amphureId: json["amphureId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "zipCode": zipCode,
    "nameTH": nameTh,
    "nameEN": nameEn,
    "amphureId": amphureId,
  };

  @override
  String toString() {
    return 'TambonModel{id: $id, nameTH: $nameTh, nameEN: $nameEn}';
  }

  @override
  operator ==(o) => o is TambonModel && o.id == id;

  @override
  int get hashCode => id.hashCode^nameTh.hashCode^nameEn.hashCode;

  @override
  bool filter(String query) {
    return nameTh!.toLowerCase().contains(query.toLowerCase());
  }
}
