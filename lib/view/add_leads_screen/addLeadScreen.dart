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
  var controller = Get.put(AddLeadsController());
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
            getDynamicSizedBox(height: 1.h),
            CustomLinearStepper(
              currentStep: _currentStep,
              steps: _steps,
              activeColor: primaryColor,
              inactiveColor: Colors.grey[300]!,
              onStepTapped: _onStepTapped,
            ),
            getDynamicSizedBox(height: 2.h),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 3.w,
                        right: 3.w,
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
                                    controller.val.validateCompanyName(val);
                                  },
                                  inputType: TextInputType.text,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.companyNameModel.value.error,
                                );
                              }),
                              // Obx(() {
                              //   return getTextField(
                              //     context: context,
                              //     wantLabel: true,
                              //     isBorderSideEnable: true,
                              //     label: 'Company Name',
                              //     ctr: controller.companyNameCtr,
                              //     node: controller.companyNameNode,
                              //     model: controller.companyNameModel.value,
                              //     function: (val) {
                              //       controller.validateFields(
                              //         val,
                              //         iscomman: true,
                              //         model: controller.companyNameModel,
                              //         errorText1: 'Company Name is required',
                              //       );
                              //     },
                              //     hint: 'Enter Company Name',
                              //     isRequired: true,
                              //   );
                              // }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Address", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.addressNode,
                                  controller: controller.addressCtr,
                                  hintLabel: "Enter Address",
                                  onChanged: (val) {
                                    controller.val.validateAddress(val);
                                  },
                                  inputType: TextInputType.text,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.addressModel.value.error,
                                );
                              }),
                              getLable("Country", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.countryNode,
                                  controller: controller.countryCtr,
                                  hintLabel: "Enter Country",
                                  onChanged: (val) {
                                    controller.val.validateCountry(val);
                                  },
                                  onTap: () {
                                    controller.countrySearchCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "Country",
                                      onCloseClick: () {},
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
                                  hintLabel: "Enter State",
                                  onChanged: (val) {},
                                  onTap: () {
                                    controller.countryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "State",
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
                                  errorText: controller.stateModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable("District", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.districtNode,
                                  controller: controller.districtCtr,
                                  hintLabel: "Enter District",
                                  onChanged: (val) {
                                    controller.val.validateDistrict(val);
                                  },
                                  onTap: () {
                                    controller.countryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "District",
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
                                      controller.districtModel.value.error,
                                );
                              }),
                              getLable("Contact Person Name", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.personNameNode,
                                  controller: controller.personNameCtr,
                                  hintLabel: "Enter Person Name",
                                  onChanged: (val) {
                                    controller.val.validatePersonName(val);
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
                                    controller.val.validatePersonMobile(val);
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
                                    controller.val.validateLatitude(val);
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
                                    controller.val.validateLongitude(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.mobile,
                                  wantSuffix: false,
                                  errorText:
                                      controller.longitudeModel.value.error,
                                );
                              }),
                              getLable(
                                "Required Solution Type",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.requiredSolutionTypeNode,
                                  controller:
                                      controller.requiredSolutionTypeCtr,
                                  hintLabel: "Enter Solution Type",
                                  onChanged: (val) {
                                    controller.val.validateRequiredSolutionType(
                                      val,
                                    );
                                  },
                                  onTap: () {
                                    controller.countryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "Solution Type",
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
                                  hintLabel: "Enter Solution",
                                  onChanged: (val) {
                                    controller.val.validateRequiredSolution(
                                      val,
                                    );
                                  },
                                  onTap: () {
                                    controller.countryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "Required Solution",
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
                                  hintLabel: "Enter Lead Category",
                                  onChanged: (val) {
                                    controller.val.validateLeadCategory(val);
                                  },
                                  onTap: () {
                                    controller.countryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "Lead Category",
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
                                    controller.val.validateDGCapacity(val);
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
                                hint: "Enter DG Sync",
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
                                    controller.val.validateInstalledSolarCap(
                                      val,
                                    );
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
                                    controller.val.validateSanctionedLoad(val);
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
                                hint: "Enter VFD",
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
                                    controller.val.validateGridAvailability(
                                      val,
                                    );
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
                              getLable(
                                "Peak Monthly Energy Cons (KWH)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.peakMonthlyEnergyNode,
                                  controller: controller.peakMonthlyEnergyCtr,
                                  hintLabel: "Enter Peak Monthly Energy Cons",
                                  onChanged: (val) {
                                    controller.val.validatePeakMonthlyEnergy(
                                      val,
                                    );
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
                              getLable(
                                "Required Solar Cap (KWp)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.requiredSolarCapNode,
                                  controller: controller.requiredSolarCapCtr,
                                  hintLabel: "Enter Required Solar Cap",
                                  onChanged: (val) {
                                    controller.val.validateRequiredSolarCap(
                                      val,
                                    );
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
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.distanceToTransformerNode,
                                  controller:
                                      controller.distanceToTransformerCtr,
                                  hintLabel:
                                      "Enter Distance to Nearest Transformer",
                                  onChanged: (val) {
                                    controller.val
                                        .validateDistanceToTransformer(val);
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
                              getLable(
                                "Rating of Nearest Transformer (KVA)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.ratingOfTransformerNode,
                                  controller: controller.ratingOfTransformerCtr,
                                  hintLabel:
                                      "Enter Rating of Nearest Transformer",
                                  onChanged: (val) {
                                    controller.val.validateRatingOfTransformer(
                                      val,
                                    );
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
                              getLable(
                                "Purpose of Solarization",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.purposeOfSolarizationNode,
                                  controller:
                                      controller.purposeOfSolarizationCtr,
                                  hintLabel: "Enter Purpose of Solarization",
                                  onChanged: (val) {
                                    controller.val
                                        .validatePurposeOfSolarization(val);
                                  },
                                  onTap: () {
                                    controller.countryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "Purpose of Solarization",
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
                                  errorText: controller
                                      .purposeOfSolarizationModel
                                      .value
                                      .error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable(
                                "Dist. Inverter & ACDB Panel (Mtrs)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.distInverterACDBNode,
                                  controller: controller.distInverterACDBCtr,
                                  hintLabel:
                                      "Enter Dist. Inverter & ACDB Panel",
                                  onChanged: (val) {
                                    controller.val.validateDistInverterACDB(
                                      val,
                                    );
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
                              getLable(
                                "Dist. Solar & ACDB Panel (Mtrs)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.distSolarACDBNode,
                                  controller: controller.distSolarACDBCtr,
                                  hintLabel:
                                      "Enter Dist. Solar & ACDB Panel (Mtrs)",
                                  onChanged: (val) {
                                    controller.val.validateDistSolarACDB(val);
                                  },
                                  inputType: TextInputType.number,
                                  formType: FieldType.text,
                                  wantSuffix: false,
                                  errorText:
                                      controller.distSolarACDBModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable(
                                "Building Height (Floors)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.buildHeightNode,
                                  controller: controller.buildingHeightCtr,
                                  hintLabel: "Enter Building Height (Floors)",
                                  onChanged: (val) {
                                    controller.val.validateDistInverterACDB(
                                      val,
                                    );
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
                              getLable(
                                "Roof Size Length (ft)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.roofSizeLengthNode,
                                  controller: controller.roofSizeLengthCtr,
                                  hintLabel: "Enter Roof Size Length",
                                  onChanged: (val) {
                                    controller.val.validateRoofSizeLength(val);
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
                              getLable(
                                "Roof Size Breadth (ft)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.roofSizeBreadthNode,
                                  controller: controller.roofSizeBreadthCtr,
                                  hintLabel: "Enter Roof Size Breadth",
                                  onChanged: (val) {
                                    controller.val.validateRoofSizeBreadth(val);
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
                                  hintLabel: "Enter Roof Nature",
                                  onChanged: (val) {
                                    controller.val.validateRoofNature(val);
                                  },
                                  onTap: () {
                                    controller.countryCtr.text = "";
                                    commonDropDownDialog(
                                      context,
                                      content: controller
                                          .setCountryListDialog(),
                                      title: "Roof Nature",
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
                                      controller.roofNatureModel.value.error,
                                );
                              }),
                              getDynamicSizedBox(height: 2.h),
                              getLable(
                                "Age of Metal Sheet (years)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.ageOfMetalSheetNode,
                                  controller: controller.ageOfMetalSheetCtr,
                                  hintLabel: "Enter Age of Metal Sheet",
                                  onChanged: (val) {
                                    controller.val.validateAgeOfMetalSheet(val);
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
                              getLable(
                                "Ground Size Length (ft)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.groundSizeLengthNode,
                                  controller: controller.groundSizeLengthCtr,
                                  hintLabel: "Enter Ground Size Length",
                                  onChanged: (val) {
                                    controller.val.validateGroundSizeLength(
                                      val,
                                    );
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
                              getLable(
                                "Ground Size Breadth (ft)",
                                isRequired: true,
                              ),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.groundSizeBreadthNode,
                                  controller: controller.groundSizeBreadthCtr,
                                  hintLabel: "Enter Ground Size Breadth",
                                  onChanged: (val) {
                                    controller.val.validateGroundSizeBreadth(
                                      val,
                                    );
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
                              getLable("Other Remarks", isRequired: true),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.otherRemarksNode,
                                  controller: controller.otherRemarksCtr,
                                  hintLabel: "Enter Other Remarks",
                                  onChanged: (val) {
                                    controller.val.validateOtherRemarks(val);
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
                                    controller.val.validateScheduleMeeting(val);
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
                                isRequired: true,
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
                                      item.usageHrs.toString(),
                                      item.usageHrs.toString(),
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
                                isRequired: true,
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
                            // Step 5: Additional Details
                            // if (_currentStep == 4) ...[],
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
