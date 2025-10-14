import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/log.dart';
import '../../models/MeetingCalendarModel.dart';

class MeetingsHistoryController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;
  // List of MeetingHistory items (from API)
  RxList<MeetingHistory> meetingsList = <MeetingHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    logcat("Init", "Done");
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    unfocusAll();
    update();
  }

  final RxList<String> headers = <String>[
    "Sr No.",
    "Contacted",
    "Status",
    "From",
    "To",
    "Reason",
    "Action By",
  ].obs;

  // Prepare table data
  // List<List<String?>> get meetingsHistoryData {
  //   return meetingsList.asMap().entries.map((entry) {
  //     final index = entry.key + 1;
  //     final e = entry.value;
  //     return [
  //       index.toString(), // Sr No.
  //       e.actionAt, // Contacted
  //       e.actionLabel, // Status
  //       e.oldScheduledAt, // From
  //       e.newScheduledAt, // To
  //       e.reason, // Reason
  //       e.actionBy, // Action By
  //     ];
  //   }).toList();
  // }

  List<List<String?>> get meetingsHistoryData {
    return meetingsList.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final e = entry.value;

      // Format actionAt to remove seconds
      String formattedActionAt = e.actionAt!;
      if (formattedActionAt.contains(' ')) {
        final parts = formattedActionAt.split(' ');
        if (parts.length == 2 && parts[1].length >= 5) {
          formattedActionAt = '${parts[0]} ${parts[1].substring(0, 5)}';
        }
      }

      return [
        index.toString(), // Sr No.
        formattedActionAt, // Contacted (action_at without seconds)
        e.actionLabel, // Status
        e.oldScheduledAt, // From
        e.newScheduledAt, // To
        e.reason, // Reason
        e.actionBy, // Action By
      ];
    }).toList();
  }

  // Load data into controller (e.g., from API)
  void setMeetingHistory(List<MeetingHistory> history) {
    meetingsList.assignAll(history);
    state.value = ScreenState.apiSuccess;
  }
}
