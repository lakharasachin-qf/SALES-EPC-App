// To parse this JSON data, do
//
//     final customerModelWp = customerModelWpFromJson(jsonString);

import 'dart:convert';

CustomerModelWp customerModelWpFromJson(String str) =>
    CustomerModelWp.fromJson(json.decode(str));

String customerModelWpToJson(CustomerModelWp data) =>
    json.encode(data.toJson());

class CustomerModelWp {
  bool status;
  String message;
  List<ResultWp> result;

  CustomerModelWp({
    required this.status,
    required this.message,
    required this.result,
  });

  factory CustomerModelWp.fromJson(Map<String, dynamic> json) =>
      CustomerModelWp(
        status: json["status"],
        message: json["message"],
        result: List<ResultWp>.from(
          json["result"].map((x) => ResultWp.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class ResultWp {
  int customerId;
  String customerName;
  List<String> meterNumbers;

  ResultWp({
    required this.customerId,
    required this.customerName,
    required this.meterNumbers,
  });

  factory ResultWp.fromJson(Map<String, dynamic> json) => ResultWp(
    customerId: json["customer_id"],
    customerName: json["customer_name"],
    meterNumbers: List<String>.from(json["meter_numbers"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId,
    "customer_name": customerName,
    "meter_numbers": List<dynamic>.from(meterNumbers.map((x) => x)),
  };
}

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});
}
