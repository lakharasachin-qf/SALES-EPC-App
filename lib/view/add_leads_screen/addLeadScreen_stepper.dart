
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/controller/leads_controller/leads_controller.dart';
import 'package:sales_app/utils/buildDynamicTable.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sizer/sizer.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  var controller = Get.put(LeadsController());
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    Statusbar().trasparentStatusbarProfile(false);
    return CustomParentScaffold(
      onWillPop: () async {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
          return false;
        }
        return true;
      },
      onTap: () {
        hideKeyboard(context);
      },
      isExtendBodyScreen: true,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          getCommonToolbar(
            "Add Leads",
            onClick: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
              } else {
                Get.back();
              }
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                _buildStep(0, "Basic"),
                _buildConnector(),
                _buildStep(1, "Add Load Element"),
                _buildConnector(),
                _buildStep(2, "Add Files"),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: controller.formKey,
              child: StepperBody(
                currentStep: _currentStep,
                controller: controller,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    // Submit form
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep--;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title) {
    bool isActive = _currentStep == stepIndex;
    bool isCompleted = _currentStep > stepIndex;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _currentStep = stepIndex;
            });
          },
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? primaryColor : (isActive ? primaryColor.withOpacity(0.5) : Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  color: isCompleted || isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          title,
          style: TextStyle(
            color: isActive || isCompleted ? primaryColor : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 10.sp
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey.shade300,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
      ),
    );
  }
}

class StepperBody extends StatelessWidget {
  final int currentStep;
  final LeadsController controller;
  final VoidCallback onStepContinue;
  final VoidCallback onStepCancel;

  const StepperBody({
    super.key,
    required this.currentStep,
    required this.controller,
    required this.onStepContinue,
    required this.onStepCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: _buildStepContent(context),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentStep > 0)
                ElevatedButton(
                  onPressed: onStepCancel,
                  child: const Text("Back"),
                ),
              ElevatedButton(
                onPressed: onStepContinue,
                child: Text(currentStep == 2 ? "Submit" : "Next"),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (currentStep) {
      case 0:
        return _buildBasicForm(context);
      case 1:
        return _buildAddLoadElementForm(context);
      case 2:
        return _buildAddFilesForm(context);
      default:
        return const SizedBox.shrink();
    }
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
            errorText:
                controller.personNameModel.value.error,
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
            errorText:
                controller.personMobileModel.value.error,
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
            errorText:
                controller.leadCategoryModel.value.error,
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
            errorText:
                controller.dgCapacityModel.value.error,
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
        getLable(
          "Installed Solar Capacity",
          isRequired: true,
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
            errorText:
                controller.sanctionedLoadModel.value.error,
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
            errorText: controller
                .gridAvailabilityModel
                .value
                .error,
          );
        }),

        getDynamicSizedBox(height: 2.h),
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
          isRequired: true,
        ),
        Obx(() {
          return getReactiveFormField(
            node: controller.distanceToTransformerNode,
            controller: controller.distanceToTransformerCtr,
            hintLabel:
                "Enter Distance to Nearest Transformer",
            onChanged: (val) {
              controller.validateDistanceToTransformer(val);
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
        getLable(
          "Purpose of Solarization",
          isRequired: true,
        ),
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
            hintLabel: "Enter Dist. Inverter & ACDB Panel",
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
              controller.validateDistInverterACDB(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText:
                controller.buildingHeightModel.value.error,
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
            errorText:
                controller.roofSizeLengthModel.value.error,
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
              controller.validateRoofSizeBreadth(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText:
                controller.roofSizeBreadthModel.value.error,
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
              controller.validateAgeOfMetalSheet(val);
            },
            inputType: TextInputType.number,
            formType: FieldType.text,
            wantSuffix: false,
            errorText:
                controller.ageOfMetalSheetModel.value.error,
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
            errorText:
                controller.scheduleMeeeingModel.value.error,
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
      ],
    );
  }
}
