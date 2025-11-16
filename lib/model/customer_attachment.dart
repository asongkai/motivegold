import 'dart:convert';

List<CustomerAttachmentModel> customerAttachmentListFromJson(String str) =>
    List<CustomerAttachmentModel>.from(
        json.decode(str).map((x) => CustomerAttachmentModel.fromJson(x)));

String customerAttachmentListToJson(List<CustomerAttachmentModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

CustomerAttachmentModel customerAttachmentFromJson(String str) =>
    CustomerAttachmentModel.fromJson(json.decode(str));

String customerAttachmentToJson(CustomerAttachmentModel data) =>
    json.encode(data.toJson());

class CustomerAttachmentModel {
  int? id;
  int? customerId;
  String? attachmentType;
  String? fileName;
  String? filePath;
  int? fileSize;
  String? mimeType;
  DateTime? attachmentDate;
  DateTime? uploadedDate;
  String? uploadedBy;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;

  CustomerAttachmentModel({
    this.id,
    this.customerId,
    this.attachmentType,
    this.fileName,
    this.filePath,
    this.fileSize,
    this.mimeType,
    this.attachmentDate,
    this.uploadedDate,
    this.uploadedBy,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory CustomerAttachmentModel.fromJson(Map<String, dynamic> json) =>
      CustomerAttachmentModel(
        id: json["id"],
        customerId: json["customerId"],
        attachmentType: json["attachmentType"],
        fileName: json["fileName"],
        filePath: json["filePath"],
        fileSize: json["fileSize"],
        mimeType: json["mimeType"],
        attachmentDate: json["attachmentDate"] == null
            ? null
            : DateTime.parse(json["attachmentDate"]).toLocal(),
        uploadedDate: json["uploadedDate"] == null
            ? null
            : DateTime.parse(json["uploadedDate"]).toLocal(),
        uploadedBy: json["uploadedBy"],
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
        "customerId": customerId,
        "attachmentType": attachmentType,
        "fileName": fileName,
        "filePath": filePath,
        "fileSize": fileSize,
        "mimeType": mimeType,
        "attachmentDate": attachmentDate?.toIso8601String(),
        "uploadedDate": uploadedDate?.toIso8601String(),
        "uploadedBy": uploadedBy,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
      };

  @override
  String toString() {
    return 'CustomerAttachmentModel{id: $id, customerId: $customerId, attachmentType: $attachmentType, fileName: $fileName}';
  }
}
