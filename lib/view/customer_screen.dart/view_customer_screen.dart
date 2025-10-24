import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/controller/customer_controller/view_customer_controller.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class ViewCustomerScreen extends StatefulWidget {
  ViewCustomerScreen({super.key, required this.customerId});
  String customerId;

  @override
  State<ViewCustomerScreen> createState() => _ViewCustomerScreenState();
}

class _ViewCustomerScreenState extends State<ViewCustomerScreen> {
  final ViewCustomerController ctr = Get.put(ViewCustomerController());

  @override
  void initState() {
    super.initState();
    futureDelay(() {
      ctr.getViewCustomer(context, true, widget.customerId);
    }, isOneSecond: false);
  }

  @override
  Widget build(BuildContext context) {
    Statusbar().trasparentStatusbar();
    return CustomParentScaffold(
      isExtendBodyScreen: true,
      extendedbodybehindappbar: false,
      resizeToAvoidBottomInset: true,
      onWillPop: () => Future.value(true),
      onTap: () => hideKeyboard(context),
      body: Column(
        children: [
          getDynamicSizedBox(height: 1.h),
          getCommonToolbar(
            "View Customer",
            onClick: () {
              Get.back();
            },
          ),
          getDynamicSizedBox(height: 1.h),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 5.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    getDynamicSizedBox(height: 2.h),

                    /// Company Name
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Company Name',
                        ctr: ctr.companyNameCtr,
                        node: ctr.companyNameNode,
                        model: ctr.companynameModel.value,
                        gestureFunction: () {},
                        hint: 'Not Set',
                        isenable: false,
                        isRequired: false,
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Contact Person Name
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Contact Person Name',
                        ctr: ctr.personNameCtr,
                        node: ctr.personNameNode,
                        model: ctr.personNameModel.value,
                        gestureFunction: () {},
                        hint: 'Not Set',
                        isenable: false,
                        isRequired: false,
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Contact Person Mobile
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Contact Person Mobile',
                        ctr: ctr.mobileCtr,
                        node: ctr.mobileNode,
                        model: ctr.mobileModel.value,
                        gestureFunction: () {},
                        hint: 'Not Set',
                        isenable: false,
                        isRequired: false,
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Address',
                        ctr: ctr.addressCtr,
                        node: ctr.addressNode,
                        model: ctr.addressModel.value,
                        isenable: false,
                        hint: 'Not Set',
                        isMultipline: true,
                        isRequired: false,
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Country
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Country',
                        ctr: ctr.countryCtr,
                        node: ctr.countryNode,
                        model: ctr.countryModel.value,
                        isenable: false,
                        hint: 'Not Set',
                        isRequired: false,
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// State
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'State',
                        ctr: ctr.stateCtr,
                        node: ctr.stateNode,
                        model: ctr.stateModel.value,
                        isenable: false,
                        hint: 'Not Set',
                        isRequired: false,
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// District
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'District',
                        ctr: ctr.districtCtr,
                        node: ctr.districtNode,
                        model: ctr.districtModel.value,
                        isenable: false,
                        hint: 'Not Set',
                        isRequired: false,
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Latitude
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Latitude',
                        ctr: ctr.latitudeCtr,
                        node: ctr.latitudeNode,
                        model: ctr.latitudeModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Longitude
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Longitude',
                        ctr: ctr.longitudeCtr,
                        node: ctr.longitudeNode,
                        model: ctr.longitudeModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Customer Status
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Customer Status',
                        ctr: ctr.customerStatusCtr,
                        node: ctr.customerStatusNode,
                        model: ctr.customerStatusModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Conversion Date
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Conversion Date',
                        ctr: ctr.conversionDateCtr,
                        node: ctr.conversionDateNode,
                        model: ctr.conversionDateModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Live At
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Live At',
                        ctr: ctr.liveAtCtr,
                        node: ctr.liveAtNode,
                        model: ctr.liveAtModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Original Lead ID
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Original Lead ID',
                        ctr: ctr.leadIdCtr,
                        node: ctr.leadIdNode,
                        model: ctr.leadIdModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Expected Delivery Date
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Expected Delivery Date',
                        ctr: ctr.deliveryDateCtr,
                        node: ctr.deliveryDateNode,
                        model: ctr.deliveryDateModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Warranty Period
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Warranty Period (Years)',
                        ctr: ctr.warrantyPeriodCtr,
                        node: ctr.warrantyPeriodNode,
                        model: ctr.warrantyPeriodModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Warranty Type
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Warranty Type',
                        ctr: ctr.warrantyTypeCtr,
                        node: ctr.warrantyTypeNode,
                        model: ctr.warrantyTypeModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Warranty Start Date
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Warranty Start Date',
                        ctr: ctr.warrantyStartCtr,
                        node: ctr.warrantyStartNode,
                        model: ctr.warrantyStartModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Expiry
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Expiry',
                        ctr: ctr.expiryCtr,
                        node: ctr.expiryNode,
                        model: ctr.expiryModel.value,
                        isenable: false,
                        hint: 'Not Set',
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),

                    /// Installation Certificate
                    Obx(() {
                      return getTextField(
                        context: context,
                        wantLabel: true,
                        label: 'Installation Certificate',
                        ctr: ctr.installationCtr,
                        node: ctr.installationNode,
                        model: ctr.installationModel.value,
                        isNumeric: false,
                        wantsuffix: true,
                        ispass: true,
                        isenable: false,
                        usegesture: true,
                        gestureFunction: () {
                          // https://staging.sync-in.co.za/modules/auth/images/children_male_3.png
                          if (ctr.installationUrl.isNotEmpty) {
                            viewNetworkFile(context, ctr.installationUrl.value);
                          }
                        },
                        hint: 'Not Uploaded',
                      );
                    }),
                    getDynamicSizedBox(height: 3.h),

                    /// Submit Button
                    getFormButton(
                      context,
                      () {
                        Get.back();
                      },
                      'Close  ',
                      validate: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
