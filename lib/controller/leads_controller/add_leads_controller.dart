import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
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
import 'package:sales_app/controller/master_controller/Master_Controller.dart';
import 'package:sales_app/models/LoadElement.dart';
import 'package:sales_app/models/customer_model_wo_p.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';

class AddLeadsController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = "".obs;
  RxBool isFormInvalidate = true.obs;
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
  var aboutUsFilterList = <String>[].obs;
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

  void addLoad(LoadElement element) {
    productDetailList.add(element);
    update();
  }

  void updateLoad(int index, LoadElement element) {
    productDetailList[index] = element;
    update();
  }

  deleteLoad(int index) {
    productDetailList.removeAt(index);
    update();
  }

  void addFile(UploadFile file) {
    fileList.add(file);
  }

  void updateFile(int index, UploadFile file) {
    fileList[index] = file;
  }

  deleteFile(int index) {
    fileList.removeAt(index);
  }

  // 🔹 Controllers
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

  // 🔹 FocusNodes
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

  // 🔹 Validation Models
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
  var latitudeModel = ValidationModel(null, null, isValidate: false).obs;
  var longitudeModel = ValidationModel(null, null, isValidate: false).obs;
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
  var dgCapacityModel = ValidationModel(null, null, isValidate: false).obs;
  var dgSyncModel = ValidationModel(null, null, isValidate: false).obs;
  var installedSolarCapModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
  var sanctionedLoadModel = ValidationModel(null, null, isValidate: false).obs;
  var vfdModel = ValidationModel(null, null, isValidate: false).obs;
  var gridAvailabilityModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;
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

  //Dynamic Lead Element
  late TextEditingController deviceNameCtr,
      categoryCtr,
      powerCtr,
      usageHrsCtr,
      energyWhCtr,
      energyKWhCtr;

  // 🔹 FocusNodes
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

  //Dynamic Lead Element
  late TextEditingController uploadFileCtr,
      uploadCategoryCtr,
      searchUploadCategoryCtr;

  // 🔹 FocusNodes
  late FocusNode uploadFileNode, uploadCategoryNode, searchUploadCategoryNode;

  var uploadFileModel = ValidationModel(null, null, isValidate: false).obs;
  var uploadCategoryModel = ValidationModel(null, null, isValidate: false).obs;
  var searchUploadCategoryModel = ValidationModel(
    null,
    null,
    isValidate: false,
  ).obs;

  @override
  void onInit() {
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

    //Dynamic
    deviceNameCtr = TextEditingController();
    categoryCtr = TextEditingController();
    powerCtr = TextEditingController();
    usageHrsCtr = TextEditingController();
    energyWhCtr = TextEditingController();
    energyKWhCtr = TextEditingController();

    //Dynamic file choose
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

    //Dynamic
    deviceNameNode = FocusNode();
    categorysNode = FocusNode();
    powerNode = FocusNode();
    usageHrsNode = FocusNode();
    energyWhNode = FocusNode();
    energyKWhNode = FocusNode();

    //Dynamic upload file
    uploadFileNode = FocusNode();
    uploadCategoryNode = FocusNode();
    searchUploadCategoryNode = FocusNode();

    update();
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
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
                    // Get.back();
                    // Navigator.pop(context);
                    // countryId.value = countryFilterList[index].countryId
                    //     .toString();
                    // countryCtr.text = countryFilterList[index].shortName;
                    // if (countryCtr.text.toString().isNotEmpty) {
                    //   countryFilterList.clear();
                    //   countryFilterList.addAll(countryList);
                    // }
                    validateCountry(countryCtr.text);
                  },
                  title: showSelectedTextInDialog(
                    // name: countryFilterList[index].shortName,
                    // modelId: countryFilterList[index].countryId.toString(),
                    storeId: countryId.value,
                  ),
                ),
                // commonListDevider(),
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
    // countryFilterList.clear();
    // for (TicketsCountry model in countryList) {
    //   if (model.shortName.toLowerCase().contains(keyword.toLowerCase())) {
    //     countryFilterList.add(model);
    //   }
    // }
    // countryFilterList.refresh();
    // countryFilterList.call();
    // logcat('filterApply', countryFilterList.length.toString());
    update();
  }

  // 🔹 Existing Validation Functions
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
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateCompany(String? val) {
    companyNameModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Address is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
    enableContactInfoButton();
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
    enableContactInfoButton();
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
    enableContactInfoButton();
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
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateLatitude(String? val) {
    latitudeModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter latitude";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateLongitude(String? val) {
    longitudeModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter longitude";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
    enableContactInfoButton();
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
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateDGCapacity(String? val) {
    dgCapacityModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid DG Capacity";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateInstalledSolarCap(String? val) {
    installedSolarCapModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid Installed Solar Capacity";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateSanctionedLoad(String? val) {
    sanctionedLoadModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid Sanctioned Load";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateGridAvailability(String? val) {
    gridAvailabilityModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid Grid Availability (hours)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  // 🔹 New Validation Functions
  void validatePeakMonthlyEnergy(String? val) {
    peakMonthlyEnergyModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Peak Monthly Energy";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid Peak Monthly Energy (kWh)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateRequiredSolarCap(String? val) {
    requiredSolarCapModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Required Solar Cap";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid Required Solar Cap (kWp)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateDistanceToTransformer(String? val) {
    distanceToTransformerModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Distance to Nearest Transformer";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid distance (Mtrs)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateRatingOfTransformer(String? val) {
    ratingOfTransformerModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Rating of Nearest Transformer";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid rating (kVA)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateDistInverterACDB(String? val) {
    distInverterACDBModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Distance Inverter & ACDB Panel";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid distance (Mtrs)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateDistSolarACDB(String? val) {
    distSolarACDBModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Distance Solar & ACDB Panel";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid distance (Mtrs)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateBuildingHeightACDB(String? val) {
    buildingHeightModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Building Height";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateRoofSizeLength(String? val) {
    roofSizeLengthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Roof Size Length";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid length (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateRoofSizeBreadth(String? val) {
    roofSizeBreadthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Roof Size Breadth";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid breadth (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateAgeOfMetalSheet(String? val) {
    ageOfMetalSheetModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Age of Metal Sheet";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid age (years)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateGroundSizeLength(String? val) {
    groundSizeLengthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Ground Size Length";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid length (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  void validateGroundSizeBreadth(String? val) {
    groundSizeBreadthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Ground Size Breadth";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid breadth (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
    enableContactInfoButton();
  }

  void validateScheduleMeetings(String? val) {
    otherRemarksModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Other Remarks is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

  // void validateFields(
  //   dynamic val, {
  //   required Rx<ValidationModel> model,
  //   String? errorText1,
  //   String? errorText2,
  //   String? errorText3,
  //   bool iscomman = false,
  //   bool isemail = false,
  //   bool ispassword = false,
  // }) {
  //   return validateField(
  //     val: val,
  //     models: model,
  //     isEmail: isemail,
  //     iscomman: iscomman,
  //     ispassword: ispassword,
  //     errorText1: errorText1,
  //     errorText2: errorText2,
  //     errorText3: errorText3,
  //     notifyListeners: refresh,
  //     enableBtnFunction: enableContactInfoButton,
  //   );
  // }

  // 🔹 Final Button Enable Check
  
  void enableContactInfoButton() {
    bool isValid = true;

    if (!companyNameModel.value.isValidate) isValid = false;
    if (!addressModel.value.isValidate) isValid = false;
    if (!countryModel.value.isValidate) isValid = false;
    if (!stateModel.value.isValidate) isValid = false;
    if (!districtModel.value.isValidate) isValid = false;
    if (!personNameModel.value.isValidate) isValid = false;
    if (!personMobileModel.value.isValidate) isValid = false;
    if (!latitudeModel.value.isValidate) isValid = false;
    if (!longitudeModel.value.isValidate) isValid = false;
    if (!requiredSolutionTypeModel.value.isValidate) isValid = false;
    if (!requiredSolutionModel.value.isValidate) isValid = false;
    if (!leadCategoryModel.value.isValidate) isValid = false;
    if (!dgCapacityModel.value.isValidate) isValid = false;
    if (!dgSyncModel.value.isValidate) isValid = false;
    if (!installedSolarCapModel.value.isValidate) isValid = false;
    if (!sanctionedLoadModel.value.isValidate) isValid = false;
    if (!vfdModel.value.isValidate) isValid = false;
    if (!gridAvailabilityModel.value.isValidate) isValid = false;
    if (!peakMonthlyEnergyModel.value.isValidate) isValid = false;
    if (!requiredSolarCapModel.value.isValidate) isValid = false;
    if (!distanceToTransformerModel.value.isValidate) isValid = false;
    if (!ratingOfTransformerModel.value.isValidate) isValid = false;
    if (!purposeOfSolarizationModel.value.isValidate) isValid = false;
    if (!distInverterACDBModel.value.isValidate) isValid = false;
    if (!roofSizeLengthModel.value.isValidate) isValid = false;
    if (!roofSizeBreadthModel.value.isValidate) isValid = false;
    if (!roofNatureModel.value.isValidate) isValid = false;
    if (!ageOfMetalSheetModel.value.isValidate) isValid = false;
    if (!groundSizeLengthModel.value.isValidate) isValid = false;
    if (!groundSizeBreadthModel.value.isValidate) isValid = false;
    if (!otherRemarksModel.value.isValidate) isValid = false;

    isFormInvalidate.value = isValid;
  }

  void validatescheduleMeeeingModel(String? val) {
    scheduleMeeeingModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "District is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
  }

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
      minDate: isEndDate && startDate.value.isNotEmpty
          ? dateTimeFormat.parse(startDate.value)
          : null,
      showTimePickers: showTimePickers,
      onDatePicked: (DateTime date) {
        final formatted = dateTimeFormat.format(date);
        dateRx.value = formatted;
        controller.text = formatted;
        validatescheduleMeeeingModel(controller.text);
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
                                  validateLongitude(val);
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
                                  validateLongitude(val);
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
                                  validateLongitude(val);
                                },
                                inputType: TextInputType.text,
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
                                  validateLongitude(val);
                                },
                                inputType: TextInputType.text,
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
                                            validateLongitude(val);
                                          },
                                          inputType: TextInputType.text,
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
                                            validateLongitude(val);
                                          },
                                          inputType: TextInputType.text,
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
                                  'Cancle',
                                  validate: true,
                                ),
                              ),
                              getDynamicSizedBox(width: 3.w),
                              Expanded(
                                child: getFormButton(
                                  context,
                                  () {
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
                                  },
                                  loadElementItem != null ? "Update" : 'Add',
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
                                  'Cancle',
                                  validate: true,
                                ),
                              ),
                              getDynamicSizedBox(width: 3.w),
                              Expanded(
                                child: getFormButton(
                                  context,
                                  () {
                                    final newFile = UploadFile(
                                      uploadFile: uploadFileCtr.text,
                                      category: uploadCategoryCtr.text,
                                    );

                                    if (index == null) {
                                      addFile(newFile); // Add new
                                    } else {
                                      updateFile(
                                        index,
                                        newFile,
                                      ); // Update existing
                                    }
                                    Get.back();
                                  },
                                  fileItem != null ? "Update" : 'Add',
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

  // Common filter
  var currentFilterSource = [].obs;
  var filteredData = [].obs;
  RxString categoryId = "".obs;
  // RxList<ResultWp> customerList = <ResultWp>[].obs;

  RxList<CategoryModel> categoryList = <CategoryModel>[
    CategoryModel(id: "1", name: "Invoice"),
    CategoryModel(id: "2", name: "Bills"),
    CategoryModel(id: "3", name: "Reports"),
    CategoryModel(id: "4", name: "Others"),
  ].obs;

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
        uploadCategoryCtr.clear();
        uploadCategoryCtr.text = data.name;
        categoryId.value = data.id.toString();
        logcat('customerID', categoryId.value);
        validateuploadCategoryModel(uploadCategoryCtr.text);
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

  void validateuploadCategoryModel(String? val) {
    uploadCategoryModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "District is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    enableContactInfoButton();
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
}
