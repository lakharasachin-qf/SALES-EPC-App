import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/file_picker_util.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/controller/leads_controller/add_leads_controller.dart';
import 'package:sales_app/utils/AppPermissions.dart';
import 'package:sales_app/utils/CalendarHelper.dart';
import 'package:sales_app/utils/buildDynamicTable.dart';
import 'package:sales_app/utils/custom_stepper_widget.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';

// Assuming CustomLinearStepper is in a separate file or included here
// ignore: must_be_immutable
class AddLeadScreen extends StatefulWidget {
  final bool isEdit;
  String? leadId;
  AddLeadScreen({super.key, required this.isEdit, this.leadId});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen>
    with WidgetsBindingObserver {
  final AddLeadsController controller = Get.isRegistered<AddLeadsController>()
      ? Get.find<AddLeadsController>()
      : Get.put(AddLeadsController());
  int _currentStep = 0;

  // Define steps for the stepper
  final List<String> _steps = ['Info', 'Site', 'Load Element', 'Files'];
  // Callback to handle step tap
  // void _onStepTapped(int index) {
  //   setState(() {
  //     _currentStep = index;
  //   });
  // }

  Future<void> initAllData() async {
    final loadingIndicator = LoadingProgressDialog();

    try {
      // Show loader before starting all
      loadingIndicator.show(context, '');

      // Run all API calls in parallel
      await Future.wait<void>([
        controller.getDropDownList(
          context,
          false,
        ), // pass false to avoid inner loader
        controller.getLatLongData(context, false),
      ]);

      // After that, if editing, fetch lead data
      if (widget.isEdit == true) {
        controller.isEditMode.value = true;
        await controller.getLeadDataByIdList(
          context,
          false,
          widget.leadId.toString(),
        );
      }
    } catch (e) {
      logcat("Error in initAllData: $e", '');
    } finally {
      // Hide loader at the very end
      loadingIndicator.hide(context);
    }
  }

  @override
  void initState() {
    super.initState();
    CalendarHelper.checkCalendarPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      logcat("IsEdit::", widget.isEdit.toString());
      initAllData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !controller.locationFetched) {
      controller.getLatLongData(context, false);
    }
  }

  void _onStepContinue() {
    bool canProceed = true;

    // Step 2: "Site"
    if (_currentStep == 1 && controller.isTechnicalProposalMode.value) {
      final firstFile = controller.firstTechnicalProposalFile.value;
      final finalFile = controller.finalTechnicalProposalFile.value;

      if (firstFile == null && finalFile == null) {
        // Show error dialog safely
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialogForScreen(
            context,
            'Lead',
            'You have to upload at least one technical proposal.',
            callback: () {
              controller.validateStep2();
              controller.isStep2Valid.value = false;
              controller.update();
            },
          );
        });

        canProceed = false; // Prevent moving to next step
      } else {
        canProceed = controller.isStep2Valid.value;
      }
    }

    if (_currentStep == 1 && controller.isCommercialProposalMode.value) {
      final firstFile = controller.firstCommercialProposalFile.value;
      final finalFile = controller.finalCommercialProposalFile.value;

      if (firstFile == null && finalFile == null) {
        // Show error dialog safely
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialogForScreen(
            context,
            'Lead',
            'You have to upload at least one commercial proposal.',
            callback: () {
              controller.validateStep2();
              controller.isStep2Valid.value = false;
              controller.update();
            },
          );
        });

        canProceed = false; // Prevent moving to next step
      } else {
        canProceed = controller.isStep2Valid.value;
      }
    }

    // Proceed if allowed
    if (canProceed) {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        // Submit logic
        if (controller.isFormValid()) {
          if (widget.isEdit == true) {
            controller.updateLeadApi(
              context,
              int.tryParse(widget.leadId ?? '') ?? 0,
            );
          } else {
            controller.addLeadApi(context);
          }
        }
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
                Get.back(result: true);
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
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10),
                                  ],

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
                                // isRequired: false,
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
                                    controller
                                            .searchRequiredSolutionTypeCtr
                                            .text =
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
                              getLable("Required Solution"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.requiredSolutionNode,
                                  controller: controller.requiredSolutionCtr,
                                  hintLabel: "Select Solution",
                                  onChanged: (val) {
                                    controller.validateRequiredSolution(val);
                                  },
                                  onTap: () {
                                    controller.searchRequiredSolutionCtr.text =
                                        "";
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
                                    controller.searchLeadCategoryCtr.text = "";
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
                              Obx(
                                () => getReactiveDropdown(
                                  hint: "Select DG Sync",
                                  items: controller.filterDgSyncRequiredList
                                      .map((item) => item.label)
                                      .toList(),
                                  selectedValue:
                                      controller
                                          .selectedDgSyncLabel
                                          .value
                                          .isNotEmpty
                                      ? controller.selectedDgSyncLabel.value
                                      : null,
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.selectedDgSyncLabel.value =
                                          value;

                                      final selectedItem = controller
                                          .dgSyncRequiredList
                                          .firstWhere(
                                            (item) => item.label == value,
                                            orElse: () => controller
                                                .dgSyncRequiredList
                                                .first,
                                          );

                                      controller.selectedDgSyncValue.value =
                                          selectedItem.value;

                                      logcat(
                                        "dg_sync_required",
                                        controller.selectedDgSyncValue.value,
                                      );
                                    }
                                  },
                                ),
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
                              Obx(
                                () => getReactiveDropdown(
                                  hint: "Select VFD",
                                  items: controller.filterVfdRequiredList
                                      .map((item) => item.label)
                                      .toList(), // Display labels
                                  selectedValue:
                                      controller
                                          .selectedVfdLabel
                                          .value
                                          .isNotEmpty
                                      ? controller.selectedVfdLabel.value
                                      : null,
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.selectedVfdLabel.value = value;

                                      final selectedItem = controller
                                          .vfdRequiredList
                                          .firstWhere(
                                            (item) => item.label == value,
                                            orElse: () => controller
                                                .vfdRequiredList
                                                .first,
                                          );

                                      controller.selectedVfdValue.value =
                                          selectedItem.value;
                                      controller.vfdCtr.text = value;
                                      controller.validateVFD(
                                        selectedItem.value,
                                      );

                                      logcat(
                                        "vfd_required",
                                        controller.selectedVfdValue.value,
                                      );
                                    }
                                  },
                                ),
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
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(2),
                                  ],

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
                                    controller.validatePeakMonthlyEnergy(val);
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
                                    controller.validateRequiredSolarCap(val);
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
                                    controller.validateDistanceToTransformer(
                                      val,
                                    );
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
                                    controller.validateRatingOfTransformer(val);
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
                              Row(
                                children: [
                                  Obx(() {
                                    return Expanded(
                                      child: getReactiveFormField(
                                        node: controller
                                            .purposeOfSolarizationNode,
                                        controller:
                                            controller.purposeOfSolarizationCtr,
                                        hintLabel:
                                            "Select Purpose of Solarization",
                                        onChanged: (val) {
                                          if (controller
                                                  .isOtherPurposeOfSolarisationVisible
                                                  .value ==
                                              true) {
                                            controller
                                                    .selectedPurposeOfSolarisationValue
                                                    .value =
                                                val ?? '';
                                          }
                                          // controller.validatePurposeOfSolarization(
                                          //   val,
                                          // );
                                        },
                                        onTap: () {
                                          if (controller
                                                  .isOtherPurposeOfSolarisationVisible
                                                  .value ==
                                              false) {
                                            controller
                                                .searchPurposeOfSolarizationCtr
                                                .clear();
                                            commonDropDownDialog(
                                              context,
                                              content: controller
                                                  .setPurposeOfSolarisationListDialog(),
                                              title: "Purpose of Solarization",
                                              onCloseClick: () {
                                                controller
                                                    .applyFilterForPurposeOfSolarisation(
                                                      '',
                                                    );
                                              },
                                            ).then((_) {});
                                          }
                                        },
                                        isdown:
                                            controller
                                                    .isOtherPurposeOfSolarisationVisible
                                                    .value ==
                                                false
                                            ? true
                                            : false,
                                        formType: FieldType.text,

                                        wantSuffix:
                                            controller
                                                    .isOtherPurposeOfSolarisationVisible
                                                    .value ==
                                                false
                                            ? true
                                            : false,

                                        isReadOnly:
                                            controller
                                                .isOtherPurposeOfSolarisationVisible
                                                .value
                                            ? false
                                            : true,
                                        inputType:
                                            controller
                                                .isOtherPurposeOfSolarisationVisible
                                                .value
                                            ? TextInputType.text
                                            : TextInputType.none,
                                        errorText: controller
                                            .purposeOfSolarizationModel
                                            .value
                                            .error,
                                      ),
                                    );
                                  }),
                                  getDynamicSizedBox(width: 1.w),
                                  if (controller
                                          .isOtherPurposeOfSolarisationVisible
                                          .value ==
                                      true)
                                    Material(
                                      color: Colors
                                          .transparent, // needed if you want no background
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ), // optional for rounded ripple
                                        onTap: () {
                                          controller.purposeOfSolarizationCtr
                                              .clear();
                                          controller
                                                  .selectedPurposeOfSolarisationLabel
                                                  .value =
                                              '';
                                          controller
                                                  .isOtherPurposeOfSolarisationVisible
                                                  .value =
                                              false;
                                          // Your tap logic here
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 1.5.w,
                                            vertical: 1.h,
                                          ),
                                          child: Icon(
                                            Icons.restore,
                                            size: 2.5.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              getDynamicSizedBox(height: 2.h),
                              getLable("Dist. Inverter & ACDB Panel (Mtrs)"),
                              Obx(() {
                                return getReactiveFormField(
                                  node: controller.distInverterACDBNode,
                                  controller: controller.distInverterACDBCtr,
                                  hintLabel:
                                      "Enter Dist. Inverter & ACDB Panel",
                                  onChanged: (val) {
                                    controller.validateDistInverterACDB(val);
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
                                    controller.validateDistSolarACDB(val);
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
                                    controller.validateBuildingHeight(val);
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
                                    controller.validateRoofSizeLength(val);
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
                                    controller.validateRoofSizeBreadth(val);
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
                              if (widget.isEdit == true)
                                getLable("Installation Area (sq ft)"),

                              if (widget.isEdit == true)
                                Obx(() {
                                  return getReactiveFormField(
                                    node: controller.installationareaNode,
                                    controller: controller.installationareaCtr,
                                    hintLabel: "Enter Installation Area",
                                    onChanged: (val) {
                                      controller.installationAreaPath.value =
                                          double.tryParse(val!) ?? 0.0;
                                      // controller.validateRoofSizeBreadth(val);
                                    },
                                    inputType: TextInputType.number,
                                    formType: FieldType.text,
                                    wantSuffix: false,
                                    errorText: controller
                                        .installationAreaModel
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
                                    controller.searchRoofNatureCtr.text = "";
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
                                    controller.validateAgeOfMetalSheet(val);
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
                                    controller.validateGroundSizeLength(val);
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
                                    controller.validateGroundSizeBreadth(val);
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

                              Obx(() {
                                final canShowLeadStatus =
                                    widget.isEdit ||
                                    (controller.isAppproveMode.value);

                                if (canShowLeadStatus) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      getLable("Lead Status", isRequired: true),
                                      getReactiveFormField(
                                        node: controller.leadStatusNode,
                                        controller: controller.leadStatusCtr,
                                        hintLabel: "Select Lead Status",
                                        onChanged: (val) {
                                          controller.validateRoofNature(val);
                                        },
                                        onTap: () {
                                          commonDropDownDialog(
                                            context,
                                            content: controller
                                                .setLeadStatusstDialog(),
                                            title: "Lead Status",
                                            onCloseClick: () {},
                                          );
                                        },
                                        formType: FieldType.text,
                                        wantSuffix: true,
                                        isdown: true,
                                        isReadOnly: true,
                                        inputType: TextInputType.none,
                                        errorText: controller
                                            .roofNatureModel
                                            .value
                                            .error,
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),

                              Obx(() {
                                return controller
                                                .isTechnicalProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFirstTechincaluploaded
                                                .value ==
                                            true
                                    ? getDynamicSizedBox(height: 2.h)
                                    : SizedBox.shrink();
                              }),

                              Obx(() {
                                return controller
                                                .isTechnicalProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFirstTechincaluploaded
                                                .value ==
                                            true
                                    ? getTextField(
                                        context: context,
                                        wantLabel: true,
                                        isBorderSideEnable: true,
                                        label: 'First Technical Proposal',
                                        ctr: controller
                                            .firstTechnicalProposal1Ctr,
                                        node: controller
                                            .firstTechnicalProposal1Node,
                                        model: controller
                                            .firstTechnicalProposal1Model
                                            .value,
                                        isenable: false,
                                        isdropdown: true,
                                        wantsuffix: false,
                                        usegesture: true,
                                        gestureFunction: () {
                                          SimplePdfPicker.pickPdf(
                                            onFileSelected: (filePath, fileName) {
                                              // Convert path to File
                                              final file = File(filePath);

                                              // Store in your controller Rx variable
                                              controller
                                                  .setTechnicalProposalFile(
                                                    file,
                                                  );

                                              // Optional: update the TextEditingController to display file name
                                              controller
                                                      .firstTechnicalProposal1Ctr
                                                      .text =
                                                  fileName;

                                              controller.validateStep2();
                                            },
                                          );
                                        },

                                        hint: 'Select File',
                                        isRequired: false,
                                      )
                                    : SizedBox.shrink();
                              }),
                              Obx(() {
                                return controller
                                                .isTechnicalProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFinalTechnicaluploaded
                                                .value ==
                                            true
                                    ? getDynamicSizedBox(height: 2.h)
                                    : SizedBox.shrink();
                              }),
                              Obx(() {
                                return controller
                                                .isTechnicalProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFinalTechnicaluploaded
                                                .value ==
                                            true
                                    ? getTextField(
                                        context: context,
                                        wantLabel: true,
                                        isBorderSideEnable: true,
                                        label: 'Final Technical Proposal',
                                        ctr: controller
                                            .finalTechnicalProposal2Ctr,
                                        node: controller
                                            .finalTechnicalProposal2Node,
                                        model: controller
                                            .finalTechnicalProposal2Model
                                            .value,
                                        isenable: false,
                                        isdropdown: true,
                                        wantsuffix: false,
                                        usegesture: true,
                                        gestureFunction: () {
                                          SimplePdfPicker.pickPdf(
                                            onFileSelected: (filePath, fileName) {
                                              final file = File(filePath);
                                              controller
                                                  .setfinalTechnicalProposalFile(
                                                    file,
                                                  );
                                              controller
                                                      .finalTechnicalProposal2Ctr
                                                      .text =
                                                  fileName;

                                              controller.validateStep2();
                                            },
                                          );
                                        },

                                        hint: 'Select File',
                                        isRequired: false,
                                      )
                                    : SizedBox.shrink();
                              }),

                              Obx(() {
                                return controller
                                                .isCommercialProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFirstComercialluploaded
                                                .value ==
                                            true
                                    ? getDynamicSizedBox(height: 2.h)
                                    : SizedBox.shrink();
                              }),

                              Obx(() {
                                return controller
                                                .isCommercialProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFirstComercialluploaded
                                                .value ==
                                            true
                                    ? getTextField(
                                        context: context,
                                        wantLabel: true,
                                        isBorderSideEnable: true,
                                        label: 'First Commercial Proposal',
                                        ctr: controller
                                            .firstCommercialProposal1Ctr,
                                        node: controller
                                            .firstCommercialProposal1Node,
                                        model: controller
                                            .firstCommercialProposal1Model
                                            .value,
                                        isenable: false,
                                        isdropdown: true,
                                        wantsuffix: false,
                                        usegesture: true,
                                        gestureFunction: () {
                                          SimplePdfPicker.pickPdf(
                                            onFileSelected: (filePath, fileName) {
                                              // Convert path to File
                                              final file = File(filePath);

                                              // Store in your controller Rx variable
                                              controller
                                                  .setCommercialProposalFile(
                                                    file,
                                                  );

                                              // Optional: update the TextEditingController to display file name
                                              controller
                                                      .firstCommercialProposal1Ctr
                                                      .text =
                                                  fileName;

                                              controller.validateStep2();
                                            },
                                          );
                                        },

                                        hint: 'Select File',
                                        isRequired: false,
                                      )
                                    : SizedBox.shrink();
                              }),
                              Obx(() {
                                return controller
                                                .isCommercialProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFinalComercialluploaded
                                                .value ==
                                            true
                                    ? getDynamicSizedBox(height: 2.h)
                                    : SizedBox.shrink();
                              }),
                              Obx(() {
                                return controller
                                                .isCommercialProposalMode
                                                .value ==
                                            true &&
                                        controller
                                                .isFinalComercialluploaded
                                                .value ==
                                            true
                                    ? getTextField(
                                        context: context,
                                        wantLabel: true,
                                        isBorderSideEnable: true,
                                        label: 'Final Commercial  Proposal',
                                        ctr: controller
                                            .finalCommercialProposal2Ctr,
                                        node: controller
                                            .finalCommercialProposal2Node,
                                        model: controller
                                            .finalCommercialProposal2Model
                                            .value,
                                        isenable: false,
                                        isdropdown: true,
                                        wantsuffix: false,
                                        usegesture: true,
                                        gestureFunction: () {
                                          SimplePdfPicker.pickPdf(
                                            onFileSelected: (filePath, fileName) {
                                              final file = File(filePath);
                                              controller
                                                  .setfinalCommercialProposalFile(
                                                    file,
                                                  );
                                              controller
                                                      .finalCommercialProposal2Ctr
                                                      .text =
                                                  fileName;

                                              controller.validateStep2();
                                            },
                                          );
                                        },

                                        hint: 'Select File',
                                        isRequired: false,
                                      )
                                    : SizedBox.shrink();
                              }),
                              Obx(() {
                                if (controller.isLeadPaymentMode.value) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      getDynamicSizedBox(height: 2.h),

                                      // Token Amount
                                      getLable(
                                        "Token Amount",
                                        isRequired: true,
                                        isVerified:
                                            controller.iswonShow.value == true
                                            ? true
                                            : false,
                                      ),
                                      getReactiveFormField(
                                        isEnable:
                                            controller.iswonShow.value == true
                                            ? false
                                            : true,
                                        isVerified:
                                            controller.iswonShow.value == true
                                            ? true
                                            : false,
                                        node: controller.tokenAmountNode,
                                        controller: controller.tokenAmountCtr,
                                        hintLabel: "Enter Token Amount",
                                        onChanged: (val) {
                                          controller.validateTokenAmountt(val);
                                        },
                                        inputType: TextInputType.number,
                                        formType: FieldType.text,
                                        wantSuffix: false,
                                        errorText: controller
                                            .tokenAmountModel
                                            .value
                                            .error,
                                      ),

                                      getDynamicSizedBox(height: 2.h),

                                      // Total Project Cost
                                      getLable(
                                        "Total Project Cost",
                                        isRequired: true,
                                        isVerified:
                                            controller.iswonShow.value == true
                                            ? true
                                            : false,
                                      ),
                                      getReactiveFormField(
                                        node: controller.totalProjectCostNode,
                                        controller:
                                            controller.totalProjectCostCtr,
                                        isEnable:
                                            controller.iswonShow.value == true
                                            ? false
                                            : true,
                                        isVerified:
                                            controller.iswonShow.value == true
                                            ? true
                                            : false,
                                        hintLabel: "Enter Total Project Cost",
                                        onChanged: (val) {
                                          controller.validateTotalProject(val);
                                        },
                                        inputType: TextInputType.number,
                                        formType: FieldType.text,
                                        wantSuffix: false,
                                        errorText: controller
                                            .totalProjectCostModel
                                            .value
                                            .error,
                                      ),

                                      getDynamicSizedBox(height: 2.h),

                                      // Balance Amount
                                      getLable(
                                        "Balance Amount",
                                        isVerified: true,
                                      ),
                                      getReactiveFormField(
                                        isEnable: false,
                                        isVerified: true,
                                        node: controller.balanceAmonutNode,
                                        controller:
                                            controller
                                                    .isFullPaymentReceived
                                                    .value ==
                                                true
                                            ? controller.fullpaymentamountCtr
                                            : controller.balanceAmonutCtr,
                                        hintLabel: "Enter Balance Amount",
                                        onChanged: (val) {
                                          // controller.validateGroundSizeLength(
                                          //   val,
                                          // );
                                        },
                                        inputType: TextInputType.number,
                                        formType: FieldType.text,
                                        wantSuffix: false,
                                        errorText: controller
                                            .balanceAmonutModel
                                            .value
                                            .error,
                                      ),

                                      Obx(() {
                                        return controller.isFinancialType.value
                                            ? getDynamicSizedBox(height: 2.h)
                                            : SizedBox.shrink();
                                      }),

                                      Obx(() {
                                        final financialType =
                                            controller.isFinancialType.value;

                                        if (financialType) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              getLable(
                                                "Financing Type",
                                                isRequired: true,
                                              ),
                                              getReactiveFormField(
                                                node: controller.financialNode,
                                                controller:
                                                    controller.financialTypeCtr,
                                                hintLabel:
                                                    "Select Financing Type",
                                                onChanged: (val) {
                                                  controller
                                                      .validateFinancialStatus(
                                                        val,
                                                      );
                                                },
                                                onTap: () {
                                                  commonDropDownDialog(
                                                    context,
                                                    content: controller
                                                        .setFinacialTypeDialog(),
                                                    title: "Financing Type",
                                                    onCloseClick: () {},
                                                  );
                                                },
                                                formType: FieldType.text,
                                                wantSuffix: true,
                                                isdown: true,
                                                isReadOnly: true,
                                                inputType: TextInputType.none,
                                                errorText: controller
                                                    .financialModel
                                                    .value
                                                    .error,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      }),

                                      Obx(() {
                                        return controller
                                                    .isOMCPartnerMode
                                                    .value ==
                                                true
                                            ? getDynamicSizedBox(height: 2.h)
                                            : SizedBox.shrink();
                                      }),

                                      Obx(() {
                                        final financialType =
                                            controller.isOMCPartnerMode.value ==
                                            true;

                                        if (financialType) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              getLable(
                                                "Financing Progress Status",
                                                isRequired: true,
                                              ),
                                              getReactiveFormField(
                                                node: controller
                                                    .financialOMCPartnerNode,
                                                controller: controller
                                                    .financialOMCPartnerCtr,
                                                hintLabel:
                                                    "Select Financing Progress Type",
                                                onChanged: (val) {
                                                  // controller
                                                  //     .validateFinancialStatus(
                                                  //       val,
                                                  //     );
                                                },
                                                onTap: () {
                                                  commonDropDownDialog(
                                                    context,
                                                    content: controller
                                                        .setOMCPartnerTypeDialog(),
                                                    title:
                                                        "Financing Progress Status",
                                                    onCloseClick: () {},
                                                  );
                                                },
                                                formType: FieldType.text,
                                                wantSuffix: true,
                                                isdown: true,
                                                isReadOnly: true,
                                                inputType: TextInputType.none,
                                                errorText: controller
                                                    .financialOMCPartnerModel
                                                    .value
                                                    .error,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      }),

                                      Obx(() {
                                        return controller
                                                    .isFullPaymentAmountMode
                                                    .value ||
                                                controller.iswonShow.value
                                            ? getDynamicSizedBox(height: 2.h)
                                            : SizedBox.shrink();
                                      }),
                                      Obx(() {
                                        return controller
                                                    .isFullPaymentAmountMode
                                                    .value ||
                                                controller.iswonShow.value
                                            ? getLable(
                                                "Full Payment Amount",
                                                isVerified: true,
                                                isRequired: true,
                                              )
                                            : SizedBox.shrink();
                                      }),
                                      Obx(() {
                                        return controller
                                                    .isFullPaymentAmountMode
                                                    .value ||
                                                controller.iswonShow.value
                                            ? getReactiveFormField(
                                                isEnable: false,
                                                isVerified: true,
                                                node: controller
                                                    .balanceAmonutNode,
                                                controller:
                                                    controller.balanceAmonutCtr,
                                                hintLabel:
                                                    "Enter Full Payment Amount",
                                                onChanged: (val) {
                                                  // controller.validateGroundSizeLength(
                                                  //   val,
                                                  // );
                                                },
                                                inputType: TextInputType.number,
                                                formType: FieldType.text,
                                                wantSuffix: false,
                                                errorText: controller
                                                    .balanceAmonutModel
                                                    .value
                                                    .error,
                                              )
                                            : SizedBox.shrink();
                                      }),
                                      Obx(() {
                                        return controller
                                                .isOMCFinanceDocumentShown
                                                .value
                                            ? getDynamicSizedBox(height: 2.h)
                                            : SizedBox.shrink();
                                      }),

                                      // Obx(() {
                                      //   return controller
                                      //           .isOMCFinanceDocumentShown
                                      //           .value
                                      //       ? getLable(
                                      //           "Finance Documents (PDF only)",
                                      //         )
                                      //       : SizedBox.shrink();
                                      // }),
                                      Obx(() {
                                        return controller
                                                .isOMCFinanceDocumentShown
                                                .value
                                            ? getTextField(
                                                context: context,
                                                wantLabel: true,
                                                label:
                                                    'Finance Documents (PDF only)',
                                                ctr: controller
                                                    .financeDocumentCtr,
                                                node: controller
                                                    .financeDocumentNode,
                                                model: controller
                                                    .financeDocumentModel
                                                    .value,
                                                isenable: false,
                                                isdropdown: true,
                                                wantsuffix: false,
                                                usegesture: true,
                                                gestureFunction: () async {
                                                  await controller
                                                      .pickMultiplePdfFiles();
                                                },
                                                hint: 'Select File',
                                                isRequired: true,
                                              )
                                            : SizedBox.shrink();
                                      }),

                                      Obx(() {
                                        return controller
                                                .isOMCFinanceDocumentShown
                                                .value
                                            ? Container(
                                                padding: EdgeInsets.only(
                                                  top: 0.5.h,
                                                ),
                                                child: Text(
                                                  'You can select multiple PDF files.',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: grey,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink();
                                      }),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              widget.isEdit
                                  ? const SizedBox.shrink()
                                  : getLable(
                                      "Schedule Meeting",
                                      isRequired: true,
                                    ),
                              widget.isEdit
                                  ? const SizedBox.shrink()
                                  : Obx(() {
                                      return getReactiveFormField(
                                        node: controller.scheduleMeetingNode,
                                        controller:
                                            controller.scheduleMeetingCtr,
                                        hintLabel: "Select Schedule Meeting",
                                        onChanged: (val) {
                                          controller.validateScheduleMeeting(
                                            val,
                                          );
                                        },
                                        onTap: () {
                                          controller.openDatePicker(
                                            context: context,
                                            title: 'Select Schedule Date',
                                            controller:
                                                controller.scheduleMeetingCtr,
                                            dateRx: controller.startDate,
                                            model:
                                                controller.scheduleMeeeingModel,
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
                                isAddShow:
                                    controller.isLeadRejectedMode.value ==
                                            true ||
                                        controller.iswonShow.value == true
                                    ? false
                                    : true,
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
                                      if (controller.isLeadRejectedMode.value ==
                                              true ||
                                          controller.iswonShow.value) {
                                        Get.snackbar(
                                          'Action Not Allowed',
                                          'You can’t edit items in Rejected mode',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red
                                              .withValues(alpha: 0.1),
                                          colorText: Colors.redAccent,
                                        );
                                        return;
                                      }
                                      controller.addLoadElement(
                                        context,
                                        loadElementItem: item,
                                        index: i,
                                      );
                                    },
                                    onDelete: (i) {
                                      if (controller.isLeadRejectedMode.value ==
                                              true ||
                                          controller.iswonShow.value) {
                                        Get.snackbar(
                                          'Action Not Allowed',
                                          'You can’t delete items in Rejected mode',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red
                                              .withValues(alpha: 0.1),
                                          colorText: Colors.redAccent,
                                        );
                                        return;
                                      }
                                      controller.deleteLoad(i);
                                    },
                                    isRejected:
                                        controller.isLeadRejectedMode.value ||
                                        controller.iswonShow.value,
                                    isEditVisible: true,
                                    isEyeButtonShow: false,
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
                                  controller.addUploadFile(
                                    context,
                                    isEdit: widget.isEdit,
                                  );
                                },
                                isAddShow:
                                    AppPermissions().canUploadFiles == true
                                    ? !(controller.isLeadRejectedMode.value ||
                                          controller.iswonShow.value)
                                    : false,
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
                                      displayFileName(file),
                                      formatText(file.category.toString()),
                                    ],

                                    onEdit: (i, file) {
                                      controller.addUploadFile(
                                        context,
                                        fileItem: file,
                                        index: i,
                                        isEdit: widget.isEdit,
                                      );
                                    },
                                    onDelete: (i) {
                                      controller.deleteFile(
                                        index: i,
                                        fileId: controller.fileList[i].id ?? 0,
                                      );
                                    },

                                    // 🔹 Per-file rejection logic
                                    isRejected: (file) =>
                                        !(file.canManage ??
                                            false) || // disable edit/delete if cannot manage
                                        controller.isLeadRejectedMode.value ||
                                        controller.iswonShow.value,
                                    isEditVisible: false,
                                    isEyeButtonShow: true,
                                    onEyeButtonClick: (i) {
                                      logcat(
                                        'path name isss',
                                        controller.fileList[i].link,
                                      );
                                      // return;
                                      controller.viewFile(
                                        context,
                                        controller.fileList[i].link,
                                        setState: () {
                                          logcat(
                                            'setState called',
                                            'setState ',
                                          );
                                          setState(() {});
                                          // controller.update();
                                        },
                                      );
                                    },
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
                                        // Normal step 2 validation
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
                                        () {
                                          if (isNextEnabled) {
                                            _onStepContinue();
                                          }
                                        },
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
