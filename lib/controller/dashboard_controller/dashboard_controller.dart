import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/ClusterData.dart';
import 'package:sales_app/models/dashboard1_model.dart';
import 'package:sales_app/models/fillter_model.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/month_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/view/dashboard_screen/widgets/dashboard_widgets.dart';

import '../../api_handle/Repository.dart';
import '../../configs/apicall_constant.dart';
import '../master_controller/Master_Controller.dart';

class DashboardController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();

  Rx<ScreenState> state = ScreenState.apiLoading.obs;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter-related variables
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

  RxBool isFormInvalidate = false.obs;
  RxBool isStartDateActive = true.obs;
  RxBool isStartDateSelected = false.obs;
  RxBool isDistrictSelected = false.obs;
  RxBool isClusterSelected = false.obs;

  RxString selectedDistrictId = ''.obs;
  RxString selectedClusterId = ''.obs;
  RxList districtListInt = [].obs;
  RxList categoryListInt = [].obs;
  RxList clusterListInt = [].obs;
  RxList customerListInt = [].obs;

  // Chart pagination
  final int pageSize = 10;
  final RxInt chartPage = 0.obs;
  final RxInt revenuePage = 0.obs;
  final RxInt unitPage = 0.obs;
  final RxInt kpiPage = 0.obs;

  // Chart data lists using BilledUnit
  RxList<BilledUnit> data = <BilledUnit>[].obs;
  RxList<BilledUnit> revenueData = <BilledUnit>[].obs;
  RxList<BilledUnit> unitData = <BilledUnit>[].obs;
  RxList<BilledUnit> kpiRevenueData = <BilledUnit>[].obs;

  // Tile data
  final Rx<Tiles?> tilesData = Rx<Tiles?>(null);
  final Rx<Resco?> resco = Rx<Resco?>(null);
  final Rx<Performance?> performance = Rx<Performance?>(null);
  final Rx<Kpi?> kpi = Rx<Kpi?>(null);
  final Rx<Revenue?> revenue = Rx<Revenue?>(null);
  RxString message = ''.obs;

  // Filter source and filtered data
  var currentFilterSource = [].obs;
  var filteredData = [].obs;

  RxBool isRescoTileVisible = true.obs;
  RxBool isPerformanceTileVisible = true.obs;
  RxBool isKpiRevenueTileVisible = true.obs;
  RxBool isRevenueTileVisible = true.obs;
  RxBool isDashboard1Visible = true.obs;

  RxBool isAddMeterReadings = true.obs;
  RxBool isViewMeterReadings = true.obs;
  RxBool isViewCustomer = true.obs;

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

  Future<void> getRights() async {
    User? user = await UserPreferences().getSignInInfo();
    List<String> rights = user?.rights ?? [];

    logcat('allrights 2:::', rights);

    isRescoTileVisible.value = rights.contains("mobile_app_resco_tile");
    isPerformanceTileVisible.value = rights.contains(
      "mobile_app_performance_tile",
    );
    isKpiRevenueTileVisible.value = rights.contains("mobile_app_kpi_tile");
    isRevenueTileVisible.value = rights.contains("mobile_app_revenue_tile");
    isDashboard1Visible.value = rights.contains(
      "mobile_app_dashboard_without_graph",
    );
    isAddMeterReadings.value = rights.contains("mobile_app_add_meter_reading");
    isViewMeterReadings.value = rights.contains(
      "mobile_app_view_meter_reading",
    );
    isViewCustomer.value = rights.contains("mobile_app_customers");

    // Final logging at the end
    logcat('User Rights', rights);
    logcat('isRescoTileVisible', isRescoTileVisible.value);
    logcat('isPerformanceTileVisible', isPerformanceTileVisible.value);
    logcat('isKpiRevenueTileVisible', isKpiRevenueTileVisible.value);
    logcat('isRevenueTileVisible', isRevenueTileVisible.value);
    logcat('isDashboard1Visible', isDashboard1Visible.value);
    logcat('isAddMeterReadings', isAddMeterReadings.value);
    logcat('isViewMeterReadings', isViewMeterReadings.value);
    logcat('isViewCustomer', isViewCustomer.value);
  }

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
    data.clear();
    revenueData.clear();
    unitData.clear();
    kpiRevenueData.clear();
    chartPage.value = 0;
    revenuePage.value = 0;
    unitPage.value = 0;
    kpiPage.value = 0;
    startTimeModel.value = ValidationModel(null, null, isValidate: false);
    endTimeModel.value = ValidationModel(null, null, isValidate: false);
    disitrict.value = ValidationModel(null, null, isValidate: false);
    categoryModel.value = ValidationModel(null, null, isValidate: false);
    clusterModel.value = ValidationModel(null, null, isValidate: false);
    customerModel.value = ValidationModel(null, null, isValidate: false);
    isFormInvalidate.value = false;
    update();
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

    // getFillterOptions(context);

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

  final List<LeadData> leadData = [
    LeadData('New Lead', 34, Colors.lightBlueAccent),
    LeadData('Contacted', 4, Colors.orange),
    LeadData('Proposal Sent', 4, Colors.amber),
    LeadData('Qualified', 4, Colors.green),
    LeadData('Won', 50, Colors.blue),
    LeadData('Lost', 4, Colors.red),
  ].obs;

  List<ClusterData> clusterData = [
    ClusterData(
      clusterName: 'Cluster 1',
      leads: 9,
      won: 4,
      lost: 0,
      ongoing: 5,
    ),
    ClusterData(
      clusterName: 'Cluster 2',
      leads: 9,
      won: 2,
      lost: 0,
      ongoing: 6,
    ),
    ClusterData(
      clusterName: 'Cluster 3',
      leads: 9,
      won: 4,
      lost: 0,
      ongoing: 5,
    ),
    ClusterData(
      clusterName: 'Cluster 4',
      leads: 9,
      won: 4,
      lost: 0,
      ongoing: 5,
    ),
  ].obs;

  final List<LeadsWonData> leadWonData = [
    LeadsWonData(clusterName: 'WK-1', won: 0),
    LeadsWonData(clusterName: 'WK-2', won: 0),
    LeadsWonData(clusterName: 'WK-3', won: 12),
    LeadsWonData(clusterName: 'WK-4', won: 13),
    LeadsWonData(clusterName: 'WK-5', won: 0),
  ];

  final List<RevenueData> revenuesData = [
    RevenueData(clusterName: 'Cluster 1', target: 600000, achieved: 156000),
    RevenueData(clusterName: 'Cluster 2', target: 400000, achieved: 1005000),
    RevenueData(clusterName: 'Cluster 3', target: 200000, achieved: 0),
    RevenueData(clusterName: 'Cluster 4', target: 200000, achieved: 60000),
  ].obs;

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
    getDashboardData(context, 1, issearch: true);
    print('API Start Date: ${startDateApi.value}');
    print('API End Date: ${endDateApi.value}');
    print('Selected Group IDs: ${selectedDistrictId.value}');
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

  Future<void> getFillterOptions(context) async {
    User? userData = await UserPreferences().getSignInInfo();
    var loadingIndicator = LoadingProgressDialog();
    commonGetApiCallFormate(
      context,
      title: 'Dashboard Screen',
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

  Future<void> getCurrentMonth(BuildContext context) async {
    if (networkManager.connectionType.value == 0) {
      showDialogForScreen(
        context,
        'Dashboard',
        "No internet connection",
        callback: () => Get.back(),
      );
      return;
    }

    try {
      state.value = ScreenState.apiLoading;

      final response = await Repository.get(
        {},
        ApiUrl.getbillingMonth,
        allowHeader: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final MonthModel model = MonthModel.fromJson(jsonData);
        logcat('date is:::', model.previousMonthYear);
        await UserPreferences().setDate(model.previousMonthYear);

        state.value = ScreenState.apiSuccess;
        message.value = '';
      } else {
        state.value = ScreenState.apiError;
        message.value = "Unexpected server error";

        showDialogForScreen(
          context,
          "Dashboard",
          "Server returned an error. Please try again.",
          callback: () {},
        );
      }
    } catch (e) {
      state.value = ScreenState.apiError;
      message.value = "Something went wrong";

      showDialogForScreen(
        context,
        "Dashboard",
        "Failed to load billing month.",
        callback: () {},
      );

      print("getCurrentMonth Exception: $e");
    }
  }

  Future<void> getDashboardData(
    BuildContext context,
    int page, {
    bool isFirstTime = false,
    bool issearch = false,
    bool hideLoading = false,
  }) async {
    if (hideLoading == false) {
      state.value = ScreenState.apiLoading;
    }

    if (issearch || isFirstTime) {
      data.clear();
      revenueData.clear();
      unitData.clear();
      kpiRevenueData.clear();
      chartPage.value = 0;
      revenuePage.value = 0;
      unitPage.value = 0;
      kpiPage.value = 0;
    }

    if (isFirstTime) {
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

      // Fetch previousMonthYear from SharedPreferences and assign to both start and end
      final previousMonth = await UserPreferences().getDate();
      if (previousMonth != null && previousMonth.isNotEmpty) {
        startDateApi.value = previousMonth;
        endDateApi.value = previousMonth;
      }

      logcat('Start Date from SharedPref:', startDateApi.value);
      logcat('End Date from SharedPref:', endDateApi.value);

      loadingIndicator.show(context, '');

      final Map<String, dynamic> body = {'user_id': userData.userId};

      if (districtListInt.isNotEmpty) body['groups'] = districtListInt;
      if (clusterListInt.isNotEmpty) body['clusters'] = clusterListInt;
      if (customerListInt.isNotEmpty) body['customers'] = customerListInt;
      if (startDateApi.isNotEmpty) body['startMonthYear'] = startDateApi.value;
      if (endDateApi.isNotEmpty) body['endMonthYear'] = endDateApi.value;

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
        if (responseData['status'] == true) {
          state.value = ScreenState.apiSuccess;
          message.value = '';

          final Dashboard1Model responseDetail = Dashboard1Model.fromJson(
            responseData,
          );

          // Update tiles
          final tiles = responseDetail.result.tiles;
          tilesData.value = tiles;
          resco.value = tiles.resco;
          performance.value = tiles.performance;
          kpi.value = tiles.kpi;
          revenue.value = tiles.revenue;

          // Update chart data
          data.value = responseDetail.result.graphs.sgf;
          revenueData.value = responseDetail.result.graphs.revenue;
          unitData.value = responseDetail.result.graphs.billedUnit;
          kpiRevenueData.value = responseDetail.result.graphs.kpi;

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

  List<BilledUnit> get paginatedChartData =>
      data.skip(chartPage.value * pageSize).take(pageSize).toList();
  List<BilledUnit> get paginatedRevenueData =>
      revenueData.skip(revenuePage.value * pageSize).take(pageSize).toList();
  List<BilledUnit> get paginatedUnitData =>
      unitData.skip(unitPage.value * pageSize).take(pageSize).toList();
  List<BilledUnit> get paginatedKpiData =>
      kpiRevenueData.skip(kpiPage.value * pageSize).take(pageSize).toList();

  int get maxChartPage => (data.length / pageSize).ceil();
  int get maxRevenuePage => (revenueData.length / pageSize).ceil();
  int get maxUnitPage => (unitData.length / pageSize).ceil();
  int get maxKpiPage => (kpiRevenueData.length / pageSize).ceil();
}
