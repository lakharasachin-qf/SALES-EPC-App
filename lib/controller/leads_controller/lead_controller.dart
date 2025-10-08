import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:intl/intl.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/controller/master_controller/Master_Controller.dart';
import 'package:sales_app/models/LeadModel.dart';
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
  RxList<Category> districtList = <Category>[].obs;
  RxList<Category> clustersList = <Category>[].obs;
  RxList<Category> categoryList = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize static data
    initializeStaticData();

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
  }

  // Initialize static customer data
  void initializeStaticData() {
    customerList.clear();
    customerList.addAll([
      CustomerData(
        company: "Tech Corp",
        contactPerson: "John Doe",
        mobile: "123-456-7890",
        category: "Premium",
        leadStatus: "Active",
      ),
      CustomerData(
        company: "Innovate Ltd",
        contactPerson: "Jane Smith",
        mobile: "234-567-8901",
        category: "Standard",
        leadStatus: "Inactive",
      ),
      CustomerData(
        company: "Global Solutions",
        contactPerson: "Alice Johnson",
        mobile: "345-678-9012",
        category: "Enterprise",
        leadStatus: "Reschedule",
      ),
      CustomerData(
        company: "Future Tech",
        contactPerson: "Bob Wilson",
        mobile: "456-789-0123",
        category: "Premium",
        leadStatus: "Active",
      ),
      CustomerData(
        company: "Star Enterprises",
        contactPerson: "Emma Brown",
        mobile: "567-890-1234",
        category: "Standard",
        leadStatus: "Inactive",
      ),
      CustomerData(
        company: "NextGen Systems",
        contactPerson: "Michael Lee",
        mobile: "678-901-2345",
        category: "Enterprise",
        leadStatus: "Active",
      ),
      CustomerData(
        company: "Bright Future Ltd",
        contactPerson: "Sophia Davis",
        mobile: "789-012-3456",
        category: "Premium",
        leadStatus: "Reschedule",
      ),
      CustomerData(
        company: "Visionary Labs",
        contactPerson: "Daniel Martinez",
        mobile: "890-123-4567",
        category: "Standard",
        leadStatus: "Inactive",
      ),
      CustomerData(
        company: "GreenTech Innovations",
        contactPerson: "Olivia Taylor",
        mobile: "901-234-5678",
        category: "Enterprise",
        leadStatus: "Active",
      ),
      CustomerData(
        company: "BlueSky Ventures",
        contactPerson: "Ethan Anderson",
        mobile: "012-345-6789",
        category: "Premium",
        leadStatus: "Reschedule",
      ),
    ]);

    // Set pagination details for static data
    totalItems.value = customerList.length;
    currentPage.value = 1;
    lastPage.value = 1; // Static data fits in one page
    fromItem.value = 1;
    toItem.value = customerList.length;
    nextPageURL.value = "";
    state.value = ScreenState.apiSuccess;
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
    selectedStatus.value = 'Select Status';
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
  RxString selectedStatus = 'Select Status'.obs;
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
                    .contains(c.id.toString()),
              )
              .map((c) => c.name)
              .join(', ')
        : '';
    statusCtr.text = selectedStatus.value != 'Select Status'
        ? selectedStatus.value
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
    isStatusSelected.value = selectedStatus.value != 'Select Status';

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
        categoryList.clear();
        FiltterModel responseDetail = FiltterModel.fromJson(data);
        districtList.addAll(responseDetail.result.groups);
        clustersList.addAll(responseDetail.result.clusters);
        categoryList.addAll(responseDetail.result.categories);
        update();
      },
      networkManager: networkManager,
    );
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

      final apiUrl = "${ApiUrl.leadList}?user_id=${1}&page=$page&per_page=1";

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
          if (model.result.data.isNotEmpty) {
            leadList.addAll(model.result.data);
            leadList.refresh();

            // Update pagination info
            currentPage.value = model.result.meta.page;
            lastPage.value = model.result.meta.lastPage;
            totalItems.value = model.result.meta.total;
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

  // Future<void> getLeadLists(
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
  //     isCustomerLoading(true);
  //   }

  //   try {
  //     if (networkManager.connectionType.value == 0) {
  //       if (isFirstTime == true) {
  //         isCustomerLoading(false);
  //       }
  //       showDialogForScreen(
  //         context,
  //         'Lead Screen',
  //         Connection.noConnection,
  //         callback: () {
  //           Get.back();
  //         },
  //       );
  //       return;
  //     }

  //     var pageURL =
  //         "${ApiUrl.getcustomerbyIdwwithpagination}=${userData?.userId ?? ''}&page=$currentPage&per_page=10";
  //     var response = await Repository.get({}, pageURL, allowHeader: true);

  //     if (isFirstTime == true) {
  //       isCustomerLoading(false);
  //     }

  //     logcat("RESPONSE::", response.body);
  //     var responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       if (responseData['status'] == true) {
  //         state.value = ScreenState.apiSuccess;
  //         message.value = '';

  //         if (isFirstTime == true && customerList.isNotEmpty) {
  //           currentPage = 1;
  //           customerList.clear();
  //         }

  //         var customerListData = LeadsModel.fromJson(responseData);
  //         if (customerListData.result.isNotEmpty) {
  //           customerList.addAll(customerListData.result);
  //           customerList.refresh();
  //           update();
  //         } else {
  //           customerList.clear();
  //         }

  //         this.currentPage.value = customerListData.pagination.currentPage;
  //         lastPage.value = customerListData.pagination.lastPage;
  //         totalItems.value = customerListData.pagination.total;
  //         fromItem.value = customerListData.pagination.from;
  //         toItem.value = customerListData.pagination.to;

  //         if (customerListData.pagination.currentPage <
  //             customerListData.pagination.lastPage) {
  //           nextPageURL.value =
  //               "${ApiUrl.getcustomerbyIdwwithpagination}=${userData?.userId ?? ''}&page=${currentPage + 1}&per_page=10";
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
  //           'Meter Screen',
  //           responseData['message'],
  //           callback: () {},
  //         );
  //       }
  //     } else {
  //       state.value = ScreenState.apiError;
  //       message.value = APIResponseHandleText.serverError;
  //       showDialogForScreen(
  //         context,
  //         'Meter Screen',
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
  //       isCustomerLoading(false);
  //     }
  //     state.value = ScreenState.apiError;
  //   }
  // }

  final RxList<String> customerHeaders = <String>[
    "Sr No.",
    "Company",
    "Contact Person",
    "Mobile",
    "Category",
    "Lead Status",
    "Action",
  ].obs;

  List<List<String>> get leadData {
    if (customerList.isEmpty) return [];

    return leadList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;

      return [
        index.toString(),
        e.companyName,
        e.contactPersonName,
        e.contactPersonMobile,
        e.leadCategory,
        e.leadStatus,
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

  void clearSearch() {
    searchCtr.clear();
    // filterData('');
    unfocusAll();
  }

  final List<String> status = [
    'Select Status',
    'Reschedule',
    'Active',
    'Inactive',
  ];

  final List<String> cateory = [
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
      showTimePickers: showTimePickers,
      onDatePicked: (DateTime date) {
        final formatted = dateFormat.format(date);
        dateRx.value = formatted;
        controller.text = formatted;
        model.value = ValidationModel(formatted, null, isValidate: true);
        enableSubmitButton();
      },
    );
  }

  void showCategorySelectionPopups(BuildContext context) {
    fetchSelectionPopup<String>(
      context,
      title: 'Categories',
      controller: categoryCtr,
      list: cateory,
      searchCtr: searchCategoriesCtr,
      searchNode: searchCategoriesNode,
      filterFunction: (val) {
        return categoryList
            .where(
              (item) => item.name.toLowerCase().contains(val.toLowerCase()),
            )
            .toList();
      },
      getTitle: (value) => value,
      // getId: (value) => value.id.toString(),
      onSelected: (selectedList) {
        selectedCategoryId.value = selectedList;
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

  void showStatusSelectionPopups(BuildContext context) {
    fetchSelectionPopup<String>(
      context,
      title: 'Status',
      controller: statusCtr,
      list: status,
      searchCtr: searchCustomerCtr,
      searchNode: searchCustomerNode,
      filterFunction: (val) {
        return status
            .where((item) => item.toLowerCase().contains(val.toLowerCase()))
            .toList();
      },
      getTitle: (value) => value,
      // getId: (value) => value,
      onSelected: (selected) {
        selectedStatus.value = selected;
        statusCtr.text = selected;
        statusModel.value = ValidationModel(
          selected,
          null,
          isValidate: selected != 'Select Status',
        );
        isStatusSelected.value = selected != 'Select Status';
        enableSubmitButton();
      },
      function: () {},
      backBtn: () {
        Get.back();
      },
    );
  }

  var currentFilterSource = [].obs;
  var filteredData = [].obs;
  RxString categoryId = "".obs;
  RxList<CategoryModel> warrantyType = <CategoryModel>[
    CategoryModel(id: "1", name: "Invoice"),
    CategoryModel(id: "2", name: "Bills"),
    CategoryModel(id: "3", name: "Reports"),
    CategoryModel(id: "4", name: "Others"),
  ].obs;

  void showDistrictSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(districtList);
    searchDistrictCtr.clear();

    showUpdatedMultpleSelectionPopup<Category>(
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
                        // openDatePickerDash(context, isStart: true, ctr: ctr);
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
                        // if (!ctr.isStartDateSelected.value) {
                        //   showDialogForScreen(
                        //     context,
                        //     'Dashboard',
                        //     'Please select the start date first.',
                        //     callback: () {},
                        //   );
                        // } else {
                        //   openDatePickerDash(context, isStart: false, ctr: ctr);
                        // }
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
                        // ctr.showDistrictSelectionPopups(context);
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
                        // ctr.showClusterSelectionPopups(context);
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
                        // ctr.showCategorySelectionPopups(context);
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
                        // ctr.showStatusSelectionPopups(context);
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
