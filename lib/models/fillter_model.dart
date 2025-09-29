// To parse this JSON data, do
//
//     final filtterModel = filtterModelFromJson(jsonString);

import 'dart:convert';

FiltterModel filtterModelFromJson(String str) =>
    FiltterModel.fromJson(json.decode(str));

String filtterModelToJson(FiltterModel data) => json.encode(data.toJson());

class FiltterModel {
  bool status;
  String message;
  Result result;

  FiltterModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory FiltterModel.fromJson(Map<String, dynamic> json) => FiltterModel(
    status: json["status"],
    message: json["message"],
    result: Result.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result.toJson(),
  };
}

class Result {
  List<Category> groups;
  List<Category> categories;
  List<Category> clusters;
  List<Category> customers;

  Result({
    required this.groups,
    required this.categories,
    required this.clusters,
    required this.customers,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    groups: List<Category>.from(
      json["groups"].map((x) => Category.fromJson(x)),
    ),
    categories: List<Category>.from(
      json["categories"].map((x) => Category.fromJson(x)),
    ),
    clusters: List<Category>.from(
      json["clusters"].map((x) => Category.fromJson(x)),
    ),
    customers: List<Category>.from(
      json["customers"].map((x) => Category.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "groups": List<dynamic>.from(groups.map((x) => x.toJson())),
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "clusters": List<dynamic>.from(clusters.map((x) => x.toJson())),
    "customers": List<dynamic>.from(customers.map((x) => x.toJson())),
  };
}

class Category {
  int id;
  String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
