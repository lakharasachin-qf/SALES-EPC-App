import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:file_picker/file_picker.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/LeadByIdModel.dart';
import 'package:sales_app/models/LeadDropDownListModel.dart';
import 'package:sales_app/models/LoadElement.dart';
import 'package:sales_app/models/LocationModel.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';

import '../../configs/apicall_constant.dart';

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});
}

class StatusItem {
  final String label;
  final String value;

  const StatusItem({required this.label, required this.value});
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
  RxBool isResoltuinSolutonTypeApiCallLoading = false.obs;
  RxBool isStateApiCallLoading = false.obs;
  RxBool isDistrictApiCallLoading = false.obs;
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
  var fileList = <UploadedFile>[].obs;
  var roofNature = <String>[
    'Concrete',
    'Metal',
    'Tile',
    'Asbestos',
    'Flat',
    'Sloped',
  ].obs;
  var countryList = <String>['Usa', 'India'].obs;
  var requiredSolutuionList = <String>['Ongrid', 'Offgrid'].obs;
  var solutuionList = <String>[
    'Solar Power',
    'Wind Power',
    'Battery Storage',
    'Grid-Tied Inverter',
    'Microgrid',
  ].obs;

  // var leadCategoryList = <String>[
  //   'Residential',
  //   'Commercial',
  //   'Industrial',
  //   'Agricultural',
  //   'Institutional',
  // ].obs;
  var stateList = <String>['Usa', 'India'].obs;
  var districtList = <String>['Usa', 'India'].obs;
  DateTime? selectedDateTime;
  final RxString startDate = ''.obs;

  // Observable lists for dynamic dropdowns
  var requiredSolutionTypeList = <DgSyncRequired>[].obs;
  var requiredSolutionList = <DgSyncRequired>[].obs;
  var leadCategoryList = <DgSyncRequired>[].obs;
  var dgSyncRequiredList = <DgSyncRequired>[].obs;
  var vfdRequiredList = <DgSyncRequired>[].obs;
  var roofNatureList = <DgSyncRequired>[].obs;
  var financingTypeList = <DgSyncRequired>[].obs;
  var filterPurposeOfSolarisationList = <DgSyncRequired>[].obs;
  var purposeOfSolarisationList = <DgSyncRequired>[].obs;

  var filterRequiredSolutionTypeList = <DgSyncRequired>[].obs;
  var filterRequiredSolutionList = <DgSyncRequired>[].obs;
  var filterLeadCategoryList = <DgSyncRequired>[].obs;
  var filterDgSyncRequiredList = <DgSyncRequired>[].obs;
  var filterVfdRequiredList = <DgSyncRequired>[].obs;
  var filterRoofNatureList = <DgSyncRequired>[].obs;
  var filterFinancingTypeList = <DgSyncRequired>[].obs;

  // RxList<Cluster> districtList = <Cluster>[].obs;

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

  void addFile(UploadedFile file) {
    fileList.add(file);
    validateStep4();
    update();
  }

  void updateFile(int index, UploadedFile file) {
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
      searchPurposeOfSolarizationCtr,
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
      scheduleMeetingCtr,
      searchLeadCategoryCtr,
      searchRequiredSolutionTypeCtr,
      searchRequiredSolutionCtr,
      searchRoofNatureCtr,
      leadStatusCtr;

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
      searchPurposeOfSolarizationNode,
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
      scheduleMeetingNode,
      searchLeadCategoryNode,
      searchRequiredSolutionTypeNode,
      searchRequiredSolutionNode,
      searchRoofNatureNode,
      leadStatusNode;

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
  var latitudeModel = ValidationModel(null, null, isValidate: true).obs;
  var longitudeModel = ValidationModel(null, null, isValidate: true).obs;
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
  var dgCapacityModel = ValidationModel(null, null, isValidate: true).obs;
  var dgSyncModel = ValidationModel(null, null, isValidate: false).obs;
  var installedSolarCapModel = ValidationModel(
    null,
    null,
    isValidate: true,
  ).obs;
  var sanctionedLoadModel = ValidationModel(null, null, isValidate: true).obs;
  var vfdModel = ValidationModel(null, null, isValidate: false).obs;
  var gridAvailabilityModel = ValidationModel(null, null, isValidate: true).obs;
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

  //edit
  var leadStatusModel = ValidationModel(null, null, isValidate: false).obs;

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

  // Observable lists
  var countries = <CountryData>[].obs;
  var states = <StateData>[].obs;
  var districts = <District>[].obs;

  // Selected IDs
  var selectedCountryId = 0.obs;
  var selectedStateId = 0.obs;
  var selectedDistrictId = 0.obs;

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
  late bool locationFetched = true;
  // Add reactive variables for selection
  RxString selectedRequiredSolutionTypeValue = ''.obs;
  RxString selectedRequiredSolutionTypeLabel = ''.obs;
  RxString selectedRequiredSolutionValue = ''.obs;
  RxString selectedRequiredSolutionLabel = ''.obs;
  RxString selectedLeadCategoryValue = ''.obs;
  RxString selectedLeadCategoryLabel = ''.obs;
  RxString selectedDgSyncValue = ''.obs; // Already present
  RxString selectedDgSyncLabel = ''.obs; // Already present
  RxString selectedVfdValue = ''.obs; // Already present
  RxString selectedVfdLabel = ''.obs; // Already present
  RxString selectedRoofNatureValue = ''.obs;
  RxString selectedRoofNatureLabel = ''.obs;
  RxString selectedFinancingTypeValue = ''.obs;
  RxString selectedFinancingTypeLabel = ''.obs;
  RxString selectedPurposeOfSolarisationValue = ''.obs;
  RxString selectedPurposeOfSolarisationLabel = ''.obs;

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
    searchPurposeOfSolarizationCtr = TextEditingController();
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

    searchLeadCategoryCtr = TextEditingController();
    searchRequiredSolutionTypeCtr = TextEditingController();
    searchRequiredSolutionCtr = TextEditingController();
    searchRoofNatureCtr = TextEditingController();

    searchLeadCategoryNode = FocusNode();
    searchRequiredSolutionTypeNode = FocusNode();
    searchRequiredSolutionNode = FocusNode();
    searchRoofNatureNode = FocusNode();

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

    //edit lead status
    leadStatusCtr = TextEditingController();
    firstTechnicalProposal1Ctr = TextEditingController();
    finalTechnicalProposal2Ctr = TextEditingController();
    firstCommercialProposal1Ctr = TextEditingController();
    finalCommercialProposal2Ctr = TextEditingController();

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
    searchPurposeOfSolarizationNode = FocusNode();
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

    //edit lead status
    leadStatusNode = FocusNode();
    firstTechnicalProposal1Node = FocusNode();
    finalTechnicalProposal2Node = FocusNode();
    firstCommercialProposal1Node = FocusNode();
    finalCommercialProposal2Node = FocusNode();

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
    //edit lead status
    leadStatusCtr.dispose();

    firstTechnicalProposal1Ctr.dispose();
    finalTechnicalProposal2Ctr.dispose();
    firstCommercialProposal1Ctr.dispose();
    finalCommercialProposal2Ctr.dispose();

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
    searchPurposeOfSolarizationNode.dispose();
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

    searchLeadCategoryCtr.dispose();
    searchRequiredSolutionTypeCtr.dispose();
    searchRequiredSolutionCtr.dispose();
    searchRoofNatureCtr.dispose();

    searchLeadCategoryNode.dispose();
    searchRequiredSolutionTypeNode.dispose();
    searchRequiredSolutionNode.dispose();
    searchRoofNatureNode.dispose();
    //edit lead status
    leadStatusNode.dispose();
    firstTechnicalProposal1Node.dispose();
    finalTechnicalProposal2Node.dispose();
    firstCommercialProposal1Node.dispose();
    finalCommercialProposal2Node.dispose();

    super.dispose();
  }

  Future<void> getLatLongData(
    BuildContext context,
    bool locationFetched,
  ) async {
    await fetchLocationTracking(
      context,
      (isFromLocation) {
        if (locationFetched == true) {
          this.locationFetched = isFromLocation;
        }
        logcat("locationFetched::", locationFetched.toString());
      },
      getLatLongData: (lat, long, location) {
        logcat("Latitude", lat.toString());
        logcat("Longitude", long.toString());
        latitudeCtr.text = lat;
        longitudeCtr.text = long;
        validateLatitude(latitudeCtr.text);
        validateLongitude(longitudeCtr.text);
        update();
      },
    );
  }
  // getLatLongData(BuildContext context, bool locationFetched) {
  //   fetchLocationTracking(
  //     context,
  //     (isFromLocation) {
  //       if (locationFetched == true) {
  //         this.locationFetched = isFromLocation;
  //       }
  //       logcat("locationFetched::", locationFetched.toString());
  //     },
  //     getLatLongData: (lat, long, location) {
  //       logcat("Latitude", lat.toString());
  //       logcat("Longitude", long.toString());
  //       latitudeCtr.text = lat;
  //       longitudeCtr.text = long;
  //       validateLatitude(latitudeCtr.text);
  //       validateLongitude(longitudeCtr.text);
  //       update();
  //     },
  //   );
  // }

  // Dialog for State List
  // Widget setStateListDialog() {
  //   return Obx(() {
  //     if (isCountryApiCallLoading.value == true) {
  //       return setDropDownContent(
  //         [].obs,
  //         const Text(SearchScreenConstant.loading),
  //         isApiIsLoading: isCountryApiCallLoading.value,
  //       );
  //     }
  //     return setDropDownContent(
  //       stateList,
  //       controller: stateSearchCtr,
  //       noDataLable: "No State",
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const BouncingScrollPhysics(),
  //         itemCount: stateList.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           return Column(
  //             children: [
  //               ListTile(
  //                 dense: true,
  //                 visualDensity: const VisualDensity(
  //                   horizontal: 0,
  //                   vertical: -4,
  //                 ),
  //                 contentPadding: const EdgeInsets.only(
  //                   left: 0.0,
  //                   right: 0.0,
  //                   top: 0.0,
  //                 ),
  //                 horizontalTitleGap: null,
  //                 minLeadingWidth: 5,
  //                 onTap: () async {
  //                   stateCtr.text = stateList[index];
  //                   validateState(stateCtr.text);
  //                   Get.back();
  //                 },
  //                 title: Text(
  //                   stateList[index],
  //                   style: TextStyle(fontSize: 17.sp),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //       searchcontent: getReactiveFormField(
  //         node: stateSearchNode,
  //         controller: stateSearchCtr,
  //         hintLabel: SearchScreenConstant.hint,
  //         onChanged: (val) {
  //           applyFilterForState(val.toString());
  //           update();
  //         },
  //         isSearch: true,
  //         inputType: TextInputType.text,
  //         errorText: stateSearchModel.value.error,
  //       ),
  //     );
  //   });
  // }

  // void applyFilterForState(String keyword) {
  //   stateList.clear();
  //   if (keyword.isEmpty) {
  //     stateList.addAll(['Usa', 'India']); // Mock data
  //   } else {
  //     stateList.addAll(
  //       ['Usa', 'India']
  //           .where(
  //             (state) => state.toLowerCase().contains(keyword.toLowerCase()),
  //           )
  //           .toList(),
  //     );
  //   }
  //   update();
  // }

  Widget setStateListDialog() {
    return Obx(() {
      if (isStateApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isStateApiCallLoading.value,
        );
      }
      return setDropDownContent(
        states,
        controller: stateSearchCtr,
        noDataLable: "No State",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: states.length,
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
                selectState(states[index]);
                Get.back();
              },
              title: buildSelectableRow(
                states[index].stateName,
                states[index].stateId == selectedStateId.value,
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: stateSearchNode,
          controller: stateSearchCtr,
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForState(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: stateSearchModel.value.error,
        ),
      );
    });
  }

  void applyFilterForState(String keyword) {
    states.clear();
    if (keyword.isEmpty) {
      states.assignAll(
        countries
            .firstWhere((c) => c.countryId == selectedCountryId.value)
            .states,
      );
    } else {
      states.assignAll(
        countries
            .firstWhere((c) => c.countryId == selectedCountryId.value)
            .states
            .where(
              (s) => s.stateName.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  // Update dialogs
  Widget setCountryListDialog() {
    return Obx(() {
      if (isCountryApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isCountryApiCallLoading.value,
        );
      }
      return setDropDownContent(
        countries,
        controller: countrySearchCtr,
        noDataLable: "No Country",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: countries.length,
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
                selectCountry(countries[index]);
                Get.back();
              },
              title: buildSelectableRow(
                countries[index].countryName,
                countries[index].countryId == selectedCountryId.value,
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: countrySearchNode,
          controller: countrySearchCtr,
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterforCountry(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: countrySearchModel.value.error,
        ),
      );
    });
  }

  // Filter methods
  void applyFilterforCountry(String keyword) {
    if (keyword.isEmpty) {
      countryList.assignAll(countries.map((c) => c.countryName).toList());
    } else {
      countryList.assignAll(
        countries
            .where(
              (c) =>
                  c.countryName.toLowerCase().contains(keyword.toLowerCase()),
            )
            .map((c) => c.countryName)
            .toList(),
      );
    }
    update();
  }

  Widget setDistrictListDialog() {
    return Obx(() {
      if (isDesignationApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isDesignationApiCallLoading.value,
        );
      }
      return setDropDownContent(
        districts,
        controller: districtSearchCtr,
        noDataLable: "No District",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: districts.length,
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
                selectDistrict(districts[index]);
                Get.back();
              },
              title: buildSelectableRow(
                districts[index].districtName,
                districts[index].districtId == selectedDistrictId.value,
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: districtSearchNode,
          controller: districtSearchCtr,
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForDistrict(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: districtSearchModel.value.error,
        ),
      );
    });
  }

  void applyFilterForDistrict(String keyword) {
    if (keyword.isEmpty) {
      districts.assignAll(
        states.firstWhere((s) => s.stateId == selectedStateId.value).districts,
      );
    } else {
      districts.assignAll(
        states
            .firstWhere((s) => s.stateId == selectedStateId.value)
            .districts
            .where(
              (d) =>
                  d.districtName.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  Widget setRequiredSolutionTypeListDialog() {
    return Obx(() {
      if (isResoltuinSolutonTypeApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isResoltuinSolutonTypeApiCallLoading.value,
        );
      }
      return setDropDownContent(
        filterRequiredSolutionTypeList,
        controller: requiredSolutionTypeCtr,
        noDataLable: "No Solution Type",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filterRequiredSolutionTypeList.length,
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
                final selectedItem = filterRequiredSolutionTypeList[index];
                requiredSolutionTypeCtr.text = selectedItem.label;
                selectedRequiredSolutionTypeLabel.value = selectedItem.label;
                selectedRequiredSolutionTypeValue.value = selectedItem.value;
                validateRequiredSolutionType(selectedItem.value);
                if (requiredSolutionTypeCtr.text.toString().isNotEmpty) {
                  filterRequiredSolutionTypeList.clear();
                  filterRequiredSolutionTypeList.addAll(
                    requiredSolutionTypeList,
                  );
                }
                Get.back();
              },
              // selectedRequiredSolutionTypeLabel.value
              title: buildSelectableRow(
                filterRequiredSolutionTypeList[index].label,
                filterRequiredSolutionTypeList[index].value.trim() ==
                    selectedRequiredSolutionTypeValue.value.trim(),
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: requiredSolutionTypeNode,
          controller: searchRequiredSolutionTypeCtr, // New search controller
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForRequiredSolutionType(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: requiredSolutionTypeModel.value.error,
        ),
      );
    });
  }

  void applyFilterForRequiredSolutionType(String keyword) {
    if (keyword.isEmpty) {
      filterRequiredSolutionTypeList.assignAll(requiredSolutionTypeList);
    } else {
      filterRequiredSolutionTypeList.assignAll(
        requiredSolutionTypeList
            .where(
              (item) =>
                  item.label.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  Widget setRequiredSolutionListDialog() {
    return Obx(() {
      if (isCountryApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isCountryApiCallLoading.value,
        );
      }
      return setDropDownContent(
        filterRequiredSolutionList,
        controller: requiredSolutionCtr,
        noDataLable: "No Solution",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filterRequiredSolutionList.length,
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
                final selectedItem = filterRequiredSolutionList[index];
                requiredSolutionCtr.text = selectedItem.label;
                selectedRequiredSolutionLabel.value = selectedItem.label;
                selectedRequiredSolutionValue.value = selectedItem.value;
                validateRequiredSolution(selectedItem.value);
                if (requiredSolutionCtr.text.toString().isNotEmpty) {
                  filterRequiredSolutionList.clear();
                  filterRequiredSolutionList.addAll(requiredSolutionList);
                }
                Get.back();
              },
              title: buildSelectableRow(
                filterRequiredSolutionList[index].label,
                filterRequiredSolutionList[index].label.trim() ==
                    requiredSolutionCtr.text.trim(),
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: requiredSolutionNode,
          controller: searchRequiredSolutionCtr, // New search controller
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForRequiredSolution(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: requiredSolutionModel.value.error,
        ),
      );
    });
  }

  void applyFilterForRequiredSolution(String keyword) {
    if (keyword.isEmpty) {
      filterRequiredSolutionList.assignAll(requiredSolutionList);
    } else {
      filterRequiredSolutionList.assignAll(
        requiredSolutionList
            .where(
              (item) =>
                  item.label.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  Widget setLeadCategoryListDialog() {
    return Obx(() {
      if (isCountryApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isCountryApiCallLoading.value,
        );
      }
      return setDropDownContent(
        filterLeadCategoryList,
        controller: leadCategoryCtr,
        noDataLable: "No Lead Category",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filterLeadCategoryList.length,
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
                final selectedItem = filterLeadCategoryList[index];
                leadCategoryCtr.text = selectedItem.label;
                selectedLeadCategoryLabel.value = selectedItem.label;
                selectedLeadCategoryValue.value = selectedItem.value;
                validateLeadCategory(selectedItem.value);
                if (leadCategoryCtr.text.toString().isNotEmpty) {
                  filterLeadCategoryList.clear();
                  filterLeadCategoryList.addAll(leadCategoryList);
                }
                Get.back();
              },
              title: buildSelectableRow(
                filterLeadCategoryList[index].label,
                filterLeadCategoryList[index].label.trim() ==
                    leadCategoryCtr.text.trim(),
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: leadCategoryNode,
          controller: searchLeadCategoryCtr,
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForLeadCategory(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: leadCategoryModel.value.error,
        ),
      );
    });
  }

  void applyFilterForLeadCategory(String keyword) {
    if (keyword.isEmpty) {
      filterLeadCategoryList.assignAll(leadCategoryList);
    } else {
      filterLeadCategoryList.assignAll(
        leadCategoryList
            .where(
              (item) =>
                  item.label.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  RxBool isOtherPurposeOfSolarisationVisible = false.obs;
  Widget setPurposeOfSolarisationListDialog() {
    return Obx(() {
      if (isCountryApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isCountryApiCallLoading.value,
        );
      }
      return setDropDownContent(
        filterPurposeOfSolarisationList,
        controller: purposeOfSolarizationCtr,
        noDataLable: "No Purpose of Solarisation",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filterPurposeOfSolarisationList.length,
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
                final selectedItem = filterPurposeOfSolarisationList[index];
                purposeOfSolarizationCtr.text = selectedItem.label;
                selectedPurposeOfSolarisationLabel.value = selectedItem.label;
                selectedPurposeOfSolarisationValue.value = selectedItem.value;

                if (selectedPurposeOfSolarisationValue.value == 'Other') {
                  isOtherPurposeOfSolarisationVisible.value = true;
                  purposeOfSolarizationCtr.text = '';
                  selectedPurposeOfSolarisationValue.value =
                      purposeOfSolarizationCtr.text;
                } else {
                  isOtherPurposeOfSolarisationVisible.value = false;
                  purposeOfSolarizationCtr.text = selectedItem.label;
                }
                validatePurposeOfSolarization(selectedItem.value);
                if (purposeOfSolarizationCtr.text.toString().isNotEmpty) {
                  filterPurposeOfSolarisationList.clear();
                  filterPurposeOfSolarisationList.addAll(
                    purposeOfSolarisationList,
                  );
                }
                Get.back();
              },
              title: buildSelectableRow(
                filterPurposeOfSolarisationList[index].label,
                filterPurposeOfSolarisationList[index].label.trim() ==
                    purposeOfSolarizationCtr.text.trim(),
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: searchPurposeOfSolarizationNode,
          controller: searchPurposeOfSolarizationCtr,
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForPurposeOfSolarisation(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: purposeOfSolarizationModel.value.error,
        ),
      );
    });
  }

  // Updated filter method to use the original list for reset
  void applyFilterForPurposeOfSolarisation(String keyword) {
    if (keyword.isEmpty) {
      filterPurposeOfSolarisationList.assignAll(purposeOfSolarisationList);
    } else {
      filterPurposeOfSolarisationList.assignAll(
        purposeOfSolarisationList
            .where(
              (item) =>
                  item.label.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }

  Widget setRoofNatureListDialog() {
    return Obx(() {
      if (isCountryApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isCountryApiCallLoading.value,
        );
      }
      return setDropDownContent(
        filterRoofNatureList,
        controller: roofNatureCtr,
        noDataLable: "No Roof Nature",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filterRoofNatureList.length,
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
                final selectedItem = filterRoofNatureList[index];
                roofNatureCtr.text = selectedItem.label;
                selectedRoofNatureLabel.value = selectedItem.label;
                selectedRoofNatureValue.value = selectedItem.value;
                validateRoofNature(selectedItem.value);
                if (roofNatureCtr.text.toString().isNotEmpty) {
                  filterRoofNatureList.clear();
                  filterRoofNatureList.addAll(roofNatureList);
                }
                Get.back();
              },
              title: buildSelectableRow(
                filterRoofNatureList[index].label,
                filterRoofNatureList[index].label.trim() ==
                    roofNatureCtr.text.trim(),
              ),
            );
          },
        ),
        searchcontent: getReactiveFormField(
          node: roofNatureNode,
          controller: searchRoofNatureCtr, // New search controller
          hintLabel: SearchScreenConstant.hint,
          onChanged: (val) {
            applyFilterForRoofNature(val.toString());
          },
          isSearch: true,
          inputType: TextInputType.text,
          errorText: roofNatureModel.value.error,
        ),
      );
    });
  }

  void applyFilterForRoofNature(String keyword) {
    if (keyword.isEmpty) {
      filterRoofNatureList.assignAll(roofNatureList);
    } else {
      filterRoofNatureList.assignAll(
        roofNatureList
            .where(
              (item) =>
                  item.label.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList(),
      );
    }
    update();
  }
  // Widget setCountryListDialog() {
  //   return Obx(() {
  //     if (isCountryApiCallLoading.value == true) {
  //       return setDropDownContent(
  //         [].obs,
  //         const Text(SearchScreenConstant.loading),
  //         isApiIsLoading: isCountryApiCallLoading.value,
  //       );
  //     }
  //     return setDropDownContent(
  //       countryList,
  //       controller: countrySearchCtr,
  //       noDataLable: "No Country",
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const BouncingScrollPhysics(),
  //         itemCount: countryList.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           return Column(
  //             children: [
  //               ListTile(
  //                 dense: true,
  //                 visualDensity: const VisualDensity(
  //                   horizontal: 0,
  //                   vertical: -4,
  //                 ),
  //                 contentPadding: const EdgeInsets.only(
  //                   left: 0.0,
  //                   right: 0.0,
  //                   top: 0.0,
  //                 ),
  //                 horizontalTitleGap: null,
  //                 minLeadingWidth: 5,
  //                 onTap: () async {
  //                   countryId.value = countryList[index];
  //                   countryCtr.text = countryList[index];
  //                   validateCountry(countryCtr.text);
  //                   Get.back();
  //                 },
  //                 title: Text(
  //                   countryList[index],
  //                   style: TextStyle(fontSize: 17.sp),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //       searchcontent: getReactiveFormField(
  //         node: countrySearchNode,
  //         controller: countrySearchCtr,
  //         hintLabel: SearchScreenConstant.hint,
  //         onChanged: (val) {
  //           applyFilterforCountry(val.toString());
  //           update();
  //         },
  //         isSearch: true,
  //         inputType: TextInputType.text,
  //         errorText: countrySearchModel.value.error,
  //       ),
  //     );
  //   });
  // }

  // void applyFilterforCountry(String keyword) {
  //   countryList.clear();
  //   if (keyword.isEmpty) {
  //     countryList.addAll(['USA', 'India', 'Canada']); // Mock data
  //   } else {
  //     countryList.addAll(
  //       ['USA', 'India', 'Canada']
  //           .where(
  //             (country) =>
  //                 country.toLowerCase().contains(keyword.toLowerCase()),
  //           )
  //           .toList(),
  //     );
  //   }
  //   update();
  // }

  // Validation Methods
  void validateCompanyName(String? val) {
    companyNameModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Company Name is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateAddress(String? val) {
    addressModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Address is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateCountry(String? val) {
    countryModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Country is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateState(String? val) {
    stateModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "State is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateDistrict(String? val) {
    districtModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "District is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validatePersonName(String? val) {
    personNameModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Contact Person Name is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validatePersonMobile(String? val) {
    personMobileModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Contact Person Mobile is required";
        model.isValidate = false;
      } else if (val.length < 10) {
        model!.error = "Enter valid mobile number";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateLatitude(String? val) {
    latitudeModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid latitude";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateLongitude(String? val) {
    longitudeModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid longitude";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateRequiredSolutionType(String? val) {
    requiredSolutionTypeModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Solution Type";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateRequiredSolution(String? val) {
    requiredSolutionModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Required Solution";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateLeadCategory(String? val) {
    leadCategoryModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Lead Category";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateDGCapacity(String? val) {
    dgCapacityModel.update((model) {
      if (val != null && double.parse(val) < 0) {
        model!.error = "DG Capacity cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateDGSync(String? val) {
    dgSyncModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter DG Sync selection";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateInstalledSolarCap(String? val) {
    installedSolarCapModel.update((model) {
      if (val != null && val.isNotEmpty) {
        if (double.parse(val) < 0) {
          model!.error = "Installed Solar Capacity cannot be negative";
          model.isValidate = false;
        } else {
          model!.error = null;
          model.isValidate = true;
        }
      } else {
        // Empty is allowed
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateSanctionedLoad(String? val) {
    sanctionedLoadModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Sanctioned Load cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateVFD(String? val) {
    vfdModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter VFD selection";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validateGridAvailability(String? val) {
    gridAvailabilityModel.update((model) {
      if (val != null && double.tryParse(val) != null) {
        double value = double.parse(val);
        if (value < 0 || value > 24) {
          model!.error = "Grid Availability must be between 0 and 24";
          model.isValidate = false;
        } else {
          model!.error = null;
          model.isValidate = true;
        }
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep1();
  }

  void validatePeakMonthlyEnergy(String? val) {
    peakMonthlyEnergyModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Peak Monthly Energy cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateRequiredSolarCap(String? val) {
    requiredSolarCapModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Required Solar Capacity cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateDistanceToTransformer(String? val) {
    distanceToTransformerModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Distance cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateRatingOfTransformer(String? val) {
    ratingOfTransformerModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Rating cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validatePurposeOfSolarization(String? val) {
    purposeOfSolarizationModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Purpose of Solarization is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateDistInverterACDB(String? val) {
    distInverterACDBModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Distance cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateDistSolarACDB(String? val) {
    distSolarACDBModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Distance cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateBuildingHeight(String? val) {
    buildingHeightModel.update((model) {
      if (val != null && int.tryParse(val) != null) {
        int value = int.parse(val);
        if (value < 1) {
          model!.error = "Building height must be at least 1 floor";
          model.isValidate = false;
        } else {
          model!.error = null;
          model.isValidate = true;
        }
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateRoofSizeLength(String? val) {
    roofSizeLengthModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Roof size length cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateRoofSizeBreadth(String? val) {
    roofSizeBreadthModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Roof size breadth cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateRoofNature(String? val) {
    roofNatureModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Roof Nature";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateAgeOfMetalSheet(String? val) {
    ageOfMetalSheetModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Age of metal sheet cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateGroundSizeLength(String? val) {
    groundSizeLengthModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Ground size length cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateGroundSizeBreadth(String? val) {
    groundSizeBreadthModel.update((model) {
      if (val != null &&
          double.tryParse(val) != null &&
          double.parse(val) < 0) {
        model!.error = "Ground size breadth cannot be negative";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateOtherRemarks(String? val) {
    otherRemarksModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Other Remarks is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  void validateScheduleMeeting(String? val) {
    scheduleMeeeingModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Schedule Meeting is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

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

  RxBool isvalidateAddLoadElement = false.obs;

  resetFileUpload() {
    uploadFileCtr.clear();
    uploadCategoryCtr.clear();

    uploadFileModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
    uploadCategoryModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
    update();
  }

  resetvalidationOfAddLoadElement() {
    isvalidateAddLoadElement.value = false;
    deviceNameCtr.clear();
    categoryCtr.clear();
    powerCtr.clear();
    usageHrsCtr.clear();
    energyWhCtr.clear();
    energyKWhCtr.clear();

    // Reset validation models
    deviceNameModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
    categoryModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
    powerModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
    usageHrsModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
    energyWhModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
    energyKWhModel.update((m) {
      m!.error = null;
      m.isValidate = false;
    });
  }

  void validateAddLoadElement() {
    final isValid =
        deviceNameModel.value.isValidate &&
        categoryModel.value.isValidate &&
        powerModel.value.isValidate &&
        usageHrsModel.value.isValidate;

    isvalidateAddLoadElement.value = isValid;
  }

  void validateStep2() {
    bool isValid = true;
    // if (!peakMonthlyEnergyModel.value.isValidate) isValid = false;
    // if (!requiredSolarCapModel.value.isValidate) isValid = false;
    // if (!distanceToTransformerModel.value.isValidate) isValid = false;
    // if (!ratingOfTransformerModel.value.isValidate) isValid = false;
    // if (!purposeOfSolarizationModel.value.isValidate) isValid = false;
    // if (!distInverterACDBModel.value.isValidate) isValid = false;
    // if (!distSolarACDBModel.value.isValidate) isValid = false;
    // if (!buildingHeightModel.value.isValidate) isValid = false;
    // if (!roofSizeLengthModel.value.isValidate) isValid = false;
    // if (!roofSizeBreadthModel.value.isValidate) isValid = false;
    if (!roofNatureModel.value.isValidate) isValid = false;
    // if (!ageOfMetalSheetModel.value.isValidate) isValid = false;
    // if (!groundSizeLengthModel.value.isValidate) isValid = false;
    // if (!groundSizeBreadthModel.value.isValidate) isValid = false;
    // if (!otherRemarksModel.value.isValidate) isValid = false;

    if (isEditMode.value == false) {
      if (!scheduleMeeeingModel.value.isValidate) isValid = false;
    } else {
      if (!leadStatusModel.value.isValidate) isValid = false;
    }
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
    return isStep1Valid.value && isStep2Valid.value;
    // isStep3Valid.value &&
    // isStep4Valid.value;
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
        validateScheduleMeeting(controller.text);
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
      validateAddLoadElement();
    } else {
      resetvalidationOfAddLoadElement();
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
                              // Clear all controllers
                              resetvalidationOfAddLoadElement();

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
                          getLable("Device Name", isRequired: true),
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
                                  validateAddLoadElement();
                                },
                                inputType: TextInputType.text,
                                formType: FieldType.text,
                                wantSuffix: false,
                                errorText: deviceNameModel.value.error,
                              );
                            }),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          getLable("Category", isRequired: true),
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
                                  validateAddLoadElement();
                                },
                                inputType: TextInputType.text,
                                formType: FieldType.text,
                                wantSuffix: false,
                                errorText: categoryModel.value.error,
                              );
                            }),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          getLable("Power (W)", isRequired: true),
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
                                    } else if (double.parse(val) < 0) {
                                      model!.error = "Power cannot be negative";
                                      model.isValidate = false;
                                    } else {
                                      model!.error = null;
                                      model.isValidate = true;
                                    }
                                  });
                                  validateAddLoadElement();

                                  /// 🔹 Recalculate Energy automatically
                                  calculateEnergy();
                                },
                                inputType: TextInputType.number,
                                formType: FieldType.text,
                                wantSuffix: false,
                                errorText: powerModel.value.error,
                              );
                            }),
                          ),
                          getDynamicSizedBox(height: 1.h),
                          getLable("Usage (hrs)", isRequired: true),
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
                                    } else if (double.parse(val) < 0) {
                                      model!.error =
                                          "Usage hours cannot be negative";
                                      model.isValidate = false;
                                    } else {
                                      model!.error = null;
                                      model.isValidate = true;
                                    }
                                  });
                                  validateAddLoadElement();

                                  /// 🔹 Recalculate Energy automatically
                                  calculateEnergy();
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
                                  children: [
                                    getLable("Energy (Wh)", isVerified: true),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Obx(() {
                                        return getReactiveFormField(
                                          node: energyWhNode,
                                          controller: energyWhCtr,
                                          hintLabel: "Energy (Wh)",
                                          isEnable: false,
                                          inputType: TextInputType.number,
                                          formType: FieldType.text,
                                          wantSuffix: false,
                                          errorText: energyWhModel.value.error,
                                          onChanged: (String? val) {},
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
                                  children: [
                                    getLable("Energy (KWh)", isVerified: true),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Obx(() {
                                        return getReactiveFormField(
                                          node: energyKWhNode,
                                          controller: energyKWhCtr,
                                          hintLabel: "Energy (KWh)",
                                          isEnable: false,
                                          inputType: TextInputType.number,
                                          formType: FieldType.text,
                                          wantSuffix: false,
                                          errorText: energyKWhModel.value.error,
                                          onChanged: (String? val) {},
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
                                    resetvalidationOfAddLoadElement();
                                    Get.back();
                                  },
                                  'Cancel',
                                  validate: true,
                                ),
                              ),
                              getDynamicSizedBox(width: 3.w),
                              Expanded(
                                child: Obx(() {
                                  return getFormButton(
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
                                    validate: isvalidateAddLoadElement.value,
                                  );
                                }),
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

  addUploadFile(context, {UploadedFile? fileItem, int? index}) async {
    if (fileItem != null) {
      uploadFileCtr.text = fileItem.path ?? '';
      uploadCategoryCtr.text = fileItem.category ?? '';
    } else {
      resetFileUpload();
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
                              resetFileUpload();
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
                                      final newFile = UploadedFile(
                                        path: uploadFileCtr.text,
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

  Future<void> addLeadApi(BuildContext context) async {
    User? user = await UserPreferences().getSignInInfo();
    final body = <String, dynamic>{
      // 'company_name': companyNameCtr.text.trim(),
      // 'address': addressCtr.text.trim(),
      // 'country': countryCtr.text.trim(),
      // 'state': stateCtr.text.trim(),
      // 'district': districtCtr.text.trim(),
      // 'contact_person_name': personNameCtr.text.trim(),
      // 'contact_person_mobile': personMobileCtr.text.trim(),
      // 'latitude': latitudeCtr.text.trim(),
      // 'longitude': longitudeCtr.text.trim(),
      // 'required_solution_type': selectedRequiredSolutionTypeValue.value,
      // 'required_solution': selectedRequiredSolutionValue.value,
      // // 'lead_category': leadCategoryCtr.text.trim(),
      // 'lead_category': selectedLeadCategoryValue.value,
      // 'dg_capacity_kva': dgCapacityCtr.text.trim(),
      // 'dg_sync_required': selectedDgSyncValue.value,
      // 'curr_inst_solar_cap_kwp': installedSolarCapCtr.text.trim(),
      // 'sanctioned_load_kva': sanctionedLoadCtr.text.trim(),
      // 'vfd_required': selectedVfdValue.value,
      // 'grid_availability_hrs': gridAvailabilityCtr.text.trim(),
      // 'peak_monthly_energy_cons_kwh': peakMonthlyEnergyCtr.text.trim(),
      // 'required_solar_cap_kwp': requiredSolarCapCtr.text.trim(),
      // 'dist_to_nearest_transformer': distanceToTransformerCtr.text.trim(),
      // 'rating_of_nearest_transformer_kva': ratingOfTransformerCtr.text.trim(),
      // 'purpose_of_solarisation': purposeOfSolarizationCtr.text.trim(),
      // 'dist_btw_inverter_acdb_panel_mtrs': distInverterACDBCtr.text.trim(),
      // 'dist_btw_solar_acdb_panel_mtrs': distSolarACDBCtr.text.trim(),
      // 'building_height': buildingHeightCtr.text.trim(),
      // 'roof_size_length_ft': roofSizeLengthCtr.text.trim(),
      // 'roof_size_breadth_ft': roofSizeBreadthCtr.text.trim(),
      // 'roof_nature': roofNatureCtr.text.trim(),
      // 'age_of_metal_sheet': ageOfMetalSheetCtr.text.trim(),
      // 'ground_size_length_ft': groundSizeLengthCtr.text.trim(),
      // 'ground_size_breadth_ft': groundSizeBreadthCtr.text.trim(),
      // 'other_remarks': otherRemarksCtr.text.trim(),
      // 'schedule_meeting': scheduleMeetingCtr.text.trim(),
      // 'user_id': user != null ? user.userId : '',
      'company_name': companyNameCtr.text.trim(),
      'address': addressCtr.text.trim(),
      'country': selectedCountryId.value,
      'state': selectedStateId.value,
      'district': selectedDistrictId.value,
      'contact_person_name': personNameCtr.text.trim(),
      'contact_person_mobile': personMobileCtr.text.trim(),
      'latitude': latitudeCtr.text.trim(),
      'longitude': longitudeCtr.text.trim(),
      'required_solution_type': selectedRequiredSolutionTypeValue.value,
      'required_solution': selectedRequiredSolutionValue.value,
      'lead_category': selectedLeadCategoryValue.value,
      'dg_capacity_kva': dgCapacityCtr.text.trim(),
      'dg_sync_required': selectedDgSyncValue.value,
      'curr_inst_solar_cap_kwp': installedSolarCapCtr.text.trim(),
      'sanctioned_load_kva': sanctionedLoadCtr.text.trim(),
      'vfd_required': selectedVfdValue.value,
      'grid_availability_hrs': gridAvailabilityCtr.text.trim(),
      'peak_monthly_energy_cons_kwh': peakMonthlyEnergyCtr.text.trim(),
      'required_solar_cap_kwp': requiredSolarCapCtr.text.trim(),
      'dist_to_nearest_transformer': distanceToTransformerCtr.text.trim(),
      'rating_of_nearest_transformer_kva': ratingOfTransformerCtr.text.trim(),
      'purpose_of_solarisation': selectedPurposeOfSolarisationValue.value,
      'dist_btw_inverter_acdb_panel_mtrs': distInverterACDBCtr.text.trim(),
      'dist_btw_solar_acdb_panel_mtrs': distSolarACDBCtr.text.trim(),
      'building_height': buildingHeightCtr.text.trim(),
      'roof_size_length_ft': roofSizeLengthCtr.text.trim(),
      'roof_size_breadth_ft': roofSizeBreadthCtr.text.trim(),
      'roof_nature': selectedRoofNatureValue.value,
      'age_of_metal_sheet': ageOfMetalSheetCtr.text.trim(),
      'ground_size_length_ft': groundSizeLengthCtr.text.trim(),
      'ground_size_breadth_ft': groundSizeBreadthCtr.text.trim(),
      'other_remarks': otherRemarksCtr.text.trim(),
      // 'schedule_meeting': scheduleMeetingCtr.text.trim(),
      'schedule_meeting': formatScheduleDate(scheduleMeetingCtr.text.trim()),
      'user_id': user != null ? user.userId : '',
    };

    // Step 2: Add load elements
    for (int i = 0; i < productDetailList.length; i++) {
      final product = productDetailList[i];
      body.addAll({
        'load_elements[$i][device_name]': product.deviceName,
        'load_elements[$i][category]': product.category,
        'load_elements[$i][power_rating_w]': product.power,
        'load_elements[$i][daily_usage_hrs]': product.usageHrs,
      });
    }

    // Step 3: Add uploaded files
    for (int i = 0; i < fileList.length; i++) {
      final file = fileList[i];
      body.addAll({
        'uploaded_files[$i][category]': file.category,
        'uploaded_files[$i][file]': file.path,
      });
    }
    debugPrint('my body: Starting individual field logging');
    body.forEach((key, value) {
      debugPrint('my body: $key = $value');
    });
    debugPrint('my body: Finished individual field logging');
    // logcat("addLeadApi::", jsonEncode(body));
    // Step 4: API Call
    // return;
    await commonPostApiCallFormate(
      context,
      title: 'Add Lead Screen',
      body: body,
      allowHeader: true,
      apiEndPoint: ApiUrl.addLead,
      onResponse: (data) async {
        logcat('AddLeadApi', 'Response: $data');

        Get.back();

        Get.snackbar(
          "Success",
          "Lead added successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      state: state,
      message: message,
      networkManager: networkManager,
      isModelResponse: false,
    );
  }

  // Future<void> getLocation(BuildContext context, bool isLoading) async {
  //   var loadingIndicator = LoadingProgressDialog();

  //   commonGetApiCallFormate(
  //     context,
  //     title: 'Add Lead Screen',
  //     apiEndPoint: ApiUrl.getLocation,
  //     allowHeader: true,
  //     state: state,
  //     message: message,
  //     isStatus: true,
  //     apisLoading: (isTrue) {
  //       if (isLoading) {
  //         if (isTrue) {
  //           loadingIndicator.show(context, '');
  //         } else {
  //           loadingIndicator.hide(context);
  //         }
  //       }
  //     },
  //     onResponse: (data) {
  //       var responseDetail = LocationModel.fromJson(data);

  //       if (responseDetail.status) {
  //         countries.assignAll(responseDetail.data);

  //         // Select default country "India"
  //         CountryData? defaultCountry;
  //         if (countries.isNotEmpty) {
  //           defaultCountry = countries.firstWhere(
  //             (country) => country.countryName.trim().toLowerCase() == 'india',
  //             orElse: () => countries.first,
  //           );

  //           selectCountry(defaultCountry);
  //           countryCtr.text = defaultCountry.countryName;
  //           selectedCountryId.value = defaultCountry.countryId;
  //           states.assignAll(defaultCountry.states);
  //           validateCountry(defaultCountry.countryName);
  //         }

  //         // Select default state "Uttar Pradesh"
  //         if (states.isNotEmpty) {
  //           final defaultState = states.firstWhere(
  //             (state) =>
  //                 state.stateName.trim().toLowerCase() == 'uttar pradesh',
  //             orElse: () => states.first,
  //           );

  //           selectState(defaultState);
  //           stateCtr.text = defaultState.stateName;
  //           selectedStateId.value = defaultState.stateId;
  //           districts.assignAll(defaultState.districts);
  //           validateState(defaultState.stateName);
  //         }

  //         update();
  //       }
  //     },
  //     networkManager: networkManager,
  //   );
  // }

  Future<void> getDropDownList(BuildContext context, bool isLoading) async {
    var loadingIndicator = LoadingProgressDialog();
    commonGetApiCallFormate(
      context,
      title: 'Add Lead Screen',
      apiEndPoint: ApiUrl.getDropdownList,
      allowHeader: true,
      state: state,
      message: message,
      isStatus: false,
      apisLoading: (isTrue) {
        if (isLoading) {
          if (isTrue) {
            loadingIndicator.show(context, '');
          } else {
            loadingIndicator.hide(context);
          }
        }
      },
      onResponse: (data) {
        var responseDetail = LeadDropDownListModel.fromJson(data);
        var dropdowns = responseDetail.data.dropdowns;

        countries.assignAll(responseDetail.data.locations);

        // Select default country "India"
        CountryData? defaultCountry;
        if (countries.isNotEmpty) {
          defaultCountry = countries.firstWhere(
            (country) => country.countryName.trim().toLowerCase() == 'india',
            orElse: () => countries.first,
          );

          selectCountry(defaultCountry);
          countryCtr.text = defaultCountry.countryName;
          selectedCountryId.value = defaultCountry.countryId;
          states.assignAll(defaultCountry.states);
          validateCountry(defaultCountry.countryName);
        }

        // Select default state "Uttar Pradesh"
        if (states.isNotEmpty) {
          final defaultState = states.firstWhere(
            (state) => state.stateName.trim().toLowerCase() == 'uttar pradesh',
            orElse: () => states.first,
          );

          selectState(defaultState);
          stateCtr.text = defaultState.stateName;
          selectedStateId.value = defaultState.stateId;
          districts.assignAll(defaultState.districts);
          validateState(defaultState.stateName);
        }

        // Populate dynamic lists from API response
        requiredSolutionTypeList.assignAll(dropdowns.requiredSolutionType);
        filterRequiredSolutionTypeList.assignAll(
          dropdowns.requiredSolutionType,
        ); // New filtered list
        requiredSolutionList.assignAll(dropdowns.requiredSolution);
        filterRequiredSolutionList.assignAll(
          dropdowns.requiredSolution,
        ); // New filtered list
        leadCategoryList.assignAll(dropdowns.leadCategory);
        filterLeadCategoryList.assignAll(
          dropdowns.leadCategory,
        ); // New filtered list
        dgSyncRequiredList.assignAll(dropdowns.dgSyncRequired);
        filterDgSyncRequiredList.assignAll(
          dropdowns.dgSyncRequired,
        ); // New filtered list
        vfdRequiredList.assignAll(dropdowns.vfdRequired);
        filterVfdRequiredList.assignAll(
          dropdowns.vfdRequired,
        ); // New filtered list
        roofNatureList.assignAll(dropdowns.roofNature);
        filterRoofNatureList.assignAll(
          dropdowns.roofNature,
        ); // New filtered list
        financingTypeList.assignAll(dropdowns.financingType);
        filterFinancingTypeList.assignAll(
          dropdowns.financingType,
        ); // New filtered list
        purposeOfSolarisationList.assignAll(dropdowns.purposeOfSolarisation);
        filterPurposeOfSolarisationList.assignAll(
          dropdowns.purposeOfSolarisation,
        );
        update();
      },
      networkManager: networkManager,
    );
  }

  // Update country selection
  void selectCountry(CountryData country) {
    selectedCountryId.value = country.countryId;
    countryCtr.text = country.countryName;
    validateCountry(countryCtr.text);
    // Update states based on selected country
    states.assignAll(country.states);
    stateCtr.clear();
    districtCtr.clear();
    selectedStateId.value = 0;
    selectedDistrictId.value = 0;
    districts.clear();
    // validateState('');
    // validateDistrict('');
    applyFilterforCountry('');
    update();
  }

  // Update state selection
  void selectState(StateData state) {
    selectedStateId.value = state.stateId;
    stateCtr.text = state.stateName;
    validateState(stateCtr.text);
    // Update districts based on selected state
    districts.assignAll(state.districts);
    districtCtr.clear();
    selectedDistrictId.value = 0;
    // validateDistrict('');
    applyFilterForState('');
    update();
  }

  // Update district selection
  void selectDistrict(District district) {
    selectedDistrictId.value = district.districtId;
    districtCtr.text = district.districtName;
    validateDistrict(districtCtr.text);
    applyFilterForDistrict('');
    update();
  }

  void calculateEnergy() {
    final power = double.tryParse(powerCtr.text.trim());
    final usage = double.tryParse(usageHrsCtr.text.trim());

    if (power != null && usage != null && power >= 0 && usage >= 0) {
      final energyWh = power * usage;
      final energyKWh = energyWh / 1000;

      energyWhCtr.text = energyWh.toStringAsFixed(2);
      energyKWhCtr.text = energyKWh.toStringAsFixed(3);

      energyWhModel.update((model) {
        model!.error = null;
        model.isValidate = true;
      });
      energyKWhModel.update((model) {
        model!.error = null;
        model.isValidate = true;
      });
    } else {
      energyWhCtr.text = '';
      energyKWhCtr.text = '';
    }
  }

  //dropdown
  RxBool isEditMode = false.obs;

  //technical proposal
  RxBool isTechnicalProposalMode = false.obs;
  late TextEditingController firstTechnicalProposal1Ctr,
      finalTechnicalProposal2Ctr;

  late FocusNode firstTechnicalProposal1Node, finalTechnicalProposal2Node;
  var firstTechnicalProposal1Model = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var finalTechnicalProposal2Model = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  List<StatusItem> leadStatusTechnical = [
    StatusItem(label: "New Lead", value: "new_lead"),
    StatusItem(label: "Technical Proposal", value: "technical_proposal"),
  ];

  final Rx<File?> firstTechnicalProposalFile = Rx<File?>(null);

  final Rx<File?> finalTechnicalProposalFile = Rx<File?>(null);

  void setTechnicalProposalFile(File file) {
    firstTechnicalProposalFile.value = file;
    update();
  }

  void setfinalTechnicalProposalFile(File file) {
    finalTechnicalProposalFile.value = file;
    update();
  }

  resetTechincalProposal() {
    isTechnicalProposalMode.value = false;
    firstTechnicalProposal1Ctr.clear();
    finalTechnicalProposal2Ctr.clear();
    firstTechnicalProposal1Model.value = ValidationModel(
      null,
      null,
      isValidate: false,
    );
    finalTechnicalProposal2Model.value = ValidationModel(
      null,
      null,
      isValidate: false,
    );

    firstTechnicalProposalFile.value = null;
    finalTechnicalProposalFile.value = null;
    leadStatusCtr.clear();
    selectedLeadStatusvalue.value = '';
    leadStatusList.clear();
    update();
  }

  //commerical proposal
  RxBool isCommercialProposalMode = false.obs;
  late TextEditingController firstCommercialProposal1Ctr,
      finalCommercialProposal2Ctr;

  late FocusNode firstCommercialProposal1Node, finalCommercialProposal2Node;
  var firstCommercialProposal1Model = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var finalCommercialProposal2Model = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  List<StatusItem> leadStatusCommercial = [
    StatusItem(label: "Commercial proposal", value: "commercial_proposal"),
  ];

  final Rx<File?> firstCommercialProposalFile = Rx<File?>(null);

  final Rx<File?> finalCommercialProposalFile = Rx<File?>(null);

  void setCommercialProposalFile(File file) {
    firstCommercialProposalFile.value = file;
    update();
  }

  void setfinalCommercialProposalFile(File file) {
    finalCommercialProposalFile.value = file;
    update();
  }

  resetCommercialProposal() {
    isCommercialProposalMode.value = false;
    firstCommercialProposal1Ctr.clear();
    finalCommercialProposal2Ctr.clear();
    firstCommercialProposal1Model.value = ValidationModel(
      null,
      null,
      isValidate: false,
    );
    finalCommercialProposal2Model.value = ValidationModel(
      null,
      null,
      isValidate: false,
    );

    firstCommercialProposalFile.value = null;
    finalCommercialProposalFile.value = null;
    leadStatusCtr.clear();
    selectedLeadStatusvalue.value = '';
    leadStatusList.clear();
    update();
  }

  RxString selectedLeadStatusvalue = ''.obs;
  RxList<StatusItem> leadStatusList = <StatusItem>[].obs;

  void validateLeadStatus(String? val) {
    leadStatusModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Select Lead Status";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    validateStep2();
  }

  Widget setLeadStatusstDialog() {
    return Obx(() {
      if (isCountryApiCallLoading.value) {
        return setDropDownContent(
          [].obs,
          const Text(SearchScreenConstant.loading),
          isApiIsLoading: isCountryApiCallLoading.value,
        );
      }
      return setDropDownContent(
        leadStatusList,
        controller: leadStatusCtr,
        noDataLable: "No Roof Nature",
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: leadStatusList.length,
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
                final selectedItem = leadStatusList[index];

                selectedLeadStatusvalue.value = selectedItem.value;

                validateLeadStatus(leadStatusCtr.text);
                if (selectedLeadStatusvalue.value == "technical_proposal") {
                  // Enable technical proposal mode
                  isTechnicalProposalMode.value = true;

                  // Reset commercial proposal fields
                  firstCommercialProposalFile.value = null;
                  finalCommercialProposalFile.value = null;
                  firstCommercialProposal1Ctr.clear();
                  finalCommercialProposal2Ctr.clear();
                  isCommercialProposalMode.value = false;
                } else if (selectedLeadStatusvalue.value ==
                    "commercial_proposal") {
                  // Enable commercial proposal mode
                  isCommercialProposalMode.value = true;

                  // Reset technical proposal fields
                  firstTechnicalProposalFile.value = null;
                  finalTechnicalProposalFile.value = null;
                  firstTechnicalProposal1Ctr.clear();
                  finalTechnicalProposal2Ctr.clear();
                  isTechnicalProposalMode.value = false;
                } else {
                  // Neither technical nor commercial
                  isTechnicalProposalMode.value = false;
                  isCommercialProposalMode.value = false;

                  // Reset all fields
                  firstTechnicalProposalFile.value = null;
                  finalTechnicalProposalFile.value = null;
                  firstTechnicalProposal1Ctr.clear();
                  finalTechnicalProposal2Ctr.clear();

                  firstCommercialProposalFile.value = null;
                  finalCommercialProposalFile.value = null;
                  firstCommercialProposal1Ctr.clear();
                  finalCommercialProposal2Ctr.clear();
                }

                Get.back();
              },
              title: buildSelectableRow(
                leadStatusList[index].label,
                leadStatusList[index].label.trim() == leadStatusCtr.text.trim(),
              ),
            );
          },
        ),
      );
    });
  }

  Future<void> getLeadDataByIdList(
    BuildContext context,
    bool isLoading,
    String leadId,
  ) async {
    final loadingIndicator = LoadingProgressDialog();
    commonGetApiCallFormate(
      context,
      title: 'Update Lead Screen',
      apiEndPoint: '${ApiUrl.leadList}/$leadId',
      allowHeader: true,
      state: state,
      message: message,
      isStatus: false,
      apisLoading: (isTrue) {
        if (isLoading) {
          isTrue
              ? loadingIndicator.show(context, '')
              : loadingIndicator.hide(context);
        }
      },
      onResponse: (data) {
        final response = LeadByIdModel.fromJson(data);
        final result = response.result;
        if (result == null) return;

        logcat("onResponse::", jsonEncode(result));

        if (result.availableNextStatuses != null) {
          leadStatusList.clear();
          for (var status in result.availableNextStatuses!) {
            switch (status) {
              case 'technical_proposal':
                // isTechnicalProposalMode.value = true;
                leadStatusList.assignAll(leadStatusTechnical);
                leadStatusCtr.text = leadStatusList.first.label;

                break;
              case 'commercial_proposal':
                isCommercialProposalMode.value = true;
                leadStatusList.assignAll(leadStatusCommercial);
                leadStatusCtr.text = leadStatusList.first.label;
                break;
            }
          }
        }

        // 🔹 Helper: safely set text controller values
        void setText(TextEditingController ctr, dynamic value) =>
            ctr.text = (value ?? '').toString();

        // 🔹 Basic Info
        setText(companyNameCtr, result.companyName);
        setText(addressCtr, result.address);
        setText(countryCtr, result.countryName);
        selectedCountryId.value = result.country ?? 0;

        setText(stateCtr, result.stateName);
        selectedStateId.value = result.state ?? 0;

        setText(districtCtr, result.districtName);
        selectedDistrictId.value = result.district ?? 0;

        setText(personNameCtr, result.contactPersonName);
        setText(personMobileCtr, result.contactPersonMobile);
        setText(latitudeCtr, result.latitude);
        setText(longitudeCtr, result.longitude);

        // 🔹 Power & Energy
        setText(dgCapacityCtr, result.dgCapacityKva);
        setText(installedSolarCapCtr, result.currInstSolarCapKwp);
        setText(sanctionedLoadCtr, result.sanctionedLoadKva);
        setText(gridAvailabilityCtr, result.gridAvailabilityHrs);
        setText(peakMonthlyEnergyCtr, result.peakMonthlyEnergyConsKwh);
        setText(requiredSolarCapCtr, result.requiredSolarCapKwp);
        setText(distanceToTransformerCtr, result.distToNearestTransformer);
        setText(ratingOfTransformerCtr, result.ratingOfNearestTransformerKva);
        setText(distInverterACDBCtr, result.distBtwInverterAcdbPanelMtrs);
        setText(distSolarACDBCtr, result.distBtwSolarAcdbPanelMtrs);

        // 🔹 Physical Site
        setText(buildingHeightCtr, result.buildingHeight);
        setText(roofSizeLengthCtr, result.roofSizeLengthFt);
        setText(roofSizeBreadthCtr, result.roofSizeBreadthFt);
        setText(ageOfMetalSheetCtr, result.ageOfMetalSheet);
        setText(groundSizeLengthCtr, result.groundSizeLengthFt);
        setText(groundSizeBreadthCtr, result.groundSizeBreadthFt);
        setText(otherRemarksCtr, result.otherRemarks);
        setText(scheduleMeetingCtr, result.meeting?.scheduledAt);

        // 🔹 Dropdowns
        void setDropdown(
          RxString value,
          RxString label,
          TextEditingController ctr,
          dynamic data,
        ) {
          value.value = (data ?? '').toString();
          label.value = (data ?? '').toString();
          ctr.text = (data ?? '').toString();
        }

        logcat(
          "selectedRequiredSolutionTypeValue",
          selectedRequiredSolutionTypeValue.toString(),
        );
        logcat("requiredSolutionType", result.requiredSolutionType.toString());
        // setDropdown(
        //   selectedRequiredSolutionTypeValue,
        //   selectedRequiredSolutionTypeLabel,
        //   requiredSolutionTypeCtr,
        //   result.requiredSolutionType,
        // );

        final matchedLabel = getLabelFromValue(
          requiredSolutionTypeList,
          result.requiredSolutionType!,
        );

        selectedRequiredSolutionTypeValue.value = result.requiredSolutionType!;
        selectedRequiredSolutionTypeLabel.value = matchedLabel;

        if (filterRequiredSolutionTypeList.any(
          (element) => element.label == selectedRequiredSolutionTypeLabel.value,
        )) {
          logcat("matchedLabel", "matchedLabel");
        } else {
          logcat("not matchedLabel", "not matchedLabel");
        }

        requiredSolutionTypeCtr.text = matchedLabel;

        final requiredSolutionLabel = getLabelFromValue(
          filterRequiredSolutionList,
          result.requiredSolution!,
        );

        selectedRequiredSolutionValue.value = result.requiredSolution!;
        selectedRequiredSolutionLabel.value = requiredSolutionLabel;
        requiredSolutionCtr.text = requiredSolutionLabel;
        // setDropdown(
        //   selectedRequiredSolutionValue,
        //   selectedRequiredSolutionLabel,
        //   requiredSolutionCtr,
        //   result.requiredSolution,
        // );
        setDropdown(
          selectedLeadCategoryValue,
          selectedLeadCategoryLabel,
          leadCategoryCtr,
          result.leadCategory,
        );
        setDropdown(
          selectedPurposeOfSolarisationValue,
          selectedPurposeOfSolarisationLabel,
          purposeOfSolarizationCtr,
          result.purposeOfSolarisation,
        );
        setDropdown(
          selectedRoofNatureValue,
          selectedRoofNatureLabel,
          roofNatureCtr,
          result.roofNature,
        );

        // 🔹 Boolean dropdowns (Yes/No)
        void setBoolDropdown(
          RxString value,
          RxString label,
          TextEditingController ctr,
          bool? condition,
        ) {
          final text = (condition ?? false) ? 'Yes' : 'No';
          value.value = condition.toString();
          label.value = text;
          ctr.text = text;
        }

        setBoolDropdown(
          selectedDgSyncValue,
          selectedDgSyncLabel,
          dgSyncCtr,
          result.dgSyncRequired,
        );
        setBoolDropdown(
          selectedVfdValue,
          selectedVfdLabel,
          vfdCtr,
          result.vfdRequired,
        );

        // 🔹 Product List
        productDetailList
          ..clear()
          ..assignAll(
            result.loadElementDetails?.map(
                  (e) => LoadElement(
                    deviceName: e.deviceName ?? '',
                    category: e.category ?? '',
                    power: e.powerRatingWatts?.toString() ?? '',
                    usageHrs: e.dailyUsageHours?.toString() ?? '',
                    energyWh: e.dailyEnergyWh?.toString() ?? '',
                    energyKWh: e.dailyEnergyKwh?.toString() ?? '',
                  ),
                ) ??
                [],
          );

        // 🔹 Uploaded Files
        fileList
          ..clear()
          ..assignAll(
            result.uploadedFiles?.map(
                  (f) => UploadedFile(
                    path: f.category?.split('/').last ?? '',
                    category: f.tag != null && f.tag!.isNotEmpty
                        ? "${f.tag}_${f.category}"
                        : f.category,
                  ),
                ) ??
                [],
          );

        // 🔹 Validations (can be extracted into one helper call)
        validateAll();
        update();
      },
      networkManager: networkManager,
    );
  }

  String getLabelFromValue(List<DgSyncRequired> list, String value) {
    final match = list.firstWhere(
      (item) =>
          item.value.toString().trim().toLowerCase() ==
          value.trim().toLowerCase(),
      orElse: () => DgSyncRequired(label: "", value: ""),
    );
    return match?.label ?? value;
  }

  String formatCategory(String category, String? tag) {
    switch (category) {
      case 'technical_proposal':
        if (tag == 'first') return 'First Technical Proposal';
        if (tag == 'final') return 'Final Technical Proposal';
        return 'Technical Proposal';

      case 'commercial_proposal':
        if (tag == 'first') return 'First Commercial Proposal';
        if (tag == 'final') return 'Final Commercial Proposal';
        return 'Commercial Proposal';

      case 'finance_document':
        return 'Finance Document';

      default:
        return category.replaceAll('_', ' ').capitalizeFirst ?? category;
    }
  }

  // Future<void> getLeadDataByIdList(
  //   BuildContext context,
  //   bool isLoading,
  //   String leadId,
  // ) async {
  //   var loadingIndicator = LoadingProgressDialog();
  //   commonGetApiCallFormate(
  //     context,
  //     title: 'Update Lead Screen',
  //     apiEndPoint: '${ApiUrl.leadList}/$leadId',
  //     allowHeader: true,
  //     state: state,
  //     message: message,
  //     isStatus: false,
  //     apisLoading: (isTrue) {
  //       if (isLoading) {
  //         if (isTrue) {
  //           loadingIndicator.show(context, '');
  //         } else {
  //           loadingIndicator.hide(context);
  //         }
  //       }
  //     },
  //     onResponse: (data) {
  //       var responseDetail = LeadByIdModel.fromJson(data);
  //       logcat("onResponse::", jsonEncode(responseDetail.result));

  //       // Populate text fields and reactive variables
  //       final result = responseDetail.result;
  //       companyNameCtr.text = result?.companyName ?? '';
  //       addressCtr.text = result?.address ?? '';
  //       countryCtr.text = result?.countryName ?? '';
  //       selectedCountryId.value = result?.country ?? 0;
  //       stateCtr.text = result?.stateName ?? '';
  //       selectedStateId.value = result?.state ?? 0;
  //       districtCtr.text = result?.districtName ?? '';
  //       selectedDistrictId.value = result!.district ?? 0;
  //       personNameCtr.text = result.contactPersonName ?? '';
  //       personMobileCtr.text = result.contactPersonMobile ?? '';
  //       latitudeCtr.text = result.latitude?.toString() ?? '';
  //       longitudeCtr.text = result.longitude?.toString() ?? '';
  //       dgCapacityCtr.text = result.dgCapacityKva?.toString() ?? '';
  //       installedSolarCapCtr.text =
  //           result.currInstSolarCapKwp?.toString() ?? '';
  //       sanctionedLoadCtr.text = result.sanctionedLoadKva?.toString() ?? '';
  //       gridAvailabilityCtr.text = result.gridAvailabilityHrs?.toString() ?? '';
  //       peakMonthlyEnergyCtr.text =
  //           result.peakMonthlyEnergyConsKwh?.toString() ?? '';
  //       requiredSolarCapCtr.text = result.requiredSolarCapKwp?.toString() ?? '';
  //       distanceToTransformerCtr.text =
  //           result.distToNearestTransformer?.toString() ?? '';
  //       ratingOfTransformerCtr.text =
  //           result.ratingOfNearestTransformerKva?.toString() ?? '';
  //       distInverterACDBCtr.text =
  //           result.distBtwInverterAcdbPanelMtrs?.toString() ?? '';
  //       distSolarACDBCtr.text =
  //           result.distBtwSolarAcdbPanelMtrs?.toString() ?? '';
  //       buildingHeightCtr.text = result.buildingHeight?.toString() ?? '';
  //       roofSizeLengthCtr.text = result.roofSizeLengthFt?.toString() ?? '';
  //       roofSizeBreadthCtr.text = result.roofSizeBreadthFt?.toString() ?? '';
  //       ageOfMetalSheetCtr.text = result.ageOfMetalSheet?.toString() ?? '';
  //       groundSizeLengthCtr.text = result.groundSizeLengthFt?.toString() ?? '';
  //       groundSizeBreadthCtr.text =
  //           result.groundSizeBreadthFt?.toString() ?? '';
  //       otherRemarksCtr.text = result.otherRemarks ?? '';
  //       scheduleMeetingCtr.text = result.meeting?.scheduledAt ?? '';

  //       // Set dropdown values
  //       selectedRequiredSolutionTypeValue.value =
  //           result.requiredSolutionType ?? '';
  //       selectedRequiredSolutionTypeLabel.value =
  //           result.requiredSolutionType ?? '';
  //       requiredSolutionTypeCtr.text = result.requiredSolutionType ?? '';

  //       selectedRequiredSolutionValue.value = result.requiredSolution ?? '';
  //       selectedRequiredSolutionLabel.value = result.requiredSolution ?? '';
  //       requiredSolutionCtr.text = result.requiredSolution ?? '';

  //       selectedLeadCategoryValue.value = result.leadCategory ?? '';
  //       selectedLeadCategoryLabel.value = result.leadCategory ?? '';
  //       leadCategoryCtr.text = result.leadCategory ?? '';

  //       selectedDgSyncValue.value = result.dgSyncRequired.toString() ?? '';
  //       selectedDgSyncLabel.value = result?.dgSyncRequired ? 'Yes' : 'No';
  //       dgSyncCtr.text = result.dgSyncRequired ? 'Yes' : 'No';

  //       selectedVfdValue.value = result.vfdRequired.toString() ?? '';
  //       selectedVfdLabel.value = result.vfdRequired ? 'Yes' : 'No';
  //       vfdCtr.text = result.vfdRequired ? 'Yes' : 'No';

  //       selectedPurposeOfSolarisationValue.value =
  //           result.purposeOfSolarisation ?? '';
  //       selectedPurposeOfSolarisationLabel.value =
  //           result.purposeOfSolarisation ?? '';
  //       purposeOfSolarizationCtr.text = result.purposeOfSolarisation ?? '';

  //       selectedRoofNatureValue.value = result.roofNature ?? '';
  //       selectedRoofNatureLabel.value = result.roofNature ?? '';
  //       roofNatureCtr.text = result.roofNature ?? '';

  //       // Populate load elements (if any)
  //       productDetailList.clear();
  //       if (result.loadElementDetails != null &&
  //           result.loadElementDetails!.isNotEmpty) {
  //         productDetailList.assignAll(
  //           result.loadElementDetails!.map((element) {
  //             return LoadElement(
  //               deviceName: element.deviceName ?? '',
  //               category: element.category ?? '',
  //               power: element.powerRatingW?.toString() ?? '',
  //               usageHrs: element.dailyUsageHrs?.toString() ?? '',
  //               energyWh: element.energyWh?.toString() ?? '',
  //               energyKWh: element.energyKWh?.toString() ?? '',
  //             );
  //           }).toList(),
  //         );
  //       }

  //       // Populate uploaded files
  //       fileList.clear();
  //       if (result.uploadedFiles != null && result.uploadedFiles!.isNotEmpty) {
  //         fileList.assignAll(
  //           result.uploadedFiles!.map((file) {
  //             return UploadFile(
  //               uploadFile:
  //                   file.path?.split('/').last ?? '', // Use file name from path
  //               category: file.category ?? '',
  //             );
  //           }).toList(),
  //         );
  //       }

  //       validateAll();
  //       update();
  //     },
  //     networkManager: networkManager,
  //   );
  // }

  void validateAll() {
    validateCompanyName(companyNameCtr.text);
    validateAddress(addressCtr.text);
    validateCountry(countryCtr.text);
    validateState(stateCtr.text);
    validateDistrict(districtCtr.text);
    validatePersonName(personNameCtr.text);
    validatePersonMobile(personMobileCtr.text);

    validateRequiredSolutionType(selectedRequiredSolutionTypeValue.value);
    validateRequiredSolution(selectedRequiredSolutionValue.value);
    validateLeadCategory(selectedLeadCategoryValue.value);

    validateRoofNature(selectedRoofNatureValue.value);

    validateScheduleMeeting(scheduleMeetingCtr.text);

    validateStep1();
    validateStep2();
    // validateStep3();
    // validateStep4();
  }
}
