import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:intl/intl.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
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
import '../../view/customer_screen.dart/customer_widgets.dart';

class CustomerScreenController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;

  // 🔹 Controllers
  late TextEditingController dateCtr,
      uploadFileCtr,
      warrantyCtr,
      warrantyPeriodCtr,
      amountCtr,
      startTimeCtr,
      endTimeCtr,
      districtCtr,
      clusterCtr,
      warrantyTypeCtr,
      customerStatusCtr,
      searchDistrictCtr,
      searchClusterCtr,
      searchWarrantyTypeCtr,
      searchCustomerStatusCtr;

  // 🔹 FocusNodes
  late FocusNode dateNode,
      uploadFileNode,
      warrantyNode,
      warrantyPeriodNode,
      amountNode,
      startTimeNode,
      endTimeNode,
      districtNode,
      clusterNode,
      warrantyTypeNode,
      customerStatusNode,
      searchDistrictNode,
      searchClusterNode,
      searchWarrantyTypeNode,
      searchCustomerStatusNode;

  // 🔹 Validation Models
  var dateModel = ValidationModel(null, null, isValidate: false).obs;
  var uploadFileModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyPeriodModel = ValidationModel(null, null, isValidate: false).obs;
  var amountModel = ValidationModel(null, null, isValidate: false).obs;
  var startTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var endTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var districtModel = ValidationModel(null, null, isValidate: false).obs;
  var clusterModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyTypeModel = ValidationModel(null, null, isValidate: false).obs;
  var customerStatusModel = ValidationModel(null, null, isValidate: false).obs;
  var searchDistrictModel = ValidationModel(null, null, isValidate: false).obs;
  var searchClusterModel = ValidationModel(null, null, isValidate: false).obs;
  var searchWarrantyTypModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var searchCustomerStatusModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;

  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  final RxString startDateApi = ''.obs;
  final RxString endDateApi = ''.obs;
  final DateFormat dateFormat = DateFormat('MMMM yyyy');
  final DateFormat apiDateFormat = DateFormat('yyyy-MM');

  RxString selectedDistrictId = ''.obs;
  RxString selectedClusterId = ''.obs;
  RxList districtListInt = [].obs;
  RxList categoryListInt = [].obs;
  RxList clusterListInt = [].obs;
  RxList customerListInt = [].obs;

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
    dateCtr = TextEditingController();
    uploadFileCtr = TextEditingController();
    warrantyCtr = TextEditingController();
    warrantyPeriodCtr = TextEditingController();
    amountCtr = TextEditingController();
    startTimeCtr = TextEditingController();
    endTimeCtr = TextEditingController();
    districtCtr = TextEditingController();
    clusterCtr = TextEditingController();
    warrantyTypeCtr = TextEditingController();
    customerStatusCtr = TextEditingController();
    searchDistrictCtr = TextEditingController();
    searchClusterCtr = TextEditingController();
    searchWarrantyTypeCtr = TextEditingController();
    searchCustomerStatusCtr = TextEditingController();

    // 🔹 Initialize FocusNodes
    dateNode = FocusNode();
    uploadFileNode = FocusNode();
    warrantyNode = FocusNode();
    warrantyPeriodNode = FocusNode();
    amountNode = FocusNode();
    startTimeNode = FocusNode();
    endTimeNode = FocusNode();
    districtNode = FocusNode();
    clusterNode = FocusNode();
    warrantyTypeNode = FocusNode();
    customerStatusNode = FocusNode();
    searchDistrictNode = FocusNode();
    searchClusterNode = FocusNode();
    searchWarrantyTypeNode = FocusNode();
    searchCustomerStatusNode = FocusNode();
  }

  @override
  void onClose() {
    // 🔹 Dispose Controllers
    dateCtr.dispose();
    uploadFileCtr.dispose();
    warrantyCtr.dispose();
    warrantyPeriodCtr.dispose();
    amountCtr.dispose();
    startTimeCtr.dispose();
    endTimeCtr.dispose();
    districtCtr.dispose();
    clusterCtr.dispose();
    warrantyTypeCtr.dispose();
    customerStatusCtr.dispose();

    // 🔹 Dispose FocusNodes
    dateNode.dispose();
    uploadFileNode.dispose();
    warrantyNode.dispose();
    warrantyPeriodNode.dispose();
    amountNode.dispose();
    startTimeNode.dispose();
    endTimeNode.dispose();
    districtNode.dispose();
    clusterNode.dispose();
    warrantyTypeNode.dispose();
    customerStatusNode.dispose();

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
    "Company Name",
    "Contact Person",
    "Mobile",
    "Status",
    "Live Data",
    "Warranty Type",
    "Expiry",
    "Action",
  ].obs;
  // Provide all customer data without pagination
  List<List<String>> get customerData {
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
        e.location ?? 'N/A',
        e.solarCapacity?.toString() ?? '0',
        e.customerStatus.toString().split('.').last,
        "${e.liveDate.year}-${e.liveDate.month.toString().padLeft(2, '0')}-${e.liveDate.day.toString().padLeft(2, '0')}",
      ];
    }).toList();
  }

  void updateCustomer(context) async {
    var result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13.w)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: Device.width),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                color: white,
                child: Wrap(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.w),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.w),
                              ),
                            ),
                            padding: EdgeInsets.only(top: 2.5.h, bottom: 2.h),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Update Customer",
                                style: TextStyle(
                                  color: white,
                                  fontSize: 16.sp,
                                  fontFamily: plusJakartaSansBold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.close_rounded,
                                    color: white,
                                    size: Device.screenType == ScreenType.mobile
                                        ? 25
                                        : 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 5.w,
                        right: 5.w,
                        top: 1.5.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Expected Date of Delivery
                          Obx(
                            () => getTextField(
                              context: context,
                              wantLabel: true,
                              label: 'Expected Date of Delivery',
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
                                  title: 'Select Start Date',
                                  controller: dateCtr,
                                  dateRx: startDate,
                                  model: dateModel,
                                );
                                // final picked = await showDatePicker(
                                //   context: context,
                                //   initialDate: DateTime.now(),
                                //   firstDate: DateTime(2000),
                                //   lastDate: DateTime(2100),
                                // );
                                // if (picked != null) {
                                //   dateCtr.text =
                                //       "${picked.day}-${picked.month}-${picked.year}";
                                // }
                              },
                              hint: 'Select Date',
                            ),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          Obx(() {
                            return getTextField(
                              context: context,
                              wantLabel: true,
                              label: 'Upload Installation Certificate',
                              ctr: uploadFileCtr,
                              node: uploadFileNode,
                              model: uploadFileModel.value,
                              isenable: false,
                              isdropdown: true,
                              wantsuffix: false,
                              usegesture: true,
                              gestureFunction: () {
                                pickAnyFile();
                              },
                              hint: 'Select File',
                              isRequired: false,
                            );
                          }),
                          getDynamicSizedBox(height: 1.h),

                          /// Group
                          Obx(() {
                            return getTextField(
                              context: context,
                              wantLabel: true,
                              label: 'Warranty',
                              ctr: warrantyCtr,
                              node: warrantyNode,
                              model: warrantyModel.value,
                              isenable: false,
                              isdropdown: true,
                              wantsuffix: true,
                              usegesture: true,
                              isRequired: true,
                              gestureFunction: () {
                                // ctr.showDistrictSelectionPopups(context);
                              },
                              hint: 'Select District',
                            );
                          }),
                          getDynamicSizedBox(height: 1.h),

                          /// Contact Person Name
                          Obx(() {
                            return getTextField(
                              context: context,
                              wantLabel: true,
                              label: 'Warranty Period (Years)',
                              ctr: warrantyPeriodCtr,
                              node: warrantyPeriodNode,
                              model: warrantyPeriodModel.value,
                              hint: 'Not Set',
                              isNumber: true,
                              isRequired: true,
                            );
                          }),
                          getDynamicSizedBox(height: 1.h),

                          /// Contact Person Name
                          Obx(() {
                            return getTextField(
                              context: context,
                              wantLabel: true,
                              label: 'Amount',
                              ctr: amountCtr,
                              node: amountNode,
                              model: amountModel.value,
                              hint: 'Not Set',
                              isNumber: true,
                              isRequired: true,
                            );
                          }),
                          getDynamicSizedBox(height: 1.h),
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
                                  'Cancle',
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
                    ),
                    getDynamicSizedBox(height: 2.h, width: Device.width),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    // Check if the bottom sheet was dismissed by pressing submit button
    if (result != null && result == true) {
      logcat("DismissDialog", 'DONE');
    }
  }

  // Open system file picker
  Future<void> pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // 👈 allows ALL types (images, pdf, docs, etc.)
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // show file name in your text field controller
      uploadFileCtr.text = fileName;
      update();
      print("Picked file path: ${file.path}");
      print("Picked file name: $fileName");
    }
  }

  DateTime? selectedDateTime;
  void openDatePicker({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required RxString dateRx,
    required Rx<ValidationModel> model,
    bool showTimePickers = true,
  }) {
    showCommonDatePicker(
      context: context,
      title: title,
      initialDate: dateRx.value.isNotEmpty
          ? dateFormat.parse(dateRx.value)
          : null,
      minDate: startDate.value.isNotEmpty
          ? dateFormat.parse(startDate.value)
          : null,
      showTimePickers: false,
      onDatePicked: (DateTime date) {
        final formatted = dateFormat.format(date);
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

  void openFilterBottomSheet({required BuildContext context}) {
    startTimeCtr.text = startDate.value;
    endTimeCtr.text = endDate.value;
    districtCtr.text = selectedDistrictId.value.isNotEmpty
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
    districtModel.value = ValidationModel(
      districtCtr.text.isNotEmpty ? districtCtr.text : null,
      null,
      isValidate: districtCtr.text.isNotEmpty,
    );
    clusterModel.value = ValidationModel(
      clusterCtr.text.isNotEmpty ? clusterCtr.text : null,
      null,
      isValidate: clusterCtr.text.isNotEmpty,
    );

    isDistrictSelected.value = selectedDistrictId.value.isNotEmpty;
    isClusterSelected.value = selectedClusterId.value.isNotEmpty;

    openBottomtsheetDialog(
      context,
      title: "Filters",
      widget: addFilterSheetWidget(context),
    );
    enableSubmitButton();
  }

  Widget addFilterSheetWidget(context) {
    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.5.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() {
                  return getTextField(
                    context: context,
                    wantLabel: true,
                    label: 'Start Month-Year',
                    ctr: startTimeCtr,
                    node: startTimeNode,
                    model: startTimeModel.value,
                    isenable: false,
                    isdropdown: true,
                    wantsuffix: true,
                    usegesture: true,
                    gestureFunction: () {
                      openCustomerDatePicker(context, isStart: true, ctr: this);
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
                    ctr: endTimeCtr,
                    node: endTimeNode,
                    model: endTimeModel.value,
                    isenable: false,
                    isdropdown: true,
                    wantsuffix: true,
                    usegesture: true,
                    gestureFunction: () {
                      if (!isStartDateSelected.value) {
                        showDialogForScreen(
                          context,
                          'Dashboard',
                          'Please select the start date first.',
                          callback: () {},
                        );
                      } else {
                        openCustomerDatePicker(
                          context,
                          isStart: false,
                          ctr: this,
                        );
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
              ctr: districtCtr,
              node: districtNode,
              model: districtModel.value,
              isenable: false,
              isdropdown: true,
              wantsuffix: true,
              usegesture:
                  (!isDistrictSelected.value && !isClusterSelected.value) ||
                  isDistrictSelected.value,
              isVerified:
                  !isDistrictSelected.value && (isClusterSelected.value),
              gestureFunction: () {
                showDistrictSelectionPopups(context);
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
              ctr: clusterCtr,
              node: clusterNode,
              model: clusterModel.value,
              isenable: false,
              isdropdown: true,
              wantsuffix: true,
              usegesture:
                  (!isDistrictSelected.value) || isClusterSelected.value,
              isVerified:
                  !isClusterSelected.value && (isDistrictSelected.value),
              gestureFunction: () {
                showClusterSelectionPopups(context);
              },
              hint: 'Select Clusters',
            );
          }),
          getDynamicSizedBox(height: 1.h),
          Obx(() {
            return getTextField(
              context: context,
              wantLabel: true,
              label: 'Warranty Type',
              ctr: warrantyCtr,
              node: warrantyNode,
              model: warrantyModel.value,
              isenable: false,
              isdropdown: true,
              wantsuffix: true,
              usegesture: true,
              gestureFunction: () {
                showWarrantyTypeSelectionPopups(context);
              },
              hint: 'Select Warranty Type',
              isRequired: true,
            );
          }),
          getDynamicSizedBox(height: 1.h),
          Obx(() {
            return getTextField(
              context: context,
              wantLabel: true,
              label: 'Customer Status',
              ctr: customerStatusCtr,
              node: customerStatusNode,
              model: customerStatusModel.value,
              isenable: false,
              isdropdown: true,
              wantsuffix: true,
              usegesture: true,
              gestureFunction: () {
                showCustomerStatusSelectionPopups(context);
              },
              hint: 'Select Customer Status',
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
                  'Reset',
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
                  "Apply",
                  validate: true,
                ),
              ),
            ],
          ),
        ],
      ),
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

  void showWarrantyTypeSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(warrantyType);
    filteredData.value = List.from(warrantyType);

    fetchSelectionPopup<CategoryModel>(
      context,
      title: 'Warranty Type',
      controller: warrantyCtr,
      list: filteredData,
      searchCtr: searchWarrantyTypeCtr,
      searchNode: searchWarrantyTypeNode,
      filterFunction: (val) {
        filterFetchData<CategoryModel>(
          val,
          source: warrantyType,
          getTitle: (item) => item.name,
        );
      },
      getTitle: (value) => value.name,
      onSelected: (data) {
        warrantyCtr.clear();
        warrantyCtr.text = data.name;
        categoryId.value = data.id.toString();
        logcat('customerID', categoryId.value);
        // validateFields(
        //   uploadCategoryCtr.text,
        //   iscomman: true,
        //   model: uploadCategoryModel,
        //   errorText1: 'Enter Category',
        // );
        update();
      },
      backBtn: () {
        Get.back();
      },
    );
  }

  void showCustomerStatusSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(warrantyType);
    filteredData.value = List.from(warrantyType);

    fetchSelectionPopup<CategoryModel>(
      context,
      title: 'Customer Status',
      controller: warrantyCtr,
      list: filteredData,
      searchCtr: searchWarrantyTypeCtr,
      searchNode: searchWarrantyTypeNode,
      filterFunction: (val) {
        filterFetchData<CategoryModel>(
          val,
          source: warrantyType,
          getTitle: (item) => item.name,
        );
      },
      getTitle: (value) => value.name,
      onSelected: (data) {
        warrantyCtr.clear();
        warrantyCtr.text = data.name;
        categoryId.value = data.id.toString();
        logcat('customerID', categoryId.value);
        // validateFields(
        //   uploadCategoryCtr.text,
        //   iscomman: true,
        //   model: uploadCategoryModel,
        //   errorText1: 'Enter Category',
        // );
        update();
      },
      backBtn: () {
        Get.back();
      },
    );
  }

  void filterFetchData<T>(
    String query, {
    required List<T> source,
    required String Function(T) getTitle,
  }) {
    if (query.isEmpty) {
      filteredData.value = List.from(source);
    } else {
      filteredData.value = source.where((item) {
        String title = getTitle(item).toLowerCase();
        return title.startsWith(query.toLowerCase());
      }).toList();
    }
    update();
  }

  void enableSubmitButton() {
    isFormInvalidate.value =
        startTimeModel.value.isValidate && endTimeModel.value.isValidate;
    update();
  }

  // Filter source and filtered data

  void showDistrictSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(districtList);
    searchDistrictCtr.clear();

    showUpdatedMultpleSelectionPopup<Category>(
      context,
      title: 'District',
      controller: districtCtr,
      list: districtList,
      searchCtr: searchDistrictCtr,
      searchNode: searchDistrictNode,
      filterFunction: (val) {
        return districtList
            .where(
              (item) => item.name.toLowerCase().contains(val.toLowerCase()),
            )
            .toList();
      },
      getTitle: (value) => value.name,
      getId: (value) => value.id.toString(),
      onSelected: (selectedList) {
        selectedDistrictId.value = selectedList
            .map((e) => e.id.toString())
            .join(', ');
        districtListInt.value = selectedList.map((e) => e.id).toList();

        if (selectedList.isNotEmpty) {
          isDistrictSelected.value = true;
          isClusterSelected.value = false;
        } else {
          isDistrictSelected.value = false;
          if (!isClusterSelected.value) {
            resetSelectionFlags();
          }
        }
      },
      function: () {},
    );
  }

  void showClusterSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(clustersList);
    searchClusterCtr.clear();

    showUpdatedMultpleSelectionPopup<Category>(
      context,
      title: 'Clusters',
      controller: clusterCtr,
      list: clustersList,
      searchCtr: searchClusterCtr,
      searchNode: searchClusterNode,
      filterFunction: (val) {
        return clustersList
            .where(
              (item) => item.name.toLowerCase().contains(val.toLowerCase()),
            )
            .toList();
      },
      getTitle: (value) => value.name,
      getId: (value) => value.id.toString(),
      onSelected: (selectedList) {
        selectedClusterId.value = selectedList
            .map((e) => e.id.toString())
            .join(', ');
        clusterListInt.value = selectedList.map((e) => e.id).toList();

        if (selectedList.isNotEmpty) {
          isDistrictSelected.value = false;
          isClusterSelected.value = true;
        } else {
          isClusterSelected.value = false;
          if (!isDistrictSelected.value) {
            resetSelectionFlags();
          }
        }
      },
      function: () {},
    );
  }

  void resetSelectionFlags() {
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
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
}
