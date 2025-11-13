import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/ViewCustomerModel.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/log.dart';
import '../../configs/apicall_constant.dart';
import '../master_controller/Master_Controller.dart';

class ViewCustomerController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxBool isFormInvalidate = false.obs;
  final ScrollController scrollController = ScrollController();
  RxString message = ''.obs;
  late FocusNode companyNameNode,
      personNameNode,
      mobileNode,
      addressNode,
      countryNode,
      stateNode,
      districtNode,
      latitudeNode,
      longitudeNode,
      customerStatusNode,
      conversionDateNode,
      liveAtNode,
      leadIdNode,
      deliveryDateNode,
      warrantyTypeNode,
      warrantyStartNode,
      warrantyPeriodNode,
      expiryNode,
      installationNode;

  // Text controllers
  late TextEditingController companyNameCtr,
      personNameCtr,
      mobileCtr,
      addressCtr,
      countryCtr,
      stateCtr,
      districtCtr,
      latitudeCtr,
      longitudeCtr,
      customerStatusCtr,
      conversionDateCtr,
      liveAtCtr,
      leadIdCtr,
      deliveryDateCtr,
      warrantyTypeCtr,
      warrantyStartCtr,
      warrantyPeriodCtr,
      expiryCtr,
      installationCtr;

  // Validation models
  var companynameModel = ValidationModel(null, null, isValidate: false).obs;
  var personNameModel = ValidationModel(null, null, isValidate: false).obs;
  var mobileModel = ValidationModel(null, null, isValidate: false).obs;
  var addressModel = ValidationModel(null, null, isValidate: false).obs;
  var countryModel = ValidationModel(null, null, isValidate: false).obs;
  var stateModel = ValidationModel(null, null, isValidate: false).obs;
  var districtModel = ValidationModel(null, null, isValidate: false).obs;
  var latitudeModel = ValidationModel(null, null, isValidate: false).obs;
  var longitudeModel = ValidationModel(null, null, isValidate: false).obs;
  var customerStatusModel = ValidationModel(null, null, isValidate: false).obs;
  var conversionDateModel = ValidationModel(null, null, isValidate: false).obs;
  var liveAtModel = ValidationModel(null, null, isValidate: false).obs;
  var leadIdModel = ValidationModel(null, null, isValidate: false).obs;
  var deliveryDateModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyTypeModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyStartModel = ValidationModel(null, null, isValidate: false).obs;
  var warrantyPeriodModel = ValidationModel(null, null, isValidate: false).obs;
  var expiryModel = ValidationModel(null, null, isValidate: false).obs;
  var installationModel = ValidationModel(null, null, isValidate: false).obs;
  RxBool isCustomerApiCallLoading = false.obs;
  RxBool isViewMeterReadings = false.obs;

  var currentFilterSource = [].obs;
  var filteredData = [].obs;

  Future<void> getRights() async {
    User? user = await UserPreferences().getSignInInfo();
    List<String> rights = user?.rights ?? [];

    isViewMeterReadings.value = rights.contains(
      "mobile_app_view_meter_reading",
    );
    logcat('mobile_app_view_meter_reading is:::', isViewMeterReadings);
  }

  @override
  void onInit() {
    super.onInit();
    getRights();
    // Initialize FocusNodes
    companyNameNode = FocusNode();
    personNameNode = FocusNode();
    mobileNode = FocusNode();
    addressNode = FocusNode();
    countryNode = FocusNode();
    stateNode = FocusNode();
    districtNode = FocusNode();
    latitudeNode = FocusNode();
    longitudeNode = FocusNode();
    customerStatusNode = FocusNode();
    conversionDateNode = FocusNode();
    liveAtNode = FocusNode();
    leadIdNode = FocusNode();
    deliveryDateNode = FocusNode();
    warrantyTypeNode = FocusNode();
    warrantyStartNode = FocusNode();
    warrantyPeriodNode = FocusNode();
    expiryNode = FocusNode();
    installationNode = FocusNode();
    // Initialize TextControllers
    companyNameCtr = TextEditingController();
    personNameCtr = TextEditingController();
    mobileCtr = TextEditingController();
    addressCtr = TextEditingController();
    countryCtr = TextEditingController();
    stateCtr = TextEditingController();
    districtCtr = TextEditingController();
    latitudeCtr = TextEditingController();
    longitudeCtr = TextEditingController();
    customerStatusCtr = TextEditingController();
    conversionDateCtr = TextEditingController();
    liveAtCtr = TextEditingController();
    leadIdCtr = TextEditingController();
    deliveryDateCtr = TextEditingController();
    warrantyTypeCtr = TextEditingController();
    warrantyStartCtr = TextEditingController();
    warrantyPeriodCtr = TextEditingController();
    expiryCtr = TextEditingController();
    installationCtr = TextEditingController();
  }

  @override
  void onClose() {
    // Dispose FocusNodes
    companyNameNode.dispose();
    personNameNode.dispose();
    mobileNode.dispose();
    addressNode.dispose();
    countryNode.dispose();
    stateNode.dispose();
    districtNode.dispose();
    latitudeNode.dispose();
    longitudeNode.dispose();
    customerStatusNode.dispose();
    conversionDateNode.dispose();
    liveAtNode.dispose();
    leadIdNode.dispose();
    deliveryDateNode.dispose();
    warrantyTypeNode.dispose();
    warrantyStartNode.dispose();
    warrantyPeriodNode.dispose();
    expiryNode.dispose();
    installationNode.dispose();

    // Dispose Controllers
    companyNameCtr.dispose();
    personNameCtr.dispose();
    mobileCtr.dispose();
    addressCtr.dispose();
    countryCtr.dispose();
    stateCtr.dispose();
    districtCtr.dispose();
    latitudeCtr.dispose();
    longitudeCtr.dispose();
    customerStatusCtr.dispose();
    conversionDateCtr.dispose();
    liveAtCtr.dispose();
    leadIdCtr.dispose();
    deliveryDateCtr.dispose();
    warrantyTypeCtr.dispose();
    warrantyStartCtr.dispose();
    warrantyPeriodCtr.dispose();
    expiryCtr.dispose();
    installationCtr.dispose();
    super.onClose();
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    unfocusAll();

    // Clear all inputs
    companyNameCtr.clear();
    personNameCtr.clear();

    // Reset validation states
    companynameModel.value = ValidationModel(null, null, isValidate: false);
    personNameModel.value = ValidationModel(null, null, isValidate: false);

    isFormInvalidate.value = false;
    update();
  }

  void validateFields(
    val, {
    required Rx<ValidationModel> model,
    errorText1,
    errorText2,
    errorText3,
    iscomman = false,
    isemail = false,
    ispassword = false,
  }) {
    return validateField(
      val: val,
      models: model,
      isEmail: isemail,
      iscomman: iscomman,
      errorText1: errorText1,
      errorText2: errorText2,
      errorText3: errorText3,
      ispassword: ispassword,
      notifyListeners: () {
        refresh();
      },
      enableBtnFunction: () {
        enableSubmitButton();
      },
    );
  }

  void enableSubmitButton() {
    isFormInvalidate.value =
        companynameModel.value.isValidate && personNameModel.value.isValidate;
    update();
  }

  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: primaryColor,
      colorText: white,
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

  RxString installationUrl = ''.obs;
  Future<void> getViewCustomer(
    context,
    bool isLoading,
    String customerid,
  ) async {
    var loadingIndicator = LoadingProgressDialog();
    // User? userData = await UserPreferences().getSignInInfo();
    commonGetApiCallFormate(
      context,
      title: 'View Customer Screen',
      apiEndPoint: "${ApiUrl.getCustomerList}/$customerid",
      allowHeader: true,
      state: state,
      message: message,
      apisLoading: (isTrue) {
        if (isLoading == true) {
          if (isTrue) {
            loadingIndicator.show(context, '');
          } else {
            loadingIndicator.hide(context);
          }
        }
      },
      onResponse: (data) {
        personNameCtr.clear();
        var responseDetail = ViewCustomerModel.fromJson(data);
        setCustomerData(responseDetail.data);
        logcat("customerResponse", jsonEncode(responseDetail.data));
        update();
      },
      networkManager: networkManager,
    );
  }

  void setCustomerData(ViewCustomerData data) {
    companyNameCtr.text = data.companyName;
    personNameCtr.text = data.contactPersonName;
    mobileCtr.text = data.contactPersonMobile;
    addressCtr.text = data.address;
    countryCtr.text = data.countryName;
    stateCtr.text = data.stateName;
    districtCtr.text = data.districtName;
    latitudeCtr.text = data.latitude;
    longitudeCtr.text = data.longitude;
    customerStatusCtr.text = data.customerStatusFormatted;
    conversionDateCtr.text = data.conversionDateFormatted;
    liveAtCtr.text = data.liveAtFormatted;
    leadIdCtr.text = data.leadId.toString();
    deliveryDateCtr.text = data.expectedDeliveryDateFormatted;
    warrantyPeriodCtr.text = data.warrantyPeriod.toString();
    warrantyTypeCtr.text = data.warrantyTypeFormatted;
    warrantyStartCtr.text = data.warrantyStartDateFormatted;
    expiryCtr.text = data.warrantyEndDateFormatted;

    // Installation certificate
    if (data.hasInstallationCertificate &&
        data.installationCertificate!.path.isNotEmpty) {
      logcat(
        "installationCertificat::",
        data.installationCertificate!.path.toString(),
      );
      installationUrl.value = data.installationCertificate!.path;
      // installationCtr.text = "View File";
      installationCtr.text = "Uploaded";
    } else {
      installationCtr.text = "Not Uploaded";
    }

    update(); // refresh Obx widgets
  }
}
