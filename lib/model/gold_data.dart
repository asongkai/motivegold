// To parse this JSON data, do
//
//     final goldDataModel = goldDataModelFromJson(jsonString);

import 'dart:convert';

GoldDataModel goldDataModelFromJson(String str) =>
    GoldDataModel.fromJson(json.decode(str));

String goldDataModelToJson(GoldDataModel data) => json.encode(data.toJson());

class GoldDataModel {
  String? date;
  Lakha? theng;
  Lakha? paphun;

  GoldDataModel({
    this.date,
    this.theng,
    this.paphun,
  });

  factory GoldDataModel.fromJson(Map<String, dynamic> json) => GoldDataModel(
        date: json["date"],
        theng: json["theng"] == null ? null : Lakha.fromJson(json["theng"]),
        paphun: json["paphun"] == null ? null : Lakha.fromJson(json["paphun"]),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "theng": theng?.toJson(),
        "paphun": paphun?.toJson(),
      };
}

class Lakha {
  String? buy;
  String? sell;

  Lakha({
    this.buy,
    this.sell,
  });

  factory Lakha.fromJson(Map<String, dynamic> json) => Lakha(
        buy: json["buy"],
        sell: json["sell"],
      );

  Map<String, dynamic> toJson() => {
        "buy": buy,
        "sell": sell,
      };
}
