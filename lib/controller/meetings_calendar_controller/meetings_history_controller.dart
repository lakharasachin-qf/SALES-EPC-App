import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/meeting_history_model.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/api_handle/Repository.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';

class MeetingsHistoryController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;
  RxList<MeetingHistoryModelList> meetingsList =
      <MeetingHistoryModelList>[].obs; // Updated to use Datum
  RxString nextPageURL = "".obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt fromItem = 0.obs;
  final RxInt toItem = 0.obs;
  RxBool isMeetingLoading = false.obs;

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
    meetingsList.clear();
    currentPage.value = 1;
    lastPage.value = 1;
    totalItems.value = 0;
    fromItem.value = 0;
    toItem.value = 0;
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

  List<List<String?>> get meetingsHistoryData {
    return meetingsList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;

      // Format actionAt to remove seconds
      // String formattedActionAt = e.actionAt.toIso8601String();
      // if (formattedActionAt.contains('T')) {
      //   final parts = formattedActionAt.split('T');
      //   if (parts.length == 2 && parts[1].length >= 5) {
      //     formattedActionAt = '${parts[0]} ${parts[1].substring(0, 5)}';
      //   }
      // }

      return [
        index.toString(), // Sr No.
        // formattedActionAt,
        e.visitedAt, // Contacted (action_at without seconds)
        e.actionLabel ?? '-', // Status
        e.oldScheduledAt ?? '-', // From
        e.newScheduledAt ?? '-', // To
        e.reason ?? '-', // Reason
        e.actionBy ?? '-', // Action By
      ];
    }).toList();
  }

  // Load static data into controller

  // Fetch meeting history from API with pagination
  Future<void> getMeetingHistory({
    required BuildContext context,
    required String meetingId,
    int page = 1,
    bool? hideLoading,
    bool isInitialLoad = false,
  }) async {
    if (hideLoading == false) {
      state.value = ScreenState.apiLoading;
    }
    if (isInitialLoad == true) {
      isMeetingLoading(true);
    }

    if (isInitialLoad) {
      resetForm();
    }

    try {
      if (networkManager.connectionType.value == 0) {
        if (isInitialLoad == true) {
          isMeetingLoading(false);
        }
        showDialogForScreen(
          context,
          'Meeting History Screen',
          'No internet connection',
          callback: Get.back,
        );
        return;
      }

      final apiUrl =
          "${ApiUrl.getMeetingsCalendarList}/$meetingId/history?page=$page&per_page=10";

      logcat("MeetingHistory URL", apiUrl);

      final response = await Repository.get({}, apiUrl, allowHeader: true);

      isMeetingLoading(false);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == "success") {
          state.value = ScreenState.apiSuccess;
          message.value = '';
          final model = MeetingHistoryModel.fromJson(responseData);
          meetingsList.clear();
          if (model.result.data.isNotEmpty) {
            meetingsList.addAll(model.result.data);
            meetingsList.refresh();
            currentPage.value = model.result.meta.page;
            lastPage.value = model.result.meta.lastPage;
            totalItems.value = model.result.meta.total;
            const int perPage = 10;
            fromItem.value = (currentPage.value - 1) * perPage + 1;
            toItem.value = currentPage.value * perPage > totalItems.value
                ? totalItems.value
                : currentPage.value * perPage;
          } else {
            currentPage.value = 1;
            lastPage.value = 1;
            totalItems.value = 0;
            fromItem.value = 0;
            toItem.value = 0;
          }
        } else {
          message.value = responseData['message'];
          showDialogForScreen(
            context,
            'Meeting History Screen',
            responseData['message'],
            callback: Get.back,
          );
        }
      } else {
        state.value = ScreenState.apiError;
        message.value = 'Server error';
        showDialogForScreen(
          context,
          'Meeting History Screen',
          responseData['message'] ?? 'Server error',
          callback: () {
            getUnauthenticatedUser(
              context,
              responseData['message'],
              "Unauthenticated user",
            );
          },
        );
      }
    } catch (e) {
      logcat("Exception", e);
      if (isInitialLoad == true) {
        isMeetingLoading(false);
      }
      state.value = ScreenState.apiError;
      message.value = 'An error occurred';
    }
    update();
  }
}
