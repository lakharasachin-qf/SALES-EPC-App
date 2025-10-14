import 'dart:convert';

MeetingCalendarModel meetingResponseFromJson(String str) =>
    MeetingCalendarModel.fromJson(json.decode(str));

String meetingResponseToJson(MeetingCalendarModel data) =>
    json.encode(data.toJson());

class MeetingCalendarModel {
  String? status;
  String? message;
  MeetingResult? result;

  MeetingCalendarModel({this.status, this.message, this.result});

  factory MeetingCalendarModel.fromJson(Map<String, dynamic> json) {
    return MeetingCalendarModel(
      status: json['status'],
      message: json['message'] ?? '',
      result: json['result'] != null
          ? MeetingResult.fromJson(json['result'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'result': result?.toJson()};
  }
}

class MeetingResult {
  List<MeetingData>? data;
  Pagination? pagination;

  MeetingResult({this.data, this.pagination});

  factory MeetingResult.fromJson(Map<String, dynamic> json) {
    return MeetingResult(
      data: (json['data'] as List?)
          ?.map((item) => MeetingData.fromJson(item))
          .toList(),
      pagination: json['meta'] != null
          ? Pagination.fromJson(json['meta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((m) => m.toJson()).toList(),
      'meta': pagination?.toJson(),
    };
  }
}

class MeetingData {
  int? id;
  int? leadId;
  String? contactPersonName;
  String? companyName;
  String? meetingStatus;
  String? meetingStatusLabel;
  String? scheduledAt;
  String? visitedAt;
  String? formattedScheduledAt;
  String? formattedVisitedAt;
  String? meetingNotes;
  String? rescheduleReason;
  List<MeetingHistory>? history;

  MeetingData({
    this.id,
    this.leadId,
    this.contactPersonName,
    this.companyName,
    this.meetingStatus,
    this.meetingStatusLabel,
    this.scheduledAt,
    this.visitedAt,
    this.formattedScheduledAt,
    this.formattedVisitedAt,
    this.meetingNotes,
    this.rescheduleReason,
    this.history,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    return MeetingData(
      id: json['id'],
      leadId: json['lead_id'],
      contactPersonName: json['contact_person_name'] ?? '',
      companyName: json['company_name'] ?? '',
      meetingStatus: json['meeting_status'] ?? '',
      meetingStatusLabel: json['meeting_status_label'] ?? '',
      scheduledAt: json['scheduled_at'] ?? '',
      visitedAt: json['visited_at'] ?? '',
      formattedScheduledAt: json['formatted_scheduled_at'] ?? '',
      formattedVisitedAt: json['formatted_visited_at'] ?? '',
      meetingNotes: json['meeting_notes'] ?? '',
      rescheduleReason: json['reschedule_reason'] ?? '',
      history: (json['history'] as List?)
          ?.map((item) => MeetingHistory.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'contact_person_name': contactPersonName,
      'company_name': companyName,
      'meeting_status': meetingStatus,
      'meeting_status_label': meetingStatusLabel,
      'scheduled_at': scheduledAt,
      'visited_at': visitedAt,
      'formatted_scheduled_at': formattedScheduledAt,
      'formatted_visited_at': formattedVisitedAt,
      'meeting_notes': meetingNotes,
      'reschedule_reason': rescheduleReason,
      'history': history?.map((h) => h.toJson()).toList(),
    };
  }
}

class MeetingHistory {
  String? actionLabel;
  String? actionAt;
  String? oldScheduledAt;
  String? newScheduledAt;
  String? visitedAt;
  String? reason;
  String? actionBy;

  MeetingHistory({
    this.actionLabel,
    this.actionAt,
    this.oldScheduledAt,
    this.newScheduledAt,
    this.visitedAt,
    this.reason,
    this.actionBy,
  });

  factory MeetingHistory.fromJson(Map<String, dynamic> json) {
    return MeetingHistory(
      actionLabel: json['action_label'] ?? '',
      actionAt: json['action_at'] ?? '',
      oldScheduledAt: json['old_scheduled_at'] ?? '',
      newScheduledAt: json['new_scheduled_at'] ?? '',
      visitedAt: json['visited_at'] ?? '',
      reason: json['reason'] ?? '',
      actionBy: json['action_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_label': actionLabel,
      'action_at': actionAt,
      'old_scheduled_at': oldScheduledAt,
      'new_scheduled_at': newScheduledAt,
      'visited_at': visitedAt,
      'reason': reason,
      'action_by': actionBy,
    };
  }
}

class Pagination {
  int? page;
  int? perPage;
  int? total;
  int? lastPage;
  bool? hasMore;

  Pagination({
    this.page,
    this.perPage,
    this.total,
    this.lastPage,
    this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
      hasMore: json['has_more'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
      'has_more': hasMore,
    };
  }
}
