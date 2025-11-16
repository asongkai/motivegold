// To parse this JSON data, do
//
//     final nationalityModel = nationalityModelFromJson(jsonString);

import 'dart:convert';

List<NationalityModel> nationalityListModelFromJson(String str) =>
    List<NationalityModel>.from(
        json.decode(str).map((x) => NationalityModel.fromJson(x)));

String nationalityListModelToJson(List<NationalityModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

NationalityModel nationalityModelFromJson(String str) =>
    NationalityModel.fromJson(json.decode(str));

String nationalityModelToJson(NationalityModel data) =>
    json.encode(data.toJson());

class NationalityModel {
  int? id;
  String? countryTH;
  String? countryEN;
  String? nationalityTH;
  String? nationalityEN;
  String? iso;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;

  NationalityModel({
    this.id,
    this.countryTH,
    this.countryEN,
    this.nationalityTH,
    this.nationalityEN,
    this.iso,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory NationalityModel.fromJson(Map<String, dynamic> json) =>
      NationalityModel(
        id: json["id"],
        countryTH: json["countryTH"],
        countryEN: json["countryEN"],
        nationalityTH: json["nationalityTH"],
        nationalityEN: json["nationalityEN"],
        iso: json["iso"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]).toLocal(),
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "countryTH": countryTH,
        "countryEN": countryEN,
        "nationalityTH": nationalityTH,
        "nationalityEN": nationalityEN,
        "iso": iso,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
      };

  @override
  String toString() {
    return 'NationalityModel{id: $id, countryTH: $countryTH, countryEN: $countryEN, nationalityTH: $nationalityTH, nationalityEN: $nationalityEN, iso: $iso}';
  }

  @override
  operator ==(Object other) =>
      other is NationalityModel && other.id == id;

  @override
  int get hashCode => id.hashCode ^ countryTH.hashCode ^ iso.hashCode;

  // Getter for compatibility with DropDownItemWidget
  String? get name => nationalityTH;

  bool filter(String query) {
    return nationalityTH!.toLowerCase().contains(query.toLowerCase()) ||
           (nationalityEN?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
           (countryTH?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
           (countryEN?.toLowerCase().contains(query.toLowerCase()) ?? false);
  }
}
