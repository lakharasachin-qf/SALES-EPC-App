import 'dart:convert';

LeadsModel leadsModelFromJson(String str) =>
    LeadsModel.fromJson(json.decode(str));

String leadsModelToJson(LeadsModel data) => json.encode(data.toJson());

class LeadsModel {
  String status;
  String message;
  Result result;

  LeadsModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory LeadsModel.fromJson(Map<String, dynamic> json) => LeadsModel(
    status: json["status"] ?? "",
    message: json["message"] ?? "",
    result: json["result"] != null
        ? Result.fromJson(json["result"])
        : Result.empty(),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result.toJson(),
  };
}

class Result {
  List<LeadData> data;
  Pagination meta;

  Result({required this.data, required this.meta});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    data:
        (json["data"] as List?)?.map((x) => LeadData.fromJson(x)).toList() ??
        [],
    meta: json["meta"] != null
        ? Pagination.fromJson(json["meta"])
        : Pagination.empty(),
  );

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x.toJson()).toList(),
    "meta": meta.toJson(),
  };

  factory Result.empty() => Result(data: [], meta: Pagination.empty());
}

class LeadData {
  int id;
  int country;
  int state;
  int district;
  String address;
  String companyName;
  String contactPersonName;
  String contactPersonMobile;

  String? latitude;
  String? longitude;

  String? dgCapacityKva;
  bool dgSyncRequired;

  String? currInstSolarCapKwp;
  String? distToNearestTransformer;
  String? ratingOfNearestTransformerKva;
  String? sanctionedLoadKva;

  String? requiredSolutionType;
  bool vfdRequired;

  String? gridAvailabilityHrs;
  String? peakMonthlyEnergyConsKwh;
  String? requiredSolarCapKwp;

  String? purposeOfSolarisation;

  String? distBtwInverterAcdbPanelMtrs;
  String? distBtwSolarAcdbPanelMtrs;

  String? requiredSolution;

  dynamic buildingHeight;

  String? roofSizeLengthFt;
  String? roofSizeBreadthFt;

  String? installationArea;
  String installationCapacity;

  String? roofNature;
  dynamic ageOfMetalSheet;

  String? groundSizeLengthFt;
  String? groundSizeBreadthFt;

  String leadCategory;
  String leadStatus;

  String? otherRemarks;
  String source;

  DateTime createdAt;
  DateTime updatedAt;

  String countryName;
  String stateName;
  String districtName;

  bool canInstallation;

  LeadData({
    required this.id,
    required this.country,
    required this.state,
    required this.district,
    required this.address,
    required this.companyName,
    required this.contactPersonName,
    required this.contactPersonMobile,
    required this.latitude,
    required this.longitude,
    required this.dgCapacityKva,
    required this.dgSyncRequired,
    required this.currInstSolarCapKwp,
    required this.distToNearestTransformer,
    required this.ratingOfNearestTransformerKva,
    required this.sanctionedLoadKva,
    required this.requiredSolutionType,
    required this.vfdRequired,
    required this.gridAvailabilityHrs,
    required this.peakMonthlyEnergyConsKwh,
    required this.requiredSolarCapKwp,
    required this.purposeOfSolarisation,
    required this.distBtwInverterAcdbPanelMtrs,
    required this.distBtwSolarAcdbPanelMtrs,
    required this.requiredSolution,
    required this.buildingHeight,
    required this.roofSizeLengthFt,
    required this.roofSizeBreadthFt,
    required this.installationArea,
    required this.installationCapacity,
    required this.roofNature,
    required this.ageOfMetalSheet,
    required this.groundSizeLengthFt,
    required this.groundSizeBreadthFt,
    required this.leadCategory,
    required this.leadStatus,
    required this.otherRemarks,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.countryName,
    required this.stateName,
    required this.districtName,
    required this.canInstallation,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) => LeadData(
    id: json["id"] ?? 0,
    country: json["country"] ?? 0,
    state: json["state"] ?? 0,
    district: json["district"] ?? 0,
    address: json["address"] ?? "",
    companyName: json["company_name"] ?? "",
    contactPersonName: json["contact_person_name"] ?? "",
    contactPersonMobile: json["contact_person_mobile"] ?? "",

    latitude: json["latitude"]?.toString(),
    longitude: json["longitude"]?.toString(),

    dgCapacityKva: json["dg_capacity_kva"]?.toString(),
    dgSyncRequired: json["dg_sync_required"] ?? false,

    currInstSolarCapKwp: json["curr_inst_solar_cap_kwp"]?.toString(),
    distToNearestTransformer: json["dist_to_nearest_transformer"]?.toString(),
    ratingOfNearestTransformerKva: json["rating_of_nearest_transformer_kva"]
        ?.toString(),
    sanctionedLoadKva: json["sanctioned_load_kva"]?.toString(),

    requiredSolutionType: json["required_solution_type"]?.toString(),
    vfdRequired: json["vfd_required"] ?? false,

    gridAvailabilityHrs: json["grid_availability_hrs"]?.toString(),
    peakMonthlyEnergyConsKwh: json["peak_monthly_energy_cons_kwh"]?.toString(),
    requiredSolarCapKwp: json["required_solar_cap_kwp"]?.toString(),

    purposeOfSolarisation: json["purpose_of_solarisation"]?.toString(),

    distBtwInverterAcdbPanelMtrs: json["dist_btw_inverter_acdb_panel_mtrs"]
        ?.toString(),
    distBtwSolarAcdbPanelMtrs: json["dist_btw_solar_acdb_panel_mtrs"]
        ?.toString(),

    requiredSolution: json["required_solution"]?.toString(),

    buildingHeight: json["building_height"],

    roofSizeLengthFt: json["roof_size_length_ft"]?.toString(),
    roofSizeBreadthFt: json["roof_size_breadth_ft"]?.toString(),

    installationArea: json["installation_area"]?.toString(),
    installationCapacity: json["installation_capacity"]?.toString() ?? "0",

    roofNature: json["roof_nature"]?.toString(),
    ageOfMetalSheet: json["age_of_metal_sheet"],

    groundSizeLengthFt: json["ground_size_length_ft"]?.toString(),
    groundSizeBreadthFt: json["ground_size_breadth_ft"]?.toString(),

    leadCategory: json["lead_category"] ?? "",
    leadStatus: json["lead_status"] ?? "",
    otherRemarks: json["other_remarks"]?.toString(),

    source: json["source"] ?? "",

    createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),

    countryName: json["country_name"] ?? "",
    stateName: json["state_name"] ?? "",
    districtName: json["district_name"] ?? "",

    canInstallation: json["can_installation"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "country": country,
    "state": state,
    "district": district,
    "address": address,
    "company_name": companyName,
    "contact_person_name": contactPersonName,
    "contact_person_mobile": contactPersonMobile,
    "latitude": latitude,
    "longitude": longitude,
    "dg_capacity_kva": dgCapacityKva,
    "dg_sync_required": dgSyncRequired,
    "curr_inst_solar_cap_kwp": currInstSolarCapKwp,
    "dist_to_nearest_transformer": distToNearestTransformer,
    "rating_of_nearest_transformer_kva": ratingOfNearestTransformerKva,
    "sanctioned_load_kva": sanctionedLoadKva,
    "required_solution_type": requiredSolutionType,
    "vfd_required": vfdRequired,
    "grid_availability_hrs": gridAvailabilityHrs,
    "peak_monthly_energy_cons_kwh": peakMonthlyEnergyConsKwh,
    "required_solar_cap_kwp": requiredSolarCapKwp,
    "purpose_of_solarisation": purposeOfSolarisation,
    "dist_btw_inverter_acdb_panel_mtrs": distBtwInverterAcdbPanelMtrs,
    "dist_btw_solar_acdb_panel_mtrs": distBtwSolarAcdbPanelMtrs,
    "required_solution": requiredSolution,
    "building_height": buildingHeight,
    "roof_size_length_ft": roofSizeLengthFt,
    "roof_size_breadth_ft": roofSizeBreadthFt,
    "installation_area": installationArea,
    "installation_capacity": installationCapacity,
    "roof_nature": roofNature,
    "age_of_metal_sheet": ageOfMetalSheet,
    "ground_size_length_ft": groundSizeLengthFt,
    "ground_size_breadth_ft": groundSizeBreadthFt,
    "lead_category": leadCategory,
    "lead_status": leadStatus,
    "other_remarks": otherRemarks,
    "source": source,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "country_name": countryName,
    "state_name": stateName,
    "district_name": districtName,
    "can_installation": canInstallation,
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

  factory Pagination.empty() =>
      Pagination(page: 1, perPage: 10, total: 0, lastPage: 1, hasMore: false);
}
