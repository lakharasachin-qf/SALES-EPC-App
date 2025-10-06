import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
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
              child: Theme(
                data: ThemeData(
                  canvasColor: transparent,
                  colorScheme: ColorScheme.light(
                    primary: primaryColor,
                    secondary: grey,
                  ),
                ),
                child: Obx(() {
                  return Stepper(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    physics: BouncingScrollPhysics(),
                    type: StepperType.horizontal,
                    currentStep: controller.StepperValue,
                    onStepContinue: () {
                      controller.ismovingForward = true;

                      if (controller.StepperValue < 1) {
                        controller.incrementstepper();
                      }
                    },
                    onStepCancel: () {
                      controller.ismovingForward = false;
                      if (controller.StepperValue > 0) {
                        controller.decerementstepper();
                      }
                    },
                    stepIconHeight: 40,
                    controlsBuilder: (context, details) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (controller.StepperValue > 0)
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: getFormButton(
                                  context,
                                  () {
                                    details.onStepCancel?.call();
                                  },
                                  "Back",
                                  validate: true,
                                ),
                              ),
                            ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: Obx(() {
                                return getFormButton(
                                  context,
                                  () {
                                    if (controller.StepperValue == 1) {
                                      if (controller.isFormInvalidate.value) {
                                        // futureDelay(() {
                                        //   controller.registerUser(
                                        //     context,
                                        //   );
                                        // }, isOneSecond: true);
                                      }
                                    } else {
                                      details.onStepContinue?.call();
                                    }
                                  },
                                  controller.StepperValue == 1
                                      ? "Submit"
                                      : "next",
                                  validate: controller.StepperValue == 1
                                      ? controller.isFormInvalidate.value
                                      : true,
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    },
                    steps: [
                      Step(
                        title: Text(''),
                        content: _buildBasicForm(context),
                        isActive: controller.StepperValue >= 0,
                        state: controller.StepperValue > 0
                            ? StepState.complete
                            : StepState.indexed,
                      ),
                      Step(
                        title: Text(''),
                        content: _buildAddLoadElementForm(context),
                        isActive: controller.StepperValue >= 0,
                        state:
                            controller.ismovingForward &&
                                controller.isFormInvalidate.value
                            ? StepState.complete
                            : StepState.indexed,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return getTextField(
            context: context,
            wantLabel: true,
            label: 'Company Name',
            ctr: controller.companyNameCtr,
            node: controller.companyNameNode,
            model: controller.companyNameModel.value,
            function: (val) {
              controller.validateFields(
                val,
                iscomman: true,
                model: controller.companyNameModel,
                errorText1: 'Company Name is required',
              );
            },
            hint: 'Enter Company Name',
            isRequired: true,
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
            errorText: controller.addressModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Country", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.countryNode,
            controller: controller.countryCtr,
            hintLabel: "Enter Country",
            onChanged: (val) {
              controller.validateCountry(val);
            },
            onTap: () {
              controller.countrySearchCtr.text = "";
              commonDropDownDialog(
                context,
                content: controller.setCountryListDialog(),
                title: "Country",
                onCloseClick: () {},
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
            },
            formType: FieldType.text,
            wantSuffix: true,
            isdown: true,
            isReadOnly: true,
            inputType: TextInputType.none,
            errorText: controller.countryModel.value.error,
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
                content: controller.setCountryListDialog(),
                title: "State",
                onCloseClick: () {
                  controller.applyFilterforCountry('');
                },
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
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
              controller.validateDistrict(val);
            },
            onTap: () {
              controller.countryCtr.text = "";
              commonDropDownDialog(
                context,
                content: controller.setCountryListDialog(),
                title: "District",
                onCloseClick: () {
                  controller.applyFilterforCountry('');
                },
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
            },
            formType: FieldType.text,
            wantSuffix: true,
            isdown: true,
            isReadOnly: true,
            inputType: TextInputType.none,
            errorText: controller.districtModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Person Name", isRequired: true),
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
            errorText: controller.personNameModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Person Mobile", isRequired: true),
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
            errorText: controller.personMobileModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Latitude", isRequired: true),
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
            errorText: controller.latitudeModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Longitude", isRequired: true),
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
            errorText: controller.longitudeModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Required Solution Type", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.requiredSolutionTypeNode,
            controller: controller.requiredSolutionTypeCtr,
            hintLabel: "Enter Solution Type",
            onChanged: (val) {
              controller.validateRequiredSolutionType(val);
            },
            onTap: () {
              controller.countryCtr.text = "";
              commonDropDownDialog(
                context,
                content: controller.setCountryListDialog(),
                title: "Solution Type",
                onCloseClick: () {
                  controller.applyFilterforCountry('');
                },
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
            },
            formType: FieldType.text,
            wantSuffix: true,
            isdown: true,
            isReadOnly: true,
            inputType: TextInputType.none,
            errorText: controller.requiredSolutionTypeModel.value.error,
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
              controller.validateRequiredSolution(val);
            },
            onTap: () {
              controller.countryCtr.text = "";
              commonDropDownDialog(
                context,
                content: controller.setCountryListDialog(),
                title: "Required Solution",
                onCloseClick: () {
                  controller.applyFilterforCountry('');
                },
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
            },
            formType: FieldType.text,
            wantSuffix: true,
            isdown: true,
            isReadOnly: true,
            inputType: TextInputType.none,
            errorText: controller.requiredSolutionModel.value.error,
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
              controller.validateLeadCategory(val);
            },
            onTap: () {
              controller.countryCtr.text = "";
              commonDropDownDialog(
                context,
                content: controller.setCountryListDialog(),
                title: "Lead Category",
                onCloseClick: () {
                  controller.applyFilterforCountry('');
                },
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
            },
            formType: FieldType.text,
            wantSuffix: true,
            isdown: true,
            isReadOnly: true,
            inputType: TextInputType.none,
            errorText: controller.leadCategoryModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("DG Capacity", isRequired: true),
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
            errorText: controller.dgCapacityModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("DG Sync", isRequired: true),
        getReactiveDropdown(
          hint: "Enter DG Sync",
          items: controller.dgSync,
          selectedValue: controller.selectDgSync,
          onChanged: (value) {
            // setState(() {
            //   controller.selectDgSync = value!;
            // });
          },
        ),

        getDynamicSizedBox(height: 2.h),
        getLable("Installed Solar Capacity", isRequired: true),
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
            errorText: controller.installedSolarCapModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Sanctioned Load", isRequired: true),
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
            errorText: controller.sanctionedLoadModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("VFD", isRequired: true),
        getReactiveDropdown(
          hint: "Enter VFD",
          items: controller.vfd,
          selectedValue: controller.selectVfd,
          onChanged: (value) {
            // setState(() {
            //   controller.selectVfd = value!;
            // });
          },
        ),
        getDynamicSizedBox(height: 2.h),
        getLable("Grid Availability", isRequired: true),
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
            errorText: controller.gridAvailabilityModel.value.error,
          );
        }),

        getDynamicSizedBox(height: 2.h),
        getLable("Peak Monthly Energy Cons (KWH)", isRequired: true),
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
            errorText: controller.peakMonthlyEnergyModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Required Solar Cap (KWp)", isRequired: true),
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
            errorText: controller.requiredSolarCapModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Distance to Nearest Transformer (Mtrs)", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.distanceToTransformerNode,
            controller: controller.distanceToTransformerCtr,
            hintLabel: "Enter Distance to Nearest Transformer",
            onChanged: (val) {
              controller.validateDistanceToTransformer(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText: controller.distanceToTransformerModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Rating of Nearest Transformer (KVA)", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.ratingOfTransformerNode,
            controller: controller.ratingOfTransformerCtr,
            hintLabel: "Enter Rating of Nearest Transformer",
            onChanged: (val) {
              controller.validateRatingOfTransformer(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText: controller.ratingOfTransformerModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Purpose of Solarization", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.purposeOfSolarizationNode,
            controller: controller.purposeOfSolarizationCtr,
            hintLabel: "Enter Purpose of Solarization",
            onChanged: (val) {
              controller.validatePurposeOfSolarization(val);
            },
            onTap: () {
              controller.countryCtr.text = "";
              commonDropDownDialog(
                context,
                content: controller.setCountryListDialog(),
                title: "Purpose of Solarization",
                onCloseClick: () {
                  controller.applyFilterforCountry('');
                },
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
            },
            formType: FieldType.text,
            wantSuffix: true,
            isdown: true,
            isReadOnly: true,
            inputType: TextInputType.none,
            errorText: controller.purposeOfSolarizationModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Dist. Inverter & ACDB Panel (Mtrs)", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.distInverterACDBNode,
            controller: controller.distInverterACDBCtr,
            hintLabel: "Enter Dist. Inverter & ACDB Panel",
            onChanged: (val) {
              controller.validateDistInverterACDB(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText: controller.distInverterACDBModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Dist. Solar & ACDB Panel (Mtrs)", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.distSolarACDBNode,
            controller: controller.distSolarACDBCtr,
            hintLabel: "Enter Dist. Solar & ACDB Panel (Mtrs)",
            onChanged: (val) {
              controller.validateDistSolarACDB(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText: controller.distSolarACDBModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Building Height (Floors)", isRequired: true),
        Obx(() {
          return getReactiveFormField(
            node: controller.buildHeightNode,
            controller: controller.buildingHeightCtr,
            hintLabel: "Enter Building Height (Floors)",
            onChanged: (val) {
              controller.validateDistInverterACDB(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText: controller.buildingHeightModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Roof Size Length (ft)", isRequired: true),
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
            errorText: controller.roofSizeLengthModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Roof Size Breadth (ft)", isRequired: true),
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
            errorText: controller.roofSizeBreadthModel.value.error,
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
              controller.validateRoofNature(val);
            },
            onTap: () {
              controller.countryCtr.text = "";
              commonDropDownDialog(
                context,
                content: controller.setCountryListDialog(),
                title: "Roof Nature",
                onCloseClick: () {
                  controller.applyFilterforCountry('');
                },
              ).then((_) {
                // controller.addOnFilterList.refresh();
              });
            },
            formType: FieldType.text,
            wantSuffix: true,
            isdown: true,
            isReadOnly: true,
            inputType: TextInputType.none,
            errorText: controller.roofNatureModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Age of Metal Sheet (years)", isRequired: true),
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
            errorText: controller.ageOfMetalSheetModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Ground Size Length (ft)", isRequired: true),
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
            errorText: controller.groundSizeLengthModel.value.error,
          );
        }),
        getDynamicSizedBox(height: 2.h),
        getLable("Ground Size Breadth (ft)", isRequired: true),
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
            errorText: controller.groundSizeBreadthModel.value.error,
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
              controller.validateOtherRemarks(val);
            },
            inputType: TextInputType.text,
            formType: FieldType.text,
            wantSuffix: false,
            errorText: controller.otherRemarksModel.value.error,
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
              controller.validateScheduleMeetings(val);
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
            errorText: controller.scheduleMeeeingModel.value.error,
          );
        }),
      ],
    );
  }

  Widget _buildAddLoadElementForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildAddFilesForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                controller.addUploadFile(context, fileItem: file, index: i);
              },
              onDelete: (i) => controller.deleteFile(i),
            ),
          );
        }),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide ScreenType;
// import 'package:sales_app/componant/dialogs/dialogs.dart';
// import 'package:sales_app/componant/input/custom_text_field.dart';
// import 'package:sales_app/componant/input/form_inputs.dart';
// import 'package:sales_app/componant/input/getReactiveDropdown.dart';
// import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
// import 'package:sales_app/componant/toolbar/toolbar.dart';
// import 'package:sales_app/componant/widgets/widgets.dart';
// import 'package:sales_app/configs/statusbar.dart';
// import 'package:sales_app/controller/leads_controller/leads_controller.dart';
// import 'package:sales_app/utils/buildDynamicTable.dart';
// import 'package:sales_app/utils/helper.dart';
// import 'package:sizer/sizer.dart';

// class AddLeadScreen extends StatefulWidget {
//   const AddLeadScreen({super.key});

//   @override
//   State<AddLeadScreen> createState() => _AddLeadScreenState();
// }

// class _AddLeadScreenState extends State<AddLeadScreen> {
//   var controller = Get.put(LeadsController());
//   int _currentStep = 0;

//   @override
//   Widget build(BuildContext context) {
//     Statusbar().trasparentStatusbarProfile(false);
//     return CustomParentScaffold(
//       onWillPop: () async {
//         return true;
//       },
//       onTap: () {
//         hideKeyboard(context);
//       },
//       isExtendBodyScreen: true,
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         margin: EdgeInsets.only(top: 1.h),
//         child: Column(
//           children: [
//             getCommonToolbar(
//               "Add Leads",
//               onClick: () {
//                 Get.back();
//               },
//             ),
//             getDynamicSizedBox(height: 1.h),
//             // Custom Step Indicator at the top
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildStepIndicator(0, "Basic"),
//                   _buildStepConnector(),
//                   _buildStepIndicator(1, "Files"),
//                   _buildStepConnector(),
//                   _buildStepIndicator(2, "Additional Details"),
//                 ],
//               ),
//             ),
//             getDynamicSizedBox(height: 1.h),
//             // Scrollable Content
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Container(
//                   margin: EdgeInsets.only(
//                     left: 3.w,
//                     right: 3.w,
//                     top: 2.h,
//                     bottom: 10.h,
//                   ),
//                   child: Form(
//                     key: controller.formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: _getStepContent(),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStepIndicator(int step, String label) {
//     bool isActive = _currentStep == step;
//     bool isCompleted = _currentStep > step;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _currentStep = step;
//           });
//         },
//         child: Column(
//           children: [
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isActive
//                     ? Colors.blue
//                     : isCompleted
//                     ? Colors.green
//                     : Colors.grey,
//                 border: Border.all(color: Colors.black, width: 1),
//               ),
//               child: Center(
//                 child: Text(
//                   (step + 1).toString(),
//                   style: TextStyle(
//                     color: isActive || isCompleted
//                         ? Colors.white
//                         : Colors.black,
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 0.5.h),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: isActive ? Colors.blue : Colors.black,
//                 fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStepConnector() {
//     return Container(height: 2, width: 15.w, color: Colors.grey);
//   }

//   List<Widget> _getStepContent() {
//     switch (_currentStep) {
//       case 0: // Basic
//         return [
//           Obx(() {
//             return getTextField(
//               context: context,
//               wantLabel: true,
//               label: 'Company Name',
//               ctr: controller.companyNameCtr,
//               node: controller.companyNameNode,
//               model: controller.companyNameModel.value,
//               function: (val) {
//                 controller.validateFields(
//                   val,
//                   iscomman: true,
//                   model: controller.companyNameModel,
//                   errorText1: 'Company Name is required',
//                 );
//               },
//               hint: 'Enter Company Name',
//               isRequired: true,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Address", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.addressNode,
//               controller: controller.addressCtr,
//               hintLabel: "Enter Address",
//               onChanged: (val) {
//                 controller.validateAddress(val);
//               },
//               inputType: TextInputType.text,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.addressModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Country", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.countryNode,
//               controller: controller.countryCtr,
//               hintLabel: "Enter Country",
//               onChanged: (val) {
//                 controller.validateCountry(val);
//               },
//               onTap: () {
//                 controller.countrySearchCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "Country",
//                   onCloseClick: () {},
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.countryModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("State", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.stateNode,
//               controller: controller.stateCtr,
//               hintLabel: "Enter State",
//               onChanged: (val) {},
//               onTap: () {
//                 controller.countryCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "State",
//                   onCloseClick: () {
//                     controller.applyFilterforCountry('');
//                   },
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.stateModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("District", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.districtNode,
//               controller: controller.districtCtr,
//               hintLabel: "Enter District",
//               onChanged: (val) {
//                 controller.validateDistrict(val);
//               },
//               onTap: () {
//                 controller.countryCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "District",
//                   onCloseClick: () {
//                     controller.applyFilterforCountry('');
//                   },
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.districtModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Person Name", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.personNameNode,
//               controller: controller.personNameCtr,
//               hintLabel: "Enter Person Name",
//               onChanged: (val) {
//                 controller.validatePersonName(val);
//               },
//               inputType: TextInputType.text,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.personNameModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Person Mobile", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.personMobileNode,
//               controller: controller.personMobileCtr,
//               hintLabel: "Enter Mobile Number",
//               onChanged: (val) {
//                 controller.validatePersonMobile(val);
//               },
//               inputType: TextInputType.phone,
//               formType: FieldType.mobile,
//               wantSuffix: false,
//               errorText: controller.personMobileModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Latitude", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.latitudeNode,
//               controller: controller.latitudeCtr,
//               hintLabel: "Enter Latitude",
//               onChanged: (val) {
//                 controller.validateLatitude(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.latitudeModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Longitude", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.longitudeNode,
//               controller: controller.longitudeCtr,
//               hintLabel: "Enter Longitude",
//               onChanged: (val) {
//                 controller.validateLongitude(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.mobile,
//               wantSuffix: false,
//               errorText: controller.longitudeModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Required Solution Type", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.requiredSolutionTypeNode,
//               controller: controller.requiredSolutionTypeCtr,
//               hintLabel: "Enter Solution Type",
//               onChanged: (val) {
//                 controller.validateRequiredSolutionType(val);
//               },
//               onTap: () {
//                 controller.countryCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "Solution Type",
//                   onCloseClick: () {
//                     controller.applyFilterforCountry('');
//                   },
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.requiredSolutionTypeModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Required Solution", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.requiredSolutionNode,
//               controller: controller.requiredSolutionCtr,
//               hintLabel: "Enter Solution",
//               onChanged: (val) {
//                 controller.validateRequiredSolution(val);
//               },
//               onTap: () {
//                 controller.countryCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "Required Solution",
//                   onCloseClick: () {
//                     controller.applyFilterforCountry('');
//                   },
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.requiredSolutionModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Lead Category", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.leadCategoryNode,
//               controller: controller.leadCategoryCtr,
//               hintLabel: "Enter Lead Category",
//               onChanged: (val) {
//                 controller.validateLeadCategory(val);
//               },
//               onTap: () {
//                 controller.countryCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "Lead Category",
//                   onCloseClick: () {
//                     controller.applyFilterforCountry('');
//                   },
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.leadCategoryModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("DG Capacity", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.dgCapacityNode,
//               controller: controller.dgCapacityCtr,
//               hintLabel: "Enter DG Capacity",
//               onChanged: (val) {
//                 controller.validateDGCapacity(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.dgCapacityModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("DG Sync", isRequired: true),
//           getReactiveDropdown(
//             hint: "Enter DG Sync",
//             items: controller.dgSync,
//             selectedValue: controller.selectDgSync,
//             onChanged: (value) {
//               setState(() {
//                 controller.selectDgSync = value!;
//               });
//             },
//           ),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Installed Solar Capacity", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.installedSolarCapNode,
//               controller: controller.installedSolarCapCtr,
//               hintLabel: "Enter Installed Solar Capacity",
//               onChanged: (val) {
//                 controller.validateInstalledSolarCap(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.mobile,
//               wantSuffix: false,
//               errorText: controller.installedSolarCapModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Sanctioned Load", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.sanctionedLoadNode,
//               controller: controller.sanctionedLoadCtr,
//               hintLabel: "Enter Sanctioned Load",
//               onChanged: (val) {
//                 controller.validateSanctionedLoad(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.mobile,
//               wantSuffix: false,
//               errorText: controller.sanctionedLoadModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("VFD", isRequired: true),
//           getReactiveDropdown(
//             hint: "Enter VFD",
//             items: controller.vfd,
//             selectedValue: controller.selectVfd,
//             onChanged: (value) {
//               setState(() {
//                 controller.selectVfd = value!;
//               });
//             },
//           ),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Grid Availability", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.gridAvailabilityNode,
//               controller: controller.gridAvailabilityCtr,
//               hintLabel: "Enter Grid Availability",
//               onChanged: (val) {
//                 controller.validateGridAvailability(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.mobile,
//               wantSuffix: false,
//               errorText: controller.gridAvailabilityModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Peak Monthly Energy Cons (KWH)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.peakMonthlyEnergyNode,
//               controller: controller.peakMonthlyEnergyCtr,
//               hintLabel: "Enter Peak Monthly Energy Cons",
//               onChanged: (val) {
//                 controller.validatePeakMonthlyEnergy(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.peakMonthlyEnergyModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Required Solar Cap (KWp)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.requiredSolarCapNode,
//               controller: controller.requiredSolarCapCtr,
//               hintLabel: "Enter Required Solar Cap",
//               onChanged: (val) {
//                 controller.validateRequiredSolarCap(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.requiredSolarCapModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Distance to Nearest Transformer (Mtrs)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.distanceToTransformerNode,
//               controller: controller.distanceToTransformerCtr,
//               hintLabel: "Enter Distance to Nearest Transformer",
//               onChanged: (val) {
//                 controller.validateDistanceToTransformer(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.distanceToTransformerModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Rating of Nearest Transformer (KVA)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.ratingOfTransformerNode,
//               controller: controller.ratingOfTransformerCtr,
//               hintLabel: "Enter Rating of Nearest Transformer",
//               onChanged: (val) {
//                 controller.validateRatingOfTransformer(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.ratingOfTransformerModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Purpose of Solarization", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.purposeOfSolarizationNode,
//               controller: controller.purposeOfSolarizationCtr,
//               hintLabel: "Enter Purpose of Solarization",
//               onChanged: (val) {
//                 controller.validatePurposeOfSolarization(val);
//               },
//               onTap: () {
//                 controller.countryCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "Purpose of Solarization",
//                   onCloseClick: () {
//                     controller.applyFilterforCountry('');
//                   },
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.purposeOfSolarizationModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Schedule Meeting", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.scheduleMeetingNode,
//               controller: controller.scheduleMeetingCtr,
//               hintLabel: "Select Schedule Meeting",
//               onChanged: (val) {
//                 controller.validateScheduleMeetings(val);
//               },
//               onTap: () {
//                 controller.openDatePicker(
//                   context: context,
//                   title: 'Select Start Date',
//                   controller: controller.scheduleMeetingCtr,
//                   dateRx: controller.startDate,
//                   model: controller.scheduleMeeeingModel,
//                 );
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.scheduleMeeeingModel.value.error,
//             );
//           }),
//         ];
//       case 1: // Files
//         return [
//           getCommonLableWithButton(
//             "Add Files",
//             isRequired: true,
//             onClick: () {
//               controller.addUploadFile(context);
//             },
//           ),
//           Obx(() {
//             if (controller.fileList.isEmpty) {
//               return const SizedBox();
//             }
//             return SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               child: buildDynamicTable(
//                 data: controller.fileList,
//                 columns: controller.uploadColumns,
//                 getValues: (file) => [
//                   file.uploadFile.toString(),
//                   file.category.toString(),
//                 ],
//                 onEdit: (i, file) {
//                   controller.addUploadFile(context, fileItem: file, index: i);
//                 },
//                 onDelete: (i) => controller.deleteFile(i),
//               ),
//             );
//           }),
//         ];
//       case 2: // Additional Details
//         return [
//           getLable("Dist. Inverter & ACDB Panel (Mtrs)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.distInverterACDBNode,
//               controller: controller.distInverterACDBCtr,
//               hintLabel: "Enter Dist. Inverter & ACDB Panel",
//               onChanged: (val) {
//                 controller.validateDistInverterACDB(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.distInverterACDBModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Dist. Solar & ACDB Panel (Mtrs)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.distSolarACDBNode,
//               controller: controller.distSolarACDBCtr,
//               hintLabel: "Enter Dist. Solar & ACDB Panel (Mtrs)",
//               onChanged: (val) {
//                 controller.validateDistSolarACDB(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.distSolarACDBModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Building Height (Floors)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.buildHeightNode,
//               controller: controller.buildingHeightCtr,
//               hintLabel: "Enter Building Height (Floors)",
//               onChanged: (val) {
//                 controller.validateDistInverterACDB(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.buildingHeightModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Roof Size Length (ft)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.roofSizeLengthNode,
//               controller: controller.roofSizeLengthCtr,
//               hintLabel: "Enter Roof Size Length",
//               onChanged: (val) {
//                 controller.validateRoofSizeLength(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.roofSizeLengthModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Roof Size Breadth (ft)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.roofSizeBreadthNode,
//               controller: controller.roofSizeBreadthCtr,
//               hintLabel: "Enter Roof Size Breadth",
//               onChanged: (val) {
//                 controller.validateRoofSizeBreadth(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.roofSizeBreadthModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Roof Nature", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.roofNatureNode,
//               controller: controller.roofNatureCtr,
//               hintLabel: "Enter Roof Nature",
//               onChanged: (val) {
//                 controller.validateRoofNature(val);
//               },
//               onTap: () {
//                 controller.countryCtr.text = "";
//                 commonDropDownDialog(
//                   context,
//                   content: controller.setCountryListDialog(),
//                   title: "Roof Nature",
//                   onCloseClick: () {
//                     controller.applyFilterforCountry('');
//                   },
//                 ).then((_) {});
//               },
//               formType: FieldType.text,
//               wantSuffix: true,
//               isdown: true,
//               isReadOnly: true,
//               inputType: TextInputType.none,
//               errorText: controller.roofNatureModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Age of Metal Sheet (years)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.ageOfMetalSheetNode,
//               controller: controller.ageOfMetalSheetCtr,
//               hintLabel: "Enter Age of Metal Sheet",
//               onChanged: (val) {
//                 controller.validateAgeOfMetalSheet(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.ageOfMetalSheetModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Ground Size Length (ft)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.groundSizeLengthNode,
//               controller: controller.groundSizeLengthCtr,
//               hintLabel: "Enter Ground Size Length",
//               onChanged: (val) {
//                 controller.validateGroundSizeLength(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.groundSizeLengthModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Ground Size Breadth (ft)", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.groundSizeBreadthNode,
//               controller: controller.groundSizeBreadthCtr,
//               hintLabel: "Enter Ground Size Breadth",
//               onChanged: (val) {
//                 controller.validateGroundSizeBreadth(val);
//               },
//               inputType: TextInputType.number,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.groundSizeBreadthModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getLable("Other Remarks", isRequired: true),
//           Obx(() {
//             return getReactiveFormField(
//               node: controller.otherRemarksNode,
//               controller: controller.otherRemarksCtr,
//               hintLabel: "Enter Other Remarks",
//               onChanged: (val) {
//                 controller.validateOtherRemarks(val);
//               },
//               inputType: TextInputType.text,
//               formType: FieldType.text,
//               wantSuffix: false,
//               errorText: controller.otherRemarksModel.value.error,
//             );
//           }),
//           getDynamicSizedBox(height: 2.h),
//           getCommonLableWithButton(
//             "Add Load Element",
//             isRequired: true,
//             onClick: () {
//               controller.addLoadElement(context);
//             },
//           ),
//           Obx(() {
//             if (controller.productDetailList.isEmpty) {
//               return const SizedBox();
//             }
//             return SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               child: buildDynamicTable(
//                 data: controller.productDetailList,
//                 columns: controller.leadsColumns,
//                 getValues: (item) => [
//                   item.deviceName.toString(),
//                   item.category.toString(),
//                   item.power.toString(),
//                   item.usageHrs.toString(),
//                   item.usageHrs.toString(),
//                   item.usageHrs.toString(),
//                 ],
//                 onEdit: (i, item) {
//                   controller.addLoadElement(
//                     context,
//                     loadElementItem: item,
//                     index: i,
//                   );
//                 },
//                 onDelete: (i) {
//                   controller.deleteLoad(i);
//                 },
//               ),
//             );
//           }),
//         ];
//       default:
//         return [];
//     }
//   }
// }
