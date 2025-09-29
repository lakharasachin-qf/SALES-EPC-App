// To parse this JSON data, do
//
//     final meterDetails = meterDetailsFromJson(jsonString);

import 'dart:convert';

MeterDetails meterDetailsFromJson(String str) =>
    MeterDetails.fromJson(json.decode(str));

String meterDetailsToJson(MeterDetails data) => json.encode(data.toJson());

class MeterDetails {
  bool status;
  String message;
  ResultMd result;

  MeterDetails({
    required this.status,
    required this.message,
    required this.result,
  });

  factory MeterDetails.fromJson(Map<String, dynamic> json) => MeterDetails(
    status: json["status"],
    message: json["message"],
    result: ResultMd.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result.toJson(),
  };
}

class ResultMd {
  String meterNo;
  String connectionNumber;
  String buildingName;
  String? meterReadingImg; // nullable
  String? closingMeterReading; // nullable

  ResultMd({
    required this.meterNo,
    required this.connectionNumber,
    required this.buildingName,
    this.meterReadingImg,
    this.closingMeterReading,
  });

  factory ResultMd.fromJson(Map<String, dynamic> json) => ResultMd(
    meterNo: json["meter_no"],
    connectionNumber: json["connection_number"],
    buildingName: json["building_name"],
    meterReadingImg: json["meter_reading_img"] ?? '', // nullable
    closingMeterReading: json["closing_meter_reading"] ?? '', // nullable
  );

  Map<String, dynamic> toJson() => {
    "meter_no": meterNo,
    "connection_number": connectionNumber,
    "building_name": buildingName,
    "meter_reading_img": meterReadingImg,
    "closing_meter_reading": closingMeterReading,
  };
}
