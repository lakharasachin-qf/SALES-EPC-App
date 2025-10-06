import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/customer_model.dart';
import 'package:sales_app/models/customer_model_wo_p.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';
import '../../api_handle/Repository.dart';
import '../../models/fillter_model.dart' hide Result;

class MeetingsCalendarController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;

  // 🔹 Controllers
  late TextEditingController statusCtr, dateCtr, reasonCtr, notesCtr;

  // 🔹 FocusNodes
  late FocusNode statusNode, dateNode, reasonNode, notesNode;

  // 🔹 Validation Models
  var statusModel = ValidationModel(null, null, isValidate: false).obs;
  var dateModel = ValidationModel(null, null, isValidate: false).obs;
  var reasonModel = ValidationModel(null, null, isValidate: false).obs;
  var notesModel = ValidationModel(null, null, isValidate: false).obs;

  RxBool isStartDateActive = true.obs;
  RxBool isStartDateSelected = false.obs;
  RxBool isDistrictSelected = false.obs;
  RxBool isClusterSelected = false.obs;
  RxBool isFormInvalidate = false.obs;
  RxList<Category> districtList = <Category>[].obs;
  RxList<Category> clustersList = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();

    // 🔹 Initialize Controllers
    statusCtr = TextEditingController();
    dateCtr = TextEditingController();
    reasonCtr = TextEditingController();
    notesCtr = TextEditingController();

    // 🔹 Initialize FocusNodes
    statusNode = FocusNode();
    dateNode = FocusNode();
    reasonNode = FocusNode();
    notesNode = FocusNode();
  }

  @override
  void onClose() {
    // 🔹 Dispose Controllers
    statusCtr.dispose();
    dateCtr.dispose();
    reasonCtr.dispose();
    notesCtr.dispose();

    // 🔹 Dispose FocusNodes
    statusNode.dispose();
    dateNode.dispose();
    reasonNode.dispose();
    notesNode.dispose();

    super.onClose();
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    unfocusAll();
    update();
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

  final RxList<String> customerHeaders = <String>[
    "Sr No.",
    "Lead Id",
    "Contact Person",
    "Latest Appointment",
    "Contacted",
    "Status",
    "Action",
  ].obs;

  // Provide all customer data without pagination
  List<List<String>> get meetingsData {
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
        "",
      ];
    }).toList();
  }

  void resetFilterFields() {
    // 🔹 Controllers
    statusCtr.clear();
    dateCtr.clear();
    reasonCtr.clear();
    notesCtr.clear();

    // 🔹 Dropdown / reactive selection
    selectStatus.value = 'Select Status';

    // 🔹 Validation Models
    statusModel.value = ValidationModel(null, null, isValidate: false);
    dateModel.value = ValidationModel(null, null, isValidate: false);
    reasonModel.value = ValidationModel(null, null, isValidate: false);
    notesModel.value = ValidationModel(null, null, isValidate: false);

    // 🔹 Other flags
    isStartDateActive.value = true;
    isStartDateSelected.value = false;
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isFormInvalidate.value = false;
  }

  void updateMeetings(context) async {
    resetFilterFields();
    openBottomtsheetDialog(
      context,
      title: "Edit Meeting",
      widget: addFilterSheetWidget(context),
    );
  }

  final List<String> status = ['Select Status', 'Reschedule'];
  RxString selectStatus = 'Select Status'.obs;

  Widget addFilterSheetWidget(context) {
    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.5.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getDynamicSizedBox(height: 1.h),
          getLable("Status", isRequired: true),
          Obx(
            () => getReactiveDropdown(
              hint: "Select Status",
              items: status,
              selectedValue: selectStatus.value,
              onChanged: (value) {
                selectStatus.value = value!;
                update();
              },
            ),
          ),
          getDynamicSizedBox(height: 1.h),

          Obx(() {
            if (selectStatus.value == 'Reschedule') {
              return Column(
                children: [
                  getTextField(
                    context: context,
                    wantLabel: true,
                    label: 'New Date',
                    ctr: dateCtr,
                    node: dateNode,
                    model: dateModel.value,
                    isRequired: true,
                    isenable: false,
                    usegesture: true,
                    isdate: true,
                    wantsuffix: true,
                    gestureFunction: () async {
                      openDatePicker(
                        context: context,
                        title: 'Select New Date',
                        controller: dateCtr,
                        dateRx: startDate,
                        model: dateModel,
                      );
                    },
                    hint: 'Select Date',
                  ),
                  getDynamicSizedBox(height: 1.h),
                  getTextField(
                    context: context,
                    wantLabel: true,
                    label: 'Reason',
                    ctr: reasonCtr,
                    node: reasonNode,
                    model: reasonModel.value,
                    hint: 'Enter Reason',
                    isRequired: true,
                  ),
                  getDynamicSizedBox(height: 1.h),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          }),

          Obx(() {
            return getTextField(
              context: context,
              wantLabel: true,
              label: 'Notes',
              ctr: notesCtr, // 🔹 use correct controller for Notes
              node: notesNode, // 🔹 use correct node for Notes
              model: notesModel.value,
              hint: 'Enter Notes',
              isMultipline: true,
              isRequired: true,
            );
          }),

          getDynamicSizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: getFormButton(
                  context,
                  () {
                    Get.back();
                  },
                  'Cancel',
                  validate: true,
                ),
              ),
              getDynamicSizedBox(width: 3.w),
              Expanded(
                child: getFormButton(
                  context,
                  () {
                    Get.back();
                  },
                  "Update",
                  validate: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime? selectedDateTime;
  final RxString startDate = ''.obs;
  void openDatePicker({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required RxString dateRx,
    required Rx<ValidationModel> model,
    bool showTimePickers = true,
    bool isEndDate = false, // Added to identify end date picker
  }) {
    showCommonDatePicker(
      context: context,
      title: title,
      initialDate: dateRx.value.isNotEmpty
          ? dateTimeFormat.parse(dateRx.value)
          : null,
      minDate: startDate.value.isNotEmpty
          ? dateTimeFormat.parse(startDate.value)
          : null,
      showTimePickers: showTimePickers,
      onDatePicked: (DateTime date) {
        final formatted = dateTimeFormat.format(date);
        dateRx.value = formatted;
        controller.text = formatted;
        // validateFields(
        //   controller.text,
        //   iscomman: true,
        //   model: model,
        //   errorText1: showTimePickers
        //       ? 'Please choose date and time'
        //       : 'Please choose date',
        // );
      },
    );
  }

  // Common filter
  var currentFilterSource = [].obs;
  var filteredData = [].obs;
  RxString categoryId = "".obs;
  RxList<CategoryModel> warrantyType = <CategoryModel>[
    CategoryModel(id: "1", name: "Invoice"),
    CategoryModel(id: "2", name: "Bills"),
    CategoryModel(id: "3", name: "Reports"),
    CategoryModel(id: "4", name: "Others"),
  ].obs;
}
