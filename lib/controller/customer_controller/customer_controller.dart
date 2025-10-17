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
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/CustomerListModel.dart';
import 'package:sales_app/models/dashboard_fillter_model.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';
import '../../api_handle/Repository.dart';
import '../../view/customer_screen.dart/customer_widgets.dart';

// New model for static customer data
class CustomerStaticData {
  final String companyName;
  final String contactPerson;
  final String mobile;
  final String status;
  final DateTime liveData;
  final String warrantyType;
  final DateTime expiry;

  CustomerStaticData({
    required this.companyName,
    required this.contactPerson,
    required this.mobile,
    required this.status,
    required this.liveData,
    required this.warrantyType,
    required this.expiry,
  });
}

class CustomerScreenController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state =
      ScreenState.apiSuccess.obs; // Set to apiSuccess for static data
  RxString message = ''.obs;

  RxBool isTextEmpty = false.obs;
  var warrantyType = <LabelValue>[].obs;
  var customerStatus = <LabelValue>[].obs;
  var filterWarrantyType = <LabelValue>[].obs;
  var filterCustomerStatus = <LabelValue>[].obs;

  var expectedDateModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyPeriodModel = ValidationModel(null, null, isValidate: false).obs;
  var amountModel = ValidationModel(null, null, isValidate: false).obs;

  void clearSearch() {
    searchCtr.clear();
    filteredCustomerList.assignAll(customerList);
    isTextEmpty.value = false;
    update();
  }

  // 🔹 Controllers
  late TextEditingController dateCtr,
      uploadFileCtr,
      warrantyCtr,
      updateWarrantyCtr,
      warrantyPeriodCtr,
      amountCtr,
      startTimeCtr,
      endTimeCtr,
      districtCtr,
      clusterCtr,
      customerStatusCtr,
      searchDistrictCtr,
      searchClusterCtr,
      searchWarrantyTypeCtr,
      searchCtr,
      searchCustomerStatusCtr,
      searchUpdateWarrantyTypeCtr;

  // 🔹 FocusNodes
  late FocusNode dateNode,
      uploadFileNode,
      warrantyNode,
      updateWarrantyNode,
      warrantyPeriodNode,
      amountNode,
      startTimeNode,
      endTimeNode,
      districtNode,
      clusterNode,
      warrantyTypeNode,
      searchNode,
      customerStatusNode,
      searchDistrictNode,
      searchClusterNode,
      searchWarrantyTypeNode,
      searchCustomerStatusNode;

  // 🔹 Validation Models
  var dateModel = ValidationModel(null, null, isValidate: false).obs;
  var uploadFileModel = ValidationModel(null, null, isValidate: false).obs;
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
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat apiDateFormat = DateFormat('dd-MM-yyyy');

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
  RxList<Cluster> districtList = <Cluster>[].obs;
  RxList<Cluster> clustersList = <Cluster>[].obs;

  @override
  void onInit() {
    super.onInit();
    dateCtr = TextEditingController();
    uploadFileCtr = TextEditingController();
    searchCtr = TextEditingController();
    warrantyCtr = TextEditingController();
    updateWarrantyCtr = TextEditingController();
    warrantyPeriodCtr = TextEditingController();
    amountCtr = TextEditingController();
    startTimeCtr = TextEditingController();
    endTimeCtr = TextEditingController();
    districtCtr = TextEditingController();
    clusterCtr = TextEditingController();
    customerStatusCtr = TextEditingController();
    searchDistrictCtr = TextEditingController();
    searchClusterCtr = TextEditingController();
    searchWarrantyTypeCtr = TextEditingController();
    searchCustomerStatusCtr = TextEditingController();
    searchUpdateWarrantyTypeCtr = TextEditingController();

    dateNode = FocusNode();
    uploadFileNode = FocusNode();
    warrantyNode = FocusNode();
    updateWarrantyNode = FocusNode();
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
    searchNode = FocusNode();

    searchCtr.addListener(() {
      filterCustomer(searchCtr.text);
    });
  }

  @override
  void onClose() {
    dateCtr.dispose();
    uploadFileCtr.dispose();
    warrantyCtr.dispose();
    warrantyPeriodCtr.dispose();
    amountCtr.dispose();
    startTimeCtr.dispose();
    endTimeCtr.dispose();
    districtCtr.dispose();
    clusterCtr.dispose();
    customerStatusCtr.dispose();
    searchCtr.dispose();
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
    searchNode.dispose();

    super.onClose();
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    unfocusAll();
    startTimeCtr.clear();
    endTimeCtr.clear();
    districtCtr.clear();
    clusterCtr.clear();
    searchDistrictCtr.clear();
    searchClusterCtr.clear();
    customerStatusCtr.clear();
    searchCustomerStatusCtr.clear();
    warrantyCtr.clear();
    searchWarrantyTypeCtr.clear();
    selectedDistrictId.value = '';
    selectedClusterId.value = '';
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isStartDateSelected.value = false;
    districtListInt.clear();
    clusterListInt.clear();
    startDateApi.value = "";
    endDateApi.value = "";
    startDate.value = "";
    endDate.value = "";
    customerStatusId.value = "";
    warrantyTypeId.value = "";
    isStartDateSelected.value = false;
    isFormInvalidate.value = false;
    enableSubmitButton();
    update();
  }

  void filterCustomer(String query) {
    logcat("filterCustomer::", query.toString());
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      filteredCustomerList.assignAll(customerList);
      isTextEmpty.value = false;
      return;
    }

    filteredCustomerList.assignAll(
      customerList.where((lead) {
        final formattedLiveAt = lead.liveAt.isNotEmpty
            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(lead.liveAt))
            : '';
        final values = [
          lead.companyName,
          lead.contactPersonName,
          lead.contactPersonMobile,
          lead.customerStatus,
          formattedLiveAt,
          lead.warrantyType,
          lead.warrantyEndDate,
        ];
        return values.any((value) => value.toLowerCase().contains(lowerQuery));
      }).toList(),
    );

    logcat("filterResponse::", jsonEncode(filteredCustomerList));
    isTextEmpty.value = true;
  }

  RxList<CustomerData> customerList = <CustomerData>[].obs;
  RxList<CustomerData> filteredCustomerList = <CustomerData>[].obs;
  RxString nextPageURL = "".obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt fromItem = 0.obs;
  final RxInt toItem = 0.obs;

  var isCustomerLoading = false.obs;

  Future<void> getCustomerList({
    required BuildContext context,
    int page = 1,
    bool? hideLoading,
    bool isApplyFilter = false,
    bool isInitialLoad = false,
  }) async {
    User? userData = await UserPreferences().getSignInInfo();

    if (hideLoading == false) {
      state.value = ScreenState.apiLoading;
    }
    if (isInitialLoad == true) {
      isCustomerLoading(true);
    }

    if (isInitialLoad && !isApplyFilter) {
      logcat("init", "Done");
      resetForm();
    }

    try {
      if (networkManager.connectionType.value == 0) {
        if (isInitialLoad == true) {
          isCustomerLoading(false);
        }
        showDialogForScreen(
          // ignore: use_build_context_synchronously
          context,
          'Lead Screen',
          Connection.noConnection,
          callback: Get.back,
        );
        return;
      }

      // final apiUrl =
      //     "${ApiUrl.getCustomerList}?user_id=${userData?.userId ?? 1}&page=$page&per_page=10";

      // ✅ Build query string dynamically
      final queryString = buildCustomerQuery(
        userData: userData!,
        page: page,
        startDateApi: startDateApi.value, // e.g. "2027-02"
        endDateApi: endDateApi.value, // e.g. "2027-12"
        districtListInt: districtListInt,
        clusterListInt: clusterListInt,
        customerStatus: customerStatusId.value,
        warrantyType: warrantyTypeId.value,
      );

      logcat("customerStatusId.value", customerStatusId.value.toString());
      logcat("warrantyTypeId.value", warrantyTypeId.value.toString());

      final apiUrl = "${ApiUrl.getCustomerList}?$queryString";

      logcat("CustomerList URL", apiUrl);

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
          final model = CustomerListModel.fromJson(responseData);
          customerList.clear();
          filteredCustomerList.clear();
          if (model.result.data.isNotEmpty) {
            customerList.addAll(model.result.data);
            filteredCustomerList.addAll(customerList);
            customerList.refresh();
            filteredCustomerList.refresh();
            currentPage.value = model.result.pagination.page;
            lastPage.value = model.result.pagination.lastPage;
            totalItems.value = model.result.pagination.total;
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
            // ignore: use_build_context_synchronously
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
          // ignore: use_build_context_synchronously
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

  String buildCustomerQuery({
    required User userData,
    required int page,
    required String startDateApi,
    required String endDateApi,
    required String customerStatus,
    required String warrantyType,
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

    if (customerStatus.isNotEmpty) {
      queryParams.add('customer_status=$customerStatus');
    }

    if (warrantyType.isNotEmpty) {
      queryParams.add('warranty_type=$warrantyType');
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

  Future<void> getFillterOptions(context, {showLoader = true}) async {
    User? userData = await UserPreferences().getSignInInfo();
    var loadingIndicator = LoadingProgressDialog();
    commonGetApiCallFormate(
      context,
      title: 'Dashboard Screen',
      apiEndPoint: "${ApiUrl.getfillter}?user_id=${userData?.userId ?? ''}",
      allowHeader: true,
      state: state,
      message: message,
      apisLoading: (isloaing) {
        if (showLoader == true) {
          if (isloaing == true) {
            loadingIndicator.show(context, '');
          } else {
            loadingIndicator.hide(context);
          }
        }
      },
      onResponse: (data) {
        logcat('Filter Options Data', data.toString());
        districtList.clear();
        clustersList.clear();
        var innerData = data['data'];
        FiltterData responseDetail = FiltterData.fromJson(innerData);
        districtList.addAll(responseDetail.districts);
        clustersList.addAll(responseDetail.clusters);
        // warrantyType.assignAll(
        //   responseDetail.warrantyType.where((e) => e.value != 'under-warranty'),
        // );
        // filterWarrantyType.assignAll(
        //   responseDetail.warrantyType.where((e) => e.value != 'under-warranty'),
        // );

        warrantyType.assignAll(responseDetail.warrantyType);
        filterWarrantyType.assignAll(responseDetail.warrantyType);

        // warrantyType.assignAll(responseDetail.warrantyType);
        // filterWarrantyType.assignAll(responseDetail.warrantyType);
        customerStatus.assignAll(responseDetail.customerStatus);
        filterCustomerStatus.assignAll(responseDetail.customerStatus);

        logcat('DistrictList', districtList.length.toString());
        logcat('ClustersList', clustersList.length.toString());
        logcat('filterCustomerStatus', jsonEncode(filterCustomerStatus));
        logcat('filterWarrantyType', jsonEncode(filterWarrantyType));
        update();
      },
      networkManager: networkManager,
    );
  }
  // Future<void> getCustomerbyID(
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
  //     isCustomerLoading(
  //       true,
  //     ); // Assuming you have a loading state for customers
  //   }

  //   try {
  //     if (networkManager.connectionType.value == 0) {
  //       if (isFirstTime == true) {
  //         isCustomerLoading(false);
  //       }
  //       showDialogForScreen(
  //         context,
  //         'Meter Screen',
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

  //         var customerListData = CustomerModel.fromJson(responseData);
  //         if (customerListData.result.isNotEmpty) {
  //           customerList.addAll(customerListData.result);
  //           customerList.refresh();
  //           update();
  //         } else {
  //           customerList.clear();
  //         }

  //         // ✅ Set pagination info
  //         this.currentPage.value = customerListData.pagination.currentPage;
  //         lastPage.value = customerListData.pagination.lastPage;
  //         totalItems.value = customerListData.pagination.total;
  //         fromItem.value = customerListData.pagination.from;
  //         toItem.value = customerListData.pagination.to;
  //         // Handle pagination
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
  //     // message.value = ServerError.servererror;
  //     // showDialogForScreen(context, 'Meter Screen', ServerError.servererror, callback: () {});
  //   }
  // }

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

  List<List<String>> get customerData {
    if (filteredCustomerList.isEmpty) return [];

    final now = DateTime.now();

    return filteredCustomerList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;

      // Format live_at
      final formattedLiveAt = formatDate(e.liveAt);

      // Format warranty_end_date
      final formattedWarrantyEndDate = formatDate(e.warrantyEndDate);

      // Determine warranty type
      String formattedWarrantyType = e.warrantyType.toLowerCase();
      final endDate = parseDate(e.warrantyEndDate);

      if (endDate != null &&
          now.isAfter(endDate) &&
          formattedWarrantyType == "non_amc") {
        formattedWarrantyType = formattedWarrantyType.capitalize.toString();
      } else if (endDate != null &&
          now.isAfter(endDate) &&
          formattedWarrantyType == "amc") {
        formattedWarrantyType = "Not In AMC";
      } else {
        formattedWarrantyType = formattedWarrantyType.capitalize.toString();
      }

      return [
        index.toString(),
        e.companyName,
        e.contactPersonName,
        e.contactPersonMobile,
        e.customerStatus.capitalize.toString(),
        formattedLiveAt,
        formatText(formattedWarrantyType),
        formattedWarrantyEndDate,
        "",
      ];
    }).toList();
  }
  // // Provide all customer data without pagination
  // List<List<String>> get customerData {
  //   if (filteredCustomerList.isEmpty) return [];

  //   return filteredCustomerList.asMap().entries.map((entry) {
  //     final index = entry.key + 1 + ((currentPage.value - 1) * 10);
  //     final e = entry.value;
  //     final formattedLiveAt = e.liveAt.isNotEmpty
  //         ? DateFormat('dd-MM-yyyy').format(DateTime.parse(e.liveAt))
  //         : '';

  //     String formattedWarrantyType = e.warrantyType.toLowerCase();

  //     // Format warranty_end_date
  //     String formattedWarrantyEndDate = '';
  //     if (e.warrantyEndDate != null && e.warrantyEndDate.isNotEmpty) {
  //       try {
  //         formattedWarrantyEndDate = DateFormat(
  //           'dd-MM-yyyy',
  //         ).format(DateTime.parse(e.warrantyEndDate));
  //       } catch (_) {
  //         formattedWarrantyEndDate = e.warrantyEndDate;
  //       }
  //     }

  //     // Format warranty type

  //     // Parse end date safely
  //     DateTime? endDate;
  //     if (e.warrantyEndDate != null && e.warrantyEndDate.isNotEmpty) {
  //       try {
  //         endDate = DateTime.parse(e.warrantyEndDate);
  //       } catch (_) {
  //         endDate = null;
  //       }
  //     }

  //     // Check if expired and type is not AMC
  //     if (endDate != null &&
  //         DateTime.now().isAfter(endDate) &&
  //         e.warrantyType.toLowerCase() != "amc") {
  //       formattedWarrantyType = "Not In AMC";
  //     } else {
  //       formattedWarrantyType = formattedWarrantyType.capitalize.toString();
  //     }

  //     return [
  //       index.toString(),
  //       e.companyName,
  //       e.contactPersonName,
  //       e.contactPersonMobile,
  //       e.customerStatus.capitalize.toString(),
  //       formattedLiveAt,
  //       formatText(formattedWarrantyType),
  //       formattedWarrantyEndDate,
  //       "",
  //     ];
  //   }).toList();
  // }

  RxBool isUpdateEnabled = false.obs;
  CustomerData? currentCustomer;

  void validateUpdateButton() {
    if (currentCustomer == null) return;

    final customer = currentCustomer!;

    bool isDateFilled = true;
    bool isFileUploaded = true;
    bool isWarrantyFilled = selectedWarrantyTypeValue.value.isNotEmpty;
    bool isPeriodFilled = true;
    bool isAmountFilled = true;

    // 🔹 Case 1: Customer status = Open
    if (customer.customerStatus.toLowerCase() == "open") {
      isDateFilled = dateCtr.text.isNotEmpty;
      isFileUploaded = uploadFileCtr.text.isNotEmpty;
      isPeriodFilled = warrantyPeriodCtr.text.isNotEmpty;
    } else {
      if (selectedWarrantyTypeValue.value == "amc") {
        isPeriodFilled = warrantyPeriodCtr.text.isNotEmpty;
        isAmountFilled = amountCtr.text.isNotEmpty;
      } else if (selectedWarrantyTypeValue.value == "non_amc") {
        isPeriodFilled = true;
        isAmountFilled = true;
      }
    }

    // Final validation
    isUpdateEnabled.value =
        isDateFilled &&
        isFileUploaded &&
        isWarrantyFilled &&
        isPeriodFilled &&
        isAmountFilled;
  }

  void setCustomerFormFields(CustomerData customer) {
    currentCustomer = customer;

    //  Expected Delivery Date
    dateCtr.text = customer.expectedDeliveryDate;

    //  Installation Certificate
    if (customer.hasInstallationCertificate &&
        customer.installationCertificate != null) {
      final url = customer.installationCertificate!.path;
      uploadFileCtr.text = url.split('/').last;
    } else {
      uploadFileCtr.clear();
    }

    //  Match Warranty Type
    final matchedItem = filterWarrantyType.firstWhereOrNull(
      (item) => item.value.toLowerCase() == customer.warrantyType.toLowerCase(),
    );

    updateWarrantyCtr.text =
        matchedItem?.label ?? customer.warrantyType.capitalize ?? '';
    selectedWarrantyTypeValue.value = customer.warrantyType.isNotEmpty
        ? customer.warrantyType
        : '';

    //  Handle Warranty Logic Based on Status
    if (customer.customerStatus == "open") {
      updateWarrantyCtr.text = "Under-Warranty";
      selectedWarrantyTypeValue.value = "under-warranty";
    } else {
      // If not AMC, clear warranty fields
      if (customer.warrantyType.toLowerCase() != "amc") {
        updateWarrantyCtr.clear();
        selectedWarrantyTypeValue.value = '';
        warrantyPeriodCtr.clear();
      } else {
        updateWarrantyCtr.text =
            matchedItem?.label ?? customer.warrantyType.capitalize ?? '';
        selectedWarrantyTypeValue.value = customer.warrantyType.toLowerCase();
        warrantyPeriodCtr.text = customer.warrantyPeriod.toString();
      }
    }

    amountCtr.clear();
    validateUpdateButton();
  }

  void updateCustomer(context, CustomerData customer) async {
    setCustomerFormFields(customer);
    // currentCustomer = customer;
    // dateCtr.text = customer.expectedDeliveryDate;
    // if (customer.hasInstallationCertificate &&
    //     customer.installationCertificate != null) {
    //   final url = customer.installationCertificate!.path;
    //   uploadFileCtr.text = url.split('/').last;
    // } else {
    //   uploadFileCtr.clear();
    // }

    // final matchedItem = filterWarrantyType.firstWhereOrNull(
    //   (item) => item.value.toLowerCase() == customer.warrantyType.toLowerCase(),
    // );

    // updateWarrantyCtr.text =
    //     matchedItem?.label ?? customer.warrantyType.capitalize ?? '';
    // selectedWarrantyTypeValue.value = customer.warrantyType.isNotEmpty
    //     ? customer.warrantyType
    // : '';

    // if (customer.warrantyType.toLowerCase().toString() == "non_amc") {
    // } else {
    //   warrantyPeriodCtr.text = customer.warrantyPeriod.toString();
    // }
    // DateTime today = DateTime.now();
    // DateTime? warrantyEnd;

    // try {
    //   warrantyEnd = DateTime.parse(customer.warrantyEndDate);
    // } catch (_) {
    //   warrantyEnd = null;
    // }

    // if (customer.customerStatus == "open" &&
    //     warrantyEnd != null &&
    //     warrantyEnd.isAfter(today.subtract(const Duration(days: 1)))) {

    // if (customer.customerStatus == "open") {
    //   updateWarrantyCtr.text = "Under-Warranty";
    //   selectedWarrantyTypeValue.value = "under-warranty";
    // } else {
    //   // Warranty expired → use existing value or Non-AMC
    //   final matchedItem = filterWarrantyType.firstWhereOrNull(
    //     (item) =>
    //         item.value.toLowerCase() == customer.warrantyType.toLowerCase(),
    //   );

    //   if (customer.warrantyType.toLowerCase().toString() != "amc") {
    //     updateWarrantyCtr.text = "";
    //     selectedWarrantyTypeValue.value = '';
    //     warrantyPeriodCtr.clear();
    //   } else {
    //     updateWarrantyCtr.text =
    //         matchedItem?.label ?? customer.warrantyType.capitalize ?? '';
    //     selectedWarrantyTypeValue.value = customer.warrantyType.isNotEmpty
    //         ? customer.warrantyType.toLowerCase()
    //         : '';
    //     warrantyPeriodCtr.text = customer.warrantyPeriod.toString();
    //   }
    // }
    // amountCtr.clear();
    // validateUpdateButton();
    logcat("warrantyTypeId:", selectedWarrantyTypeValue.value);
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
                      buildHeader(context, "Update Customer"),
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
                            if (customer.customerStatus == "open")
                              Obx(
                                () => getTextField(
                                  context: context,
                                  wantLabel: true,
                                  label: 'Expected Date of Delivery',
                                  ctr: dateCtr,
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
                                      controller: dateCtr,
                                      dateRx: startDate,
                                      model: dateModel,
                                      showTimePickers: false,
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
                                    dateCtr.addListener(validateUpdateButton);
                                  },
                                  hint: 'Select Date',
                                ),
                              ),
                            getDynamicSizedBox(
                              height: (customer.customerStatus == "open")
                                  ? 1.h
                                  : 0.0,
                            ),
                            if (customer.customerStatus == "open")
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
                                usegesture: customer.customerStatus == "open"
                                    ? false
                                    // : customer.warrantyType.toLowerCase() ==
                                    //           "amc" ||
                                    //       customer.warrantyType.toLowerCase() ==
                                    //           "under-warranty"
                                    // ? false
                                    // : true,
                                    : true,
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
                            if (selectedWarrantyTypeValue.value != "non_amc")
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
                            if (selectedWarrantyTypeValue.value == 'amc')
                              getDynamicSizedBox(height: 1.h),
                            // if (selectedWarrantyTypeValue.value != "non_amc" &&
                            //     selectedWarrantyTypeValue.value !=
                            //         'under-warranty')
                            if (selectedWarrantyTypeValue.value == 'amc')
                              /// Contact Person Name
                              Obx(() {
                                return getTextField(
                                  context: context,
                                  wantLabel: true,
                                  label: 'Amount',
                                  ctr: amountCtr,
                                  node: amountNode,
                                  model: amountModel.value,
                                  useOnChanged: true,
                                  hint: 'Enter Amount',
                                  isNumber: true,
                                  function: (val) {
                                    amountCtr.addListener(validateUpdateButton);
                                  },
                                  isRequired: true,
                                );
                              }),
                            getDynamicSizedBox(
                              height:
                                  (selectedWarrantyTypeValue.value !=
                                          "non_amc" &&
                                      selectedWarrantyTypeValue.value !=
                                          'under-warranty')
                                  ? 3.h
                                  : 4.h,
                            ),
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
                                  child: Obx(() {
                                    return getFormButton(
                                      context,
                                      () {
                                        if (isUpdateEnabled.value == true) {
                                          customerUpdateApi(context, customer);
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
                          ],
                        ),
                      ),
                      getDynamicSizedBox(height: 6.h, width: Device.width),
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

  Future<void> customerUpdateApi(
    BuildContext context,
    CustomerData customer,
  ) async {
    var loadingIndicator = LoadingProgressDialog();

    if (networkManager.connectionType.value == 0) {
      showDialogForScreen(
        context,
        "Customer Update",
        Connection.noConnection,
        callback: () => Get.back(),
      );
      return;
    }

    try {
      loadingIndicator.show(context, '');

      final endPoint = "${ApiUrl.getCustomerList}/${customer.id}/update";

      // Prepare form fields
      final body = {
        'warranty_type': selectedWarrantyTypeValue.value,
        'warranty_period': warrantyPeriodCtr.text,
        'expected_delivery_date': dateCtr.text,
        'amount': amountCtr.text,
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
            "Customer Updated",
            data['message'] ?? "Update successful!",
            callback: () {
              Get.back(result: true);
              getCustomerList(
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
        showDialogForScreen(
          context,
          "Update Customer",
          response.body,
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

  // Future<void> customerUpdateApi(
  //   BuildContext context,
  //   CustomerData customer,
  // ) async {
  //   var loadingIndicator = LoadingProgressDialog();
  //   User? user = await UserPreferences().getSignInInfo();
  //   String? password = await UserPreferences().getPassword();

  //   if (networkManager.connectionType.value == 0) {
  //     loadingIndicator.hide(context);
  //     showDialogForScreen(
  //       context,
  //       "Customer Update",
  //       Connection.noConnection,
  //       callback: () => Get.back(),
  //     );
  //     return;
  //   }

  //   try {
  //     loadingIndicator.show(context, '');

  //     final uri = Repository.buildUrl(
  //       "${ApiUrl.getCustomerList}/${customer.id}/update",
  //     );

  //     logcat("uri::", uri.toString());
  //     var request = http.MultipartRequest('POST', uri);

  //     // Headers
  //     request.headers.addAll({
  //       'X-USER-EMAIL': user?.email ?? '',
  //       'X-USER-PASSWORD': password,
  //     });

  //     // Form fields (like in curl)
  //     request.fields['warranty_type'] = selectedWarrantyTypeValue.value;
  //     request.fields['warranty_period'] = warrantyPeriodCtr.text;
  //     request.fields['expected_delivery_date'] = dateCtr.text;
  //     request.fields['amount'] = amountCtr.text;

  //     // File upload (if exists)
  //     if (uploadFileCtr.text.isNotEmpty) {
  //       final filePath = selectedFile?.path ?? '';
  //       if (filePath.isNotEmpty) {
  //         request.files.add(
  //           await http.MultipartFile.fromPath(
  //             'installation_certificate',
  //             filePath,
  //           ),
  //         );
  //       }
  //     }

  //     logcat("FormFields:", jsonEncode(request.fields));

  //     // Send request
  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);

  //     loadingIndicator.hide(context);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       logcat('updateResponse', data.toString());
  //       if (data['status']?.toString().toLowerCase() == 'success') {
  //         showDialogForScreen(
  //           context,
  //           "Customer Updated",
  //           data['message'] ?? "Update successful!",
  //           callback: () {
  //             Get.back(result: true);
  //             getCustomerList(
  //               context: context,
  //               isInitialLoad: true,
  //               page: 1,
  //               hideLoading: false,
  //             );
  //           },
  //         );
  //       } else {
  //         showDialogForScreen(
  //           context,
  //           "Error",
  //           data['message'] ?? "Failed to update customer",
  //           callback: () => Get.back(),
  //         );
  //       }
  //     } else {
  //       logcat('Error Response', response.body);
  //       showDialogForScreen(
  //         context,
  //         // "Error ${response.statusCode}",
  //         "Update Customer",
  //         response.body,
  //         callback: () => Get.back(),
  //       );
  //     }
  //   } catch (e) {
  //     loadingIndicator.hide(context);
  //     logcat("Exception", e.toString());
  //     showDialogForScreen(
  //       context,
  //       "Error",
  //       e.toString(),
  //       callback: () => Get.back(),
  //     );
  //   }
  // }

  // Open system file picker (only PDF)

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
      update();
      print("Picked file path: ${selectedFile!.path}");
      print("Picked file name: ${uploadFileCtr.text}");
    } else {
      print("No file selected");
    }
  }

  RxBool isWarrantyTypeListApiCallLoading = false.obs;
  RxString selectedWarrantyTypeValue = ''.obs;
  RxString selectedWarrantyTypeLabel = ''.obs;
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
                  filterWarrantyType.addAll(warrantyType);
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
      filterWarrantyType.assignAll(warrantyType);
    } else {
      filterWarrantyType.assignAll(
        warrantyType
            .where(
              (item) =>
                  item.label.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
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
        dateCtr.addListener(validateUpdateButton);
        update();
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

    // startTimeModel.value = ValidationModel(
    //   startDate.value.isNotEmpty ? startDate.value : null,
    //   null,
    //   isValidate: startDate.value.isNotEmpty,
    // );
    // endTimeModel.value = ValidationModel(
    //   endDate.value.isNotEmpty ? endDate.value : null,
    //   null,
    //   isValidate: endDate.value.isNotEmpty,
    // );
    // districtModel.value = ValidationModel(
    //   districtCtr.text.isNotEmpty ? districtCtr.text : null,
    //   null,
    //   isValidate: districtCtr.text.isNotEmpty,
    // );
    // clusterModel.value = ValidationModel(
    //   clusterCtr.text.isNotEmpty ? clusterCtr.text : null,
    //   null,
    //   isValidate: clusterCtr.text.isNotEmpty,
    // );

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
                searchWarrantyTypeCtr.clear();
                showWarrantyTypeSelectionPopups(context, '');
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
                searchCustomerStatusCtr.clear();
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
                    resetForm();
                    getCustomerList(
                      context: context,
                      isInitialLoad: true,
                      isApplyFilter: false,
                      page: 1,
                    );
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
                    getCustomerList(
                      context: context,
                      isInitialLoad: true,
                      page: 1,
                      isApplyFilter: true,
                    );
                    Get.back();
                  },
                  "Apply",
                  validate: true,
                ),
              ),
            ],
          ),
          getDynamicSizedBox(height: 4.h),
        ],
      ),
    );
  }

  // Common filter
  var currentFilterSource = [].obs;
  var filteredData = [].obs;
  var customerFlteredData = [].obs;
  RxString warrantyTypeId = "".obs;
  RxString customerStatusId = "".obs;
  // RxList<CategoryModel> warrantyType = <CategoryModel>[
  //   CategoryModel(id: "1", name: "Invoice"),
  //   CategoryModel(id: "2", name: "Bills"),
  //   CategoryModel(id: "3", name: "Reports"),
  //   CategoryModel(id: "4", name: "Others"),
  // ].obs;

  void showWarrantyTypeSelectionPopups(
    BuildContext context,
    String currentValue,
  ) {
    currentFilterSource.value = List.from(warrantyType);
    filteredData.value = List.from(warrantyType);

    // // Dynamically set controller text from value
    // LabelValue? selectedItem = warrantyType.firstWhere(
    //   (e) => e.value == currentValue.toLowerCase(),
    //   orElse: () => LabelValue(label: '', value: ''),
    // );

    // warrantyCtr.text = selectedItem.label; // pre-select label
    // warrantyTypeId.value = selectedItem.value; // pre-select value

    fetchSelectionPopup<LabelValue>(
      context,
      title: 'Warranty Type',
      controller: warrantyCtr,
      list: filteredData,
      searchCtr: searchWarrantyTypeCtr,
      searchNode: searchWarrantyTypeNode,
      filterFunction: (val) {
        filterFetchData<LabelValue>(
          val,
          source: warrantyType,
          getTitle: (item) => item.label,
        );
      },
      getTitle: (value) => value.label,
      onSelected: (data) {
        warrantyCtr.clear();
        warrantyCtr.text = data.label;
        warrantyTypeId.value = data.value.toString();
        logcat('warrantyTypeId::', warrantyTypeId.value);
        update();
      },
      backBtn: () {
        Get.back();
      },
    );
  }

  void showCustomerStatusSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(customerStatus);
    filteredData.value = List.from(customerStatus);

    fetchSelectionPopup<LabelValue>(
      context,
      title: 'Customer Status',
      controller: customerStatusCtr,
      list: filteredData,
      searchCtr: searchCustomerStatusCtr,
      searchNode: searchCustomerStatusNode,
      filterFunction: (val) {
        filterFetchData<LabelValue>(
          val,
          source: customerStatus,
          getTitle: (item) => item.label,
        );
      },
      getTitle: (value) => value.label,
      onSelected: (data) {
        customerStatusCtr.clear();
        customerStatusCtr.text = data.label;
        customerStatusId.value = data.value.toString();
        logcat('CustomerStatus', customerStatusId.value);
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

  void enableSubmitButton() {
    isFormInvalidate.value =
        startTimeModel.value.isValidate && endTimeModel.value.isValidate;
    update();
  }

  // Filter source and filtered data

  void showDistrictSelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(districtList);
    searchDistrictCtr.clear();

    showUpdatedMultpleSelectionPopup<Cluster>(
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
