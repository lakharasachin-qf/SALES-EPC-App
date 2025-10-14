import 'dart:convert';

CustomerListModel customerListModelFromJson(String str) =>
    CustomerListModel.fromJson(json.decode(str));

String customerListModelToJson(CustomerListModel data) =>
    json.encode(data.toJson());

class CustomerListModel {
  String status;
  String message;
  Result result;

  CustomerListModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory CustomerListModel.fromJson(Map<String, dynamic> json) =>
      CustomerListModel(
        status: json["status"] ?? '',
        message: json["message"] ?? '',
        result: Result.fromJson(json["result"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result.toJson(),
  };
}

class Result {
  List<CustomerData> data;
  Pagination pagination;

  Result({required this.data, required this.pagination});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    data: List<CustomerData>.from(
      (json["data"] ?? []).map((x) => CustomerData.fromJson(x)),
    ),
    pagination: Pagination.fromJson(json["meta"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": pagination.toJson(),
  };
}

class CustomerData {
  int id;
  int leadId;
  String conversionDate;
  String liveAt;
  String customerStatus;
  String companyName;
  String contactPersonName;
  String contactPersonMobile;
  String address;
  int country;
  int state;
  int district;
  String latitude;
  String longitude;
  String createdAt;
  String updatedAt;
  String expectedDeliveryDate;
  String warrantyStartDate;
  String warrantyEndDate;
  int warrantyPeriod;
  String warrantyType;
  bool hasInstallationCertificate;
  InstallationCertificate? installationCertificate;

  CustomerData({
    required this.id,
    required this.leadId,
    required this.conversionDate,
    required this.liveAt,
    required this.customerStatus,
    required this.companyName,
    required this.contactPersonName,
    required this.contactPersonMobile,
    required this.address,
    required this.country,
    required this.state,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.expectedDeliveryDate,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.warrantyPeriod,
    required this.warrantyType,
    required this.hasInstallationCertificate,
    this.installationCertificate,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) => CustomerData(
    id: json["id"] ?? 0,
    leadId: json["lead_id"] ?? 0,
    conversionDate: json["conversion_date"] ?? '',
    liveAt: json["live_at"] ?? '',
    customerStatus: json["customer_status"] ?? '',
    companyName: json["company_name"] ?? '',
    contactPersonName: json["contact_person_name"] ?? '',
    contactPersonMobile: json["contact_person_mobile"] ?? '',
    address: json["address"] ?? '',
    country: json["country"] ?? 0,
    state: json["state"] ?? 0,
    district: json["district"] ?? 0,
    latitude: json["latitude"] ?? '',
    longitude: json["longitude"] ?? '',
    createdAt: json["created_at"] ?? '',
    updatedAt: json["updated_at"] ?? '',
    expectedDeliveryDate: json["expected_delivery_date"] ?? '',
    warrantyStartDate: json["warranty_start_date"] ?? '',
    warrantyEndDate: json["warranty_end_date"] ?? '',
    warrantyPeriod: json["warranty_period"] ?? 0,
    warrantyType: json["warranty_type"] ?? '',
    hasInstallationCertificate: json["has_installation_certificate"] ?? false,
    installationCertificate: json["installation_certificate"] != null
        ? InstallationCertificate.fromJson(json["installation_certificate"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lead_id": leadId,
    "conversion_date": conversionDate,
    "live_at": liveAt,
    "customer_status": customerStatus,
    "company_name": companyName,
    "contact_person_name": contactPersonName,
    "contact_person_mobile": contactPersonMobile,
    "address": address,
    "country": country,
    "state": state,
    "district": district,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "expected_delivery_date": expectedDeliveryDate,
    "warranty_start_date": warrantyStartDate,
    "warranty_end_date": warrantyEndDate,
    "warranty_period": warrantyPeriod,
    "warranty_type": warrantyType,
    "has_installation_certificate": hasInstallationCertificate,
    "installation_certificate": installationCertificate?.toJson(),
  };
}

class InstallationCertificate {
  int id;
  int relatedModelId;
  String relatedModelType;
  String category;
  String? tag;
  String path;
  String fileUploadedAt;
  String createdAt;
  String updatedAt;

  InstallationCertificate({
    required this.id,
    required this.relatedModelId,
    required this.relatedModelType,
    required this.category,
    this.tag,
    required this.path,
    required this.fileUploadedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InstallationCertificate.fromJson(Map<String, dynamic> json) =>
      InstallationCertificate(
        id: json["id"] ?? 0,
        relatedModelId: json["related_model_id"] ?? 0,
        relatedModelType: json["related_model_type"] ?? '',
        category: json["category"] ?? '',
        tag: json["tag"],
        path: json["path"] ?? '',
        fileUploadedAt: json["file_uploaded_at"] ?? '',
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "related_model_id": relatedModelId,
    "related_model_type": relatedModelType,
    "category": category,
    "tag": tag,
    "path": path,
    "file_uploaded_at": fileUploadedAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Pagination {
  int page;
  int perPage;
  int total;
  int lastPage;
  bool hasMore;

  Pagination({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"] ?? 1,
    perPage: json["per_page"] ?? 10,
    total: json["total"] ?? 0,
    lastPage: json["last_page"] ?? 1,
    hasMore: json["has_more"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
    "has_more": hasMore,
  };
}
