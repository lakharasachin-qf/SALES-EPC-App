import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:intl/intl.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart' hide getpopup;
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/dashboard_controller/dashboard_controller.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/AppPermissions.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/view/customer_screen.dart/customer_screen.dart';
import 'package:sales_app/view/lead_screenn/lead_screen.dart';
import 'package:sales_app/view/meetings_calendar_screen/meetings_calendar_screen.dart';
import 'package:sales_app/view/signin_screen/signin_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Widget getContainer({
  required titleText,
  required Map<String, String> items,
  String? imagePath,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Stack(
        children: [
          Container(
            width: Device.width,
            height: 15.5.h,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...items.entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(
                        bottom: 0.5.h,
                        left: 2.w,
                        right: 2.w,
                      ),
                      child: Text(
                        "${e.key}: ${e.value}",
                        style: TextStyle(
                          color: white,
                          fontFamily: plusJakartaSansBold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 👇 PNG Image on Top Right
          Positioned(
            top: 0.9.h, // adjust padding
            right: 2.w,
            child: Image.asset(imagePath!, height: 3.h, width: 3.h),
          ),
        ],
      ),

      Container(height: 0.1.h, color: white),
      Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        width: Device.width,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            titleText,
            style: TextStyle(
              color: white,
              fontFamily: plusJakartaSansBold,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    ],
  );
}

Drawer getDrawer(BuildContext context, {required var ctr, widget}) {
  return Drawer(
    width: 70.w,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
    ),
    child: Container(
      decoration: BoxDecoration(color: transparent),
      child: widget,
    ),
  );
}

Drawer getDrawerDash(BuildContext context, {required var ctr}) {
  return getDrawer(
    context,
    ctr: ctr,
    widget: getDashboardDrawer(context, ctr: ctr),
  );
}

Widget getDashboardDrawer(
  BuildContext context, {
  required DashboardController ctr,
}) {
  logcat('isLeadManagement', AppPermissions().isLeadManagement);
  logcat('canViewCustomer', AppPermissions().canViewCustomer);
  logcat('canAccessMeetingCalendar', AppPermissions().canAccessMeetingCalendar);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getDynamicSizedBox(height: 6.h),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        child: Image.asset(Asset.logoPng),
      ),
      getDynamicSizedBox(height: 2.h),
      Row(
        children: [
          SizedBox(width: 2.w),
          Icon(Icons.person),
          SizedBox(width: 3.w),
          Expanded(
            child: Obx(() {
              return Text(
                ctr.userEmail.value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: plusJakartaSansSemiBold,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              );
            }),
          ),
        ],
      ),

      getDynamicSizedBox(height: 2.h),
      getappLine(),
      getDynamicSizedBox(height: 1.h),

      AppPermissions().canAccessDashboard == true
          ? buildDrawerItem(Asset.dashboard2, HomeScreenConst.dashboard, () {
              ctr.scaffoldKey.currentState?.closeDrawer();
              logcat("onTap", "Done");
            })
          : SizedBox.shrink(),
      // getDynamicSizedBox(height: 1.h),
      AppPermissions().isLeadManagement
          ? buildDrawerItem(Asset.compass, HomeScreenConst.leads, () {
              ctr.scaffoldKey.currentState?.closeDrawer();
              Get.to(LeadScreen());
            })
          : SizedBox.shrink(),
      // getDynamicSizedBox(height: 1.h),
      // Obx(() {
      //   return ctr.isAddMeterReadings.value == true
      //       ? buildDrawerItem(Asset.compass, HomeScreenConst.leads, () {
      //           ctr.scaffoldKey.currentState?.closeDrawer();
      //           Get.to(LeadScreen());
      //         })
      //       : SizedBox.shrink();
      // }),
      // Obx(() {
      //   return ctr.isAddMeterReadings.value == true
      //       ? getDynamicSizedBox(height: 1.h)
      //       : SizedBox.shrink();
      // }),
      AppPermissions().isCustomerManagement
          ? buildDrawerItem(Asset.users2, HomeScreenConst.customers, () {
              ctr.scaffoldKey.currentState?.closeDrawer();
              Get.to(Customerscreen());
            })
          : SizedBox.shrink(),
      // Obx(() {
      //   return ctr.isViewCustomer.value == true
      //       ? buildDrawerItem(Asset.users2, HomeScreenConst.customers, () {
      //           ctr.scaffoldKey.currentState?.closeDrawer();
      //           Get.to(Customerscreen());
      //         })
      //       : SizedBox.shrink();
      // }),
      // getDynamicSizedBox(height: 1.h),
      AppPermissions().canAccessMeetingCalendar
          ? buildDrawerItem(
              Asset.meetingsCalendar,
              HomeScreenConst.meetingsCalendar,
              () {
                ctr.scaffoldKey.currentState?.closeDrawer();
                Get.to(MeetingsCalendarScreen());
              },
            )
          : SizedBox.shrink(),
      buildDrawerItem(Asset.logout, 'Logout', () async {
        ctr.scaffoldKey.currentState?.closeDrawer();
        getpopup(
          context,
          title: Logout.title,
          message: Logout.msg,
          function: () {
            UserPreferences().logout();
            Get.offAll(Signinscreen());
          },
        );
      }),
    ],
  );
}

Widget buildDrawerItem(
  String icon,
  String title,
  VoidCallback onTap, {
  Color color = black,
  double iconHeight = 18,
  IconData? iconData,
}) {
  return SizedBox(
    width: double.infinity,
    height: 5.h,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconData != null
              ? Icon(iconData, size: 18.sp, color: color)
              : getSvgAsset(
                  icon,
                  iconHeight.sp,
                  iconHeight.sp,
                  color: ColorFilter.mode(black, BlendMode.srcIn),
                ),
          getDynamicSizedBox(width: 2.w),
          Container(
            margin: EdgeInsets.only(bottom: 0.2.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                color: color,
                // fontWeight: FontWeight.w500,
                fontFamily: plusJakartaSansSemiBold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void openDatePickerDash(
  BuildContext context, {
  required bool isStart,
  required DashboardController ctr,
}) {
  ctr.isStartDateActive.value = isStart;

  final String selected = isStart ? ctr.startDate.value : ctr.endDate.value;
  DateTime? initialDate;
  if (selected.isNotEmpty) {
    try {
      // Try parsing with the new display format (MMMM yyyy)
      initialDate = ctr.dateFormat.parse(selected);
    } catch (e) {
      try {
        // Fallback to legacy format (dd-MM-yyyy) for backward compatibility
        initialDate = DateFormat('dd-MM-yyyy').parse(selected);
      } catch (e) {
        initialDate = null; // Handle invalid format gracefully
      }
    }
  }

  // Determine minDate for end date selection
  DateTime? minDate;
  if (!isStart && ctr.startDate.value.isNotEmpty) {
    try {
      minDate = ctr.dateFormat.parse(ctr.startDate.value);
      // Set minDate to the first of the start month
      minDate = DateTime(minDate.year, minDate.month, 1);
    } catch (e) {
      minDate = null; // Handle invalid start date gracefully
    }
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        height: 45.h,
        width: double.maxFinite,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                isStart
                    ? 'Select Start Month & Year'
                    : 'Select End Month & Year',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.single,
                view: DateRangePickerView.year, // Show year view with months
                initialSelectedDate: initialDate,
                initialDisplayDate: initialDate,
                minDate:
                    minDate, // Restrict end date to be on or after start date
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is DateTime) {
                    DateTime selectedDate = args.value;

                    // Set date to 1st of the month to ignore day
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      1,
                    );

                    // Pass DateTime to controller
                    ctr.onDateSelected(selectedDate);
                    Navigator.of(context).pop(); // Close dialog immediately
                  }
                },
                showTodayButton: false,
                showNavigationArrow: true,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1,
                ),
                selectionColor: primaryColor,
                todayHighlightColor: primaryColor,
                allowViewNavigation: false, // Prevent switching to day view
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget addFilterSheetWidget(
  BuildContext context, {
  required DashboardController ctr,
  required setStateTrigger,
}) {
  return GestureDetector(
    onTap: () {
      ctr.unfocusAll();
    },
    child: SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 2.h, left: 6.w, right: 6.w, top: 2.h),
      child: SizedBox(
        width: Device.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // getCustomDivider(),
            // getDynamicSizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() {
                    return getTextField(
                      context: context,
                      wantLabel: true,
                      label: 'Start Month-Year',
                      ctr: ctr.startTimeCtr,
                      node: ctr.startTimeNode,
                      model: ctr.startTimeModel.value,
                      isenable: false,
                      isdropdown: true,
                      wantsuffix: true,
                      usegesture: true,
                      gestureFunction: () {
                        openDatePickerDash(context, isStart: true, ctr: ctr);
                      },
                      hint: 'Select Date',
                      isRequired: false,
                    );
                  }),
                ),
                getDynamicSizedBox(width: 4.w),
                Expanded(
                  child: Obx(() {
                    return getTextField(
                      context: context,
                      wantLabel: true,
                      label: 'End Month-Year',
                      ctr: ctr.endTimeCtr,
                      node: ctr.endTimeNode,
                      model: ctr.endTimeModel.value,
                      isenable: false,
                      isdropdown: true,
                      wantsuffix: true,
                      usegesture: true,
                      gestureFunction: () {
                        if (!ctr.isStartDateSelected.value) {
                          showDialogForScreen(
                            context,
                            'Dashboard',
                            'Please select the start date first.',
                            callback: () {},
                          );
                        } else {
                          openDatePickerDash(context, isStart: false, ctr: ctr);
                        }
                      },
                      hint: 'Select End Date',
                      isRequired: false,
                    );
                  }),
                ),
              ],
            ),
            getDynamicSizedBox(height: 1.h),

            /// District
            Obx(() {
              return getTextField(
                context: context,
                wantLabel: true,
                label: 'District',
                ctr: ctr.district,
                node: ctr.districtNode,
                model: ctr.districtModel.value,
                isenable: false,
                isdropdown: true,
                wantsuffix: true,
                usegesture:
                    (!ctr.isDistrictSelected.value &&
                        !ctr.isClusterSelected.value) ||
                    ctr.isDistrictSelected.value,
                isVerified:
                    !ctr.isDistrictSelected.value &&
                    (ctr.isClusterSelected.value),
                gestureFunction: () {
                  ctr.showDistrictSelectionPopups(context);
                },
                hint: 'Select District',
              );
            }),
            getDynamicSizedBox(height: 1.h),

            /// Clusters
            Obx(() {
              return getTextField(
                context: context,
                wantLabel: true,
                label: 'Clusters',
                ctr: ctr.clusterCtr,
                node: ctr.clusterNode,
                model: ctr.clusterModel.value,
                isenable: false,
                isdropdown: true,
                wantsuffix: true,
                usegesture:
                    (!ctr.isDistrictSelected.value) ||
                    ctr.isClusterSelected.value,
                isVerified:
                    !ctr.isClusterSelected.value &&
                    (ctr.isDistrictSelected.value),
                gestureFunction: () {
                  ctr.showClusterSelectionPopups(context);
                },
                hint: 'Select Clusters',
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
                      ctr.resetForm();
                      ctr.isStartDateSelected = false.obs;
                      ctr.getDashboardData(context, isFirstTime: true);
                      Get.back();
                    },
                    'Clear',
                    validate: true,
                  ),
                ),
                getDynamicSizedBox(width: 3.w),
                Expanded(
                  child: getFormButton(
                    context,
                    () {
                      // ctr.makeApiCall(context);
                      ctr.getDashboardData(context, isApplyFilter: true);
                      Get.back();
                    },
                    'Search',
                    validate: true,
                  ),
                ),
              ],
            ),
            getDynamicSizedBox(height: 4.h),
          ],
        ),
      ),
    ),
  );
}
