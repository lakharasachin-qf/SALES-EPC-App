// To parse this JSON data, do
//
//     final monthModel = monthModelFromJson(jsonString);

import 'dart:convert';

MonthModel monthModelFromJson(String str) =>
    MonthModel.fromJson(json.decode(str));

String monthModelToJson(MonthModel data) => json.encode(data.toJson());

class MonthModel {
  String previousMonthYear;

  MonthModel({required this.previousMonthYear});

  factory MonthModel.fromJson(Map<String, dynamic> json) =>
      MonthModel(previousMonthYear: json["previousMonthYear"]);

  Map<String, dynamic> toJson() => {"previousMonthYear": previousMonthYear};
}
