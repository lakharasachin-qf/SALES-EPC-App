import 'dart:convert';

LocationModel locationModelFromJson(String str) =>
    LocationModel.fromJson(json.decode(str));

String locationModelToJson(LocationModel data) => json.encode(data.toJson());

class LocationModel {
  bool status;
  String message;
  List<CountryData> data;

  LocationModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    status: json["status"],
    message: json["message"],
    data: List<CountryData>.from(
      json["data"].map((x) => CountryData.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
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
    countryId: json["country_id"],
    countryName: json["country_name"] ?? '',
    states: List<StateData>.from(json["states"].map((x) => StateData.fromJson(x))),
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
    stateId: json["state_id"],
    stateName: json["state_name"] ?? '',
    districts: List<District>.from(
      json["districts"].map((x) => District.fromJson(x)),
    ),
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
