import 'dart:convert';

Dashboard1Model dashboard1ModelFromJson(String str) =>
    Dashboard1Model.fromJson(json.decode(str));

String dashboard1ModelToJson(Dashboard1Model data) =>
    json.encode(data.toJson());

class Dashboard1Model {
  bool status;
  String message;
  Result result;
  Pagination? pagination;

  Dashboard1Model({
    required this.status,
    required this.message,
    required this.result,
    this.pagination,
  });

  factory Dashboard1Model.fromJson(Map<String, dynamic> json) =>
      Dashboard1Model(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        result:
            (json["result"] != null && json["result"] is Map<String, dynamic>)
            ? Result.fromJson(json["result"])
            : Result.empty(),
        pagination: json["pagination"] != null
            ? Pagination.fromJson(json["pagination"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result.toJson(),
    "pagination": pagination?.toJson(),
  };
}

class Result {
  Tiles tiles;
  Graphs graphs;
  List<Dashboard2> dashboard2;

  Result({required this.tiles, required this.graphs, required this.dashboard2});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    tiles: Tiles.fromJson(json["tiles"] ?? {}),
    graphs: Graphs.fromJson(json["graphs"] ?? {}),
    dashboard2: json["dashboard2"] != null
        ? List<Dashboard2>.from(
            json["dashboard2"].map((x) => Dashboard2.fromJson(x)),
          )
        : [],
  );

  factory Result.empty() =>
      Result(tiles: Tiles.empty(), graphs: Graphs.empty(), dashboard2: []);

  Map<String, dynamic> toJson() => {
    "tiles": tiles.toJson(),
    "graphs": graphs.toJson(),
    "dashboard2": List<dynamic>.from(dashboard2.map((x) => x.toJson())),
  };
}

class Dashboard2 {
  int customerId;
  String customerName;
  String month;
  double amount;

  Dashboard2({
    required this.customerId,
    required this.customerName,
    required this.month,
    required this.amount,
  });

  factory Dashboard2.fromJson(Map<String, dynamic> json) => Dashboard2(
    customerId: json["customer_id"] ?? 0,
    customerName: json["customer_name"] ?? "",
    month: json["month"] ?? "",
    amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId,
    "customer_name": customerName,
    "month": month,
    "amount": amount,
  };
}

class Graphs {
  List<BilledUnit> sgf;
  List<BilledUnit> revenue;
  List<BilledUnit> billedUnit;
  List<BilledUnit> kpi;

  Graphs({
    required this.sgf,
    required this.revenue,
    required this.billedUnit,
    required this.kpi,
  });

  factory Graphs.fromJson(Map<String, dynamic> json) => Graphs(
    sgf: json["sgf"] != null
        ? List<BilledUnit>.from(json["sgf"].map((x) => BilledUnit.fromJson(x)))
        : [],
    revenue: json["revenue"] != null
        ? List<BilledUnit>.from(
            json["revenue"].map((x) => BilledUnit.fromJson(x)),
          )
        : [],
    billedUnit: json["billed_unit"] != null
        ? List<BilledUnit>.from(
            json["billed_unit"].map((x) => BilledUnit.fromJson(x)),
          )
        : [],
    kpi: json["kpi"] != null
        ? List<BilledUnit>.from(json["kpi"].map((x) => BilledUnit.fromJson(x)))
        : [],
  );

  factory Graphs.empty() =>
      Graphs(sgf: [], revenue: [], billedUnit: [], kpi: []);

  Map<String, dynamic> toJson() => {
    "sgf": List<dynamic>.from(sgf.map((x) => x.toJson())),
    "revenue": List<dynamic>.from(revenue.map((x) => x.toJson())),
    "billed_unit": List<dynamic>.from(billedUnit.map((x) => x.toJson())),
    "kpi": List<dynamic>.from(kpi.map((x) => x.toJson())),
  };
}

class BilledUnit {
  int customerId;
  String customerShortName;
  int target;
  double actual;

  BilledUnit({
    required this.customerId,
    required this.customerShortName,
    required this.target,
    required this.actual,
  });

  factory BilledUnit.fromJson(Map<String, dynamic> json) => BilledUnit(
    customerId: json["customer_id"] ?? 0,
    customerShortName: json["customer_short_name"] ?? "",
    target: (json["target"] ?? 0).toDouble().toInt(),
    actual: (json["actual"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId,
    "customer_short_name": customerShortName,
    "target": target,
    "actual": actual,
  };
}

class Tiles {
  Resco resco;
  Performance performance;
  Kpi kpi;
  Revenue revenue;

  Tiles({
    required this.resco,
    required this.performance,
    required this.kpi,
    required this.revenue,
  });

  factory Tiles.fromJson(Map<String, dynamic> json) => Tiles(
    resco: Resco.fromJson(json["resco"] ?? {}),
    performance: Performance.fromJson(json["performance"] ?? {}),
    kpi: Kpi.fromJson(json["kpi"] ?? {}),
    revenue: Revenue.fromJson(json["revenue"] ?? {}),
  );

  factory Tiles.empty() => Tiles(
    resco: Resco(customerCountTile: 0, solarCapacityMwpTile: 0.0),
    performance: Performance(sgfTargetTile: 0.0, actualSgfTile: 0.0),
    kpi: Kpi(revenueTargetKpiTile: 0, revenueActualKpiTile: 0),
    revenue: Revenue(billingAmountTile: 0, collectedAmountTile: 0),
  );

  Map<String, dynamic> toJson() => {
    "resco": resco.toJson(),
    "performance": performance.toJson(),
    "kpi": kpi.toJson(),
    "revenue": revenue.toJson(),
  };
}

class Kpi {
  int revenueTargetKpiTile;
  int revenueActualKpiTile;

  Kpi({required this.revenueTargetKpiTile, required this.revenueActualKpiTile});

  factory Kpi.fromJson(Map<String, dynamic> json) => Kpi(
    revenueTargetKpiTile: json["revenueTargetKpiTile"] ?? 0,
    revenueActualKpiTile: json["revenueActualKpiTile"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "revenueTargetKpiTile": revenueTargetKpiTile,
    "revenueActualKpiTile": revenueActualKpiTile,
  };
}

class Performance {
  double sgfTargetTile;
  double actualSgfTile;

  Performance({required this.sgfTargetTile, required this.actualSgfTile});

  factory Performance.fromJson(Map<String, dynamic> json) => Performance(
    sgfTargetTile: (json["sgfTargetTile"] ?? 0).toDouble(),
    actualSgfTile: (json["actualSgfTile"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "sgfTargetTile": sgfTargetTile,
    "actualSgfTile": actualSgfTile,
  };
}

class Resco {
  int customerCountTile;
  double solarCapacityMwpTile;

  Resco({required this.customerCountTile, required this.solarCapacityMwpTile});

  factory Resco.fromJson(Map<String, dynamic> json) => Resco(
    customerCountTile: json["customerCountTile"] ?? 0,
    solarCapacityMwpTile: (json["solarCapacityMwpTile"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "customerCountTile": customerCountTile,
    "solarCapacityMwpTile": solarCapacityMwpTile,
  };
}

class Revenue {
  int billingAmountTile;
  int collectedAmountTile;

  Revenue({required this.billingAmountTile, required this.collectedAmountTile});

  factory Revenue.fromJson(Map<String, dynamic> json) => Revenue(
    billingAmountTile: json["billingAmountTile"] ?? 0,
    collectedAmountTile: json["collectedAmountTile"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "billingAmountTile": billingAmountTile,
    "collectedAmountTile": collectedAmountTile,
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
    total: json["total"] ?? 0,
    perPage: json["per_page"] ?? 10,
    currentPage: json["current_page"] ?? 1,
    lastPage: json["last_page"] ?? 1,
    from: json["from"] ?? 0,
    to: json["to"] ?? 0,
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
