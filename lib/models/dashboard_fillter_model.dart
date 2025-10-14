import 'dart:convert';

Dashboardfiltter dashboardfiltterFromJson(String str) =>
    Dashboardfiltter.fromJson(json.decode(str));

String dashboardfiltterToJson(Dashboardfiltter data) =>
    json.encode(data.toJson());

class Dashboardfiltter {
  String status;
  FiltterData data;

  Dashboardfiltter({required this.status, required this.data});

  factory Dashboardfiltter.fromJson(Map<String, dynamic>? json) =>
      Dashboardfiltter(
        status: (json?["status"] ?? '').toString(),
        data: FiltterData.fromJson(json?["data"] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class FiltterData {
  List<Cluster> clusters;
  List<Cluster> districts;
  List<Location> locations;
  List<LabelValue> requiredSolutionType;
  List<LabelValue> requiredSolution;
  List<LabelValue> leadCategory;
  List<LabelValue> dgSyncRequired;
  List<LabelValue> vfdRequired;
  List<LabelValue> roofNature;
  List<LabelValue> financingType;
  List<LabelValue> purposeOfSolarisation;
  List<LabelValue> uploadedFilesCategories;
  List<LabelValue> customerStatus;
  List<LabelValue> warrantyType;

  FiltterData({
    required this.clusters,
    required this.districts,
    required this.locations,
    required this.requiredSolutionType,
    required this.requiredSolution,
    required this.leadCategory,
    required this.dgSyncRequired,
    required this.vfdRequired,
    required this.roofNature,
    required this.financingType,
    required this.purposeOfSolarisation,
    required this.uploadedFilesCategories,
    required this.customerStatus,
    required this.warrantyType,
  });

  factory FiltterData.fromJson(Map<String, dynamic>? json) => FiltterData(
    clusters: (json?["clusters"] as List? ?? [])
        .map((x) => Cluster.fromJson(x))
        .toList(),
    districts: (json?["districts"] as List? ?? [])
        .map((x) => Cluster.fromJson(x))
        .toList(),
    locations: (json?["locations"] as List? ?? [])
        .map((x) => Location.fromJson(x))
        .toList(),
    requiredSolutionType: (json?["required_solution_type"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    requiredSolution: (json?["required_solution"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    leadCategory: (json?["lead_category"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    dgSyncRequired: (json?["dg_sync_required"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    vfdRequired: (json?["vfd_required"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    roofNature: (json?["roof_nature"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    financingType: (json?["financing_type"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    purposeOfSolarisation: (json?["purpose_of_solarisation"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    uploadedFilesCategories: (json?["uploaded_files_categories"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    customerStatus: (json?["customer_status"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
    warrantyType: (json?["warranty_type"] as List? ?? [])
        .map((x) => LabelValue.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "clusters": clusters.map((x) => x.toJson()).toList(),
    "districts": districts.map((x) => x.toJson()).toList(),
    "locations": locations.map((x) => x.toJson()).toList(),
    "required_solution_type": requiredSolutionType
        .map((x) => x.toJson())
        .toList(),
    "required_solution": requiredSolution.map((x) => x.toJson()).toList(),
    "lead_category": leadCategory.map((x) => x.toJson()).toList(),
    "dg_sync_required": dgSyncRequired.map((x) => x.toJson()).toList(),
    "vfd_required": vfdRequired.map((x) => x.toJson()).toList(),
    "roof_nature": roofNature.map((x) => x.toJson()).toList(),
    "financing_type": financingType.map((x) => x.toJson()).toList(),
    "purpose_of_solarisation": purposeOfSolarisation
        .map((x) => x.toJson())
        .toList(),
    "uploaded_files_categories": uploadedFilesCategories
        .map((x) => x.toJson())
        .toList(),
    "customer_status": customerStatus.map((x) => x.toJson()).toList(),
    "warranty_type": warrantyType.map((x) => x.toJson()).toList(),
  };
}

class Cluster {
  int id;
  String name;

  Cluster({required this.id, required this.name});

  factory Cluster.fromJson(Map<String, dynamic>? json) =>
      Cluster(id: json?["id"] ?? 0, name: (json?["name"] ?? '').toString());

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Location {
  int countryId;
  String countryName;
  List<StateData> states;

  Location({
    required this.countryId,
    required this.countryName,
    required this.states,
  });

  factory Location.fromJson(Map<String, dynamic>? json) => Location(
    countryId: json?["country_id"] ?? 0,
    countryName: (json?["country_name"] ?? '').toString(),
    states: (json?["states"] as List? ?? [])
        .map((x) => StateData.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "country_id": countryId,
    "country_name": countryName,
    "states": states.map((x) => x.toJson()).toList(),
  };
}

class StateData {
  int stateId;
  String stateName;
  List<District> districts;

  StateData({
    required this.stateId,
    required this.stateName,
    required this.districts,
  });

  factory StateData.fromJson(Map<String, dynamic>? json) => StateData(
    stateId: json?["state_id"] ?? 0,
    stateName: (json?["state_name"] ?? '').toString(),
    districts: (json?["districts"] as List? ?? [])
        .map((x) => District.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "state_id": stateId,
    "state_name": stateName,
    "districts": districts.map((x) => x.toJson()).toList(),
  };
}

class District {
  int districtId;
  String districtName;

  District({required this.districtId, required this.districtName});

  factory District.fromJson(Map<String, dynamic>? json) => District(
    districtId: json?["district_id"] ?? 0,
    districtName: (json?["district_name"] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    "district_id": districtId,
    "district_name": districtName,
  };
}

class LabelValue {
  String label;
  String value;

  LabelValue({required this.label, required this.value});

  factory LabelValue.fromJson(Map<String, dynamic>? json) => LabelValue(
    label: (json?["label"] ?? '').toString(),
    value: (json?["value"] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {"label": label, "value": value};
}
