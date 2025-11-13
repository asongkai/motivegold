class TitleNameCategoryModel {
  int? id;
  String? nameTH;
  String? nameEN;
  int? displayOrder;
  bool? isActive;
  String? createdBy;
  String? createdDate;
  String? updatedBy;
  String? updatedDate;

  TitleNameCategoryModel({
    this.id,
    this.nameTH,
    this.nameEN,
    this.displayOrder,
    this.isActive,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  TitleNameCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameTH = json['nameTH'];
    nameEN = json['nameEN'];
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
    data['displayOrder'] = displayOrder;
    data['isActive'] = isActive;
    data['createdBy'] = createdBy;
    data['createdDate'] = createdDate;
    data['updatedBy'] = updatedBy;
    data['updatedDate'] = updatedDate;
    return data;
  }
}
