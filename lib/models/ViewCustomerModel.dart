import 'dart:convert';

ViewCustomerModel viewCustomerModelFromJson(String str) =>
    ViewCustomerModel.fromJson(json.decode(str));

String viewCustomerModelToJson(ViewCustomerModel data) =>
    json.encode(data.toJson());

class ViewCustomerModel {
  String status;
  ViewCustomerData data;

  ViewCustomerModel({required this.status, required this.data});

  factory ViewCustomerModel.fromJson(Map<String, dynamic> json) =>
      ViewCustomerModel(
        status: json["status"] ?? '',
        data: ViewCustomerData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class ViewCustomerData {
  int id;
  int leadId;
  String conversionDate;
  String conversionDateFormatted;
  String liveAt;
  String liveAtFormatted;
  String customerStatus;
  String customerStatusFormatted;
  String companyName;
  String contactPersonName;
  String contactPersonMobile;
  String address;
  int countryId;
  String countryName;
  int stateId;
  String stateName;
  int districtId;
  String districtName;
  String fullLocation;
  String latitude;
  String longitude;
  DateTime? expectedDeliveryDate;
  String expectedDeliveryDateFormatted;
  DateTime? warrantyStartDate;
  String warrantyStartDateFormatted;
  DateTime? warrantyEndDate;
  DateTime? warrantyEndDateRaw;
  String warrantyEndDateFormatted;
  int warrantyPeriod;
  String warrantyType;
  String warrantyTypeFormatted;
  String warrantyStatus;
  bool hasInstallationCertificate;
  InstallationCertificate? installationCertificate;

  ViewCustomerData({
    required this.id,
    required this.leadId,
    required this.conversionDate,
    required this.conversionDateFormatted,
    required this.liveAt,
    required this.liveAtFormatted,
    required this.customerStatus,
    required this.customerStatusFormatted,
    required this.companyName,
    required this.contactPersonName,
    required this.contactPersonMobile,
    required this.address,
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.districtId,
    required this.districtName,
    required this.fullLocation,
    required this.latitude,
    required this.longitude,
    this.expectedDeliveryDate,
    required this.expectedDeliveryDateFormatted,
    this.warrantyStartDate,
    required this.warrantyStartDateFormatted,
    this.warrantyEndDate,
    this.warrantyEndDateRaw,
    required this.warrantyEndDateFormatted,
    required this.warrantyPeriod,
    required this.warrantyType,
    required this.warrantyTypeFormatted,
    required this.warrantyStatus,
    required this.hasInstallationCertificate,
    this.installationCertificate,
  });

  factory ViewCustomerData.fromJson(Map<String, dynamic> json) =>
      ViewCustomerData(
        id: json["id"] ?? 0,
        leadId: json["lead_id"] ?? 0,
        conversionDate: json["conversion_date"] ?? '',
        conversionDateFormatted: json["conversion_date_formatted"] ?? '',
        liveAt: json["live_at"] ?? '',
        liveAtFormatted: json["live_at_formatted"] ?? '',
        customerStatus: json["customer_status"] ?? '',
        customerStatusFormatted: json["customer_status_formatted"] ?? '',
        companyName: json["company_name"] ?? '',
        contactPersonName: json["contact_person_name"] ?? '',
        contactPersonMobile: json["contact_person_mobile"] ?? '',
        address: json["address"] ?? '',
        countryId: json["country_id"] ?? 0,
        countryName: json["country_name"] ?? '',
        stateId: json["state_id"] ?? 0,
        stateName: json["state_name"] ?? '',
        districtId: json["district_id"] ?? 0,
        districtName: json["district_name"] ?? '',
        fullLocation: json["full_location"] ?? '',
        latitude: json["latitude"] ?? '',
        longitude: json["longitude"] ?? '',
        expectedDeliveryDate: json["expected_delivery_date"] != null
            ? DateTime.tryParse(json["expected_delivery_date"])
            : null,
        expectedDeliveryDateFormatted:
            json["expected_delivery_date_formatted"] ?? '',
        warrantyStartDate: json["warranty_start_date"] != null
            ? DateTime.tryParse(json["warranty_start_date"])
            : null,
        warrantyStartDateFormatted: json["warranty_start_date_formatted"] ?? '',
        warrantyEndDate: json["warranty_end_date"] != null
            ? DateTime.tryParse(json["warranty_end_date"])
            : null,
        warrantyEndDateRaw: json["warranty_end_date_raw"] != null
            ? DateTime.tryParse(json["warranty_end_date_raw"])
            : null,
        warrantyEndDateFormatted: json["warranty_end_date_formatted"] ?? '',
        warrantyPeriod: json["warranty_period"] ?? 0,
        warrantyType: json["warranty_type"] ?? '',
        warrantyTypeFormatted: json["warranty_type_formatted"] ?? '',
        warrantyStatus: json["warranty_status"] ?? '',
        hasInstallationCertificate:
            json["has_installation_certificate"] ?? false,
        installationCertificate: json["installation_certificate"] != null
            ? InstallationCertificate.fromJson(json["installation_certificate"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lead_id": leadId,
    "conversion_date": conversionDate,
    "conversion_date_formatted": conversionDateFormatted,
    "live_at": liveAt,
    "live_at_formatted": liveAtFormatted,
    "customer_status": customerStatus,
    "customer_status_formatted": customerStatusFormatted,
    "company_name": companyName,
    "contact_person_name": contactPersonName,
    "contact_person_mobile": contactPersonMobile,
    "address": address,
    "country_id": countryId,
    "country_name": countryName,
    "state_id": stateId,
    "state_name": stateName,
    "district_id": districtId,
    "district_name": districtName,
    "full_location": fullLocation,
    "latitude": latitude,
    "longitude": longitude,
    "expected_delivery_date": expectedDeliveryDate?.toIso8601String(),
    "expected_delivery_date_formatted": expectedDeliveryDateFormatted,
    "warranty_start_date": warrantyStartDate?.toIso8601String(),
    "warranty_start_date_formatted": warrantyStartDateFormatted,
    "warranty_end_date": warrantyEndDate?.toIso8601String(),
    "warranty_end_date_raw": warrantyEndDateRaw?.toIso8601String(),
    "warranty_end_date_formatted": warrantyEndDateFormatted,
    "warranty_period": warrantyPeriod,
    "warranty_type": warrantyType,
    "warranty_type_formatted": warrantyTypeFormatted,
    "warranty_status": warrantyStatus,
    "has_installation_certificate": hasInstallationCertificate,
    "installation_certificate": installationCertificate?.toJson(),
  };
}

class InstallationCertificate {
  int id;
  int relatedModelId;
  String relatedModelType;
  String category;
  dynamic tag;
  String path;
  DateTime? fileUploadedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  InstallationCertificate({
    required this.id,
    required this.relatedModelId,
    required this.relatedModelType,
    required this.category,
    this.tag,
    required this.path,
    this.fileUploadedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory InstallationCertificate.fromJson(Map<String, dynamic> json) =>
      InstallationCertificate(
        id: json["id"] ?? 0,
        relatedModelId: json["related_model_id"] ?? 0,
        relatedModelType: json["related_model_type"] ?? '',
        category: json["category"] ?? '',
        tag: json["tag"],
        path: json["path"] ?? '',
        fileUploadedAt: json["file_uploaded_at"] != null
            ? DateTime.tryParse(json["file_uploaded_at"])
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "related_model_id": relatedModelId,
    "related_model_type": relatedModelType,
    "category": category,
    "tag": tag,
    "path": path,
    "file_uploaded_at": fileUploadedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
