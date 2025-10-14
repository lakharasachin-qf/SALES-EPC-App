import 'dart:convert';

CustomerModel customerModelFromJson(String str) =>
    CustomerModel.fromJson(json.decode(str));

String customerModelToJson(CustomerModel data) => json.encode(data.toJson());

class CustomerModel {
  bool status;
  String message;
  List<Result> result;
  Pagination pagination;

  CustomerModel({
    required this.status,
    required this.message,
    required this.result,
    required this.pagination,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    status: json["status"],
    message: json["message"],
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
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

class Result {
  int customerId;
  String connectionNo;
  String customerName;
  ContactPerson contactPerson;
  BillToName billToName;
  String businessUnit;
  String solarCapacity;
  String invertorCapacity;
  dynamic categoryId;
  String address;
  String zipcode;
  String mobileNo;
  CustomerStatus customerStatus;
  DateTime liveDate;
  DateTime ppaDate;
  CustomerType customerType;
  String cafNo;
  dynamic email;
  GstStatus gstStatus;
  String gstNo;
  String location;
  String customerShortName;
  CategoryName categoryName;
  List<String> meterNumbers;

  Result({
    required this.customerId,
    required this.connectionNo,
    required this.customerName,
    required this.contactPerson,
    required this.billToName,
    required this.businessUnit,
    required this.solarCapacity,
    required this.invertorCapacity,
    required this.categoryId,
    required this.address,
    required this.zipcode,
    required this.mobileNo,
    required this.customerStatus,
    required this.liveDate,
    required this.ppaDate,
    required this.customerType,
    required this.cafNo,
    required this.email,
    required this.gstStatus,
    required this.gstNo,
    required this.location,
    required this.customerShortName,
    required this.categoryName,
    required this.meterNumbers,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    customerId: json["customer_id"] ?? 0,
    connectionNo: json["connection_no"] ?? "",
    customerName: json["customer_name"] ?? "",
    contactPerson:
        contactPersonValues.map[json["contact_person"]] ??
        ContactPerson.SANTOSH_KUMAR,
    billToName:
        billToNameValues.map[json["bill_to_name"]] ?? BillToName.THE_DIRECTOR,
    businessUnit: json["business_unit"] ?? "",
    solarCapacity: json["solar_capacity"] ?? "",
    invertorCapacity: json["invertor_capacity"] ?? "",
    categoryId: json["category_id"],
    address: json["address"] ?? "",
    zipcode: json["zipcode"] ?? "",
    mobileNo: json["mobile_no"] ?? "",
    customerStatus:
        customerStatusValues.map[json["customer_status"]] ??
        CustomerStatus.ACTIVE,
    liveDate: DateTime.tryParse(json["live_date"] ?? "") ?? DateTime(2000),
    ppaDate: DateTime.tryParse(json["ppa_date"] ?? "") ?? DateTime(2000),
    customerType:
        customerTypeValues.map[json["customer_type"]] ?? CustomerType.RESCO,
    cafNo: json["caf_no"] ?? "",
    email: json["email"] ?? "",
    gstStatus: gstStatusValues.map[json["gst_status"]] ?? GstStatus.REGISTERED,
    gstNo: json["gst_no"] ?? "",
    location: json["location"] ?? "",
    customerShortName: json["customer_short_name"] ?? "",
    categoryName:
        categoryNameValues.map[json["category_name"]] ??
        CategoryName.AUTONOMOUS,
    meterNumbers: json["meter_numbers"] != null
        ? List<String>.from(json["meter_numbers"].map((x) => x))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId,
    "connection_no": connectionNo,
    "customer_name": customerName,
    "contact_person": contactPersonValues.reverse[contactPerson],
    "bill_to_name": billToNameValues.reverse[billToName],
    "business_unit": businessUnit,
    "solar_capacity": solarCapacity,
    "invertor_capacity": invertorCapacity,
    "category_id": categoryId,
    "address": address,
    "zipcode": zipcode,
    "mobile_no": mobileNo,
    "customer_status": customerStatusValues.reverse[customerStatus],
    "live_date":
        "${liveDate.year.toString().padLeft(4, '0')}-${liveDate.month.toString().padLeft(2, '0')}-${liveDate.day.toString().padLeft(2, '0')}",
    "ppa_date":
        "${ppaDate.year.toString().padLeft(4, '0')}-${ppaDate.month.toString().padLeft(2, '0')}-${ppaDate.day.toString().padLeft(2, '0')}",
    "customer_type": customerTypeValues.reverse[customerType],
    "caf_no": cafNo,
    "email": email,
    "gst_status": gstStatusValues.reverse[gstStatus],
    "gst_no": gstNo,
    "location": location,
    "customer_short_name": customerShortName,
    "category_name": categoryNameValues.reverse[categoryName],
    "meter_numbers": List<dynamic>.from(meterNumbers.map((x) => x)),
  };
}

enum BillToName {
  THE_CHIEF_MEDICAL_SUPERINTENDENT_CMS,
  THE_DEAN_PRINCIPAL,
  THE_DIRECTOR,
}

final billToNameValues = EnumValues({
  "The Chief Medical Superintendent (CMS)":
      BillToName.THE_CHIEF_MEDICAL_SUPERINTENDENT_CMS,
  "The Dean/Principal": BillToName.THE_DEAN_PRINCIPAL,
  "The Director": BillToName.THE_DIRECTOR,
});

enum CategoryName {
  AUTONOMOUS,
  AUTONOMOUS_STATE_MEDICAL_COLLEGE,
  DIRECTOR_GENERAL_MEDICAL_HEALTH_SERVICES,
}

final categoryNameValues = EnumValues({
  "Autonomous": CategoryName.AUTONOMOUS,
  "Autonomous State Medical College":
      CategoryName.AUTONOMOUS_STATE_MEDICAL_COLLEGE,
  "Director General Medical & Health Services":
      CategoryName.DIRECTOR_GENERAL_MEDICAL_HEALTH_SERVICES,
});

enum ContactPerson { SANTOSH_KUMAR }

final contactPersonValues = EnumValues({
  "Santosh Kumar": ContactPerson.SANTOSH_KUMAR,
});

enum CustomerStatus { ACTIVE }

final customerStatusValues = EnumValues({"Active": CustomerStatus.ACTIVE});

enum CustomerType { RESCO }

final customerTypeValues = EnumValues({"RESCO": CustomerType.RESCO});

enum GstStatus { REGISTERED }

final gstStatusValues = EnumValues({"Registered": GstStatus.REGISTERED});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
