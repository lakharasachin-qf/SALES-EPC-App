import 'dart:convert';

Dashboard1Model dashboard1ModelFromJson(String str) =>
    Dashboard1Model.fromJson(json.decode(str));

String dashboard1ModelToJson(Dashboard1Model data) =>
    json.encode(data.toJson());

class Dashboard1Model {
  bool success;
  String message;
  FiltersApplied? filtersApplied;
  Tiles? tiles;
  Charts? charts;

  Dashboard1Model({
    required this.success,
    required this.message,
    this.filtersApplied,
    this.tiles,
    this.charts,
  });

  factory Dashboard1Model.fromJson(Map<String, dynamic> json) =>
      Dashboard1Model(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        filtersApplied: json["filters_applied"] != null
            ? FiltersApplied.fromJson(json["filters_applied"])
            : null,
        tiles: json["tiles"] != null ? Tiles.fromJson(json["tiles"]) : null,
        charts: json["charts"] != null ? Charts.fromJson(json["charts"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "filters_applied": filtersApplied?.toJson(),
    "tiles": tiles?.toJson(),
    "charts": charts?.toJson(),
  };
}

class FiltersApplied {
  DateRangeFilter? dateRangeFilter;
  List<String>? selectedClusterIds;

  FiltersApplied({this.dateRangeFilter, this.selectedClusterIds});

  factory FiltersApplied.fromJson(Map<String, dynamic> json) => FiltersApplied(
    dateRangeFilter: json["dateRangeFilter"] != null
        ? DateRangeFilter.fromJson(json["dateRangeFilter"])
        : null,
    selectedClusterIds: json["selectedClusterIds"] != null
        ? List<String>.from(json["selectedClusterIds"].map((x) => x))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "dateRangeFilter": dateRangeFilter?.toJson(),
    "selectedClusterIds": selectedClusterIds,
  };
}

class DateRangeFilter {
  int? startMonth;
  int? startYear;
  int? endMonth;
  int? endYear;
  String? periodStartDate;
  String? periodEndDate;

  DateRangeFilter({
    this.startMonth,
    this.startYear,
    this.endMonth,
    this.endYear,
    this.periodStartDate,
    this.periodEndDate,
  });

  factory DateRangeFilter.fromJson(Map<String, dynamic> json) =>
      DateRangeFilter(
        startMonth: json["start_month"],
        startYear: json["start_year"],
        endMonth: json["end_month"],
        endYear: json["end_year"],
        periodStartDate: json["period_start_date"],
        periodEndDate: json["period_end_date"],
      );

  Map<String, dynamic> toJson() => {
    "start_month": startMonth,
    "start_year": startYear,
    "end_month": endMonth,
    "end_year": endYear,
    "period_start_date": periodStartDate,
    "period_end_date": periodEndDate,
  };
}

class Tiles {
  Leads? leads;

  Tiles({this.leads});

  factory Tiles.fromJson(Map<String, dynamic> json) => Tiles(
    leads: json["leads"] != null ? Leads.fromJson(json["leads"]) : null,
  );

  Map<String, dynamic> toJson() => {"leads": leads?.toJson()};
}

class Leads {
  int? totalLeads;
  int? leadsWon;
  int? leadsLost;
  int? leadsInProgress;
  int? conversion;
  LeadCategories? leadCategories;
  int? totalRevenue;

  Leads({
    this.totalLeads,
    this.leadsWon,
    this.leadsLost,
    this.leadsInProgress,
    this.conversion,
    this.leadCategories,
    this.totalRevenue,
  });

  factory Leads.fromJson(Map<String, dynamic> json) => Leads(
    totalLeads: json["totalLeads"],
    leadsWon: json["leadsWon"],
    leadsLost: json["leadsLost"],
    leadsInProgress: json["leadsInProgress"],
    conversion: json["conversion"],
    leadCategories: json["leadCategories"] != null
        ? LeadCategories.fromJson(json["leadCategories"])
        : null,
    totalRevenue: json["totalRevenue"],
  );

  Map<String, dynamic> toJson() => {
    "totalLeads": totalLeads,
    "leadsWon": leadsWon,
    "leadsLost": leadsLost,
    "leadsInProgress": leadsInProgress,
    "conversion": conversion,
    "leadCategories": leadCategories?.toJson(),
    "totalRevenue": totalRevenue,
  };
}

class LeadCategories {
  int? hot;
  int? warm;
  int? cold;

  LeadCategories({this.hot, this.warm, this.cold});

  factory LeadCategories.fromJson(Map<String, dynamic> json) =>
      LeadCategories(hot: json["hot"], warm: json["warm"], cold: json["cold"]);

  Map<String, dynamic> toJson() => {"hot": hot, "warm": warm, "cold": cold};
}

class Charts {
  LeadsStatusDistribution? leadsStatusDistribution;
  LeadsByClusterBreakdown? leadsByClusterBreakdown;
  LeadsWonProgressOverTime? leadsWonProgressOverTime;
  RevenueVsTargetsComparison? revenueVsTargetsComparison;

  Charts({
    this.leadsStatusDistribution,
    this.leadsByClusterBreakdown,
    this.leadsWonProgressOverTime,
    this.revenueVsTargetsComparison,
  });

  factory Charts.fromJson(Map<String, dynamic> json) => Charts(
    leadsStatusDistribution: json["leadsStatusDistribution"] != null
        ? LeadsStatusDistribution.fromJson(json["leadsStatusDistribution"])
        : null,
    leadsByClusterBreakdown: json["leadsByClusterBreakdown"] != null
        ? LeadsByClusterBreakdown.fromJson(json["leadsByClusterBreakdown"])
        : null,
    leadsWonProgressOverTime: json["leadsWonProgressOverTime"] != null
        ? LeadsWonProgressOverTime.fromJson(json["leadsWonProgressOverTime"])
        : null,
    revenueVsTargetsComparison: json["revenueVsTargetsComparison"] != null
        ? RevenueVsTargetsComparison.fromJson(
            json["revenueVsTargetsComparison"],
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    "leadsStatusDistribution": leadsStatusDistribution?.toJson(),
    "leadsByClusterBreakdown": leadsByClusterBreakdown?.toJson(),
    "leadsWonProgressOverTime": leadsWonProgressOverTime?.toJson(),
    "revenueVsTargetsComparison": revenueVsTargetsComparison?.toJson(),
  };
}

class LeadsStatusDistribution {
  int? newLead;
  int? contacted;
  int? proposalSent;
  int? qualified;
  int? won;
  int? rejected;

  LeadsStatusDistribution({
    this.newLead,
    this.contacted,
    this.proposalSent,
    this.qualified,
    this.won,
    this.rejected,
  });

  factory LeadsStatusDistribution.fromJson(Map<String, dynamic> json) =>
      LeadsStatusDistribution(
        newLead: json["new_lead"],
        contacted: json["contacted"],
        proposalSent: json["proposal_sent"],
        qualified: json["qualified"],
        won: json["won"],
        rejected: json["rejected"],
      );

  Map<String, dynamic> toJson() => {
    "new_lead": newLead,
    "contacted": contacted,
    "proposal_sent": proposalSent,
    "qualified": qualified,
    "won": won,
    "rejected": rejected,
  };
}

class LeadsByClusterBreakdown {
  List<String>? labels;
  Datasets? datasets;

  LeadsByClusterBreakdown({this.labels, this.datasets});

  factory LeadsByClusterBreakdown.fromJson(Map<String, dynamic> json) =>
      LeadsByClusterBreakdown(
        labels: json["labels"] != null
            ? List<String>.from(json["labels"].map((x) => x))
            : [],
        datasets: json["datasets"] != null
            ? Datasets.fromJson(json["datasets"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "labels": labels,
    "datasets": datasets?.toJson(),
  };
}

class Datasets {
  List<int>? leads;
  List<int>? won;
  List<int>? lost;
  List<int>? ongoing;

  Datasets({this.leads, this.won, this.lost, this.ongoing});

  factory Datasets.fromJson(Map<String, dynamic> json) => Datasets(
    leads: List<int>.from(json["leads"].map((x) => x)),
    won: List<int>.from(json["won"].map((x) => x)),
    lost: List<int>.from(json["lost"].map((x) => x)),
    ongoing: List<int>.from(json["ongoing"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "leads": leads,
    "won": won,
    "lost": lost,
    "ongoing": ongoing,
  };
}

class LeadsWonProgressOverTime {
  List<String>? labels;
  List<int>? weeklyChanges;
  List<int>? cumulativeData;

  LeadsWonProgressOverTime({
    this.labels,
    this.weeklyChanges,
    this.cumulativeData,
  });

  factory LeadsWonProgressOverTime.fromJson(Map<String, dynamic> json) =>
      LeadsWonProgressOverTime(
        labels: json["labels"] != null ? List<String>.from(json["labels"]) : [],
        weeklyChanges: json["weeklyChanges"] != null
            ? List<int>.from(json["weeklyChanges"].map((x) => x))
            : [],
        cumulativeData: json["cumulativeData"] != null
            ? List<int>.from(json["cumulativeData"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
    "labels": labels,
    "weeklyChanges": weeklyChanges,
    "cumulativeData": cumulativeData,
  };
}

class RevenueVsTargetsComparison {
  List<String>? labels;
  TargetData? revenue;
  TargetData? customer;

  RevenueVsTargetsComparison({this.labels, this.revenue, this.customer});

  factory RevenueVsTargetsComparison.fromJson(Map<String, dynamic> json) =>
      RevenueVsTargetsComparison(
        labels: json["labels"] != null
            ? List<String>.from(json["labels"].map((x) => x))
            : [],
        revenue: json["revenue"] != null
            ? TargetData.fromJson(json["revenue"])
            : null,
        customer: json["customer"] != null
            ? TargetData.fromJson(json["customer"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "labels": labels,
    "revenue": revenue?.toJson(),
    "customer": customer?.toJson(),
  };
}

class TargetData {
  List<int>? target;
  List<int>? achieved;

  TargetData({this.target, this.achieved});

  factory TargetData.fromJson(Map<String, dynamic> json) => TargetData(
    target: List<int>.from(json["target"].map((x) => x)),
    achieved: List<int>.from(json["achieved"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {"target": target, "achieved": achieved};
}
