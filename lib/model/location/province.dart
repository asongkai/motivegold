// To parse this JSON data, do
//
//     final provinceModel = provinceModelFromJson(jsonString);

import 'dart:convert';

List<ProvinceModel> provinceModelFromJson(String str) => List<ProvinceModel>.from(json.decode(str).map((x) => ProvinceModel.fromJson(x)));

String provinceModelToJson(List<ProvinceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProvinceModel {
  int? id;
  String? nameTh;
  String? nameEn;
  int? geographyId;

  ProvinceModel({
    this.id,
    this.nameTh,
    this.nameEn,
    this.geographyId,
  });

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
    id: json["id"],
    nameTh: json["nameTH"],
    nameEn: json["nameEN"],
    geographyId: json["geographyId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nameTH": nameTh,
    "nameEN": nameEn,
    "geographyId": geographyId,
  };

  @override
  String toString() {
    return 'ProvinceModel{id: $id, nameTH: $nameTh, nameEN: $nameEn}';
  }

  @override
  operator ==(o) => o is ProvinceModel && o.id == id;

  @override
  int get hashCode => id.hashCode^nameTh.hashCode^nameEn.hashCode;

  @override
  bool filter(String query) {
    return nameTh!.toLowerCase().contains(query.toLowerCase());
  }
}
