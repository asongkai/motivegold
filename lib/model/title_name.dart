// To parse this JSON data, do
//
//     final titleNameModel = titleNameModelFromJson(jsonString);

import 'dart:convert';
import 'title_name_category.dart';

List<TitleNameModel> titleNameListModelFromJson(String str) =>
    List<TitleNameModel>.from(
        json.decode(str).map((x) => TitleNameModel.fromJson(x)));

String titleNameListModelToJson(List<TitleNameModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

TitleNameModel titleNameModelFromJson(String str) =>
    TitleNameModel.fromJson(json.decode(str));

String titleNameModelToJson(TitleNameModel data) =>
    json.encode(data.toJson());

class TitleNameModel {
  int? id;
  int? categoryId;
  String? category;
  String? name;
  String? customerType;
  String? nationality;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;
  TitleNameCategoryModel? titleNameCategory;

  TitleNameModel({
    this.id,
    this.categoryId,
    this.category,
    this.name,
    this.customerType,
    this.nationality,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.titleNameCategory,
  });

  factory TitleNameModel.fromJson(Map<String, dynamic> json) =>
      TitleNameModel(
        id: json["id"],
        categoryId: json["categoryId"],
        category: json["category"],
        name: json["name"],
        customerType: json["customerType"],
        nationality: json["nationality"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]).toLocal(),
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]).toLocal(),
        titleNameCategory: json["titleNameCategory"] == null
            ? null
            : TitleNameCategoryModel.fromJson(json["titleNameCategory"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryId": categoryId,
        "category": category,
        "name": name,
        "customerType": customerType,
        "nationality": nationality,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
        "titleNameCategory": titleNameCategory?.toJson(),
      };

  @override
  String toString() {
    return 'TitleNameModel{id: $id, category: $category, name: $name, customerType: $customerType, nationality: $nationality}';
  }

  @override
  operator ==(Object other) =>
      other is TitleNameModel && other.id == id;

  @override
  int get hashCode => id.hashCode ^ category.hashCode ^ name.hashCode;
}

// Helper class for grouping title names by category
class TitleNameGroup {
  String category;
  List<TitleNameModel> items;
  int displayOrder;

  TitleNameGroup({
    required this.category,
    required this.items,
    this.displayOrder = 999,
  });

  static List<TitleNameGroup> groupByCategory(List<TitleNameModel> titleNames) {
    Map<String, _CategoryInfo> grouped = {};

    for (var titleName in titleNames) {
      String category = titleName.category ?? 'อื่นๆ';
      int displayOrder = titleName.titleNameCategory?.displayOrder ?? 999;

      if (!grouped.containsKey(category)) {
        grouped[category] = _CategoryInfo(
          displayOrder: displayOrder,
          items: [],
        );
      }
      grouped[category]!.items.add(titleName);
    }

    // Convert map to list and sort by display order
    var groups = grouped.entries
        .map((entry) => TitleNameGroup(
              category: entry.key,
              items: entry.value.items,
              displayOrder: entry.value.displayOrder,
            ))
        .toList();

    // Sort by display order, then by category name
    groups.sort((a, b) {
      int orderCompare = a.displayOrder.compareTo(b.displayOrder);
      if (orderCompare != 0) return orderCompare;
      return a.category.compareTo(b.category);
    });

    return groups;
  }
}

// Helper class to store category info during grouping
class _CategoryInfo {
  int displayOrder;
  List<TitleNameModel> items;

  _CategoryInfo({
    required this.displayOrder,
    required this.items,
  });
}
