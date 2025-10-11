import 'dart:convert';

LeadDropDownListModel leadDropDownListModelFromJson(String str) =>
    LeadDropDownListModel.fromJson(json.decode(str));

String leadDropDownListModelToJson(LeadDropDownListModel data) =>
    json.encode(data.toJson());

class LeadDropDownListModel {
  String status;
  LeadDropDownListData data;

  LeadDropDownListModel({required this.status, required this.data});

  factory LeadDropDownListModel.fromJson(Map<String, dynamic> json) =>
      LeadDropDownListModel(
        status: json["status"],
        data: LeadDropDownListData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class LeadDropDownListData {
  Dropdowns dropdowns;
  List<CountryData> locations; // rename

  LeadDropDownListData({required this.dropdowns, required this.locations});

  factory LeadDropDownListData.fromJson(Map<String, dynamic> json) =>
      LeadDropDownListData(
        dropdowns: Dropdowns.fromJson(json["dropdowns"]),
        locations: (json["locations"] ?? [])
            .map<CountryData>((x) => CountryData.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    "dropdowns": dropdowns.toJson(),
    "locations": List<dynamic>.from(locations.map((x) => x.toJson())),
  };
}

class Dropdowns {
  List<DgSyncRequired> requiredSolutionType;
  List<DgSyncRequired> requiredSolution;
  List<DgSyncRequired> leadCategory;
  List<DgSyncRequired> dgSyncRequired;
  List<DgSyncRequired> vfdRequired;
  List<DgSyncRequired> roofNature;
  List<DgSyncRequired> financingType;
  List<DgSyncRequired> purposeOfSolarisation;

  Dropdowns({
    required this.requiredSolutionType,
    required this.requiredSolution,
    required this.leadCategory,
    required this.dgSyncRequired,
    required this.vfdRequired,
    required this.roofNature,
    required this.financingType,
    required this.purposeOfSolarisation,
  });

  factory Dropdowns.fromJson(Map<String, dynamic> json) => Dropdowns(
    requiredSolutionType: List<DgSyncRequired>.from(
      json["required_solution_type"].map((x) => DgSyncRequired.fromJson(x)),
    ),
    requiredSolution: List<DgSyncRequired>.from(
      json["required_solution"].map((x) => DgSyncRequired.fromJson(x)),
    ),
    leadCategory: List<DgSyncRequired>.from(
      json["lead_category"].map((x) => DgSyncRequired.fromJson(x)),
    ),
    dgSyncRequired: List<DgSyncRequired>.from(
      json["dg_sync_required"].map((x) => DgSyncRequired.fromJson(x)),
    ),
    vfdRequired: List<DgSyncRequired>.from(
      json["vfd_required"].map((x) => DgSyncRequired.fromJson(x)),
    ),
    roofNature: List<DgSyncRequired>.from(
      json["roof_nature"].map((x) => DgSyncRequired.fromJson(x)),
    ),
    financingType: List<DgSyncRequired>.from(
      json["financing_type"].map((x) => DgSyncRequired.fromJson(x)),
    ),
    purposeOfSolarisation: List<DgSyncRequired>.from(
      json["purpose_of_solarisation"].map((x) => DgSyncRequired.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "required_solution_type": List<dynamic>.from(
      requiredSolutionType.map((x) => x.toJson()),
    ),
    "required_solution": List<dynamic>.from(
      requiredSolution.map((x) => x.toJson()),
    ),
    "lead_category": List<dynamic>.from(leadCategory.map((x) => x.toJson())),
    "dg_sync_required": List<dynamic>.from(
      dgSyncRequired.map((x) => x.toJson()),
    ),
    "vfd_required": List<dynamic>.from(vfdRequired.map((x) => x.toJson())),
    "roof_nature": List<dynamic>.from(roofNature.map((x) => x.toJson())),
    "financing_type": List<dynamic>.from(financingType.map((x) => x.toJson())),
    "purpose_of_solarisation": List<dynamic>.from(
      purposeOfSolarisation.map((x) => x.toJson()),
    ),
  };
}

class DgSyncRequired {
  String label;
  String value;

  DgSyncRequired({required this.label, required this.value});

  factory DgSyncRequired.fromJson(Map<String, dynamic> json) =>
      DgSyncRequired(label: json["label"] ?? '', value: json["value"] ?? '');

  Map<String, dynamic> toJson() => {"label": label, "value": value};
}

class CountryData {
  int countryId;
  String countryName;
  List<StateData> states;

  CountryData({
    required this.countryId,
    required this.countryName,
    required this.states,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) => CountryData(
    countryId: json["country_id"] ?? 0,
    countryName: json["country_name"] ?? '',
    states: (json["states"] ?? [])
        .map<StateData>((x) => StateData.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "country_id": countryId,
    "country_name": countryName,
    "states": List<dynamic>.from(states.map((x) => x.toJson())),
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

  factory StateData.fromJson(Map<String, dynamic> json) => StateData(
    stateId: json["state_id"] ?? 0,
    stateName: json["state_name"] ?? '',
    districts: (json["districts"] ?? [])
        .map<District>((x) => District.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "state_id": stateId,
    "state_name": stateName,
    "districts": List<dynamic>.from(districts.map((x) => x.toJson())),
  };
}

class District {
  int districtId;
  String districtName;

  District({required this.districtId, required this.districtName});

  factory District.fromJson(Map<String, dynamic> json) => District(
    districtId: json["district_id"],
    districtName: json["district_name"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "district_id": districtId,
    "district_name": districtName,
  };
}
