import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/controller/master_controller/Master_Controller.dart';
import 'package:sales_app/models/LeadModel.dart';
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
import '../../models/dashboard_fillter_model.dart';

// New model for static customer data
class CustomerData {
  final String company;
  final String contactPerson;
  final String mobile;
  final String category;
  final String leadStatus;

  CustomerData({
    required this.company,
    required this.contactPerson,
    required this.mobile,
    required this.category,
    required this.leadStatus,
  });
}

class LeadController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state =
      ScreenState.apiSuccess.obs; // Set to apiSuccess for static data
  RxString message = ''.obs;

  RxBool isStartDateActive = true.obs;
  RxBool isStartDateSelected = false.obs;
  RxBool isDistrictSelected = false.obs;
  RxBool isClusterSelected = false.obs;
  RxBool isFormInvalidate = false.obs;
  RxBool isStatusSelected = false.obs;
  RxBool isCategorySelected = false.obs;
  RxList<Cluster> districtList = <Cluster>[].obs;
  RxList<Cluster> clustersList = <Cluster>[].obs;
  RxList<LabelValue> categoryList = <LabelValue>[].obs;
  RxList<LabelValue> statusList = <LabelValue>[].obs;

  var currentFilterSource = [].obs;
  var filteredData = [].obs;
  RxString categoryId = "".obs;
  RxList<CategoryModel> warrantyType = <CategoryModel>[
    CategoryModel(id: "1", name: "Invoice"),
    CategoryModel(id: "2", name: "Bills"),
    CategoryModel(id: "3", name: "Reports"),
    CategoryModel(id: "4", name: "Others"),
  ].obs;

  @override
  void onInit() {
    super.onInit();

    // ---------------------- TEXT CONTROLLERS ----------------------
    expectedDateCtr = TextEditingController();
    uploadFileCtr = TextEditingController();
    searchUpdateWarrantyTypeCtr = TextEditingController();

    updateWarrantyCtr = TextEditingController();
    warrantyPeriodCtr = TextEditingController();
    amountCtr = TextEditingController();

    // ---------------------- FOCUS NODES ---------------------------
    dateNode = FocusNode();
    uploadFileNode = FocusNode();
    searchWarrantyTypeNode = FocusNode();

    updateWarrantyNode = FocusNode();
    warrantyPeriodNode = FocusNode();
    amountNode = FocusNode();

    startTimeNode = FocusNode();
    endTimeNode = FocusNode();
    districtNode = FocusNode();
    categoryNode = FocusNode();
    clusterNode = FocusNode();
    customerNode = FocusNode();
    statusNode = FocusNode();
    searchGroupNode = FocusNode();
    searchCategoriesNode = FocusNode();
    searchClusterNode = FocusNode();
    searchCustomerNode = FocusNode();
    countrySearchNode = FocusNode();
    searchNode = FocusNode();

    startTimeCtr = TextEditingController();
    searchCtr = TextEditingController();
    countrySearchCtr = TextEditingController();
    endTimeCtr = TextEditingController();
    district = TextEditingController();
    categoryCtr = TextEditingController();
    clusterCtr = TextEditingController();
    customerCtr = TextEditingController();
    statusCtr = TextEditingController();
    searchDistrictCtr = TextEditingController();
    searchCategoriesCtr = TextEditingController();
    searchClusterCtr = TextEditingController();
    searchCustomerCtr = TextEditingController();
    // Add listener to searchCtr to filter leads
    searchCtr.addListener(() {
      filterLeads(searchCtr.text);
    });
  }

  // // Filter leads based on search query
  // void filterLeads(String query) {
  //   if (query.isEmpty) {
  //     filteredLeadList.assignAll(leadList);
  //     isTextEmpty.value = false;
  //   } else {
  //     query = query.toLowerCase();
  //     filteredLeadList.assignAll(
  //       leadList.where((lead) {
  //         return lead.companyName.toLowerCase().contains(query) ||
  //             lead.contactPersonName.toLowerCase().contains(query) ||
  //             lead.contactPersonMobile.toLowerCase().contains(query) ||
  //             lead.leadCategory.toLowerCase().contains(query) ||
  //             lead.leadStatus.toLowerCase().contains(query);
  //       }).toList(),
  //     );
  //     isTextEmpty.value = true;
  //   }
  //   update();
  // }
  void filterLeads(String query) {
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      filteredLeadList.assignAll(leadList);
      isTextEmpty.value = false;
      return;
    }

    filteredLeadList.assignAll(
      leadList.where((lead) {
        final values = [
          lead.companyName,
          lead.contactPersonName,
          lead.contactPersonMobile,
          lead.leadCategory,
          lead.leadStatus,
        ];

        return values.any((value) => value.toLowerCase().contains(lowerQuery));
      }).toList(),
    );
    isTextEmpty.value = true;
  }

  // Clear search
  void clearSearch() {
    searchCtr.clear();
    filteredLeadList.assignAll(leadList);
    isTextEmpty.value = false;
    update();
  }

  @override
  void onClose() {
    startTimeNode.dispose();
    endTimeNode.dispose();
    districtNode.dispose();
    categoryNode.dispose();
    clusterNode.dispose();
    customerNode.dispose();
    statusNode.dispose();
    searchGroupNode.dispose();
    searchNode.dispose();
    searchCategoriesNode.dispose();
    searchClusterNode.dispose();
    searchCustomerNode.dispose();
    countrySearchNode.dispose();
    countrySearchCtr.dispose();

    startTimeCtr.dispose();
    endTimeCtr.dispose();
    district.dispose();
    categoryCtr.dispose();
    searchCtr.dispose();
    clusterCtr.dispose();
    customerCtr.dispose();
    statusCtr.dispose();
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
    countrySearchCtr.clear();
    endTimeCtr.clear();
    district.clear();
    categoryCtr.clear();
    searchCtr.clear();
    clusterCtr.clear();
    customerCtr.clear();
    statusCtr.clear();
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
    selectedCategoryId.value = '';
    selectedStatus.value = '';
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isCategorySelected.value = false;
    isStatusSelected.value = false;
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
    statusModel.value = ValidationModel(null, null, isValidate: false);
    isFormInvalidate.value = false;
    update();
  }

  RxList<CustomerData> customerList = <CustomerData>[].obs;
  RxList<LeadData> leadList = <LeadData>[].obs;
  RxList<LeadData> filteredLeadList = <LeadData>[].obs;
  RxString nextPageURL = "".obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt fromItem = 0.obs;
  final RxInt toItem = 0.obs;

  var isCustomerLoading = false.obs;

  // Filter logic
  late FocusNode startTimeNode, endTimeNode;
  late FocusNode districtNode,
      categoryNode,
      clusterNode,
      customerNode,
      searchNode,
      statusNode;
  late FocusNode searchGroupNode,
      searchCategoriesNode,
      searchClusterNode,
      searchCustomerNode;
  late FocusNode countrySearchNode;
  late TextEditingController startTimeCtr,
      searchCtr,
      endTimeCtr,
      countrySearchCtr;
  late TextEditingController district,
      categoryCtr,
      clusterCtr,
      customerCtr,
      statusCtr;
  late TextEditingController searchDistrictCtr,
      searchCategoriesCtr,
      searchClusterCtr,
      searchCustomerCtr;

  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  final RxString startDateApi = ''.obs;
  final RxString endDateApi = ''.obs;
  final DateFormat dateFormat = DateFormat('MMMM yyyy');
  final DateFormat apiFormatForInstall = DateFormat('yyyy-MM-dd');
  final DateFormat apiDateFormat = DateFormat('yyyy-MM');
  var startTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var endTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var disitrict = ValidationModel(null, null, isValidate: false).obs;
  var categoryModel = ValidationModel(null, null, isValidate: false).obs;
  var clusterModel = ValidationModel(null, null, isValidate: false).obs;
  var customerModel = ValidationModel(null, null, isValidate: false).obs;
  var statusModel = ValidationModel(null, null, isValidate: false).obs;
  var countrySearchModel = ValidationModel(null, null, isValidate: false).obs;
  RxString selectedDistrictId = ''.obs;
  RxString selectedClusterId = ''.obs;
  RxString selectedCategoryId = ''.obs;
  RxString selectedStatus = ''.obs;
  RxList districtListInt = [].obs;
  RxList categoryListInt = [].obs;
  RxList clusterListInt = [].obs;
  RxList customerListInt = [].obs;

  void resetSelectionFlags() {
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isCategorySelected.value = false;
    isStatusSelected.value = false;
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
    categoryCtr.text = selectedCategoryId.value.isNotEmpty
        ? categoryList
              .where(
                (c) => selectedCategoryId.value
                    .split(', ')
                    .contains(c.value.toString()),
              )
              .map((c) => c.label)
              .join(', ')
        : '';
    statusCtr.text = selectedStatus.value.isNotEmpty
        ? statusList
              .where(
                (c) => selectedStatus.value
                    .split(', ')
                    .contains(c.value.toString()),
              )
              .map((c) => c.label)
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
    categoryModel.value = ValidationModel(
      categoryCtr.text.isNotEmpty ? categoryCtr.text : null,
      null,
      isValidate: categoryCtr.text.isNotEmpty,
    );
    statusModel.value = ValidationModel(
      statusCtr.text.isNotEmpty ? statusCtr.text : null,
      null,
      isValidate: statusCtr.text.isNotEmpty,
    );

    isDistrictSelected.value = selectedDistrictId.value.isNotEmpty;
    isClusterSelected.value = selectedClusterId.value.isNotEmpty;
    isCategorySelected.value = selectedCategoryId.value.isNotEmpty;
    isStatusSelected.value = selectedStatus.value.isNotEmpty;
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

  void openDeleteBottomSheet({required BuildContext context}) {
    openBottomtsheetDialog(
      context,
      title: "Delete",
      widget: deleteWidget(
        title: 'Are you sure you want to delete?',
        context,
        setStateTrigger: () {
          update();
        },
        cancelBtn: () {},
        deleletBtn: () {},
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
      apiEndPoint: "${ApiUrl.getfillter}?user_id=${userData?.userId ?? ''}",
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
        logcat('Filter Options Data', data.toString());

        districtList.clear();
        clustersList.clear();
        categoryList.clear();
        statusList.clear();
        var innerData = data['data'];
        FiltterData responseDetail = FiltterData.fromJson(innerData);

        districtList.addAll(responseDetail.districts);
        clustersList.addAll(responseDetail.clusters);
        categoryList.addAll(responseDetail.leadCategory);
        statusList.addAll(responseDetail.leadStatus);

        warrantyTypeforFilter.assignAll(responseDetail.warrantyType);
        cusotmerUpdateWarrantyType.assignAll(
          responseDetail.warrantyType.where((e) => e.value == 'under-warranty'),
        );
        filterWarrantyType.assignAll(
          responseDetail.warrantyType.where((e) => e.value == 'under-warranty'),
        );

        // -----------------------------------------------
        // SET SELECTED WARRANTY TYPE AUTOMATICALLY
        // -----------------------------------------------
        if (cusotmerUpdateWarrantyType.isNotEmpty) {
          final firstItem = cusotmerUpdateWarrantyType.first;

          updateWarrantyCtr.text = firstItem.label ?? "";
          selectedWarrantyTypeLabel.value = firstItem.label ?? "";
          selectedWarrantyTypeValue.value = firstItem.value ?? "";
        } else {
          // If list is empty ensure fields are cleared
          updateWarrantyCtr.text = "";
          selectedWarrantyTypeLabel.value = "";
          selectedWarrantyTypeValue.value = "";
        }

        logcat('District List', districtList.length.toString());
        logcat('Clusters List', clustersList.length.toString());

        update();
      },
      networkManager: networkManager,
    );
  }

  // Future<void> getFillterOptions(context) async {
  //   User? userData = await UserPreferences().getSignInInfo();
  //   var loadingIndicator = LoadingProgressDialog();
  //   commonGetApiCallFormate(
  //     context,
  //     title: 'Lead Screen',
  //     apiEndPoint: "${ApiUrl.getfillter}/${userData?.userId ?? ''}",
  //     allowHeader: true,
  //     state: state,
  //     message: message,
  //     apisLoading: (isloaing) {
  //       if (isloaing == true) {
  //         loadingIndicator.show(context, '');
  //       } else {
  //         loadingIndicator.hide(context);
  //       }
  //     },
  //     onResponse: (data) {
  //       districtList.clear();
  //       clustersList.clear();
  //       categoryList.clear();
  //       FiltterModel responseDetail = FiltterModel.fromJson(data);
  //       districtList.addAll(responseDetail.result.groups);
  //       clustersList.addAll(responseDetail.result.clusters);
  //       categoryList.addAll(responseDetail.result.categories);
  //       update();
  //     },
  //     networkManager: networkManager,
  //   );
  // }

  String buildCustomerQuery({
    required User userData,
    required int page,
    required String startDateApi,
    required String endDateApi,
    required String customerStatus,
    required String categoryType,
    required RxList<dynamic> districtListInt,
    required RxList<dynamic> clusterListInt,
  }) {
    final queryParams = <String>[];

    // Required params
    queryParams.add('user_id=${userData.userId}');
    queryParams.add('page=$page');
    queryParams.add('per_page=10');

    // Add date filters

    // Add date filters
    if (startDateApi.isNotEmpty) {
      queryParams.add('startMonthYear=$startDateApi');
    }

    if (endDateApi.isNotEmpty) {
      queryParams.add('endMonthYear=$endDateApi');
    }

    if (selectedStatus.isNotEmpty) {
      queryParams.add('status=$selectedStatus');
    }

    if (categoryType.isNotEmpty) {
      queryParams.add('category=$categoryType');
    }

    // Add district list
    for (final districtId in districtListInt) {
      queryParams.add('districts[]=$districtId');
    }

    // Add cluster list
    for (final clusterId in clusterListInt) {
      queryParams.add('clusters[]=$clusterId');
    }

    return queryParams.join('&');
  }

  final RxString expectedDate = ''.obs;
  File? selectedFile;
  Future<void> pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // ✅ Only allow PDFs
    );

    if (result != null && result.files.isNotEmpty) {
      selectedFile = File(result.files.single.path!);
      uploadFileCtr.text = result.files.single.name;
      uploadFileCtr.addListener(validateUpdateButton);

      validateUpdateButton();
      update();
      logcat("Picked file name:", uploadFileCtr.text);
    } else {
      logcat("Error picking file:", "No file selected");
    }
  }

  final DateFormat expectedDateFormat = DateFormat('dd-MM-yyyy');
  late TextEditingController expectedDateCtr;
  late TextEditingController uploadFileCtr;
  late TextEditingController searchUpdateWarrantyTypeCtr;

  late TextEditingController updateWarrantyCtr;
  late TextEditingController warrantyPeriodCtr;
  late TextEditingController amountCtr;
  late FocusNode dateNode;
  late FocusNode uploadFileNode;

  late FocusNode updateWarrantyNode;
  late FocusNode warrantyPeriodNode;
  late FocusNode amountNode;
  late FocusNode searchWarrantyTypeNode;

  var dateModel = ValidationModel(null, null, isValidate: false).obs;
  var uploadFileModel = ValidationModel(null, null, isValidate: false).obs;

  var warrantyModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyPeriodModel = ValidationModel(null, null, isValidate: false).obs;
  var amountModel = ValidationModel(null, null, isValidate: false).obs;

  // void validateUpdateButton() {
  //   // Final validation
  //   isUpdateEnabled.value = true;
  // }

  void validateUpdateButton() {
    final bool isValid =
        expectedDateCtr.text.trim().isNotEmpty &&
        uploadFileCtr.text.trim().isNotEmpty &&
        updateWarrantyCtr.text.trim().isNotEmpty &&
        warrantyPeriodCtr.text.trim().isNotEmpty;

    isUpdateEnabled.value = isValid;
  }

  var filterWarrantyType = <LabelValue>[].obs;
  var cusotmerUpdateWarrantyType = <LabelValue>[].obs;

  RxBool isWarrantyTypeListApiCallLoading = false.obs;
  RxString selectedWarrantyTypeValue = ''.obs;
  RxString selectedWarrantyTypeLabel = ''.obs;

  //

  void resetCustomerUpdateFieldsExceptWarranty() {
    // ❌ Reset expected delivery date
    expectedDateCtr.clear();
    expectedDate.value = "";
    dateModel.value = ValidationModel(null, null);

    // ❌ Reset file picker
    uploadFileCtr.clear();
    selectedFile = null;
    uploadFileModel.value = ValidationModel(null, null);

    // ❌ Reset Amount field (for AMC)
    amountCtr.clear();
    amountModel.value = ValidationModel(null, null);

    ///
    warrantyPeriodCtr.clear();
    warrantyPeriodModel.value = ValidationModel(null, null);

    // ❌ Reset update button
    isUpdateEnabled.value = false;

    // ✅ DO NOT RESET WARRANTY FIELDS
    // warrantyPeriodCtr     → KEEP
    // updateWarrantyCtr     → KEEP
    // selectedWarrantyTypeValue → KEEP
    // warrantyModel         → KEEP
    // warrantyPeriodModel   → KEEP
    // amountModel           → KEEP ONLY IF you want; else reset above

    logcat("Reset Done:", "Everything except warranty");
  }

  Future<void> updateInstallationApi(BuildContext context, int leadId) async {
    var loadingIndicator = LoadingProgressDialog();

    if (networkManager.connectionType.value == 0) {
      showDialogForScreen(
        context,
        "Installation Update",
        Connection.noConnection,
        callback: () => Get.back(),
      );
      return;
    }

    try {
      loadingIndicator.show(context, '');

      final endPoint = "leads/$leadId/installation";

      // Prepare form fields
      // -------------------- BODY FIELDS --------------------
      final body = {
        'expected_delivery_date': expectedDateCtr.text, // "2025-11-22"
        'warranty_period': warrantyPeriodCtr.text, // "1"
      };
      // Prepare multipart file if exists
      http.MultipartFile? file;
      if (uploadFileCtr.text.isNotEmpty && selectedFile?.path != null) {
        file = await http.MultipartFile.fromPath(
          'installation_certificate',
          selectedFile!.path,
        );
      }
      logcat("customerUpdatePassingParams::", body);

      // return;

      // 🔹 Call your common multipart function
      final streamedResponse = await Repository.multiPartPost(
        body,
        endPoint,
        allowHeader: true,
        multiPart: file,
      );

      // Convert to normal response
      final response = await http.Response.fromStream(streamedResponse);
      loadingIndicator.hide(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logcat('updateResponse', data.toString());

        if (data['status']?.toString().toLowerCase() == 'success') {
          showDialogForScreen(
            context,
            "Installation Update",
            data['message'] ?? "Update successful!",
            callback: () {
              resetCustomerUpdateFieldsExceptWarranty();
              Get.back(result: true);
              getLeadList(
                context: context,
                isInitialLoad: true,
                page: 1,
                hideLoading: false,
              );
            },
          );
        } else {
          showDialogForScreen(
            context,
            "Error",
            data['message'] ?? "Failed to update customer",
            callback: () => Get.back(),
          );
        }
      } else {
        logcat('Error Response', response.body);
        final data = jsonDecode(response.body);
        String errorMessage = 'Something went wrong';

        if (data['errors'] != null && data['errors'] is Map) {
          final firstKey = data['errors'].keys.first;
          final firstErrorList = data['errors'][firstKey];

          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            errorMessage =
                firstErrorList.first; // ✅ get first error dynamically
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }

        showDialogForScreen(
          context,
          "Installation Update",
          errorMessage,
          callback: () => Get.back(),
        );
      }
    } catch (e) {
      loadingIndicator.hide(context);
      logcat("Exception", e.toString());
      showDialogForScreen(
        context,
        "Error",
        e.toString(),
        callback: () => Get.back(),
      );
    }
  }

  Widget setWarrantyTypeListDialog() {
    return Obx(() {
      if (isWarrantyTypeListApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isWarrantyTypeListApiCallLoading.value,
        );
      }
      return setDropDownContent(
        filterWarrantyType,
        controller: updateWarrantyCtr,
        noDataLable: "No Warranty Type",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filterWarrantyType.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              contentPadding: const EdgeInsets.only(
                left: 0.0,
                right: 0.0,
                top: 0.0,
              ),
              horizontalTitleGap: null,
              minLeadingWidth: 5,
              onTap: () {
                final selectedItem = filterWarrantyType[index];
                updateWarrantyCtr.text = selectedItem.label;
                selectedWarrantyTypeLabel.value = selectedItem.label;
                selectedWarrantyTypeValue.value = selectedItem.value;
                update();
                if (updateWarrantyCtr.text.toString().isNotEmpty) {
                  filterWarrantyType.clear();
                  filterWarrantyType.addAll(cusotmerUpdateWarrantyType);
                }
                validateUpdateButton();
                Get.back();
              },
              // selectedRequiredSolutionTypeLabel.value
              title: buildSelectableRow(
                filterWarrantyType[index].label,
                filterWarrantyType[index].value.trim() ==
                    selectedWarrantyTypeValue.value,
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: searchWarrantyTypeNode,
          controller: searchUpdateWarrantyTypeCtr,
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForWarrantyType(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: warrantyModel.value.error,
        ),
      );
    });
  }

  void applyFilterForWarrantyType(String keyword) {
    if (keyword.isEmpty) {
      filterWarrantyType.assignAll(cusotmerUpdateWarrantyType);
    } else {
      filterWarrantyType.assignAll(
        cusotmerUpdateWarrantyType
            .where(
              (item) =>
                  item.label.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  var warrantyTypeforFilter = <LabelValue>[].obs;

  // Future<void> getFillterOptions(context, {showLoader = true}) async {
  //   User? userData = await UserPreferences().getSignInInfo();
  //   var loadingIndicator = LoadingProgressDialog();
  //   commonGetApiCallFormate(
  //     context,
  //     title: 'Dashboard Screen',
  //     apiEndPoint: "${ApiUrl.getfillter}?user_id=${userData?.userId ?? ''}",
  //     allowHeader: true,
  //     state: state,
  //     message: message,
  //     apisLoading: (isloaing) {
  //       if (showLoader == true) {
  //         if (isloaing == true) {
  //           loadingIndicator.show(context, '');
  //         } else {
  //           loadingIndicator.hide(context);
  //         }
  //       }
  //     },
  //     onResponse: (data) {
  //       logcat('Filter Options Data', data.toString());
  //       districtList.clear();
  //       clustersList.clear();
  //       var innerData = data['data'];
  //       FiltterData responseDetail = FiltterData.fromJson(innerData);
  //       districtList.addAll(responseDetail.districts);
  //       clustersList.addAll(responseDetail.clusters);
  //       // warrantyType.assignAll(
  //       //   responseDetail.warrantyType.where((e) => e.value != 'under-warranty'),
  //       // );
  //       warrantyTypeforFilter.assignAll(responseDetail.warrantyType);
  //       cusotmerUpdateWarrantyType.assignAll(
  //         responseDetail.warrantyType.where((e) => e.value != 'under-warranty'),
  //       );
  //       filterWarrantyType.assignAll(
  //         responseDetail.warrantyType.where((e) => e.value != 'under-warranty'),
  //       );

  //       // warrantyType.assignAll(responseDetail.warrantyType);
  //       // filterWarrantyType.assignAll(responseDetail.warrantyType);

  //       // warrantyType.assignAll(responseDetail.warrantyType);
  //       // filterWarrantyType.assignAll(responseDetail.warrantyType);

  //       update();
  //     },
  //     networkManager: networkManager,
  //   );
  // }

  RxBool isUpdateEnabled = true.obs;
  void updateCustomer(context, LeadData leadData) async {
    resetCustomerUpdateFieldsExceptWarranty();
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
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: Container(
                  color: white,
                  child: Wrap(
                    children: [
                      buildHeader(context, "Lead Installation Details"),
                      SafeArea(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 5.w,
                            right: 5.w,
                            top: 1.5.h,
                            // bottom: 3.h,
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
                                  ctr: expectedDateCtr,
                                  node: dateNode,
                                  model: dateModel.value,
                                  isRequired: true,
                                  usegesture: true,
                                  isdate: true,
                                  isenable: false,
                                  wantsuffix: true,
                                  gestureFunction: () async {
                                    openDatePicker(
                                      context: context,
                                      title: 'Select Start Date',
                                      controller: expectedDateCtr,
                                      dateRx: expectedDate,
                                      model: dateModel,
                                      showTimePickers: false,
                                      useApiFormat: true,
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
                                  useOnChanged: true,
                                  function: (val) {
                                    expectedDateCtr.addListener(
                                      validateUpdateButton,
                                    );
                                  },
                                  hint: 'Select Date',
                                ),
                              ),

                              Obx(() {
                                return getTextField(
                                  context: context,
                                  wantLabel: true,
                                  label: 'Installation Certificate (PDF)',
                                  ctr: uploadFileCtr,
                                  node: uploadFileNode,
                                  model: uploadFileModel.value,
                                  isdropdown: true,
                                  wantsuffix: false,
                                  isenable: false,
                                  usegesture: true,
                                  gestureFunction: () {
                                    pickAnyFile();
                                  },
                                  hint: 'Select File',
                                  isRequired: true,
                                );
                              }),
                              getDynamicSizedBox(height: 1.h),
                              Obx(() {
                                return getTextField(
                                  context: context,
                                  wantLabel: true,
                                  label: 'Warranty',
                                  ctr: updateWarrantyCtr,
                                  node: updateWarrantyNode,
                                  model: warrantyModel.value,
                                  isenable: false,
                                  isdropdown: true,
                                  wantsuffix: true,
                                  usegesture: true,

                                  isRequired: true,
                                  gestureFunction: () {
                                    commonDropDownDialog(
                                      context,
                                      content: setWarrantyTypeListDialog(),
                                      title: "Warranty Type",
                                      onCloseClick: () {
                                        applyFilterForWarrantyType('');
                                      },
                                    ).then((_) {});
                                    // showWarrantyTypeSelectionPopups(
                                    //   context,
                                    //   customer.warrantyType,
                                    // );
                                  },
                                  useOnChanged: true,
                                  function: (val) {
                                    warrantyPeriodCtr.addListener(
                                      validateUpdateButton,
                                    );
                                  },
                                  hint: 'Select Warranty',
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
                                  hint: 'Enter Warranty Period',
                                  isNumber: true,
                                  useOnChanged: true,
                                  function: (val) {
                                    validateUpdateButton();
                                  },
                                  isRequired: true,
                                );
                              }),
                              getDynamicSizedBox(height: 1.h),

                              // if (selectedWarrantyTypeValue.value != "non_amc" &&
                              //     selectedWarrantyTypeValue.value !=
                              //         'under-warranty')
                              /// Contact Person Name
                              // Obx(() {
                              //   return getTextField(
                              //     context: context,
                              //     wantLabel: true,
                              //     label: 'Amount',
                              //     ctr: amountCtr,
                              //     node: amountNode,
                              //     model: amountModel.value,
                              //     useOnChanged: true,
                              //     hint: 'Enter Amount',
                              //     isNumber: true,
                              //     function: (val) {
                              //       amountCtr.addListener(validateUpdateButton);
                              //     },
                              //     isRequired: true,
                              //   );
                              // }),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: getFormButton(
                                      context,
                                      () {
                                        resetCustomerUpdateFieldsExceptWarranty();
                                        Get.back();
                                      },
                                      'Cancle',
                                      validate: true,
                                    ),
                                  ),
                                  getDynamicSizedBox(width: 3.w),
                                  Expanded(
                                    child: Obx(() {
                                      return getFormButton(
                                        context,
                                        () {
                                          if (isUpdateEnabled.value == true) {
                                            updateInstallationApi(
                                              context,
                                              leadData.id,
                                            );
                                          }
                                        },
                                        "Update",
                                        // validate: true,
                                        validate: isUpdateEnabled.value,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              getDynamicSizedBox(height: 3.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Future<void> getLeadList({
    required BuildContext context,
    int page = 1,
    bool? hideLoading,
    bool isInitialLoad = false,
  }) async {
    User? userData = await UserPreferences().getSignInInfo();

    if (hideLoading == false) {
      state.value = ScreenState.apiLoading;
    }
    if (isInitialLoad == true) {
      isCustomerLoading(true);
    }

    try {
      if (networkManager.connectionType.value == 0) {
        if (isInitialLoad == true) {
          isCustomerLoading(false);
        }
        showDialogForScreen(
          context,
          'Lead Screen',
          Connection.noConnection,
          callback: Get.back,
        );
        return;
      }

      final queryString = buildCustomerQuery(
        userData: userData!,
        page: page,
        startDateApi: startDateApi.value, // e.g. "2027-02"
        endDateApi: endDateApi.value, // e.g. "2027-12"
        districtListInt: districtListInt,
        clusterListInt: clusterListInt,
        customerStatus: selectedStatus.value,
        categoryType: selectedCategoryId.value,
      );

      final apiUrl = "${ApiUrl.leadList}?$queryString";

      final response = await Repository.get({}, apiUrl, allowHeader: true);

      isCustomerLoading(false);
      if (isInitialLoad == true) {
        isCustomerLoading(false);
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == "success") {
          state.value = ScreenState.apiSuccess;
          message.value = '';
          final model = LeadsModel.fromJson(responseData);
          leadList.clear();
          filteredLeadList.clear();
          if (model.result.data.isNotEmpty) {
            leadList.addAll(model.result.data);
            filteredLeadList.addAll(leadList);
            leadList.refresh();
            filteredLeadList.refresh();
            // Update pagination info
            currentPage.value = model.result.meta.page;
            lastPage.value = model.result.meta.lastPage;
            totalItems.value = model.result.meta.total;
            // Calculate fromItem and toItem
            const int perPage = 10; // Matches per_page in API call
            fromItem.value = (currentPage.value - 1) * perPage + 1;
            toItem.value = currentPage.value * perPage > totalItems.value
                ? totalItems.value
                : currentPage.value * perPage;
          } else {
            // Handle empty data case
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
            'Lead Screen',
            responseData['message'],
            callback: Get.back,
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
      if (isInitialLoad == true) {
        isCustomerLoading(false);
      }
      state.value = ScreenState.apiError;
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

  final Map<String, double> columnWidths = {
    "Sr No.": 7.w,
    "Company": 20.w,
    "Contact Person": 20.w,
    "Mobile": 20.w,
    "Category": 20.w,
    "Lead Status": 20.w,
    "Action": 20.w,
  };

  List<List<String>> get leadData {
    if (filteredLeadList.isEmpty) return [];

    return filteredLeadList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;

      return [
        index.toString(),
        e.companyName,
        e.contactPersonName,
        e.contactPersonMobile,
        formatText(e.leadCategory),
        formatText(e.leadStatus),
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

  RxBool isTextEmpty = false.obs;

  final List<String> status = [
    'Select Status',
    'Reschedule',
    'Active',
    'Inactive',
  ];

  RxString selectStatus = 'Select Status'.obs;

  DateTime? selectedDateTime;
  void openDatePicker({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required RxString dateRx,
    required Rx<ValidationModel> model,
    bool showTimePickers = false,
    bool isEndDate = false,
    bool useApiFormat = false, // <-- NEW FLAG
  }) {
    final DateFormat format = useApiFormat
        ? DateFormat('yyyy-MM-dd')
        : DateFormat('MMMM yyyy');

    showCommonDatePicker(
      context: context,
      title: title,
      initialDate: dateRx.value.isNotEmpty ? format.parse(dateRx.value) : null,
      minDate: startDate.value.isNotEmpty
          ? format.parse(startDate.value)
          : null,
      showTimePickers: showTimePickers,
      onDatePicked: (DateTime date) {
        final formatted = format.format(date);

        dateRx.value = formatted;
        controller.text = formatted;

        model.value = ValidationModel(formatted, null, isValidate: true);
        enableSubmitButton();
      },
    );
  }

  void showCategorySelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(categoryList);
    filteredData.value = List.from(categoryList);
    searchCategoriesCtr.clear();
    fetchSelectionPopup<LabelValue>(
      context,
      title: 'Categories',
      controller: categoryCtr,
      list: filteredData,
      searchCtr: searchCategoriesCtr,
      searchNode: searchCategoriesNode,
      filterFunction: (val) {
        filterFetchData<LabelValue>(
          val,
          source: categoryList,
          getTitle: (item) => item.label,
        );
      },
      getTitle: (value) => value.label,
      // getId: (value) => value.id.toString(),
      onSelected: (selectedList) {
        selectedCategoryId.value = selectedList.value;
        //     .map((e) => e.id.toString())
        //     .join(', ');
        // categoryListInt.value = selectedList.map((e) => e.id).toList();

        // if (selectedList.isNotEmpty) {
        //   isCategorySelected.value = true;
        // } else {
        //   isCategorySelected.value = false;
        // }
      },
      function: () {},
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
    logcat("query::", query.toString());
    logcat("List:::::", jsonEncode(source));
    if (query.isEmpty) {
      filteredData.value = List.from(source);
    } else {
      filteredData.value = source.where((item) {
        String title = getTitle(item).toLowerCase();
        return title.startsWith(query.toLowerCase());
      }).toList();
    }

    logcat("filteredData::", jsonEncode(filteredData.value));
    update();
  }

  void showStatusSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(statusList);
    filteredData.value = List.from(statusList);
    searchCustomerCtr.clear();

    fetchSelectionPopup<LabelValue>(
      context,
      title: 'Status',
      controller: statusCtr,
      list: filteredData,
      searchCtr: searchCustomerCtr,
      searchNode: searchCustomerNode,
      filterFunction: (val) {
        filterFetchData<LabelValue>(
          val,
          source: statusList,
          getTitle: (item) => item.label,
        );
      },
      getTitle: (value) => value.label,
      // getId: (value) => value,
      onSelected: (selected) {
        selectedStatus.value = selected.value;

        // isStatusSelected.value = selected != 'Select Status';
      },
      function: () {},
      backBtn: () {
        Get.back();
      },
    );
  }

  void showDistrictSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(districtList);
    searchDistrictCtr.clear();

    showUpdatedMultpleSelectionPopup<Cluster>(
      context,
      title: 'District',
      controller: district,
      list: districtList,
      searchCtr: searchDistrictCtr,
      searchNode: searchGroupNode,
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

    showUpdatedMultpleSelectionPopup<Cluster>(
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
}

Widget addFilterSheetWidget(
  BuildContext context, {
  required LeadController ctr,
  required setStateTrigger,
}) {
  return SafeArea(
    child: GestureDetector(
      onTap: () {
        ctr.unfocusAll();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 2.h),
        child: SizedBox(
          width: Device.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                            openDatePickerDash(
                              context,
                              isStart: false,
                              ctr: ctr,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(() {
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
                          ctr.showDistrictSelectionPopups(context);
                        },
                        hint: 'Select District',
                      );
                    }),
                  ),
                  getDynamicSizedBox(width: 4.w),
                  Expanded(
                    child: Obx(() {
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
                          ctr.showClusterSelectionPopups(context);
                        },
                        hint: 'Select Clusters',
                      );
                    }),
                  ),
                ],
              ),
              getDynamicSizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Category',
                        ctr: ctr.categoryCtr,
                        node: ctr.categoryNode,
                        model: ctr.categoryModel.value,
                        isenable: false,
                        isdropdown: true,
                        wantsuffix: true,
                        usegesture: true,
                        gestureFunction: () {
                          ctr.showCategorySelectionPopups(context);
                        },
                        hint: 'Select Category',
                      );
                    }),
                  ),
                  getDynamicSizedBox(width: 4.w),
                  Expanded(
                    child: Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Status',
                        ctr: ctr.statusCtr,
                        node: ctr.statusNode,
                        model: ctr.statusModel.value,
                        isenable: false,
                        isdropdown: true,
                        wantsuffix: true,
                        usegesture: true,
                        gestureFunction: () {
                          ctr.showStatusSelectionPopups(context);
                        },
                        hint: 'Select Status',
                      );
                    }),
                  ),
                ],
              ),
              getDynamicSizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: getFormButton(
                      context,
                      () {
                        ctr.resetForm();
                        Get.back();
                        ctr.getLeadList(
                          context: context,
                          isInitialLoad: true,
                          page: 1,
                          hideLoading: false,
                        );
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
                        ctr.getLeadList(
                          context: context,
                          isInitialLoad: true,
                          page: 1,
                          hideLoading: false,
                        );
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
      initialDate = ctr.dateFormat.parse(selected);
    } catch (e) {
      try {
        initialDate = DateFormat('dd-MM-yyyy').parse(selected);
      } catch (e) {
        initialDate = null;
      }
    }
  }

  DateTime? minDate;
  if (!isStart && ctr.startDate.value.isNotEmpty) {
    try {
      minDate = ctr.dateFormat.parse(ctr.startDate.value);
      minDate = DateTime(minDate.year, minDate.month, 1);
    } catch (e) {
      minDate = null;
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
                view: DateRangePickerView.year,
                initialSelectedDate: initialDate,
                initialDisplayDate: initialDate,
                minDate: minDate,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is DateTime) {
                    DateTime selectedDate = args.value;
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      1,
                    );
                    ctr.onDateSelected(selectedDate);
                    Navigator.of(context).pop();
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
                allowViewNavigation: false,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
