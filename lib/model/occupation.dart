// To parse this JSON data, do
//
//     final occupationModel = occupationModelFromJson(jsonString);

import 'dart:convert';
import 'occupation_category.dart';

List<OccupationModel> occupationListModelFromJson(String str) =>
    List<OccupationModel>.from(
        json.decode(str).map((x) => OccupationModel.fromJson(x)));

String occupationListModelToJson(List<OccupationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

OccupationModel occupationModelFromJson(String str) =>
    OccupationModel.fromJson(json.decode(str));

String occupationModelToJson(OccupationModel data) =>
    json.encode(data.toJson());

class OccupationModel {
  int? id;
  int? categoryId;
  String? category;
  String? name;
  String? customerType;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;
  OccupationCategoryModel? occupationCategory;

  OccupationModel({
    this.id,
    this.categoryId,
    this.category,
    this.name,
    this.customerType,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.occupationCategory,
  });

  factory OccupationModel.fromJson(Map<String, dynamic> json) =>
      OccupationModel(
        id: json["id"],
        categoryId: json["categoryId"],
        category: json["category"],
        name: json["name"],
        customerType: json["customerType"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]).toLocal(),
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]).toLocal(),
        occupationCategory: json["occupationCategory"] == null
            ? null
            : OccupationCategoryModel.fromJson(json["occupationCategory"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryId": categoryId,
        "category": category,
        "name": name,
        "customerType": customerType,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
        "occupationCategory": occupationCategory?.toJson(),
      };

  @override
  String toString() {
    return 'OccupationModel{id: $id, category: $category, name: $name, customerType: $customerType}';
  }

  @override
  operator ==(Object other) =>
      other is OccupationModel && other.id == id;

  @override
  int get hashCode => id.hashCode ^ category.hashCode ^ name.hashCode;
}

class _CategoryInfo {
  int displayOrder;
  List<OccupationModel> items;

  _CategoryInfo({required this.displayOrder, required this.items});
}

class OccupationGroup {
  String category;
  List<OccupationModel> items;
  int displayOrder;

  OccupationGroup({
    required this.category,
    required this.items,
    required this.displayOrder,
  });

  static List<OccupationGroup> groupByCategory(List<OccupationModel> occupations) {
    Map<String, _CategoryInfo> grouped = {};

    for (var occupation in occupations) {
      String category = occupation.category ?? 'อื่นๆ';
      int displayOrder = occupation.occupationCategory?.displayOrder ?? 999;

      if (!grouped.containsKey(category)) {
        grouped[category] = _CategoryInfo(
          displayOrder: displayOrder,
          items: [],
        );
      }
      grouped[category]!.items.add(occupation);
    }

    List<OccupationGroup> groups = grouped.entries.map((entry) {
      return OccupationGroup(
        category: entry.key,
        items: entry.value.items,
        displayOrder: entry.value.displayOrder,
      );
    }).toList();

    // Sort by display order
    groups.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return groups;
  }
}
