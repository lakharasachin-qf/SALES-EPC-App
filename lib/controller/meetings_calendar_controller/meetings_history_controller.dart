import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/customer_model.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import '../../api_handle/Repository.dart';

class MeetingsHistoryController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 🔹 Initialize Controllers
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

  final RxList<String> customerHeaders = <String>[
    "Sr No.",
    "Contacted",
    "Status",
    "From	",
    "To",
    "Reason",
    "Action",
  ].obs;

  // Provide all customer data without pagination
  List<List<String>> get meetingsHistoryData {
    if (customerList.isEmpty) return [];

    return customerList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;

      return [
        index.toString(), // Sr No.
        e.businessUnit ?? 'N/A',
        e.cafNo ?? 'N/A',
        e.customerName ?? 'N/A',
        e.categoryName.toString().split('.').last,
        e.customerStatus.toString().split('.').last ?? 'N/A',
        e.customerType.toString().split('.').last ?? 'N/A',
      ];
    }).toList();
  }

  RxList<Result> customerList = <Result>[].obs;
  RxString nextPageURL = "".obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt fromItem = 0.obs;
  final RxInt toItem = 0.obs;

  var isCustomerLoading = false.obs;

  Future<void> getCustomerbyID(
    BuildContext context,
    int currentPage,
    bool hideLoading, {
    bool isFirstTime = false,
  }) async {
    User? userData = await UserPreferences().getSignInInfo();

    if (hideLoading == false) {
      state.value = ScreenState.apiLoading;
    }
    if (isFirstTime == true) {
      isCustomerLoading(
        true,
      ); // Assuming you have a loading state for customers
    }

    try {
      if (networkManager.connectionType.value == 0) {
        if (isFirstTime == true) {
          isCustomerLoading(false);
        }
        showDialogForScreen(
          context,
          'Meter Screen',
          Connection.noConnection,
          callback: () {
            Get.back();
          },
        );
        return;
      }

      var pageURL =
          "${ApiUrl.getcustomerbyIdwwithpagination}=${userData?.userId ?? ''}&page=$currentPage&per_page=10";
      var response = await Repository.get({}, pageURL, allowHeader: true);

      if (isFirstTime == true) {
        isCustomerLoading(false);
      }

      logcat("RESPONSE::", response.body);
      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          state.value = ScreenState.apiSuccess;
          message.value = '';

          if (isFirstTime == true && customerList.isNotEmpty) {
            currentPage = 1;
            customerList.clear();
          }

          var customerListData = CustomerModel.fromJson(responseData);
          if (customerListData.result.isNotEmpty) {
            customerList.addAll(customerListData.result);
            customerList.refresh();
            update();
          } else {
            customerList.clear();
          }

          // ✅ Set pagination info
          this.currentPage.value = customerListData.pagination.currentPage;
          lastPage.value = customerListData.pagination.lastPage;
          totalItems.value = customerListData.pagination.total;
          fromItem.value = customerListData.pagination.from;
          toItem.value = customerListData.pagination.to;
          // Handle pagination
          if (customerListData.pagination.currentPage <
              customerListData.pagination.lastPage) {
            nextPageURL.value =
                "${ApiUrl.getcustomerbyIdwwithpagination}=${userData?.userId ?? ''}&page=${currentPage + 1}&per_page=10";
            logcat("nextPageURL-1", nextPageURL.value.toString());
            update();
          } else {
            nextPageURL.value = "";
            logcat("nextPageURL-2", nextPageURL.value.toString());
            update();
          }
          logcat("nextPageURL", nextPageURL.value.toString());
        } else {
          message.value = responseData['message'];
          showDialogForScreen(
            context,
            'Meter Screen',
            responseData['message'],
            callback: () {},
          );
        }
      } else {
        state.value = ScreenState.apiError;
        message.value = APIResponseHandleText.serverError;
        showDialogForScreen(
          context,
          'Meter Screen',
          responseData['message'] ?? ServerError.servererror,
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
      if (isFirstTime == true) {
        isCustomerLoading(false);
      }
      state.value = ScreenState.apiError;
      // message.value = ServerError.servererror;
      // showDialogForScreen(context, 'Meter Screen', ServerError.servererror, callback: () {});
    }
  }
}
