import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:intl/intl.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/controller/master_controller/Master_Controller.dart';
import 'package:sales_app/models/customer_model.dart';
import 'package:sales_app/models/customer_model_wo_p.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../api_handle/Repository.dart';
import '../../models/fillter_model.dart' hide Result;

class LeadController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;

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

    startTimeNode = FocusNode();
    endTimeNode = FocusNode();
    districtNode = FocusNode();
    categoryNode = FocusNode();
    clusterNode = FocusNode();
    customerNode = FocusNode();
    searchGroupNode = FocusNode();
    searchCategoriesNode = FocusNode();
    searchClusterNode = FocusNode();
    searchCustomerNode = FocusNode();

    startTimeCtr = TextEditingController();
    endTimeCtr = TextEditingController();
    district = TextEditingController();
    categoryCtr = TextEditingController();
    clusterCtr = TextEditingController();
    customerCtr = TextEditingController();
    searchDistrictCtr = TextEditingController();
    searchCategoriesCtr = TextEditingController();
    searchClusterCtr = TextEditingController();
    searchCustomerCtr = TextEditingController();
  }

  @override
  void onClose() {
    startTimeNode.dispose();
    endTimeNode.dispose();
    districtNode.dispose();
    categoryNode.dispose();
    clusterNode.dispose();
    customerNode.dispose();
    searchGroupNode.dispose();
    searchCategoriesNode.dispose();
    searchClusterNode.dispose();
    searchCustomerNode.dispose();

    startTimeCtr.dispose();
    endTimeCtr.dispose();
    district.dispose();
    categoryCtr.dispose();
    clusterCtr.dispose();
    customerCtr.dispose();
    searchDistrictCtr.dispose();
    searchCategoriesCtr.dispose();
    searchClusterCtr.dispose();
    searchCustomerCtr.dispose();
    super.onClose();
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    unfocusAll();
    startTimeCtr.clear();
    endTimeCtr.clear();
    district.clear();
    categoryCtr.clear();
    clusterCtr.clear();
    customerCtr.clear();
    searchDistrictCtr.clear();
    searchCategoriesCtr.clear();
    searchClusterCtr.clear();
    searchCustomerCtr.clear();
    startDate.value = '';
    endDate.value = '';
    startDateApi.value = '';
    endDateApi.value = '';
    selectedDistrictId.value = '';
    selectedClusterId.value = '';
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isStartDateSelected.value = false;
    districtListInt.clear();
    categoryListInt.clear();
    clusterListInt.clear();
    customerListInt.clear();

    startTimeModel.value = ValidationModel(null, null, isValidate: false);
    endTimeModel.value = ValidationModel(null, null, isValidate: false);
    disitrict.value = ValidationModel(null, null, isValidate: false);
    categoryModel.value = ValidationModel(null, null, isValidate: false);
    clusterModel.value = ValidationModel(null, null, isValidate: false);
    customerModel.value = ValidationModel(null, null, isValidate: false);
    isFormInvalidate.value = false;
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

  //filter logic

  late FocusNode startTimeNode, endTimeNode;
  late FocusNode districtNode, categoryNode, clusterNode, customerNode;
  late FocusNode searchGroupNode,
      searchCategoriesNode,
      searchClusterNode,
      searchCustomerNode;
  late TextEditingController startTimeCtr, endTimeCtr;
  late TextEditingController district, categoryCtr, clusterCtr, customerCtr;
  late TextEditingController searchDistrictCtr,
      searchCategoriesCtr,
      searchClusterCtr,
      searchCustomerCtr;

  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  final RxString startDateApi = ''.obs;
  final RxString endDateApi = ''.obs;
  final DateFormat dateFormat = DateFormat('MMMM yyyy');
  final DateFormat apiDateFormat = DateFormat('yyyy-MM');
  var startTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var endTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var disitrict = ValidationModel(null, null, isValidate: false).obs;
  var categoryModel = ValidationModel(null, null, isValidate: false).obs;
  var clusterModel = ValidationModel(null, null, isValidate: false).obs;
  var customerModel = ValidationModel(null, null, isValidate: false).obs;

  RxString selectedDistrictId = ''.obs;
  RxString selectedClusterId = ''.obs;
  RxList districtListInt = [].obs;
  RxList categoryListInt = [].obs;
  RxList clusterListInt = [].obs;
  RxList customerListInt = [].obs;

  void resetSelectionFlags() {
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
  }

  void openFilterBottomSheet({required BuildContext context}) {
    startTimeCtr.text = startDate.value;
    endTimeCtr.text = endDate.value;
    district.text = selectedDistrictId.value.isNotEmpty
        ? districtList
              .where(
                (g) => selectedDistrictId.value
                    .split(', ')
                    .contains(g.id.toString()),
              )
              .map((g) => g.name)
              .join(', ')
        : '';
    clusterCtr.text = selectedClusterId.value.isNotEmpty
        ? clustersList
              .where(
                (c) => selectedClusterId.value
                    .split(', ')
                    .contains(c.id.toString()),
              )
              .map((c) => c.name)
              .join(', ')
        : '';

    startTimeModel.value = ValidationModel(
      startDate.value.isNotEmpty ? startDate.value : null,
      null,
      isValidate: startDate.value.isNotEmpty,
    );
    endTimeModel.value = ValidationModel(
      endDate.value.isNotEmpty ? endDate.value : null,
      null,
      isValidate: endDate.value.isNotEmpty,
    );
    disitrict.value = ValidationModel(
      district.text.isNotEmpty ? district.text : null,
      null,
      isValidate: district.text.isNotEmpty,
    );
    clusterModel.value = ValidationModel(
      clusterCtr.text.isNotEmpty ? clusterCtr.text : null,
      null,
      isValidate: clusterCtr.text.isNotEmpty,
    );

    isDistrictSelected.value = selectedDistrictId.value.isNotEmpty;
    isClusterSelected.value = selectedClusterId.value.isNotEmpty;

    getFillterOptions(context);

    openBottomtsheetDialog(
      context,
      title: "Filter",
      widget: addFilterSheetWidget(
        context,
        ctr: this,
        setStateTrigger: () {
          update();
        },
      ),
    );

    enableSubmitButton();
  }

  void enableSubmitButton() {
    isFormInvalidate.value =
        startTimeModel.value.isValidate && endTimeModel.value.isValidate;
    update();
  }

  void validateFields(val, {required Rx<ValidationModel> model, errorText1}) {
    return validateField(
      val: val,
      models: model,
      iscomman: true,
      errorText1: errorText1,
      notifyListeners: () => update(),
      enableBtnFunction: () => enableSubmitButton(),
    );
  }

  Future<void> getFillterOptions(context) async {
    User? userData = await UserPreferences().getSignInInfo();
    var loadingIndicator = LoadingProgressDialog();
    commonGetApiCallFormate(
      context,
      title: 'Lead Screen',
      apiEndPoint:
          "${ApiUrl.getfillter}/${userData?.userId ?? ''}/filter-options",
      allowHeader: true,
      state: state,
      message: message,
      apisLoading: (isloaing) {
        if (isloaing == true) {
          loadingIndicator.show(context, '');
        } else {
          loadingIndicator.hide(context);
        }
      },
      onResponse: (data) {
        districtList.clear();
        clustersList.clear();
        FiltterModel responseDetail = FiltterModel.fromJson(data);
        districtList.addAll(responseDetail.result.groups);
        clustersList.addAll(responseDetail.result.clusters);
        update();
      },
      networkManager: networkManager,
    );
  }

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
    "Company",
    "Contact Person",
    "Mobile",
    "Category",
    "Lead Status",
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

  void onDateSelected(DateTime? date) {
    if (date == null) return;

    final displayFormatted = dateFormat.format(date);
    final apiFormatted = apiDateFormat.format(date);

    if (isStartDateActive.value) {
      startDate.value = displayFormatted;
      startDateApi.value = apiFormatted;
      startTimeCtr.text = displayFormatted;
      isStartDateSelected.value = true;
      startTimeModel.value = ValidationModel(
        displayFormatted,
        null,
        isValidate: true,
      );
    } else {
      endDate.value = displayFormatted;
      endDateApi.value = apiFormatted;
      endTimeCtr.text = displayFormatted;
      endTimeModel.value = ValidationModel(
        displayFormatted,
        null,
        isValidate: true,
      );
    }

    enableSubmitButton();
  }

  final List<String> status = ['Select Status', 'Reschedule'];
  RxString selectStatus = 'Select Status'.obs;

  DateTime? selectedDateTime;
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

Widget addFilterSheetWidget(
  BuildContext context, {
  required LeadController ctr,
  required setStateTrigger,
}) {
  return GestureDetector(
    onTap: () {
      ctr.unfocusAll();
    },
    child: SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 2.h, left: 6.w, right: 6.w, top: 2.h),
      child: SizedBox(
        width: Device.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // getCustomDivider(),
            // getDynamicSizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() {
                    return getTextField(
                      context: context,
                      wantLabel: true,
                      label: 'Start Month-Year',
                      ctr: ctr.startTimeCtr,
                      node: ctr.startTimeNode,
                      model: ctr.startTimeModel.value,
                      isenable: false,
                      isdropdown: true,
                      wantsuffix: true,
                      usegesture: true,
                      gestureFunction: () {
                        openDatePickerDash(context, isStart: true, ctr: ctr);
                      },
                      hint: 'Select Date',
                      isRequired: false,
                    );
                  }),
                ),
                getDynamicSizedBox(width: 4.w),
                Expanded(
                  child: Obx(() {
                    return getTextField(
                      context: context,
                      wantLabel: true,
                      label: 'End Month-Year',
                      ctr: ctr.endTimeCtr,
                      node: ctr.endTimeNode,
                      model: ctr.endTimeModel.value,
                      isenable: false,
                      isdropdown: true,
                      wantsuffix: true,
                      usegesture: true,
                      gestureFunction: () {
                        if (!ctr.isStartDateSelected.value) {
                          showDialogForScreen(
                            context,
                            'Dashboard',
                            'Please select the start date first.',
                            callback: () {},
                          );
                        } else {
                          openDatePickerDash(context, isStart: false, ctr: ctr);
                        }
                      },
                      hint: 'Select End Date',
                      isRequired: false,
                    );
                  }),
                ),
              ],
            ),
            getDynamicSizedBox(height: 1.h),

            /// District
            Obx(() {
              return getTextField(
                context: context,
                wantLabel: true,
                label: 'District',
                ctr: ctr.district,
                node: ctr.districtNode,
                model: ctr.disitrict.value,
                isenable: false,
                isdropdown: true,
                wantsuffix: true,
                usegesture:
                    (!ctr.isDistrictSelected.value &&
                        !ctr.isClusterSelected.value) ||
                    ctr.isDistrictSelected.value,
                isVerified:
                    !ctr.isDistrictSelected.value &&
                    (ctr.isClusterSelected.value),
                gestureFunction: () {
                  // ctr.showDistrictSelectionPopups(context);
                },
                hint: 'Select District',
              );
            }),
            getDynamicSizedBox(height: 1.h),

            /// Clusters
            Obx(() {
              return getTextField(
                context: context,
                wantLabel: true,
                label: 'Clusters',
                ctr: ctr.clusterCtr,
                node: ctr.clusterNode,
                model: ctr.clusterModel.value,
                isenable: false,
                isdropdown: true,
                wantsuffix: true,
                usegesture:
                    (!ctr.isDistrictSelected.value) ||
                    ctr.isClusterSelected.value,
                isVerified:
                    !ctr.isClusterSelected.value &&
                    (ctr.isDistrictSelected.value),
                gestureFunction: () {
                  // ctr.showClusterSelectionPopups(context);
                },
                hint: 'Select Clusters',
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
                      ctr.resetForm();
                      ctr.isStartDateSelected = false.obs;
                      // ctr.getDashboardData(context, 1, isFirstTime: true);
                      Get.back();
                    },
                    'Clear',
                    validate: true,
                  ),
                ),
                getDynamicSizedBox(width: 3.w),
                Expanded(
                  child: getFormButton(
                    context,
                    () {
                      // ctr.makeApiCall(context);
                      Get.back();
                    },
                    'Search',
                    validate: true,
                  ),
                ),
              ],
            ),
            getDynamicSizedBox(height: 3.h),
          ],
        ),
      ),
    ),
  );
}

void openDatePickerDash(
  BuildContext context, {
  required bool isStart,
  required LeadController ctr,
}) {
  ctr.isStartDateActive.value = isStart;

  final String selected = isStart ? ctr.startDate.value : ctr.endDate.value;
  DateTime? initialDate;
  if (selected.isNotEmpty) {
    try {
      // Try parsing with the new display format (MMMM yyyy)
      initialDate = ctr.dateFormat.parse(selected);
    } catch (e) {
      try {
        // Fallback to legacy format (dd-MM-yyyy) for backward compatibility
        initialDate = DateFormat('dd-MM-yyyy').parse(selected);
      } catch (e) {
        initialDate = null; // Handle invalid format gracefully
      }
    }
  }

  // Determine minDate for end date selection
  DateTime? minDate;
  if (!isStart && ctr.startDate.value.isNotEmpty) {
    try {
      minDate = ctr.dateFormat.parse(ctr.startDate.value);
      // Set minDate to the first of the start month
      minDate = DateTime(minDate.year, minDate.month, 1);
    } catch (e) {
      minDate = null; // Handle invalid start date gracefully
    }
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        height: 45.h,
        width: double.maxFinite,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                isStart
                    ? 'Select Start Month & Year'
                    : 'Select End Month & Year',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.single,
                view: DateRangePickerView.year, // Show year view with months
                initialSelectedDate: initialDate,
                initialDisplayDate: initialDate,
                minDate:
                    minDate, // Restrict end date to be on or after start date
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is DateTime) {
                    DateTime selectedDate = args.value;

                    // Set date to 1st of the month to ignore day
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      1,
                    );

                    // Pass DateTime to controller
                    ctr.onDateSelected(selectedDate);
                    Navigator.of(context).pop(); // Close dialog immediately
                  }
                },
                showTodayButton: false,
                showNavigationArrow: true,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1,
                ),
                selectionColor: primaryColor,
                todayHighlightColor: primaryColor,
                allowViewNavigation: false, // Prevent switching to day view
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
