import 'dart:convert';

LeadByIdModel leadResponseFromJson(String str) =>
    LeadByIdModel.fromJson(json.decode(str));

String leadResponseToJson(LeadByIdModel data) => json.encode(data.toJson());

class LeadByIdModel {
  String? status;
  String? message;
  LeadData? result;

  LeadByIdModel({this.status, this.message, this.result});

  factory LeadByIdModel.fromJson(Map<String, dynamic> json) => LeadByIdModel(
    status: json["status"],
    message: json["message"],
    result: json["result"] != null ? LeadData.fromJson(json["result"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": result?.toJson(),
  };
}

class LeadData {
  int? id;
  int? country;
  int? state;
  int? district;
  String? address;
  String? companyName;
  String? contactPersonName;
  String? contactPersonMobile;
  String? latitude;
  String? longitude;
  String? dgCapacityKva;
  bool? dgSyncRequired;
  String? currInstSolarCapKwp;
  String? distToNearestTransformer;
  String? ratingOfNearestTransformerKva;
  String? sanctionedLoadKva;
  String? requiredSolutionType;
  bool? vfdRequired;
  String? gridAvailabilityHrs;
  String? peakMonthlyEnergyConsKwh;
  String? requiredSolarCapKwp;
  String? purposeOfSolarisation;
  String? distBtwInverterAcdbPanelMtrs;
  String? distBtwSolarAcdbPanelMtrs;
  String? requiredSolution;
  int? buildingHeight; // ✅ Changed from dynamic to int?
  String? roofSizeLengthFt;
  String? roofSizeBreadthFt;
  String? roofNature;
  int? ageOfMetalSheet; // ✅ Changed from dynamic to int?
  String? groundSizeLengthFt;
  String? groundSizeBreadthFt;
  String? leadCategory;
  String? leadStatus;
  String? otherRemarks;
  String? source;
  String? createdAt;
  String? updatedAt;
  List<LoadElementDetail>? loadElementDetails;
  List<UploadedFile>? uploadedFiles;
  Payment? payment;
  Meeting? meeting;
  List<String>? availableNextStatuses;
  String? scheduledAt;
  String? rescheduleReason;
  String? countryName;
  String? stateName;
  String? districtName;

  LeadData({
    this.id,
    this.country,
    this.state,
    this.district,
    this.address,
    this.companyName,
    this.contactPersonName,
    this.contactPersonMobile,
    this.latitude,
    this.longitude,
    this.dgCapacityKva,
    this.dgSyncRequired,
    this.currInstSolarCapKwp,
    this.distToNearestTransformer,
    this.ratingOfNearestTransformerKva,
    this.sanctionedLoadKva,
    this.requiredSolutionType,
    this.vfdRequired,
    this.gridAvailabilityHrs,
    this.peakMonthlyEnergyConsKwh,
    this.requiredSolarCapKwp,
    this.purposeOfSolarisation,
    this.distBtwInverterAcdbPanelMtrs,
    this.distBtwSolarAcdbPanelMtrs,
    this.requiredSolution,
    this.buildingHeight,
    this.roofSizeLengthFt,
    this.roofSizeBreadthFt,
    this.roofNature,
    this.ageOfMetalSheet,
    this.groundSizeLengthFt,
    this.groundSizeBreadthFt,
    this.leadCategory,
    this.leadStatus,
    this.otherRemarks,
    this.source,
    this.createdAt,
    this.updatedAt,
    this.loadElementDetails,
    this.uploadedFiles,
    this.payment,
    this.meeting,
    this.availableNextStatuses,
    this.scheduledAt,
    this.rescheduleReason,
    this.countryName,
    this.stateName,
    this.districtName,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) => LeadData(
    id: json["id"],
    country: json["country"],
    state: json["state"],
    district: json["district"],
    address: json["address"] ?? '',
    companyName: json["company_name"] ?? '',
    contactPersonName: json["contact_person_name"],
    contactPersonMobile: json["contact_person_mobile"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    dgCapacityKva: json["dg_capacity_kva"],
    dgSyncRequired: json["dg_sync_required"],
    currInstSolarCapKwp: json["curr_inst_solar_cap_kwp"],
    distToNearestTransformer: json["dist_to_nearest_transformer"],
    ratingOfNearestTransformerKva: json["rating_of_nearest_transformer_kva"],
    sanctionedLoadKva: json["sanctioned_load_kva"],
    requiredSolutionType: json["required_solution_type"],
    vfdRequired: json["vfd_required"],
    gridAvailabilityHrs: json["grid_availability_hrs"],
    peakMonthlyEnergyConsKwh: json["peak_monthly_energy_cons_kwh"],
    requiredSolarCapKwp: json["required_solar_cap_kwp"],
    purposeOfSolarisation: json["purpose_of_solarisation"],
    distBtwInverterAcdbPanelMtrs: json["dist_btw_inverter_acdb_panel_mtrs"],
    distBtwSolarAcdbPanelMtrs: json["dist_btw_solar_acdb_panel_mtrs"],
    requiredSolution: json["required_solution"],
    buildingHeight: json["building_height"], // ✅ No change needed in parsing
    roofSizeLengthFt: json["roof_size_length_ft"],
    roofSizeBreadthFt: json["roof_size_breadth_ft"],
    roofNature: json["roof_nature"],
    ageOfMetalSheet:
        json["age_of_metal_sheet"], // ✅ No change needed in parsing
    groundSizeLengthFt: json["ground_size_length_ft"],
    groundSizeBreadthFt: json["ground_size_breadth_ft"],
    leadCategory: json["lead_category"],
    leadStatus: json["lead_status"],
    otherRemarks: json["other_remarks"],
    source: json["source"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    loadElementDetails: json["load_element_details"] == null
        ? []
        : List<LoadElementDetail>.from(
            json["load_element_details"].map(
              (x) => LoadElementDetail.fromJson(x),
            ),
          ),
    uploadedFiles: json["uploaded_files"] == null
        ? []
        : List<UploadedFile>.from(
            json["uploaded_files"].map((x) => UploadedFile.fromJson(x)),
          ),
    payment: json["payment"] != null ? Payment.fromJson(json["payment"]) : null,
    meeting: json["meeting"] != null ? Meeting.fromJson(json["meeting"]) : null,
    availableNextStatuses: json["available_next_statuses"] == null
        ? []
        : List<String>.from(json["available_next_statuses"].map((x) => x)),
    scheduledAt: json["scheduled_at"],
    rescheduleReason: json["reschedule_reason"],
    countryName: json["country_name"],
    stateName: json["state_name"],
    districtName: json["district_name"],
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
    "roof_nature": roofNature,
    "age_of_metal_sheet": ageOfMetalSheet,
    "ground_size_length_ft": groundSizeLengthFt,
    "ground_size_breadth_ft": groundSizeBreadthFt,
    "lead_category": leadCategory,
    "lead_status": leadStatus,
    "other_remarks": otherRemarks,
    "source": source,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "load_element_details": loadElementDetails?.map((x) => x.toJson()).toList(),
    "uploaded_files": uploadedFiles?.map((x) => x.toJson()).toList(),
    "payment": payment?.toJson(),
    "meeting": meeting?.toJson(),
    "available_next_statuses": availableNextStatuses ?? [],
    "scheduled_at": scheduledAt,
    "reschedule_reason": rescheduleReason,
    "country_name": countryName,
    "state_name": stateName,
    "district_name": districtName,
  };
}

class LoadElementDetail {
  int? id;
  int? leadId;
  String? deviceName;
  String? category;
  String? powerRatingWatts;
  String? dailyUsageHours;
  String? dailyEnergyWh;
  String? dailyEnergyKwh;
  String? source;

  LoadElementDetail({
    this.id,
    this.leadId,
    this.deviceName,
    this.category,
    this.powerRatingWatts,
    this.dailyUsageHours,
    this.dailyEnergyWh,
    this.dailyEnergyKwh,
    this.source,
  });

  factory LoadElementDetail.fromJson(Map<String, dynamic> json) =>
      LoadElementDetail(
        id: json["id"],
        leadId: json["lead_id"],
        deviceName: json["device_name"],
        category: json["category"],
        powerRatingWatts: json["power_rating_watts"],
        dailyUsageHours: json["daily_usage_hours"],
        dailyEnergyWh: json["daily_energy_wh"],
        dailyEnergyKwh: json["daily_energy_kwh"],
        source: json["source"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lead_id": leadId,
    "device_name": deviceName,
    "category": category,
    "power_rating_watts": powerRatingWatts,
    "daily_usage_hours": dailyUsageHours,
    "daily_energy_wh": dailyEnergyWh,
    "daily_energy_kwh": dailyEnergyKwh,
    "source": source,
  };
}

class UploadedFile {
  int? id;
  int? relatedModelId;
  String? relatedModelType;
  String? category;
  String? tag;
  String? path;
  String? fileUploadedAt;
  String? createdAt;
  String? updatedAt;
  bool canManage;

  UploadedFile({
    this.id,
    this.relatedModelId,
    this.relatedModelType,
    this.category,
    this.tag,
    this.path,
    this.fileUploadedAt,
    this.createdAt,
    this.updatedAt,
    required this.canManage,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) => UploadedFile(
    id: json["id"],
    relatedModelId: json["related_model_id"],
    relatedModelType: json["related_model_type"],
    category: json["category"],
    tag: json["tag"],
    path: json["path"],
    fileUploadedAt: json["file_uploaded_at"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    canManage: false, // ✅ default false from backend
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "related_model_id": relatedModelId,
    "related_model_type": relatedModelType,
    "category": category,
    "tag": tag,
    "path": path,
    "file_uploaded_at": fileUploadedAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Payment {
  int? id;
  int? leadId;
  int? customerId;
  String? paymentType;
  String? tokenAmount;
  bool? isTokenAmountReceived;
  String? tokenAmountReceiveDate;
  String? financingType;
  String? financingProgressStatus;
  String? totalProjectCost;
  String? fullPaymentAmount;
  int? balanceAmount; // ✅ Changed from String? to int?
  bool? isFullPaymentReceived;
  String? fullPaymentReceivedDate;
  String? createdAt;
  String? updatedAt;
  String? warrantyStartDate;
  String? warrantyEndDate;
  String? warrantyPeriod;

  Payment({
    this.id,
    this.leadId,
    this.customerId,
    this.paymentType,
    this.tokenAmount,
    this.isTokenAmountReceived,
    this.tokenAmountReceiveDate,
    this.financingType,
    this.financingProgressStatus,
    this.totalProjectCost,
    this.fullPaymentAmount,
    this.balanceAmount,
    this.isFullPaymentReceived,
    this.fullPaymentReceivedDate,
    this.createdAt,
    this.updatedAt,
    this.warrantyStartDate,
    this.warrantyEndDate,
    this.warrantyPeriod,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    leadId: json["lead_id"],
    customerId: json["customer_id"],
    paymentType: json["payment_type"],
    tokenAmount: json["token_amount"],
    isTokenAmountReceived: json["is_token_amount_received"],
    tokenAmountReceiveDate: json["token_amount_receive_date"],
    financingType: json["financing_type"],
    financingProgressStatus: json["financing_progress_status"],
    totalProjectCost: json["total_project_cost"],
    fullPaymentAmount: json["full_payment_amount"],
    balanceAmount: json["balance_amount"], // ✅ Removed .toString()
    isFullPaymentReceived: json["is_full_payment_received"],
    fullPaymentReceivedDate: json["full_payment_received_date"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    warrantyStartDate: json["warranty_start_date"],
    warrantyEndDate: json["warranty_end_date"],
    warrantyPeriod: json["warranty_period"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lead_id": leadId,
    "customer_id": customerId,
    "payment_type": paymentType,
    "token_amount": tokenAmount,
    "is_token_amount_received": isTokenAmountReceived,
    "token_amount_receive_date": tokenAmountReceiveDate,
    "financing_type": financingType,
    "financing_progress_status": financingProgressStatus,
    "total_project_cost": totalProjectCost,
    "full_payment_amount": fullPaymentAmount,
    "balance_amount": balanceAmount,
    "is_full_payment_received": isFullPaymentReceived,
    "full_payment_received_date": fullPaymentReceivedDate,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "warranty_start_date": warrantyStartDate,
    "warranty_end_date": warrantyEndDate,
    "warranty_period": warrantyPeriod,
  };
}

class Meeting {
  int? id;
  int? leadId;
  String? scheduledAt;
  String? visitedAt;
  String? meetingStatus;
  String? meetingNotes;
  String? rescheduleReason;
  dynamic scheduledBy;
  dynamic attendedBy;
  String? createdAt;
  String? updatedAt;

  Meeting({
    this.id,
    this.leadId,
    this.scheduledAt,
    this.visitedAt,
    this.meetingStatus,
    this.meetingNotes,
    this.rescheduleReason,
    this.scheduledBy,
    this.attendedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json["id"],
    leadId: json["lead_id"],
    scheduledAt: json["scheduled_at"],
    visitedAt: json["visited_at"],
    meetingStatus: json["meeting_status"],
    meetingNotes: json["meeting_notes"],
    rescheduleReason: json["reschedule_reason"],
    scheduledBy: json["scheduled_by"],
    attendedBy: json["attended_by"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lead_id": leadId,
    "scheduled_at": scheduledAt,
    "visited_at": visitedAt,
    "meeting_status": meetingStatus,
    "meeting_notes": meetingNotes,
    "reschedule_reason": rescheduleReason,
    "scheduled_by": scheduledBy,
    "attended_by": attendedBy,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
