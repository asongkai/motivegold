// To parse this JSON data, do
//
//     final response = responseFromJson(jsonString);

import 'dart:convert';

List<Response> responseFromJson(String str) => List<Response>.from(json.decode(str).map((x) => Response.fromJson(x)));

String responseToJson(List<Response> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Response {
  Response({
    this.status,
    this.message,
    this.data,
  });

  String? status;
  String? message;
  dynamic data;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    status: json["status"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}
