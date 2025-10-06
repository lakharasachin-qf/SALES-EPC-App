import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:file_picker/file_picker.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/LoadElement.dart';
import 'package:sales_app/models/customer_model_wo_p.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/view/add_leads_screen/validateFileds.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});
}

class UploadFile {
  final String uploadFile;
  final String category;

  UploadFile({required this.uploadFile, required this.category});
}

class AddLeadsController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = "".obs;

  // Step-specific validation flags
  RxBool isStep1Valid = false.obs;
  RxBool isStep2Valid = false.obs;
  RxBool isStep3Valid = true.obs; // Load Element is optional
  RxBool isStep4Valid = true.obs; // Files are optional

  final ScrollController scrollController = ScrollController();
  RxBool isDesignationApiCallLoading = false.obs;
  RxBool isCountryApiCallLoading = false.obs;
  RxBool isAddOnApiCallLoading = false.obs;
  var isAboutUsApiCallLoading = false.obs;
  RxString designationId = ''.obs;
  RxString addOnId = ''.obs;
  RxString addOnTicketId = ''.obs;
  RxString countryId = ''.obs;
  var aboutUsId = ''.obs;
  RxList designationDynamicFilterList = [].obs;
  RxList designationDynamicList = [].obs;
  RxBool isDynamicDesignationApiCallLoading = false.obs;
  var productDetailList = <LoadElement>[].obs;
  var fileList = <UploadFile>[].obs;
  var hearAboutUsList = <String>[].obs;
  var countryList = <String>['Usa', 'India'].obs;
  var requiredSolutuionList = <String>['Usa', 'India'].obs;
  var solutuionList = <String>['Usa', 'India'].obs;
  var stateList = <String>['Usa', 'India'].obs;
  var districtList = <String>['Usa', 'India'].obs;
  DateTime? selectedDateTime;
  final RxString startDate = ''.obs;

  late List<DataColumn> leadsColumns = [
    setColumn("Sr"),
    setColumn("Action"),
    setColumn("Device Name"),
    setColumn("Category"),
    setColumn("Power (W)"),
    setColumn("Usage (hrs)"),
    setColumn("Energy (Wh)"),
    setColumn("Energy (KWh)"),
  ];

  late List<DataColumn> uploadColumns = [
    setColumn("Sr"),
    setColumn("Action"),
    setColumn("File"),
    setColumn("Category"),
  ];

  DataColumn setColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  void addLoad(LoadElement element) {
    productDetailList.add(element);
    validateStep3();
    update();
  }

  void updateLoad(int index, LoadElement element) {
    productDetailList[index] = element;
    validateStep3();
    update();
  }

  void deleteLoad(int index) {
    productDetailList.removeAt(index);
    validateStep3();
    update();
  }

  void addFile(UploadFile file) {
    fileList.add(file);
    validateStep4();
    update();
  }

  void updateFile(int index, UploadFile file) {
    fileList[index] = file;
    validateStep4();
    update();
  }

  void deleteFile(int index) {
    fileList.removeAt(index);
    validateStep4();
    update();
  }

  // Controllers
  late TextEditingController companyNameCtr,
      addressCtr,
      countryCtr,
      countrySearchCtr,
      stateCtr,
      stateSearchCtr,
      districtCtr,
      districtSearchCtr,
      personNameCtr,
      personMobileCtr,
      latitudeCtr,
      longitudeCtr,
      requiredSolutionTypeCtr,
      requiredSolutionCtr,
      leadCategoryCtr,
      dgCapacityCtr,
      dgSyncCtr,
      installedSolarCapCtr,
      sanctionedLoadCtr,
      vfdCtr,
      gridAvailabilityCtr,
      peakMonthlyEnergyCtr,
      requiredSolarCapCtr,
      distanceToTransformerCtr,
      ratingOfTransformerCtr,
      purposeOfSolarizationCtr,
      distInverterACDBCtr,
      distSolarACDBCtr,
      buildingHeightCtr,
      roofSizeLengthCtr,
      roofSizeBreadthCtr,
      roofNatureCtr,
      ageOfMetalSheetCtr,
      groundSizeLengthCtr,
      groundSizeBreadthCtr,
      otherRemarksCtr,
      scheduleMeetingCtr;

  // FocusNodes
  late FocusNode companyNameNode,
      addressNode,
      countryNode,
      countrySearchNode,
      stateNode,
      stateSearchNode,
      districtNode,
      districtSearchNode,
      personNameNode,
      personMobileNode,
      latitudeNode,
      longitudeNode,
      requiredSolutionTypeNode,
      requiredSolutionNode,
      leadCategoryNode,
      dgCapacityNode,
      dgSyncNode,
      installedSolarCapNode,
      sanctionedLoadNode,
      vfdNode,
      gridAvailabilityNode,
      peakMonthlyEnergyNode,
      requiredSolarCapNode,
      distanceToTransformerNode,
      ratingOfTransformerNode,
      purposeOfSolarizationNode,
      distInverterACDBNode,
      distSolarACDBNode,
      buildHeightNode,
      roofSizeLengthNode,
      roofSizeBreadthNode,
      roofNatureNode,
      ageOfMetalSheetNode,
      groundSizeLengthNode,
      groundSizeBreadthNode,
      otherRemarksNode,
      scheduleMeetingNode;

  // Validation Models
  var companyNameModel = ValidationModel(null, null, isValidate: false).obs;
  var addressModel = ValidationModel(null, null, isValidate: false).obs;
  var countryModel = ValidationModel(null, null, isValidate: false).obs;
  var countrySearchModel = ValidationModel(null, null, isValidate: false).obs;
  var stateModel = ValidationModel(null, null, isValidate: false).obs;
  var stateSearchModel = ValidationModel(null, null, isValidate: false).obs;
  var districtModel = ValidationModel(null, null, isValidate: false).obs;
  var districtSearchModel = ValidationModel(null, null, isValidate: false).obs;
  var personNameModel = ValidationModel(null, null, isValidate: false).obs;
  var personMobileModel = ValidationModel(null, null, isValidate: false).obs;
  var latitudeModel = ValidationModel(
    null,
    null,
    isValidate: true,
  ).obs; // Optional
  var longitudeModel = ValidationModel(
    null,
    null,
    isValidate: true,
  ).obs; // Optional
  var requiredSolutionTypeModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var requiredSolutionModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var leadCategoryModel = ValidationModel(null, null, isValidate: false).obs;
  var dgCapacityModel = ValidationModel(
    null,
    null,
    isValidate: true,
  ).obs; // Optional
  var dgSyncModel = ValidationModel(null, null, isValidate: false).obs;
  var installedSolarCapModel = ValidationModel(
    null,
    null,
    isValidate: true,
  ).obs; // Optional
  var sanctionedLoadModel = ValidationModel(
    null,
    null,
    isValidate: true,
  ).obs; // Optional
  var vfdModel = ValidationModel(null, null, isValidate: false).obs;
  var gridAvailabilityModel = ValidationModel(
    null,
    null,
    isValidate: true,
  ).obs; // Optional
  var peakMonthlyEnergyModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var requiredSolarCapModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var distanceToTransformerModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var ratingOfTransformerModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var purposeOfSolarizationModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var distInverterACDBModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var distSolarACDBModel = ValidationModel(null, null, isValidate: false).obs;
  var buildingHeightModel = ValidationModel(null, null, isValidate: false).obs;
  var roofSizeLengthModel = ValidationModel(null, null, isValidate: false).obs;
  var roofSizeBreadthModel = ValidationModel(null, null, isValidate: false).obs;
  var roofNatureModel = ValidationModel(null, null, isValidate: false).obs;
  var ageOfMetalSheetModel = ValidationModel(null, null, isValidate: false).obs;
  var groundSizeLengthModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var groundSizeBreadthModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var otherRemarksModel = ValidationModel(null, null, isValidate: false).obs;
  var scheduleMeeeingModel = ValidationModel(null, null, isValidate: false).obs;

  final List<String> dgSync = ['Yes', 'No'];
  String? selectDgSync;
  final List<String> vfd = ['Yes', 'No'];
  String? selectVfd;

  // Dynamic Lead Element
  late TextEditingController deviceNameCtr,
      categoryCtr,
      powerCtr,
      usageHrsCtr,
      energyWhCtr,
      energyKWhCtr;

  late FocusNode deviceNameNode,
      categorysNode,
      powerNode,
      usageHrsNode,
      energyWhNode,
      energyKWhNode;

  var deviceNameModel = ValidationModel(null, null, isValidate: false).obs;
  var categoryModel = ValidationModel(null, null, isValidate: false).obs;
  var powerModel = ValidationModel(null, null, isValidate: false).obs;
  var usageHrsModel = ValidationModel(null, null, isValidate: false).obs;
  var energyWhModel = ValidationModel(null, null, isValidate: false).obs;
  var energyKWhModel = ValidationModel(null, null, isValidate: false).obs;

  // Dynamic File Upload
  late TextEditingController uploadFileCtr,
      uploadCategoryCtr,
      searchUploadCategoryCtr;

  late FocusNode uploadFileNode, uploadCategoryNode, searchUploadCategoryNode;

  var uploadFileModel = ValidationModel(null, null, isValidate: false).obs;
  var uploadCategoryModel = ValidationModel(null, null, isValidate: false).obs;
  var searchUploadCategoryModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;

  // Category List
  RxList<CategoryModel> categoryList = <CategoryModel>[
    CategoryModel(id: "1", name: "Invoice"),
    CategoryModel(id: "2", name: "Bills"),
    CategoryModel(id: "3", name: "Reports"),
    CategoryModel(id: "4", name: "Others"),
  ].obs;

  var currentFilterSource = [].obs;
  var filteredData = [].obs;
  RxString categoryId = "".obs;

  @override
  void onInit() {
    // Initialize Controllers
    companyNameCtr = TextEditingController();
    addressCtr = TextEditingController();
    countryCtr = TextEditingController();
    countrySearchCtr = TextEditingController();
    stateCtr = TextEditingController();
    stateSearchCtr = TextEditingController();
    districtCtr = TextEditingController();
    districtSearchCtr = TextEditingController();
    personNameCtr = TextEditingController();
    personMobileCtr = TextEditingController();
    latitudeCtr = TextEditingController();
    longitudeCtr = TextEditingController();
    requiredSolutionTypeCtr = TextEditingController();
    requiredSolutionCtr = TextEditingController();
    leadCategoryCtr = TextEditingController();
    dgCapacityCtr = TextEditingController();
    dgSyncCtr = TextEditingController();
    installedSolarCapCtr = TextEditingController();
    sanctionedLoadCtr = TextEditingController();
    vfdCtr = TextEditingController();
    gridAvailabilityCtr = TextEditingController();
    peakMonthlyEnergyCtr = TextEditingController();
    requiredSolarCapCtr = TextEditingController();
    distanceToTransformerCtr = TextEditingController();
    ratingOfTransformerCtr = TextEditingController();
    purposeOfSolarizationCtr = TextEditingController();
    distInverterACDBCtr = TextEditingController();
    distSolarACDBCtr = TextEditingController();
    buildingHeightCtr = TextEditingController();
    roofSizeLengthCtr = TextEditingController();
    roofSizeBreadthCtr = TextEditingController();
    roofNatureCtr = TextEditingController();
    ageOfMetalSheetCtr = TextEditingController();
    groundSizeLengthCtr = TextEditingController();
    groundSizeBreadthCtr = TextEditingController();
    otherRemarksCtr = TextEditingController();
    scheduleMeetingCtr = TextEditingController();

    // Dynamic
    deviceNameCtr = TextEditingController();
    categoryCtr = TextEditingController();
    powerCtr = TextEditingController();
    usageHrsCtr = TextEditingController();
    energyWhCtr = TextEditingController();
    energyKWhCtr = TextEditingController();

    // Dynamic file choose
    uploadFileCtr = TextEditingController();
    uploadCategoryCtr = TextEditingController();
    searchUploadCategoryCtr = TextEditingController();

    // FocusNodes
    companyNameNode = FocusNode();
    addressNode = FocusNode();
    countryNode = FocusNode();
    countrySearchNode = FocusNode();
    stateNode = FocusNode();
    stateSearchNode = FocusNode();
    districtNode = FocusNode();
    districtSearchNode = FocusNode();
    personNameNode = FocusNode();
    personMobileNode = FocusNode();
    latitudeNode = FocusNode();
    longitudeNode = FocusNode();
    requiredSolutionTypeNode = FocusNode();
    requiredSolutionNode = FocusNode();
    leadCategoryNode = FocusNode();
    dgCapacityNode = FocusNode();
    dgSyncNode = FocusNode();
    installedSolarCapNode = FocusNode();
    sanctionedLoadNode = FocusNode();
    vfdNode = FocusNode();
    gridAvailabilityNode = FocusNode();
    peakMonthlyEnergyNode = FocusNode();
    requiredSolarCapNode = FocusNode();
    distanceToTransformerNode = FocusNode();
    ratingOfTransformerNode = FocusNode();
    purposeOfSolarizationNode = FocusNode();
    distInverterACDBNode = FocusNode();
    distSolarACDBNode = FocusNode();
    buildHeightNode = FocusNode();
    roofSizeLengthNode = FocusNode();
    roofSizeBreadthNode = FocusNode();
    roofNatureNode = FocusNode();
    ageOfMetalSheetNode = FocusNode();
    groundSizeLengthNode = FocusNode();
    groundSizeBreadthNode = FocusNode();
    otherRemarksNode = FocusNode();
    scheduleMeetingNode = FocusNode();

    // Dynamic
    deviceNameNode = FocusNode();
    categorysNode = FocusNode();
    powerNode = FocusNode();
    usageHrsNode = FocusNode();
    energyWhNode = FocusNode();
    energyKWhNode = FocusNode();

    // Dynamic upload file
    uploadFileNode = FocusNode();
    uploadCategoryNode = FocusNode();
    searchUploadCategoryNode = FocusNode();

    update();
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    // Dispose controllers
    companyNameCtr.dispose();
    addressCtr.dispose();
    countryCtr.dispose();
    countrySearchCtr.dispose();
    stateCtr.dispose();
    stateSearchCtr.dispose();
    districtCtr.dispose();
    districtSearchCtr.dispose();
    personNameCtr.dispose();
    personMobileCtr.dispose();
    latitudeCtr.dispose();
    longitudeCtr.dispose();
    requiredSolutionTypeCtr.dispose();
    requiredSolutionCtr.dispose();
    leadCategoryCtr.dispose();
    dgCapacityCtr.dispose();
    dgSyncCtr.dispose();
    installedSolarCapCtr.dispose();
    sanctionedLoadCtr.dispose();
    vfdCtr.dispose();
    gridAvailabilityCtr.dispose();
    peakMonthlyEnergyCtr.dispose();
    requiredSolarCapCtr.dispose();
    distanceToTransformerCtr.dispose();
    ratingOfTransformerCtr.dispose();
    purposeOfSolarizationCtr.dispose();
    distInverterACDBCtr.dispose();
    distSolarACDBCtr.dispose();
    buildingHeightCtr.dispose();
    roofSizeLengthCtr.dispose();
    roofSizeBreadthCtr.dispose();
    roofNatureCtr.dispose();
    ageOfMetalSheetCtr.dispose();
    groundSizeLengthCtr.dispose();
    groundSizeBreadthCtr.dispose();
    otherRemarksCtr.dispose();
    scheduleMeetingCtr.dispose();
    deviceNameCtr.dispose();
    categoryCtr.dispose();
    powerCtr.dispose();
    usageHrsCtr.dispose();
    energyWhCtr.dispose();
    energyKWhCtr.dispose();
    uploadFileCtr.dispose();
    uploadCategoryCtr.dispose();
    searchUploadCategoryCtr.dispose();

    // Dispose focus nodes
    companyNameNode.dispose();
    addressNode.dispose();
    countryNode.dispose();
    countrySearchNode.dispose();
    stateNode.dispose();
    stateSearchNode.dispose();
    districtNode.dispose();
    districtSearchNode.dispose();
    personNameNode.dispose();
    personMobileNode.dispose();
    latitudeNode.dispose();
    longitudeNode.dispose();
    requiredSolutionTypeNode.dispose();
    requiredSolutionNode.dispose();
    leadCategoryNode.dispose();
    dgCapacityNode.dispose();
    dgSyncNode.dispose();
    installedSolarCapNode.dispose();
    sanctionedLoadNode.dispose();
    vfdNode.dispose();
    gridAvailabilityNode.dispose();
    peakMonthlyEnergyNode.dispose();
    requiredSolarCapNode.dispose();
    distanceToTransformerNode.dispose();
    ratingOfTransformerNode.dispose();
    purposeOfSolarizationNode.dispose();
    distInverterACDBNode.dispose();
    distSolarACDBNode.dispose();
    buildHeightNode.dispose();
    roofSizeLengthNode.dispose();
    roofSizeBreadthNode.dispose();
    roofNatureNode.dispose();
    ageOfMetalSheetNode.dispose();
    groundSizeLengthNode.dispose();
    groundSizeBreadthNode.dispose();
    otherRemarksNode.dispose();
    scheduleMeetingNode.dispose();
    deviceNameNode.dispose();
    categorysNode.dispose();
    powerNode.dispose();
    usageHrsNode.dispose();
    energyWhNode.dispose();
    energyKWhNode.dispose();
    uploadFileNode.dispose();
    uploadCategoryNode.dispose();
    searchUploadCategoryNode.dispose();

    super.dispose();
  }

  Widget setCountryListDialog() {
    return Obx(() {
      if (isCountryApiCallLoading.value == true) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isCountryApiCallLoading.value,
        );
      }
      return setDropDownContent(
        aboutUsFilterList,
        controller: countrySearchCtr,
        noDataLable: "No Country",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: aboutUsFilterList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(
                    horizontal: 0,
                    vertical: -4,
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                  ),
                  horizontalTitleGap: null,
                  minLeadingWidth: 5,
                  onTap: () async {
                    countryId.value = aboutUsFilterList[index];
                    countryCtr.text = aboutUsFilterList[index];
                    val.validateCountry(countryCtr.text);
                    Get.back();
                  },
                  title: Text(
                    aboutUsFilterList[index],
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: countrySearchNode,
          controller: countrySearchCtr,
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterforCountry(val.toString());
            update();
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: countrySearchModel.value.error,
        ),
      );
    });
  }

  void applyFilterforCountry(String keyword) {
    aboutUsFilterList.clear();
    if (keyword.isEmpty) {
      aboutUsFilterList.addAll(['USA', 'India', 'Canada']); // Mock data
    } else {
      aboutUsFilterList.addAll(
        ['USA', 'India', 'Canada']
            .where(
              (country) =>
                  country.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  final ValidateAddLeadfileds val = ValidateAddLeadfileds();
  // Validation Methods

  // Step-specific validation methods
  void validateStep1() {
    bool isValid = true;
    if (!companyNameModel.value.isValidate) isValid = false;
    if (!addressModel.value.isValidate) isValid = false;
    if (!countryModel.value.isValidate) isValid = false;
    if (!stateModel.value.isValidate) isValid = false;
    if (!districtModel.value.isValidate) isValid = false;
    if (!personNameModel.value.isValidate) isValid = false;
    if (!personMobileModel.value.isValidate) isValid = false;
    if (!requiredSolutionTypeModel.value.isValidate) isValid = false;
    if (!requiredSolutionModel.value.isValidate) isValid = false;
    if (!leadCategoryModel.value.isValidate) isValid = false;
    isStep1Valid.value = isValid;
    update();
  }

  void validateStep2() {
    bool isValid = true;
    if (!peakMonthlyEnergyModel.value.isValidate) isValid = false;
    if (!requiredSolarCapModel.value.isValidate) isValid = false;
    if (!distanceToTransformerModel.value.isValidate) isValid = false;
    if (!ratingOfTransformerModel.value.isValidate) isValid = false;
    if (!purposeOfSolarizationModel.value.isValidate) isValid = false;
    if (!distInverterACDBModel.value.isValidate) isValid = false;
    if (!distSolarACDBModel.value.isValidate) isValid = false;
    if (!buildingHeightModel.value.isValidate) isValid = false;
    if (!roofSizeLengthModel.value.isValidate) isValid = false;
    if (!roofSizeBreadthModel.value.isValidate) isValid = false;
    if (!roofNatureModel.value.isValidate) isValid = false;
    if (!ageOfMetalSheetModel.value.isValidate) isValid = false;
    if (!groundSizeLengthModel.value.isValidate) isValid = false;
    if (!groundSizeBreadthModel.value.isValidate) isValid = false;
    if (!otherRemarksModel.value.isValidate) isValid = false;
    if (!scheduleMeeeingModel.value.isValidate) isValid = false;
    isStep2Valid.value = isValid;
    update();
  }

  void validateStep3() {
    // Optional: Make mandatory if at least one load element is required
    isStep3Valid.value = productDetailList.isNotEmpty;
    update();
  }

  void validateStep4() {
    // Optional: Make mandatory if at least one file is required
    isStep4Valid.value = fileList.isNotEmpty;
    update();
  }

  // Check if all steps are valid for Submit button
  bool isFormValid() {
    return isStep1Valid.value &&
        isStep2Valid.value &&
        isStep3Valid.value &&
        isStep4Valid.value;
  }

  void openDatePicker({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required RxString dateRx,
    required Rx<ValidationModel> model,
    bool showTimePickers = true,
    bool isEndDate = false,
  }) {
    showCommonDatePicker(
      context: context,
      title: title,
      initialDate: dateRx.value.isNotEmpty
          ? DateTime.parse(dateRx.value)
          : null,
      minDate: isEndDate && startDate.value.isNotEmpty
          ? DateTime.parse(startDate.value)
          : null,
      showTimePickers: showTimePickers,
      onDatePicked: (DateTime date) {
        final formatted = date.toString();
        dateRx.value = formatted;
        controller.text = formatted;
        val.validateScheduleMeeting(controller.text);
      },
    );
  }

  addLoadElement(context, {LoadElement? loadElementItem, int? index}) async {
    if (loadElementItem != null) {
      deviceNameCtr.text = loadElementItem.deviceName;
      categoryCtr.text = loadElementItem.category;
      powerCtr.text = loadElementItem.power;
      usageHrsCtr.text = loadElementItem.usageHrs;
      energyWhCtr.text = loadElementItem.energyWh;
      energyKWhCtr.text = loadElementItem.energyKWh;
    } else {
      deviceNameCtr.clear();
      categoryCtr.clear();
      powerCtr.clear();
      usageHrsCtr.clear();
      energyWhCtr.clear();
      energyKWhCtr.clear();
    }
    var result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13.w)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
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
                                "Load Element",
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
                          getLable("Device Name"),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Obx(() {
                              return getReactiveFormField(
                                node: deviceNameNode,
                                controller: deviceNameCtr,
                                hintLabel: "Enter Device Name",
                                onChanged: (val) {
                                  deviceNameModel.update((model) {
                                    if (val == null || val.trim().isEmpty) {
                                      model!.error = "Device Name is required";
                                      model.isValidate = false;
                                    } else {
                                      model!.error = null;
                                      model.isValidate = true;
                                    }
                                  });
                                },
                                inputType: TextInputType.text,
                                formType: FieldType.text,
                                wantSuffix: false,
                                errorText: deviceNameModel.value.error,
                              );
                            }),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          getLable("Category"),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Obx(() {
                              return getReactiveFormField(
                                node: categorysNode,
                                controller: categoryCtr,
                                hintLabel: "Enter Category",
                                onChanged: (val) {
                                  categoryModel.update((model) {
                                    if (val == null || val.trim().isEmpty) {
                                      model!.error = "Category is required";
                                      model.isValidate = false;
                                    } else {
                                      model!.error = null;
                                      model.isValidate = true;
                                    }
                                  });
                                },
                                inputType: TextInputType.text,
                                formType: FieldType.text,
                                wantSuffix: false,
                                errorText: categoryModel.value.error,
                              );
                            }),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          getLable("Power (W)"),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Obx(() {
                              return getReactiveFormField(
                                node: powerNode,
                                controller: powerCtr,
                                hintLabel: "Enter Power (W)",
                                onChanged: (val) {
                                  powerModel.update((model) {
                                    if (val == null || val.trim().isEmpty) {
                                      model!.error = "Power is required";
                                      model.isValidate = false;
                                    } else if (double.tryParse(val) == null) {
                                      model!.error = "Enter valid power";
                                      model.isValidate = false;
                                    } else {
                                      model!.error = null;
                                      model.isValidate = true;
                                    }
                                  });
                                },
                                inputType: TextInputType.number,
                                formType: FieldType.text,
                                wantSuffix: false,
                                errorText: powerModel.value.error,
                              );
                            }),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          getLable("Usage (hrs)"),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Obx(() {
                              return getReactiveFormField(
                                node: usageHrsNode,
                                controller: usageHrsCtr,
                                hintLabel: "Enter Usage (hrs)",
                                onChanged: (val) {
                                  usageHrsModel.update((model) {
                                    if (val == null || val.trim().isEmpty) {
                                      model!.error = "Usage hours is required";
                                      model.isValidate = false;
                                    } else if (double.tryParse(val) == null) {
                                      model!.error = "Enter valid usage hours";
                                      model.isValidate = false;
                                    } else {
                                      model!.error = null;
                                      model.isValidate = true;
                                    }
                                  });
                                },
                                inputType: TextInputType.number,
                                formType: FieldType.text,
                                wantSuffix: false,
                                errorText: usageHrsModel.value.error,
                              );
                            }),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    getLable("Energy (Wh)"),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Obx(() {
                                        return getReactiveFormField(
                                          node: energyWhNode,
                                          controller: energyWhCtr,
                                          hintLabel: "Energy (Wh)",
                                          onChanged: (val) {
                                            energyWhModel.update((model) {
                                              if (val == null ||
                                                  val.trim().isEmpty) {
                                                model!.error =
                                                    "Energy (Wh) is required";
                                                model.isValidate = false;
                                              } else if (double.tryParse(val) ==
                                                  null) {
                                                model!.error =
                                                    "Enter valid energy (Wh)";
                                                model.isValidate = false;
                                              } else {
                                                model!.error = null;
                                                model.isValidate = true;
                                              }
                                            });
                                          },
                                          inputType: TextInputType.number,
                                          formType: FieldType.text,
                                          wantSuffix: false,
                                          errorText: energyWhModel.value.error,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              getDynamicSizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    getLable("Energy (KWh)"),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Obx(() {
                                        return getReactiveFormField(
                                          node: energyKWhNode,
                                          controller: energyKWhCtr,
                                          hintLabel: "Energy (KWh)",
                                          onChanged: (val) {
                                            energyKWhModel.update((model) {
                                              if (val == null ||
                                                  val.trim().isEmpty) {
                                                model!.error =
                                                    "Energy (KWh) is required";
                                                model.isValidate = false;
                                              } else if (double.tryParse(val) ==
                                                  null) {
                                                model!.error =
                                                    "Enter valid energy (KWh)";
                                                model.isValidate = false;
                                              } else {
                                                model!.error = null;
                                                model.isValidate = true;
                                              }
                                            });
                                          },
                                          inputType: TextInputType.number,
                                          formType: FieldType.text,
                                          wantSuffix: false,
                                          errorText: energyKWhModel.value.error,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
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
                                    if (deviceNameModel.value.isValidate &&
                                        categoryModel.value.isValidate &&
                                        powerModel.value.isValidate &&
                                        usageHrsModel.value.isValidate &&
                                        energyWhModel.value.isValidate &&
                                        energyKWhModel.value.isValidate) {
                                      final newElement = LoadElement(
                                        deviceName: deviceNameCtr.text,
                                        category: categoryCtr.text,
                                        power: powerCtr.text,
                                        usageHrs: usageHrsCtr.text,
                                        energyWh: energyWhCtr.text,
                                        energyKWh: energyKWhCtr.text,
                                      );
                                      if (index == null) {
                                        addLoad(newElement);
                                      } else {
                                        updateLoad(index, newElement);
                                      }
                                      Get.back();
                                    }
                                  },
                                  loadElementItem != null ? "Update" : 'Add',
                                  validate:
                                      deviceNameModel.value.isValidate &&
                                      categoryModel.value.isValidate &&
                                      powerModel.value.isValidate &&
                                      usageHrsModel.value.isValidate &&
                                      energyWhModel.value.isValidate &&
                                      energyKWhModel.value.isValidate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    getDynamicSizedBox(
                      height: 2.h,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null && result == true) {
      logcat("DismissDialog", 'DONE');
    }
  }

  addUploadFile(context, {UploadFile? fileItem, int? index}) async {
    if (fileItem != null) {
      uploadFileCtr.text = fileItem.uploadFile;
      uploadCategoryCtr.text = fileItem.category;
    } else {
      uploadFileCtr.clear();
      uploadCategoryCtr.clear();
    }
    var result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13.w)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
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
                                "Upload File",
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
                          Obx(() {
                            return getTextField(
                              context: context,
                              wantLabel: true,
                              label: 'Choose File',
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
                              isRequired: true,
                            );
                          }),
                          getDynamicSizedBox(height: 1.h),
                          Obx(() {
                            return getTextField(
                              context: context,
                              wantLabel: true,
                              label: 'Category',
                              ctr: uploadCategoryCtr,
                              node: uploadCategoryNode,
                              model: uploadCategoryModel.value,
                              isenable: false,
                              isdropdown: true,
                              wantsuffix: true,
                              usegesture: true,
                              gestureFunction: () {
                                showCategorySelectionPopups(context);
                              },
                              hint: 'Select Category',
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
                                    if (uploadFileModel.value.isValidate &&
                                        uploadCategoryModel.value.isValidate) {
                                      final newFile = UploadFile(
                                        uploadFile: uploadFileCtr.text,
                                        category: uploadCategoryCtr.text,
                                      );
                                      if (index == null) {
                                        addFile(newFile);
                                      } else {
                                        updateFile(index, newFile);
                                      }
                                      Get.back();
                                    }
                                  },
                                  fileItem != null ? "Update" : 'Add',
                                  validate:
                                      uploadFileModel.value.isValidate &&
                                      uploadCategoryModel.value.isValidate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    getDynamicSizedBox(
                      height: 2.h,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null && result == true) {
      logcat("DismissDialog", 'DONE');
    }
  }

  Future<void> pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      final fileName = result.files.single.name;
      uploadFileCtr.text = fileName;
      uploadFileModel.update((model) {
        if (fileName.isEmpty) {
          model!.error = "File is required";
          model.isValidate = false;
        } else {
          model!.error = null;
          model.isValidate = true;
        }
      });
      validateStep4();
      update();
    }
  }

  void showCategorySelectionPopups(BuildContext context) {
    currentFilterSource.value = List.from(categoryList);
    filteredData.value = List.from(categoryList);
    searchUploadCategoryCtr.clear();
    fetchSelectionPopup<CategoryModel>(
      context,
      title: 'Category',
      controller: uploadCategoryCtr,
      list: filteredData,
      searchCtr: searchUploadCategoryCtr,
      searchNode: searchUploadCategoryNode,
      filterFunction: (val) {
        filterFetchData<CategoryModel>(
          val,
          source: categoryList,
          getTitle: (item) => item.name,
        );
      },
      getTitle: (value) => value.name,
      onSelected: (data) {
        uploadCategoryCtr.text = data.name;
        categoryId.value = data.id.toString();
        validateUploadCategory(uploadCategoryCtr.text);
        update();
      },
      backBtn: () {
        Get.back();
      },
    );
  }

  void validateUploadCategory(String? val) {
    uploadCategoryModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Category is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep4();
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

  // Placeholder for missing methods
}
