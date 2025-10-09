import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import '../../api_handle/Repository.dart';
import '../../componant/dialogs/common_date_time_picker.dart';

class MeetingsHistoryController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeStaticData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    unfocusAll();
    update();
  }

  RxList<MeetingHistoryData> meetingHistoryList = <MeetingHistoryData>[].obs;
  RxString nextPageURL = "".obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt fromItem = 0.obs;
  final RxInt toItem = 0.obs;

  var isMeetingHistoryLoading = false.obs;

  final RxList<String> meetingHeaders = <String>[
    "Sr No.",
    "Contacted",
    "Status",
    "From",
    "To",
    "Reason",
    "Action By",
  ].obs;

  // Provide all meeting history data without pagination
  List<List<String>> get meetingsHistoryData {
    if (meetingHistoryList.isEmpty) return [];

    return meetingHistoryList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;

      return [
        index.toString(), // Sr No.
        dateTimeFormat.format(e.contacted ?? DateTime.now()),
        e.status ?? 'N/A',
        dateTimeFormat.format(e.from ?? DateTime.now()),
        dateTimeFormat.format(e.to ?? DateTime.now()),
        e.reason ?? 'N/A',
        e.actionBy ?? 'N/A',
      ];
    }).toList();
  }

  // Initialize static meeting history data
  void initializeStaticData() {
    meetingHistoryList.clear();
    meetingHistoryList.addAll([
      MeetingHistoryData(
        contacted: DateTime(2025, 10, 1, 9, 0),
        status: "Scheduled",
        from: DateTime(2025, 10, 15, 10, 0),
        to: DateTime(2025, 10, 15, 11, 0),
        reason: "Initial meeting scheduled",
        actionBy: "John Doe",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 10, 5, 14, 0),
        status: "Rescheduled",
        from: DateTime(2025, 11, 10, 14, 0),
        to: DateTime(2025, 11, 10, 15, 0),
        reason: "Client requested new time",
        actionBy: "Jane Smith",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 10, 10, 11, 0),
        status: "Cancelled",
        from: DateTime(2025, 12, 20, 11, 0),
        to: DateTime(2025, 12, 20, 12, 0),
        reason: "Client unavailable",
        actionBy: "Alice Johnson",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 10, 15, 15, 0),
        status: "Scheduled",
        from: DateTime(2025, 10, 25, 15, 0),
        to: DateTime(2025, 10, 25, 16, 0),
        reason: "Demo presentation",
        actionBy: "Bob Wilson",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 9, 20, 9, 0),
        status: "Completed",
        from: DateTime(2025, 9, 30, 9, 0),
        to: DateTime(2025, 9, 30, 10, 0),
        reason: "Agreement signed",
        actionBy: "Emma Brown",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 10, 20, 13, 0),
        status: "Scheduled",
        from: DateTime(2025, 11, 5, 13, 0),
        to: DateTime(2025, 11, 5, 14, 0),
        reason: "Initial consultation",
        actionBy: "Liam Davis",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 11, 1, 16, 0),
        status: "Rescheduled",
        from: DateTime(2025, 12, 15, 16, 0),
        to: DateTime(2025, 12, 15, 17, 0),
        reason: "Project milestone review",
        actionBy: "Olivia Taylor",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 10, 5, 10, 30),
        status: "Completed",
        from: DateTime(2025, 10, 10, 10, 30),
        to: DateTime(2025, 10, 10, 11, 30),
        reason: "Deal finalized",
        actionBy: "Noah Anderson",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 11, 10, 14, 30),
        status: "Scheduled",
        from: DateTime(2025, 11, 25, 14, 30),
        to: DateTime(2025, 11, 25, 15, 30),
        reason: "Product demo scheduled",
        actionBy: "Sophia Martinez",
      ),
      MeetingHistoryData(
        contacted: DateTime(2025, 11, 15, 12, 0),
        status: "Cancelled",
        from: DateTime(2025, 12, 1, 12, 0),
        to: DateTime(2025, 12, 1, 13, 0),
        reason: "Client postponed",
        actionBy: "Ethan Thomas",
      ),
    ]);

    // Set pagination details for static data
    totalItems.value = meetingHistoryList.length;
    currentPage.value = 1;
    lastPage.value = 1; // Static data fits in one page
    fromItem.value = 1;
    toItem.value = meetingHistoryList.length;
    nextPageURL.value = "";
    state.value = ScreenState.apiSuccess;
    update();
  }

  // Future<void> getMeetingHistory(
  //   BuildContext context,
  //   int currentPage,
  //   bool hideLoading, {
  //   bool isFirstTime = false,
  // }) async {
  //   User? userData = await UserPreferences().getSignInInfo();

  //   if (hideLoading == false) {
  //     state.value = ScreenState.apiLoading;
  //   }
  //   if (isFirstTime == true) {
  //     isMeetingHistoryLoading(true);
  //   }

  //   try {
  //     if (networkManager.connectionType.value == 0) {
  //       if (isFirstTime == true) {
  //         isMeetingHistoryLoading(false);
  //       }
  //       showDialogForScreen(
  //         context,
  //         'Meeting History Screen',
  //         Connection.noConnection,
  //         callback: () {
  //           Get.back();
  //         },
  //       );
  //       return;
  //     }

  //     var pageURL =
  //         "${ApiUrl.getMeetingHistoryWithPagination}=${userData?.userId ?? ''}&page=$currentPage&per_page=10";
  //     var response = await Repository.get({}, pageURL, allowHeader: true);

  //     if (isFirstTime == true) {
  //       isMeetingHistoryLoading(false);
  //     }

  //     logcat("RESPONSE::", response.body);
  //     var responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       if (responseData['status'] == true) {
  //         state.value = ScreenState.apiSuccess;
  //         message.value = '';

  //         if (isFirstTime == true && meetingHistoryList.isNotEmpty) {
  //           currentPage.value = 1;
  //           meetingHistoryList.clear();
  //         }

  //         var meetingHistoryData = MeetingHistoryModel.fromJson(responseData);
  //         if (meetingHistoryData.result.isNotEmpty) {
  //           meetingHistoryList.addAll(meetingHistoryData.result);
  //           meetingHistoryList.refresh();
  //           update();
  //         } else {
  //           meetingHistoryList.clear();
  //         }

  //         // Set pagination info
  //         this.currentPage.value = meetingHistoryData.pagination.currentPage;
  //         lastPage.value = meetingHistoryData.pagination.lastPage;
  //         totalItems.value = meetingHistoryData.pagination.total;
  //         fromItem.value = meetingHistoryData.pagination.from;
  //         toItem.value = meetingHistoryData.pagination.to;

  //         // Handle pagination
  //         if (meetingHistoryData.pagination.currentPage <
  //             meetingHistoryData.pagination.lastPage) {
  //           nextPageURL.value =
  //               "${ApiUrl.getMeetingHistoryWithPagination}=${userData?.userId ?? ''}&page=${currentPage + 1}&per_page=10";
  //           logcat("nextPageURL-1", nextPageURL.value.toString());
  //           update();
  //         } else {
  //           nextPageURL.value = "";
  //           logcat("nextPageURL-2", nextPageURL.value.toString());
  //           update();
  //         }
  //         logcat("nextPageURL", nextPageURL.value.toString());
  //       } else {
  //         message.value = responseData['message'];
  //         showDialogForScreen(
  //           context,
  //           'Meeting History Screen',
  //           responseData['message'],
  //           callback: () {},
  //         );
  //       }
  //     } else {
  //       state.value = ScreenState.apiError;
  //       message.value = APIResponseHandleText.serverError;
  //       showDialogForScreen(
  //         context,
  //         'Meeting History Screen',
  //         responseData['message'] ?? ServerError.servererror,
  //         callback: () {
  //           getUnauthenticatedUser(
  //             context,
  //             responseData['message'],
  //             "Unauthenticated user",
  //           );
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     logcat("Exception", e);
  //     if (isFirstTime == true) {
  //       isMeetingHistoryLoading(false);
  //     }
  //     state.value = ScreenState.apiError;
  //   }
  // }
}

// Meeting history data model
class MeetingHistoryData {
  DateTime? contacted;
  String? status;
  DateTime? from;
  DateTime? to;
  String? reason;
  String? actionBy;

  MeetingHistoryData({
    this.contacted,
    this.status,
    this.from,
    this.to,
    this.reason,
    this.actionBy,
  });
}

// Meeting history model for API response
class MeetingHistoryModel {
  List<MeetingHistoryData> result;
  Pagination pagination;

  MeetingHistoryModel({required this.result, required this.pagination});

  factory MeetingHistoryModel.fromJson(Map<String, dynamic> json) {
    return MeetingHistoryModel(
      result: (json['result'] as List)
          .map(
            (e) => MeetingHistoryData(
              contacted: DateTime.parse(e['contacted']),
              status: e['status'],
              from: DateTime.parse(e['from']),
              to: DateTime.parse(e['to']),
              reason: e['reason'],
              actionBy: e['action_by'],
            ),
          )
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

// Pagination model (assumed to be the same as in previous code)
class Pagination {
  int currentPage;
  int lastPage;
  int total;
  int from;
  int to;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }
}
