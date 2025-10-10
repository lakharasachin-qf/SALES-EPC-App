import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/controller/master_controller/Master_Controller.dart';
import 'package:sales_app/models/dashboard1_model.dart';
import 'package:sales_app/models/dashboard_fillter_model.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/view/dashboard_screen/widgets/dashboard_widgets.dart';
import '../../api_handle/Repository.dart';
import '../../configs/apicall_constant.dart';

class DashboardController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();

  Rx<ScreenState> state = ScreenState.apiLoading.obs;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter-related variables
  late FocusNode startTimeNode, endTimeNode;
  late FocusNode districtNode, clusterNode;
  late FocusNode searchGroupNode, searchClusterNode;
  late TextEditingController startTimeCtr, endTimeCtr;
  late TextEditingController district, clusterCtr;
  late TextEditingController searchDistrictCtr, searchClusterCtr;

  final RxString startDate = ''.obs;
  //select target
  final List<String> selectedTargetList = [
    'Revenue Targets',
    'Customer Targets',
  ];

  RxnString selectedTarget = RxnString();

  RxBool isRevenueVisible = true.obs;
  //
  final RxString endDate = ''.obs;
  final RxString startDateApi = ''.obs;
  final RxString endDateApi = ''.obs;
  final DateFormat dateFormat = DateFormat('MMMM yyyy');
  final DateFormat apiDateFormat = DateFormat('yyyy-MM');

  var startTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var endTimeModel = ValidationModel(null, null, isValidate: false).obs;
  var districtModel = ValidationModel(null, null, isValidate: false).obs;
  var clusterModel = ValidationModel(null, null, isValidate: false).obs;

  RxBool isFormInvalidate = false.obs;
  RxBool isStartDateActive = true.obs;
  RxBool isStartDateSelected = false.obs;
  RxBool isDistrictSelected = false.obs;
  RxBool isClusterSelected = false.obs;

  RxString selectedDistrictId = ''.obs;
  RxString selectedClusterId = ''.obs;
  RxList districtListInt = [].obs;
  RxList clusterListInt = [].obs;

  // Dashboard data
  final Rx<Tiles?> tilesData = Rx<Tiles?>(null);
  final Rx<LeadsStatusDistribution?> leadsStatusDistribution =
      Rx<LeadsStatusDistribution?>(null);
  final Rx<LeadsByClusterBreakdown?> leadsByClusterBreakdown =
      Rx<LeadsByClusterBreakdown?>(null);
  final Rx<LeadsWonProgressOverTime?> leadsWonProgress =
      Rx<LeadsWonProgressOverTime?>(null);
  final Rx<RevenueVsTargetsComparison?> revenueVsTargets =
      Rx<RevenueVsTargetsComparison?>(null);

  RxString message = ''.obs;

  // Filter source and filtered data
  var currentFilterSource = [].obs;
  var filteredData = [].obs;

  // RxBool isRescoTileVisible = true.obs;
  // RxBool isPerformanceTileVisible = true.obs;
  // RxBool isKpiRevenueTileVisible = true.obs;
  // RxBool isRevenueTileVisible = true.obs;
  // RxBool isDashboard1Visible = true.obs;
  // RxBool isAddMeterReadings = true.obs;
  // RxBool isViewMeterReadings = true.obs;
  // RxBool isViewCustomer = true.obs;

  RxList<Cluster> districtList = <Cluster>[].obs;
  RxList<Cluster> clustersList = <Cluster>[].obs;

  @override
  void onInit() {
    super.onInit();
    startTimeNode = FocusNode();
    endTimeNode = FocusNode();
    districtNode = FocusNode();
    clusterNode = FocusNode();
    searchGroupNode = FocusNode();
    searchClusterNode = FocusNode();

    startTimeCtr = TextEditingController();
    endTimeCtr = TextEditingController();
    district = TextEditingController();
    clusterCtr = TextEditingController();
    searchDistrictCtr = TextEditingController();
    searchClusterCtr = TextEditingController();
  }

  @override
  void onClose() {
    startTimeNode.dispose();
    endTimeNode.dispose();
    districtNode.dispose();
    clusterNode.dispose();
    searchGroupNode.dispose();
    searchClusterNode.dispose();

    startTimeCtr.dispose();
    endTimeCtr.dispose();
    district.dispose();
    clusterCtr.dispose();
    searchDistrictCtr.dispose();
    searchClusterCtr.dispose();
    super.onClose();
  }

  // Future<void> getRights() async {
  //   User? user = await UserPreferences().getSignInInfo();
  //   List<String> rights = user?.rights ?? [];

  //   logcat('allrights 2:::', rights);

  //   // isRescoTileVisible.value = rights.contains("mobile_app_resco_tile");
  //   // isPerformanceTileVisible.value = rights.contains(
  //   //   "mobile_app_performance_tile",
  //   // );
  //   // isKpiRevenueTileVisible.value = rights.contains("mobile_app_kpi_tile");
  //   // isRevenueTileVisible.value = rights.contains("mobile_app_revenue_tile");
  //   // isDashboard1Visible.value = rights.contains(
  //   //   "mobile_app_dashboard_without_graph",
  //   // );
  //   // isAddMeterReadings.value = rights.contains("mobile_app_add_meter_reading");
  //   // isViewMeterReadings.value = rights.contains(
  //   //   "mobile_app_view_meter_reading",
  //   // );
  //   // isViewCustomer.value = rights.contains("mobile_app_customers");

  //   // logcat('User Rights', rights);
  //   // logcat('isRescoTileVisible', isRescoTileVisible.value);
  //   // logcat('isPerformanceTileVisible', isPerformanceTileVisible.value);
  //   // logcat('isKpiRevenueTileVisible', isKpiRevenueTileVisible.value);
  //   // logcat('isRevenueTileVisible', isRevenueTileVisible.value);
  //   // logcat('isDashboard1Visible', isDashboard1Visible.value);
  //   // logcat('isAddMeterReadings', isAddMeterReadings.value);
  //   // logcat('isViewMeterReadings', isViewMeterReadings.value);
  //   // logcat('isViewCustomer', isViewCustomer.value);
  // }

  void unfocusAll() => FocusManager.instance.primaryFocus?.unfocus();

  void resetSelectionFlags() {
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
  }

  void resetForm() {
    unfocusAll();
    startTimeCtr.clear();
    endTimeCtr.clear();
    district.clear();
    clusterCtr.clear();
    searchDistrictCtr.clear();
    searchClusterCtr.clear();
    selectedDistrictId.value = '';
    selectedClusterId.value = '';
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isStartDateSelected.value = false;
    isRevenueVisible.value = true;
    districtListInt.clear();
    clusterListInt.clear();

    // // Set current year and month as default on reset
    final now = DateTime.now();
    final displayFormatted = dateFormat.format(now);
    final apiFormatted = apiDateFormat.format(now);

    startDate.value = displayFormatted;
    startDateApi.value = apiFormatted;
    startTimeCtr.text = displayFormatted;
    startTimeModel.value = ValidationModel(
      displayFormatted,
      null,
      isValidate: true,
    );

    endDate.value = displayFormatted;
    endDateApi.value = apiFormatted;
    endTimeCtr.text = displayFormatted;
    endTimeModel.value = ValidationModel(
      displayFormatted,
      null,
      isValidate: true,
    );

    isStartDateSelected.value = true;
    startTimeModel.value = ValidationModel(null, null, isValidate: false);
    endTimeModel.value = ValidationModel(null, null, isValidate: false);
    districtModel.value = ValidationModel(null, null, isValidate: false);
    clusterModel.value = ValidationModel(null, null, isValidate: false);
    isFormInvalidate.value = false;

    enableSubmitButton();
    update();
  }

  void openFilterBottomSheet({required BuildContext context}) async {
    // Set current year and month as default
    final now = DateTime.now();
    final displayFormatted = dateFormat.format(now);
    final apiFormatted = apiDateFormat.format(now);

    // Prefill with current year and month if no previous selection
    if (startDate.value.isEmpty) {
      startDate.value = displayFormatted;
      startDateApi.value = apiFormatted;
      startTimeCtr.text = displayFormatted;
      startTimeModel.value = ValidationModel(
        displayFormatted,
        null,
        isValidate: true,
      );
    } else {
      startTimeCtr.text = startDate.value;
      startTimeModel.value = ValidationModel(
        startDate.value,
        null,
        isValidate: startDate.value.isNotEmpty,
      );
    }

    if (endDate.value.isEmpty) {
      endDate.value = displayFormatted;
      endDateApi.value = apiFormatted;
      endTimeCtr.text = displayFormatted;
      endTimeModel.value = ValidationModel(
        displayFormatted,
        null,
        isValidate: true,
      );
    } else {
      endTimeCtr.text = endDate.value;
      endTimeModel.value = ValidationModel(
        endDate.value,
        null,
        isValidate: endDate.value.isNotEmpty,
      );
    }

    // Prefill district and cluster fields
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

    districtModel.value = ValidationModel(
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
    isStartDateSelected.value = startDate.value.isNotEmpty;

    openBottomtsheetDialog(
      context,
      title: "Filter",
      onClosing: () {
        resetForm();
        getFillterOptions(context, showLoader: false);
        getDashboardData(context, isFirstTime: true);
      },
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

  void makeApiCall(context) {
    getDashboardData(context, issearch: true);
    print('API Start Date: ${startDateApi.value}');
    print('API End Date: ${endDateApi.value}');
    print('Selected District IDs: ${selectedDistrictId.value}');
    print('Selected Cluster IDs: ${selectedClusterId.value}');
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

        // Extract the inner 'data' object
        var innerData = data['data'];

        // Parse into your model
        FiltterData responseDetail = FiltterData.fromJson(innerData);

        districtList.addAll(responseDetail.districts);
        clustersList.addAll(responseDetail.clusters);

        logcat('District List', districtList.length.toString());
        logcat('Clusters List', clustersList.length.toString());

        // Prefill selectedClusterId with cluster ID from API request (e.g., "8")
        // if (selectedClusterId.value.isEmpty && clustersList.isNotEmpty) {
        //   final defaultCluster = clustersList.firstWhere(
        //     (cluster) => cluster.id.toString() == '8',
        //     orElse: () => clustersList.first,
        //   );
        //   selectedClusterId.value = defaultCluster.id.toString();
        //   clusterListInt.value = [defaultCluster.id];
        //   clusterCtr.text = defaultCluster.name;
        //   clusterModel.value = ValidationModel(
        //     defaultCluster.name,
        //     null,
        //     isValidate: true,
        //   );
        //   isClusterSelected.value = true;
        // }

        update();
      },
      networkManager: networkManager,
    );
  }

  Future<void> getDashboardData(
    BuildContext context, {
    bool isFirstTime = false,
    bool isApplyFilter = false,
    bool issearch = false,
    bool hideLoading = false,
  }) async {
    if (!hideLoading) {
      state.value = ScreenState.apiLoading;
    }

    if (issearch || isFirstTime) {
      tilesData.value = null;
      leadsStatusDistribution.value = null;
      leadsByClusterBreakdown.value = null;
      leadsWonProgress.value = null;
      revenueVsTargets.value = null;
    }

    if (isFirstTime && !isApplyFilter) {
      logcat("init", "Done");
      resetForm();
    }

    var loadingIndicator = LoadingProgressDialog();
    try {
      if (networkManager.connectionType.value == 0) {
        showDialogForScreen(
          context,
          'Dashboard Screen',
          'No internet connection',
          callback: () => Get.back(),
        );
        return;
      }

      User? userData = await UserPreferences().getSignInInfo();
      if (userData == null || userData.userId == null) return;

      // Use current year and month if not set
      final now = DateTime.now();
      if (startDateApi.value.isEmpty) {
        startDateApi.value =
            '${now.year}-${now.month.toString().padLeft(2, '0')}';
      }
      if (endDateApi.value.isEmpty) {
        endDateApi.value = startDateApi.value;
      }

      logcat('Start Date:', startDateApi.value);
      logcat('End Date:', endDateApi.value);

      loadingIndicator.show(context, '');

      final Map<String, dynamic> body = {
        'user_id': userData.userId,
        'startYear': startDateApi.value.split('-')[0],
        'startMonth': startDateApi.value.split('-')[1],
        'endYear': endDateApi.value.split('-')[0],
        'endMonth': endDateApi.value.split('-')[1],
      };

      if (districtListInt.isNotEmpty) {
        body['districtIds'] = districtListInt.map((e) => e.toString()).toList();
      }
      if (clusterListInt.isNotEmpty) {
        body['clusterIds'] = clusterListInt.map((e) => e.toString()).toList();
      }
      logcat('Final API Request Body', jsonEncode(body));

      final response = await Repository.post(
        body,
        ApiUrl.graphicaldashboard,
        allowHeader: true,
      );

      logcat('RESPONSE::', response.body);
      var responseData = jsonDecode(response.body);
      loadingIndicator.hide(context);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          state.value = ScreenState.apiSuccess;
          message.value = responseData['message'] ?? '';

          final Dashboard1Model responseDetail = Dashboard1Model.fromJson(
            responseData,
          );

          // Update dashboard data
          tilesData.value = responseDetail.tiles;
          leadsStatusDistribution.value =
              responseDetail.charts?.leadsStatusDistribution;
          leadsByClusterBreakdown.value =
              responseDetail.charts?.leadsByClusterBreakdown;
          leadsWonProgress.value =
              responseDetail.charts?.leadsWonProgressOverTime;
          revenueVsTargets.value =
              responseDetail.charts?.revenueVsTargetsComparison;

          update();
        } else {
          state.value = ScreenState.apiError;
          message.value = responseData['message'] ?? 'Unexpected server error';
          showDialogForScreen(
            context,
            'Dashboard Screen',
            responseData['message'] ?? 'Unexpected server error',
            callback: () {
              getUnauthenticatedUser(
                context,
                responseData['message'],
                'Unauthenticated user',
              );
            },
          );
        }
      } else {
        state.value = ScreenState.apiError;
        message.value = 'Server returned an error. Please try again.';
        showDialogForScreen(
          context,
          'Dashboard Screen',
          responseData['message'] ?? 'Server returned an error',
          callback: () {
            getUnauthenticatedUser(
              context,
              responseData['message'],
              'Unauthenticated user',
            );
          },
        );
      }
    } catch (e, st) {
      logcat('getDashboardData error', e);
      logcat('stacktrace', st);
      loadingIndicator.hide(context);
      state.value = ScreenState.apiError;
      message.value = 'Failed to load dashboard data';
      showDialogForScreen(
        context,
        'Dashboard Screen',
        'Failed to load data. Please try again.',
        callback: () {},
      );
    }
  }
}
