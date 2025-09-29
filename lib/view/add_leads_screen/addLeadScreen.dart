import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
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
              "Add Leads",
              onClick: () {
                Get.back();
              },
            ),
            getDynamicSizedBox(height: 1.h),
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
                            // DropdownButtonHideUnderline(
                            //   child: DropdownButton2(
                            //     buttonStyleData: ButtonStyleData(
                            //       padding: EdgeInsets.only(
                            //         left: Device.screenType == ScreenType.mobile
                            //             ? 0.0
                            //             : 2.0.w,
                            //         right:
                            //             Device.screenType == ScreenType.mobile
                            //             ? 3.w
                            //             : 2.0.w,
                            //         top: Device.screenType == ScreenType.mobile
                            //             ? 4.5
                            //             : 1.2.w,
                            //         bottom:
                            //             Device.screenType == ScreenType.mobile
                            //             ? 4.5
                            //             : 1.2.w,
                            //       ),
                            //       decoration: BoxDecoration(
                            //         color: inputBgColor,
                            //         borderRadius: BorderRadius.circular(
                            //           Device.screenType == ScreenType.mobile
                            //               ? 10
                            //               : 50,
                            //         ),
                            //         border: Border.all(
                            //           color: inputBorderColor,
                            //           width: 1.5,
                            //         ),
                            //       ),
                            //     ),
                            //     isExpanded: true,
                            //     hint: Text(
                            //       "Enter DG Sync",
                            //       style: styleTextHintFieldLabel(),
                            //     ),
                            //     items: controller.dgSync
                            //         .map(
                            //           (item) => DropdownMenuItem<String>(
                            //             value: item,
                            //             child:
                            //                 Device.screenType ==
                            //                     ScreenType.mobile
                            //                 ? Text(
                            //                     item,
                            //                     style: styleTextFormFieldText(),
                            //                   )
                            //                 : Padding(
                            //                     padding: const EdgeInsets.only(
                            //                       top: 20,
                            //                       bottom: 10,
                            //                       left: 10,
                            //                     ),
                            //                     child: Text(
                            //                       item,
                            //                       style:
                            //                           styleTextFormFieldText(),
                            //                     ),
                            //                   ),
                            //           ),
                            //         )
                            //         .toList(),
                            //     value: controller.selectDgSync,
                            //     onChanged: (value) {
                            //       setState(() {
                            //         controller.selectDgSync = value as String;
                            //       });
                            //     },
                            //     dropdownStyleData: DropdownStyleData(
                            //       maxHeight:
                            //           Device.screenType == ScreenType.mobile
                            //           ? Device.height / 1.8
                            //           : Device.height / 1,
                            //       decoration: BoxDecoration(
                            //         color: white,
                            //         borderRadius: BorderRadius.circular(2.h),
                            //         boxShadow: [
                            //           BoxShadow(
                            //             color: grey.withOpacity(0.2),
                            //             blurRadius: 10.0,
                            //             offset: const Offset(0, 1),
                            //             spreadRadius: 3.0,
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //     menuItemStyleData: MenuItemStyleData(
                            //       height: Device.screenType == ScreenType.mobile
                            //           ? 40
                            //           : 60,
                            //     ),
                            //     iconStyleData: IconStyleData(
                            //       icon: Icon(
                            //         Icons.keyboard_arrow_down_rounded,
                            //         size: Device.screenType == ScreenType.mobile
                            //             ? 30
                            //             : 40,
                            //         color: black.withOpacity(0.2),
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                setState(() {
                                  controller.selectVfd = value!;
                                });
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
                            getDynamicSizedBox(height: 2.h),
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

                            // Obx(() {
                            //   return controller.fileList.isNotEmpty
                            //       ? SingleChildScrollView(
                            //           scrollDirection: Axis.horizontal,
                            //           physics: const BouncingScrollPhysics(),
                            //           child: Padding(
                            //             padding: EdgeInsets.only(
                            //               bottom: 3.h,
                            //               top: 2.h,
                            //             ),
                            //             child: Obx(() {
                            //               List<DataRow> newDataList = [];
                            //               for (
                            //                 var i = 0;
                            //                 i < controller.fileList.length;
                            //                 i++
                            //               ) {
                            //                 var uploadList =
                            //                     controller.fileList[i];
                            //                 newDataList.add(
                            //                   DataRow(
                            //                     cells: [
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             (i + 1).toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Row(
                            //                             crossAxisAlignment:
                            //                                 CrossAxisAlignment
                            //                                     .center,
                            //                             mainAxisAlignment:
                            //                                 MainAxisAlignment
                            //                                     .center,
                            //                             children: [
                            //                               SizedBox(
                            //                                 width: 4.h,
                            //                                 height: 4.h,
                            //                                 child: IconButton(
                            //                                   padding:
                            //                                       EdgeInsets
                            //                                           .zero,
                            //                                   icon: const Icon(
                            //                                     Icons.edit,
                            //                                   ),
                            //                                   onPressed: () {
                            //                                     controller
                            //                                         .addUploadFile(
                            //                                           context,
                            //                                           fileItem:
                            //                                               uploadList,
                            //                                           index: i,
                            //                                         );
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                               SizedBox(
                            //                                 width: 4.h,
                            //                                 height: 4.h,
                            //                                 child: IconButton(
                            //                                   padding:
                            //                                       EdgeInsets
                            //                                           .zero,
                            //                                   icon: const Icon(
                            //                                     Icons.delete,
                            //                                     color: red,
                            //                                   ),
                            //                                   onPressed: () {
                            //                                     controller
                            //                                         .deleteFile(
                            //                                           i,
                            //                                         );
                            //                                     setState(() {});
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.uploadFile
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.category
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 );
                            //               }
                            //               return Column(
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.start,
                            //                 children: [
                            //                   DataTable(
                            //                     dataTextStyle: TextStyle(
                            //                       fontFamily:
                            //                           plusJakartaSansBold,
                            //                       fontSize: 2.h,
                            //                       color: black,
                            //                     ),
                            //                     columnSpacing: 13,
                            //                     horizontalMargin: 13,
                            //                     columns:
                            //                         controller.uploadColumns,
                            //                     headingRowColor:
                            //                         MaterialStateProperty.all(
                            //                           isDarkMode()
                            //                               ? white
                            //                               : primaryColor,
                            //                         ),

                            //                     headingTextStyle:
                            //                         const TextStyle(
                            //                           fontFamily:
                            //                               plusJakartaSansBold,
                            //                         ),
                            //                     border: TableBorder.all(
                            //                       color: grey,
                            //                       borderRadius:
                            //                           BorderRadius.only(
                            //                             topLeft:
                            //                                 Radius.circular(
                            //                                   1.h,
                            //                                 ),
                            //                             topRight:
                            //                                 Radius.circular(
                            //                                   1.h,
                            //                                 ),
                            //                           ),
                            //                     ),
                            //                     clipBehavior: Clip.antiAlias,
                            //                     showBottomBorder: true,
                            //                     rows: newDataList,
                            //                   ),
                            //                 ],
                            //               );
                            //             }),
                            //           ),
                            //         )
                            //       : SizedBox();
                            // }),
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
                            // Obx(() {
                            //   return controller.productDetailList.isNotEmpty
                            //       ? SingleChildScrollView(
                            //           scrollDirection: Axis.horizontal,
                            //           physics: const BouncingScrollPhysics(),
                            //           child: Padding(
                            //             padding: EdgeInsets.only(
                            //               bottom: 3.h,
                            //               top: 2.h,
                            //             ),
                            //             child: Obx(() {
                            //               List<DataRow> newDataList = [];
                            //               for (
                            //                 var i = 0;
                            //                 i <
                            //                     controller
                            //                         .productDetailList
                            //                         .length;
                            //                 i++
                            //               ) {
                            //                 var uploadList =
                            //                     controller.productDetailList[i];
                            //                 newDataList.add(
                            //                   DataRow(
                            //                     cells: [
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             (i + 1).toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Row(
                            //                             crossAxisAlignment:
                            //                                 CrossAxisAlignment
                            //                                     .center,
                            //                             mainAxisAlignment:
                            //                                 MainAxisAlignment
                            //                                     .center,
                            //                             children: [
                            //                               SizedBox(
                            //                                 width: 4.h,
                            //                                 height: 4.h,
                            //                                 child: IconButton(
                            //                                   padding:
                            //                                       EdgeInsets
                            //                                           .zero,
                            //                                   icon: const Icon(
                            //                                     Icons.edit,
                            //                                   ),
                            //                                   onPressed: () {
                            //                                     controller.addLoadElement(
                            //                                       context,
                            //                                       loadElementItem:
                            //                                           uploadList,
                            //                                       index: i,
                            //                                     );
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                               SizedBox(
                            //                                 width: 4.h,
                            //                                 height: 4.h,
                            //                                 child: IconButton(
                            //                                   padding:
                            //                                       EdgeInsets
                            //                                           .zero,
                            //                                   icon: const Icon(
                            //                                     Icons.delete,
                            //                                     color: red,
                            //                                   ),
                            //                                   onPressed: () {
                            //                                     controller
                            //                                         .deleteLoad(
                            //                                           i,
                            //                                         );
                            //                                     setState(() {});
                            //                                   },
                            //                                 ),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.deviceName
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.category
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.power
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.usageHrs
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.usageHrs
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       DataCell(
                            //                         Center(
                            //                           child: Text(
                            //                             uploadList.usageHrs
                            //                                 .toString(),
                            //                             maxLines: 3,
                            //                             textAlign:
                            //                                 TextAlign.center,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: TextStyle(
                            //                               fontFamily:
                            //                                   plusJakartaSansBold,
                            //                               fontSize: 1.8.h,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 );
                            //               }
                            //               return Column(
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.start,
                            //                 children: [
                            //                   DataTable(
                            //                     dataTextStyle: TextStyle(
                            //                       fontFamily:
                            //                           plusJakartaSansBold,
                            //                       fontSize: 2.h,
                            //                       color: black,
                            //                     ),
                            //                     columnSpacing: 13,
                            //                     horizontalMargin: 13,
                            //                     columns:
                            //                         controller.leadsColumns,
                            //                     headingRowColor:
                            //                         MaterialStateProperty.all(
                            //                           isDarkMode()
                            //                               ? white
                            //                               : primaryColor,
                            //                         ),

                            //                     headingTextStyle:
                            //                         const TextStyle(
                            //                           fontFamily:
                            //                               plusJakartaSansBold,
                            //                         ),
                            //                     border: TableBorder.all(
                            //                       color: grey,
                            //                       borderRadius:
                            //                           BorderRadius.only(
                            //                             topLeft:
                            //                                 Radius.circular(
                            //                                   1.h,
                            //                                 ),
                            //                             topRight:
                            //                                 Radius.circular(
                            //                                   1.h,
                            //                                 ),
                            //                           ),
                            //                     ),
                            //                     clipBehavior: Clip.antiAlias,
                            //                     showBottomBorder: true,
                            //                     rows: newDataList,
                            //                   ),
                            //                 ],
                            //               );
                            //             }),
                            //           ),
                            //         )
                            //       : SizedBox();
                            // }),
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
