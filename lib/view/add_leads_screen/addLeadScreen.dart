import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/controller/leads_controller/add_leads_controller.dart';
import 'package:sales_app/utils/buildDynamicTable.dart';
import 'package:sales_app/utils/custom_stepper_widget.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sizer/sizer.dart';

// Assuming CustomLinearStepper is in a separate file or included here
class AddLeadScreen extends StatefulWidget {
  final bool isEdit;
  const AddLeadScreen({super.key, required this.isEdit});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final AddLeadsController controller = Get.isRegistered<AddLeadsController>()
      ? Get.find<AddLeadsController>()
      : Get.put(AddLeadsController());
  int _currentStep = 0;

  // Define steps for the stepper
  final List<String> _steps = [
    'Company Details',
    'Contact Info',
    'Load Element',
    'Files',
  ];
  // Callback to handle step tap
  void _onStepTapped(int index) {
    setState(() {
      _currentStep = index;
    });
  }

  void _onStepContinue() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      // Submit logic
      if (controller.isFormValid()) {
        // Implement submit logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lead ${widget.isEdit ? "Updated" : "Added"} Successfully',
            ),
          ),
        );
        Get.back();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    Statusbar().trasparentStatusbarProfile(false);
    return CustomParentScaffold(
      onWillPop: () async {
        return true;
      },
      onTap: () {
        hideKeyboard(context);
      },
      isExtendBodyScreen: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: EdgeInsets.only(top: 1.h),
        child: Column(
          children: [
            getCommonToolbar(
              widget.isEdit == true ? 'Edit Lead' : "Add Leads",
              onClick: () {
                Get.back();
              },
            ),
            getDynamicSizedBox(height: 2.h),
            CustomLinearStepper(
              currentStep: _currentStep,
              steps: _steps,
              activeColor: primaryColor,
              inactiveColor: Colors.grey[300]!,
              onStepTapped: (val) {
                // _onStepTapped(val);
              },
            ),
            getDynamicSizedBox(height: 2.h),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 6.w,
                        right: 6.w,
                        top: 2.h,
                        bottom: 10.h,
                      ),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step 1: Company Details
                            if (_currentStep == 0) ...[
                              getLable("Company Name", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.companyNameNode,
                                  controller: controller.companyNameCtr,
                                  hintLabel: "Enter Company Name",
                                  onChanged: (val) {
                                    controller.validateCompanyName(val);
                                  },
                                  inputType: TextInputType.text,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.companyNameModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Address", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.addressNode,
                                  controller: controller.addressCtr,
                                  hintLabel: "Enter Address",
                                  onChanged: (val) {
                                    controller.validateAddress(val);
                                  },
                                  inputType: TextInputType.text,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.addressModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Country", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.countryNode,
                                  controller: controller.countryCtr,
                                  hintLabel: "Select Country",
                                  onChanged: (val) {
                                    controller.validateCountry(val);
                                  },
                                  onTap: () {
                                    controller.countrySearchCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "Country",
                                      onCloseClick: () {
                                        controller.applyFilterforCountry('');
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText:
                                      controller.countryModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("State", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.stateNode,
                                  controller: controller.stateCtr,
                                  hintLabel: "Select State",
                                  onChanged: (val) {
                                    controller.validateState(val);
                                  },
                                  onTap: () {
                                    controller.stateSearchCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller.setStateListDialog(),
                                      title: "State",
                                      onCloseClick: () {
                                        controller.applyFilterForState('');
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText: controller.stateModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("District", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.districtNode,
                                  controller: controller.districtCtr,
                                  hintLabel: "Select District",
                                  onChanged: (val) {
                                    controller.validateDistrict(val);
                                  },
                                  onTap: () {
                                    controller.districtSearchCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setDistrictListDialog(),
                                      title: "District",
                                      onCloseClick: () {
                                        controller.applyFilterForDistrict('');
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText:
                                      controller.districtModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Contact Person Name", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.personNameNode,
                                  controller: controller.personNameCtr,
                                  hintLabel: "Enter Person Name",
                                  onChanged: (val) {
                                    controller.validatePersonName(val);
                                  },
                                  inputType: TextInputType.text,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.personNameModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable(
                                "Contact Person Mobile",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.personMobileNode,
                                  controller: controller.personMobileCtr,
                                  hintLabel: "Enter Mobile Number",
                                  onChanged: (val) {
                                    controller.validatePersonMobile(val);
                                  },
                                  inputType: TextInputType.phone,
                                  formType: FieldType.mobile,
                                  wantSuffix: false,
                                  errorText:
                                      controller.personMobileModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Latitude"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.latitudeNode,
                                  controller: controller.latitudeCtr,
                                  hintLabel: "Enter Latitude",
                                  onChanged: (val) {
                                    controller.validateLatitude(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.latitudeModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Longitude"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.longitudeNode,
                                  controller: controller.longitudeCtr,
                                  hintLabel: "Enter Longitude",
                                  onChanged: (val) {
                                    controller.validateLongitude(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.mobile,
                                  wantSuffix: false,
                                  errorText:
                                      controller.longitudeModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable(
                                "Required Solution Type",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.requiredSolutionTypeNode,
                                  controller:
                                      controller.requiredSolutionTypeCtr,
                                  hintLabel: "Select Solution Type",
                                  onChanged: (val) {
                                    controller.validateRequiredSolutionType(
                                      val,
                                    );
                                  },
                                  onTap: () {
                                    controller.requiredSolutionTypeCtr.text =
                                        "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setRequiredSolutionTypeListDialog(),
                                      title: "Solution Type",
                                      onCloseClick: () {
                                        controller
                                            .applyFilterForRequiredSolutionType(
                                              '',
                                            );
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText: controller
                                      .requiredSolutionTypeModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Required Solution", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.requiredSolutionNode,
                                  controller: controller.requiredSolutionCtr,
                                  hintLabel: "Select Solution",
                                  onChanged: (val) {
                                    controller.validateRequiredSolution(val);
                                  },
                                  onTap: () {
                                    controller.requiredSolutionCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setRequiredSolutionListDialog(),
                                      title: "Required Solution",
                                      onCloseClick: () {
                                        controller
                                            .applyFilterForRequiredSolution('');
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText: controller
                                      .requiredSolutionModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Lead Category", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.leadCategoryNode,
                                  controller: controller.leadCategoryCtr,
                                  hintLabel: "Select Lead Category",
                                  onChanged: (val) {
                                    controller.validateLeadCategory(val);
                                  },
                                  onTap: () {
                                    controller.leadCategoryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setLeadCategoryListDialog(),
                                      title: "Lead Category",
                                      onCloseClick: () {
                                        controller.applyFilterForLeadCategory(
                                          '',
                                        );
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText:
                                      controller.leadCategoryModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("DG Capacity (KVA)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.dgCapacityNode,
                                  controller: controller.dgCapacityCtr,
                                  hintLabel: "Enter DG Capacity",
                                  onChanged: (val) {
                                    controller.validateDGCapacity(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.dgCapacityModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("DG Sync Required"),
                              getReactiveDropdown(
                                hint: "Select DG Sync",
                                items: controller.dgSync,
                                selectedValue: controller.selectDgSync,
                                onChanged: (value) {
                                  setState(() {
                                    controller.selectDgSync = value!;
                                  });
                                },
                              ),
                              getDynamicSizedBox(height: 2.h),
                              getLable(
                                "Current Installed Solar Capacity (KWp)",
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.installedSolarCapNode,
                                  controller: controller.installedSolarCapCtr,
                                  hintLabel: "Enter Installed Solar Capacity",
                                  onChanged: (val) {
                                    controller.validateInstalledSolarCap(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.mobile,
                                  wantSuffix: false,
                                  errorText: controller
                                      .installedSolarCapModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Sanctioned Load (KVA)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.sanctionedLoadNode,
                                  controller: controller.sanctionedLoadCtr,
                                  hintLabel: "Enter Sanctioned Load",
                                  onChanged: (val) {
                                    controller.validateSanctionedLoad(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.mobile,
                                  wantSuffix: false,
                                  errorText: controller
                                      .sanctionedLoadModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("VFD Required"),
                              getReactiveDropdown(
                                hint: "Select VFD",
                                items: controller.vfd,
                                selectedValue: controller.selectVfd,
                                onChanged: (value) {
                                  setState(() {
                                    controller.selectVfd = value!;
                                  });
                                },
                              ),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Grid Availability (Hours)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.gridAvailabilityNode,
                                  controller: controller.gridAvailabilityCtr,
                                  hintLabel: "Enter Grid Availability",
                                  onChanged: (val) {
                                    controller.validateGridAvailability(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.mobile,
                                  wantSuffix: false,
                                  errorText: controller
                                      .gridAvailabilityModel
                                      .value
                                      .error,
                                );
                              }),
                            ],
                            // Step 2: Contact Information
                            if (_currentStep == 1) ...[
                              getLable("Peak Monthly Energy Cons (KWH)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.peakMonthlyEnergyNode,
                                  controller: controller.peakMonthlyEnergyCtr,
                                  hintLabel: "Enter Peak Monthly Energy Cons",
                                  onChanged: (val) {
                                    // controller.validatePeakMonthlyEnergy(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .peakMonthlyEnergyModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Required Solar Cap (KWp)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.requiredSolarCapNode,
                                  controller: controller.requiredSolarCapCtr,
                                  hintLabel: "Enter Required Solar Cap",
                                  onChanged: (val) {
                                    // controller.validateRequiredSolarCap(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .requiredSolarCapModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable(
                                "Distance to Nearest Transformer (Mtrs)",
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.distanceToTransformerNode,
                                  controller:
                                      controller.distanceToTransformerCtr,
                                  hintLabel:
                                      "Enter Distance to Nearest Transformer",
                                  onChanged: (val) {
                                    // controller.validateDistanceToTransformer(
                                    //   val,
                                    // );
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .distanceToTransformerModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Rating of Nearest Transformer (KVA)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.ratingOfTransformerNode,
                                  controller: controller.ratingOfTransformerCtr,
                                  hintLabel:
                                      "Enter Rating of Nearest Transformer",
                                  onChanged: (val) {
                                    // controller.validateRatingOfTransformer(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .ratingOfTransformerModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Purpose of Solarization"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.purposeOfSolarizationNode,
                                  controller:
                                      controller.purposeOfSolarizationCtr,
                                  hintLabel: "Select Purpose of Solarization",
                                  onChanged: (val) {
                                    // controller.validatePurposeOfSolarization(
                                    //   val,
                                    // );
                                  },
                                  onTap: () {
                                    controller.purposeOfSolarizationCtr.text =
                                        "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setPurposeOfSolarizationListDialog(),
                                      title: "Purpose of Solarization",
                                      onCloseClick: () {
                                        controller
                                            .applyFilterForPurposeOfSolarization(
                                              '',
                                            );
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText: controller
                                      .purposeOfSolarizationModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Dist. Inverter & ACDB Panel (Mtrs)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.distInverterACDBNode,
                                  controller: controller.distInverterACDBCtr,
                                  hintLabel:
                                      "Enter Dist. Inverter & ACDB Panel",
                                  onChanged: (val) {
                                    // controller.validateDistInverterACDB(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .distInverterACDBModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Dist. Solar & ACDB Panel (Mtrs)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.distSolarACDBNode,
                                  controller: controller.distSolarACDBCtr,
                                  hintLabel:
                                      "Enter Dist. Solar & ACDB Panel (Mtrs)",
                                  onChanged: (val) {
                                    // controller.validateDistSolarACDB(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.distSolarACDBModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Building Height (Floors)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.buildHeightNode,
                                  controller: controller.buildingHeightCtr,
                                  hintLabel: "Enter Building Height (Floors)",
                                  onChanged: (val) {
                                    // controller.validateBuildingHeight(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .buildingHeightModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Roof Size Length (ft)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.roofSizeLengthNode,
                                  controller: controller.roofSizeLengthCtr,
                                  hintLabel: "Enter Roof Size Length",
                                  onChanged: (val) {
                                    // controller.validateRoofSizeLength(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .roofSizeLengthModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Roof Size Breadth (ft)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.roofSizeBreadthNode,
                                  controller: controller.roofSizeBreadthCtr,
                                  hintLabel: "Enter Roof Size Breadth",
                                  onChanged: (val) {
                                    // controller.validateRoofSizeBreadth(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .roofSizeBreadthModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Roof Nature", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.roofNatureNode,
                                  controller: controller.roofNatureCtr,
                                  hintLabel: "Select Roof Nature",
                                  onChanged: (val) {
                                    controller.validateRoofNature(val);
                                  },
                                  onTap: () {
                                    controller.roofNatureCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setRoofNatureListDialog(),
                                      title: "Roof Nature",
                                      onCloseClick: () {
                                        controller.applyFilterForRoofNature('');
                                      },
                                    ).then((_) {});
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText:
                                      controller.roofNatureModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Age of Metal Sheet (years)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.ageOfMetalSheetNode,
                                  controller: controller.ageOfMetalSheetCtr,
                                  hintLabel: "Enter Age of Metal Sheet",
                                  onChanged: (val) {
                                    // controller.validateAgeOfMetalSheet(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .ageOfMetalSheetModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Ground Size Length (ft)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.groundSizeLengthNode,
                                  controller: controller.groundSizeLengthCtr,
                                  hintLabel: "Enter Ground Size Length",
                                  onChanged: (val) {
                                    // controller.validateGroundSizeLength(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .groundSizeLengthModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Ground Size Breadth (ft)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.groundSizeBreadthNode,
                                  controller: controller.groundSizeBreadthCtr,
                                  hintLabel: "Enter Ground Size Breadth",
                                  onChanged: (val) {
                                    // controller.validateGroundSizeBreadth(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText: controller
                                      .groundSizeBreadthModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Other Remarks"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.otherRemarksNode,
                                  controller: controller.otherRemarksCtr,
                                  hintLabel: "Enter Other Remarks",
                                  onChanged: (val) {
                                    // controller.validateOtherRemarks(val);
                                  },
                                  inputType: TextInputType.text,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.otherRemarksModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Schedule Meeting", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.scheduleMeetingNode,
                                  controller: controller.scheduleMeetingCtr,
                                  hintLabel: "Select Schedule Meeting",
                                  onChanged: (val) {
                                    controller.validateScheduleMeeting(val);
                                  },
                                  onTap: () {
                                    controller.openDatePicker(
                                      context: context,
                                      title: 'Select Start Date',
                                      controller: controller.scheduleMeetingCtr,
                                      dateRx: controller.startDate,
                                      model: controller.scheduleMeeeingModel,
                                    );
                                  },
                                  formType: FieldType.text,
                                  wantSuffix: true,
                                  isdown: true,
                                  isReadOnly: true,
                                  inputType: TextInputType.none,
                                  errorText: controller
                                      .scheduleMeeeingModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                            ],
                            // Step 3: Location Details
                            if (_currentStep == 2) ...[
                              getCommonLableWithButton(
                                "Add Load Element",
                                // isRequired: true,
                                onClick: () {
                                  controller.addLoadElement(context);
                                },
                              ),
                              Obx(() {
                                if (controller.productDetailList.isEmpty) {
                                  return const SizedBox();
                                }
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: buildDynamicTable(
                                    data: controller.productDetailList,
                                    columns: controller.leadsColumns,
                                    getValues: (item) => [
                                      item.deviceName.toString(),
                                      item.category.toString(),
                                      item.power.toString(),
                                      item.usageHrs.toString(),
                                      item.energyWh.toString(),
                                      item.energyKWh.toString(),
                                    ],
                                    onEdit: (i, item) {
                                      controller.addLoadElement(
                                        context,
                                        loadElementItem: item,
                                        index: i,
                                      );
                                    },
                                    onDelete: (i) {
                                      controller.deleteLoad(i);
                                    },
                                  ),
                                );
                              }),
                            ],
                            // Step 4: Solution Requirements
                            if (_currentStep == 3) ...[
                              getCommonLableWithButton(
                                "Add Files",
                                // isRequired: true,
                                onClick: () {
                                  controller.addUploadFile(context);
                                },
                              ),
                              Obx(() {
                                if (controller.fileList.isEmpty) {
                                  return const SizedBox();
                                }
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: buildDynamicTable(
                                    data: controller.fileList,
                                    columns: controller.uploadColumns,
                                    getValues: (file) => [
                                      file.uploadFile.toString(),
                                      file.category.toString(),
                                    ],
                                    onEdit: (i, file) {
                                      controller.addUploadFile(
                                        context,
                                        fileItem: file,
                                        index: i,
                                      );
                                    },
                                    onDelete: (i) => controller.deleteFile(i),
                                  ),
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                            ],
                            getDynamicSizedBox(height: 2.h),
                            // Navigation Buttons
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: getFormButton(
                                      context,
                                      _onStepCancel,
                                      _currentStep == 0 ? 'Cancel' : 'Previous',
                                      validate: true,
                                    ),
                                  ),
                                  getDynamicSizedBox(width: 3.w),
                                  Expanded(
                                    child: Obx(() {
                                      bool isNextEnabled = false;
                                      if (_currentStep == 0) {
                                        isNextEnabled =
                                            controller.isStep1Valid.value;
                                      } else if (_currentStep == 1) {
                                        isNextEnabled =
                                            controller.isStep2Valid.value;
                                      } else if (_currentStep == 2) {
                                        isNextEnabled =
                                            controller.isStep3Valid.value;
                                      } else if (_currentStep == 3) {
                                        isNextEnabled = controller
                                            .isFormValid();
                                      }
                                      return getFormButton(
                                        context,
                                        _onStepContinue,
                                        _currentStep == _steps.length - 1
                                            ? 'Submit'
                                            : 'Next',
                                        validate: isNextEnabled,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
