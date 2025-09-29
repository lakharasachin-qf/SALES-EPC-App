import 'dart:convert';

MeterModel meterModelFromJson(String str) =>
    MeterModel.fromJson(json.decode(str));
String meterModelToJson(MeterModel data) => json.encode(data.toJson());

class MeterModel {
  bool status;
  String message;
  List<Meter> meters;
  String lastBillingMonth; // NEW FIELD
  Pagination pagination;

  MeterModel({
    required this.status,
    required this.message,
    required this.meters,
    required this.lastBillingMonth,
    required this.pagination,
  });

  factory MeterModel.fromJson(Map<String, dynamic> json) => MeterModel(
    status: json["status"],
    message: json["message"],
    meters: List<Meter>.from(json["meters"].map((x) => Meter.fromJson(x))),
    lastBillingMonth: json["last_billing_month"] ?? "",
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "meters": List<dynamic>.from(meters.map((x) => x.toJson())),
    "last_billing_month": lastBillingMonth,
    "pagination": pagination.toJson(),
  };
}

class Meter {
  String meterNo;
  dynamic meterReadingImgPath;

  Meter({required this.meterNo, required this.meterReadingImgPath});

  factory Meter.fromJson(Map<String, dynamic> json) => Meter(
    meterNo: json["meter_no"],
    meterReadingImgPath: json["meter_reading_img_path"],
  );

  Map<String, dynamic> toJson() => {
    "meter_no": meterNo,
    "meter_reading_img_path": meterReadingImgPath,
  };
}

class Pagination {
  int total;
  int perPage;
  int currentPage;
  int lastPage;
  int from;
  int to;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    perPage: json["per_page"],
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    from: json["from"],
    to: json["to"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "per_page": perPage,
    "current_page": currentPage,
    "last_page": lastPage,
    "from": from,
    "to": to,
  };
}
