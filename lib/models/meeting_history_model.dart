// To parse this JSON data, do
//
//     final meetingHistory = meetingHistoryFromJson(jsonString);

import 'dart:convert';

MeetingHistoryModel meetingHistoryFromJson(String str) =>
    MeetingHistoryModel.fromJson(json.decode(str));

String meetingHistoryToJson(MeetingHistoryModel data) =>
    json.encode(data.toJson());

class MeetingHistoryModel {
  String status;
  String message;
  Result result;

  MeetingHistoryModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory MeetingHistoryModel.fromJson(Map<String, dynamic> json) =>
      MeetingHistoryModel(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result.toJson(),
  };
}

class Result {
  List<MeetingHistoryModelList> data;
  Meta meta;

  Result({required this.data, required this.meta});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    data: List<MeetingHistoryModelList>.from(json["data"].map((x) => MeetingHistoryModelList.fromJson(x))),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta.toJson(),
  };
}

class MeetingHistoryModelList {
  String actionLabel;
  DateTime actionAt;
  String oldScheduledAt;
  String newScheduledAt;
  String visitedAt;
  String reason;
  String actionBy;

  MeetingHistoryModelList({
    required this.actionLabel,
    required this.actionAt,
    required this.oldScheduledAt,
    required this.newScheduledAt,
    required this.visitedAt,
    required this.reason,
    required this.actionBy,
  });

  factory MeetingHistoryModelList.fromJson(Map<String, dynamic> json) => MeetingHistoryModelList(
    actionLabel: json["action_label"],
    actionAt: DateTime.parse(json["action_at"]),
    oldScheduledAt: json["old_scheduled_at"],
    newScheduledAt: json["new_scheduled_at"],
    visitedAt: json["visited_at"],
    reason: json["reason"],
    actionBy: json["action_by"],
  );

  Map<String, dynamic> toJson() => {
    "action_label": actionLabel,
    "action_at": actionAt.toIso8601String(),
    "old_scheduled_at": oldScheduledAt,
    "new_scheduled_at": newScheduledAt,
    "visited_at": visitedAt,
    "reason": reason,
    "action_by": actionBy,
  };
}

class Meta {
  int page;
  int perPage;
  int total;
  int lastPage;
  bool hasMore;

  Meta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    page: json["page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
    hasMore: json["has_more"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
    "has_more": hasMore,
  };
}
