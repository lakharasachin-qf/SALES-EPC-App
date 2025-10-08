// // To parse this JSON data, do
// //
// //     final dashboardfiltter = dashboardfiltterFromJson(jsonString);

// import 'dart:convert';

// Dashboardfiltter dashboardfiltterFromJson(String str) =>
//     Dashboardfiltter.fromJson(json.decode(str));

// String dashboardfiltterToJson(Dashboardfiltter data) =>
//     json.encode(data.toJson());

// class Dashboardfiltter {
//   String status;
//   FiltterData data;

//   Dashboardfiltter({required this.status, required this.data});

//   factory Dashboardfiltter.fromJson(Map<String, dynamic> json) =>
//       Dashboardfiltter(
//         status: json["status"],
//         data: FiltterData.fromJson(json["data"]),
//       );

//   Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
// }

// class FiltterData {
//   List<Cluster> clusters;
//   List<Cluster> districts;

//   FiltterData({required this.clusters, required this.districts});

//   factory FiltterData.fromJson(Map<String, dynamic> json) => FiltterData(
//     clusters: List<Cluster>.from(
//       json["clusters"].map((x) => Cluster.fromJson(x)),
//     ),
//     districts: List<Cluster>.from(
//       json["districts"].map((x) => Cluster.fromJson(x)),
//     ),
//   );

//   Map<String, dynamic> toJson() => {
//     "clusters": List<dynamic>.from(clusters.map((x) => x.toJson())),
//     "districts": List<dynamic>.from(districts.map((x) => x.toJson())),
//   };
// }

// class Cluster {
//   int id;
//   String name;

//   Cluster({required this.id, required this.name});

//   factory Cluster.fromJson(Map<String, dynamic> json) =>
//       Cluster(id: json["id"], name: json["name"]);

//   Map<String, dynamic> toJson() => {"id": id, "name": name};
// }
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

  FiltterData({required this.clusters, required this.districts});

  factory FiltterData.fromJson(Map<String, dynamic>? json) => FiltterData(
    clusters:
        (json?["clusters"] as List?)
            ?.map((x) => Cluster.fromJson(x as Map<String, dynamic>?))
            .toList() ??
        [],
    districts:
        (json?["districts"] as List?)
            ?.map((x) => Cluster.fromJson(x as Map<String, dynamic>?))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "clusters": clusters.map((x) => x.toJson()).toList(),
    "districts": districts.map((x) => x.toJson()).toList(),
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
