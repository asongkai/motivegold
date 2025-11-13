class OccupationCategoryModel {
  int? id;
  String? nameTH;
  String? nameEN;
  String? customerType;
  int? displayOrder;
  bool? isActive;
  String? createdBy;
  String? createdDate;
  String? updatedBy;
  String? updatedDate;

  OccupationCategoryModel({
    this.id,
    this.nameTH,
    this.nameEN,
    this.customerType,
    this.displayOrder,
    this.isActive,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  OccupationCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameTH = json['nameTH'];
    nameEN = json['nameEN'];
    customerType = json['customerType'];
    displayOrder = json['displayOrder'];
    isActive = json['isActive'];
    createdBy = json['createdBy'];
    createdDate = json['createdDate'];
    updatedBy = json['updatedBy'];
    updatedDate = json['updatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nameTH'] = nameTH;
    data['nameEN'] = nameEN;
    data['customerType'] = customerType;
    data['displayOrder'] = displayOrder;
    data['isActive'] = isActive;
    data['createdBy'] = createdBy;
    data['createdDate'] = createdDate;
    data['updatedBy'] = updatedBy;
    data['updatedDate'] = updatedDate;
    return data;
  }
}
