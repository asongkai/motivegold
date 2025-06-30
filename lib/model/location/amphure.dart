// To parse this JSON data, do
//
//     final amphureModel = amphureModelFromJson(jsonString);

import 'dart:convert';

List<AmphureModel> amphureModelFromJson(String str) => List<AmphureModel>.from(
    json.decode(str).map((x) => AmphureModel.fromJson(x)));

String amphureModelToJson(List<AmphureModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AmphureModel {
  int? id;
  String? nameTh;
  String? nameEn;
  int? provinceId;

  AmphureModel({
    this.id,
    this.nameTh,
    this.nameEn,
    this.provinceId,
  });

  factory AmphureModel.fromJson(Map<String, dynamic> json) => AmphureModel(
        id: json["id"],
        nameTh: json["nameTH"],
        nameEn: json["nameEN"],
        provinceId: json["provinceId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nameTH": nameTh,
        "nameEN": nameEn,
        "provinceId": provinceId,
      };

  @override
  String toString() {
    return 'AmphureModel{id: $id, nameTH: $nameTh, nameEN: $nameEn}';
  }

  @override
  operator ==(o) => o is AmphureModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ nameTh.hashCode ^ nameEn.hashCode;

  @override
  bool filter(String query) {
    return nameTh!.toLowerCase().contains(query.toLowerCase());
  }
}
