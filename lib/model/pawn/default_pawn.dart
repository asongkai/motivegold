// File: lib/model/default_pawn.dart

import 'dart:convert';

class DefaultPawnModel {
  final int? id;
  final int? companyId;
  final int? branchId;
  final int? taxTypeId;
  final String? taxTypeName;
  final int? taxPointId;
  final String? taxPointName;
  final String? name;
  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

  DefaultPawnModel({
    this.id,
    this.companyId,
    this.branchId,
    this.taxTypeId,
    this.taxTypeName,
    this.taxPointId,
    this.taxPointName,
    this.name,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory DefaultPawnModel.fromJson(Map<String, dynamic> json) {
    return DefaultPawnModel(
      id: json['id'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      taxTypeId: json['taxTypeId'],
      taxTypeName: json['taxTypeName'],
      taxPointId: json['taxPointId'],
      taxPointName: json['taxPointName'],
      name: json['name'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate']).toLocal()
          : null,
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'branchId': branchId,
      'taxTypeId': taxTypeId,
      'taxTypeName': taxTypeName,
      'taxPointId': taxPointId,
      'taxPointName': taxPointName,
      'name': name,
      'createdBy': createdBy,
      'createdDate': createdDate?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedDate': updatedDate?.toIso8601String(),
    };
  }

  DefaultPawnModel copyWith({
    int? id,
    int? companyId,
    int? branchId,
    int? taxTypeId,
    String? taxTypeName,
    int? taxPointId,
    String? taxPointName,
    String? name,
    String? createdBy,
    DateTime? createdDate,
    String? updatedBy,
    DateTime? updatedDate,
  }) {
    return DefaultPawnModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      taxTypeId: taxTypeId ?? this.taxTypeId,
      taxTypeName: taxTypeName ?? this.taxTypeName,
      taxPointId: taxPointId ?? this.taxPointId,
      taxPointName: taxPointName ?? this.taxPointName,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  String toString() {
    return 'DefaultPawnModel(id: $id, companyId: $companyId, branchId: $branchId, '
        'taxTypeId: $taxTypeId, taxTypeName: $taxTypeName, '
        'taxPointId: $taxPointId, taxPointName: $taxPointName, '
        'name: $name, createdBy: $createdBy, createdDate: $createdDate, '
        'updatedBy: $updatedBy, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DefaultPawnModel &&
        other.id == id &&
        other.companyId == companyId &&
        other.branchId == branchId &&
        other.taxTypeId == taxTypeId &&
        other.taxTypeName == taxTypeName &&
        other.taxPointId == taxPointId &&
        other.taxPointName == taxPointName &&
        other.name == name &&
        other.createdBy == createdBy &&
        other.createdDate == createdDate &&
        other.updatedBy == updatedBy &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    companyId.hashCode ^
    branchId.hashCode ^
    taxTypeId.hashCode ^
    taxTypeName.hashCode ^
    taxPointId.hashCode ^
    taxPointName.hashCode ^
    name.hashCode ^
    createdBy.hashCode ^
    createdDate.hashCode ^
    updatedBy.hashCode ^
    updatedDate.hashCode;
  }
}

// Helper function to parse list from JSON
List<DefaultPawnModel> defaultPawnListModelFromJson(String str) {
  final List<dynamic> jsonData = json.decode(str);
  return jsonData.map((x) => DefaultPawnModel.fromJson(x)).toList();
}

String defaultPawnListModelToJson(List<DefaultPawnModel> data) {
  final List<dynamic> jsonData = data.map((x) => x.toJson()).toList();
  return json.encode(jsonData);
}

// Tax Type Model
class TaxTypeModel {
  final int id;
  final String name;

  TaxTypeModel({required this.id, required this.name});

  factory TaxTypeModel.fromJson(Map<String, dynamic> json) {
    return TaxTypeModel(
      id: json['id'] ?? json['id'] ?? 0,
      name: json['name'] ?? json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => name;

  @override
  operator ==(o) => o is TaxTypeModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

// Tax Point Model
class TaxPointModel {
  final int id;
  final String name;
  final int taxTypeId;

  TaxPointModel({required this.id, required this.name, required this.taxTypeId});

  factory TaxPointModel.fromJson(Map<String, dynamic> json) {
    return TaxPointModel(
      id: json['id'] ?? json['id'] ?? 0,
      name: json['name'] ?? json['name'] ?? '',
      taxTypeId: json['taxTypeId'] ?? json['taxTypeId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taxTypeId': taxTypeId,
    };
  }

  @override
  String toString() => name;

  @override
  operator ==(o) => o is TaxPointModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}