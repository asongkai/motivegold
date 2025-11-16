// To parse this JSON data, do
//
//     final cardTypeModel = cardTypeModelFromJson(jsonString);

import 'dart:convert';

List<CardTypeModel> cardTypeListModelFromJson(String str) =>
    List<CardTypeModel>.from(
        json.decode(str).map((x) => CardTypeModel.fromJson(x)));

String cardTypeListModelToJson(List<CardTypeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

CardTypeModel cardTypeModelFromJson(String str) =>
    CardTypeModel.fromJson(json.decode(str));

String cardTypeModelToJson(CardTypeModel data) => json.encode(data.toJson());

class CardTypeModel {
  int? id;
  String? nameTH;
  String? nameEN;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;

  CardTypeModel({
    this.id,
    this.nameTH,
    this.nameEN,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory CardTypeModel.fromJson(Map<String, dynamic> json) => CardTypeModel(
        id: json["id"],
        nameTH: json["nameTH"],
        nameEN: json["nameEN"],
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
        "nameTH": nameTH,
        "nameEN": nameEN,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
      };

  @override
  String toString() {
    return 'CardTypeModel{id: $id, nameTH: $nameTH, nameEN: $nameEN}';
  }

  @override
  operator ==(Object other) =>
      other is CardTypeModel && other.id == id;

  @override
  int get hashCode => id.hashCode ^ nameTH.hashCode ^ nameEN.hashCode;

  // Getter for compatibility with DropDownItemWidget
  String? get name => nameTH;

  bool filter(String query) {
    return nameTH!.toLowerCase().contains(query.toLowerCase()) ||
           (nameEN?.toLowerCase().contains(query.toLowerCase()) ?? false);
  }
}
