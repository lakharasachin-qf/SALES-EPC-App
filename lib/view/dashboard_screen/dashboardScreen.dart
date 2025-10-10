import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/dashboard_controller/dashboard_controller.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/view/dashboard_screen/widgets/dashboard_widgets.dart';
import 'package:sales_app/view/dashboard_screen/widgets/widgets.dart';
import 'package:sizer/sizer.dart';
 
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController ctr = Get.put(DashboardController());
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    futureDelay(() {
      // ctr.getRights();
      // ctr.getCurrentMonth(context);
      ctr.getFillterOptions(context);
      ctr.getDashboardData(context, isFirstTime: true);
    }, isOneSecond: true);
  }

  @override
  Widget build(BuildContext context) {
    Statusbar().trasparentStatusbar();
    return CustomParentScaffold(
      isExtendBodyScreen: true,
      extendedbodybehindappbar: false,
      onWillPop: () => Future.value(true),
      onTap: () => hideKeyboard(context),
      isdraweruse: true,
      scaffoldKey: ctr.scaffoldKey,
      drower: getDrawerDash(context, ctr: ctr),
      body: Column(
        children: [
          getDynamicSizedBox(height: 5.h),
          dashboardToolbar(
            onClick: () {
              ctr.openFilterBottomSheet(context: context);
            },
          ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              header: const WaterDropMaterialHeader(
                backgroundColor: primaryColor,
                color: white,
              ),
              onRefresh: () async {
                await futureDelay(() {
                  ctr.getFillterOptions(context);
                  ctr.getDashboardData(context, isFirstTime: true);
                }, isOneSecond: false);
                _refreshController.refreshCompleted();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final start = ctr.startDate.value;
                      final end = ctr.endDate.value;

                      logcat("startDate::", ctr.startDate.value);
                      logcat("endDate::", ctr.endDate.value);

                      String displayText = (start == end)
                          ? start
                          : '$start - $end';

                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: plusJakartaSansBold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      );
                    }),
                    getDynamicSizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Obx(
                        () => Column(
                          children: [
                            Row(
                              children: [
                                // if (ctr.isRescoTileVisible.value)
                                Expanded(
                                  child: getContainer(
                                    titleText: HomeScreenConst.leads,
                                    items: {
                                      "Total":
                                          "${ctr.tilesData.value?.leads?.totalLeads ?? 0}",
                                      "Won":
                                          "${ctr.tilesData.value?.leads?.leadsWon ?? 0}",
                                      "Lost":
                                          "${ctr.tilesData.value?.leads?.leadsLost ?? 0}",
                                      "Ongoing":
                                          "${ctr.tilesData.value?.leads?.leadsInProgress ?? 0}",
                                    },
                                    imagePath: Asset.lead,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                // if (ctr.isPerformanceTileVisible.value)
                                Expanded(
                                  child: getContainer(
                                    titleText: HomeScreenConst.conversion,
                                    items: {
                                      "Winning (%)":
                                          "${ctr.tilesData.value?.leads?.conversion ?? 0}",
                                    },
                                    imagePath: Asset.conversion,
                                  ),
                                ),
                              ],
                            ),
                            getDynamicSizedBox(height: 2.h),
                            Row(
                              children: [
                                // if (ctr.isKpiRevenueTileVisible.value)
                                Expanded(
                                  child: getContainer(
                                    titleText: HomeScreenConst.leadsCategory,
                                    items: {
                                      "Hot":
                                          "${ctr.tilesData.value?.leads?.leadCategories?.hot ?? 0}",
                                      "Warm":
                                          "${ctr.tilesData.value?.leads?.leadCategories?.warm ?? 0}",
                                      "Cold":
                                          "${ctr.tilesData.value?.leads?.leadCategories?.cold ?? 0}",
                                    },
                                    imagePath: Asset.categories,
                                  ),
                                ),
                                getDynamicSizedBox(width: 4.w),
                                // if (ctr.isRevenueTileVisible.value)
                                Expanded(
                                  child: getContainer(
                                    titleText: HomeScreenConst.revenue,
                                    items: {
                                      "Total Revenue":
                                          "INR ${NumberFormat.currency(locale: 'en_IN', symbol: '').format(ctr.tilesData.value?.leads?.totalRevenue ?? 0)}",
                                    },
                                    imagePath: Asset.revenue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => Container(
                        width: Device.width,
                        margin: EdgeInsets.only(
                          right: 4.w,
                          left: 4.w,
                          top: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: buildCircularChart(
                          data: ctr.leadsStatusDistribution.value,
                        ),
                      ),
                    ),
                    Obx(
                      () => Container(
                        width: Device.width,
                        margin: EdgeInsets.only(
                          right: 4.w,
                          left: 4.w,
                          top: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: buildLeadByClusterChart(
                          data: ctr.leadsByClusterBreakdown.value,
                        ),
                      ),
                    ),
                    Obx(
                      () => Container(
                        width: Device.width,
                        margin: EdgeInsets.only(
                          right: 4.w,
                          left: 4.w,
                          top: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: buildLeadsWonOverTimeChart(
                          data: ctr.leadsWonProgress.value,
                        ),
                      ),
                    ),
                    // Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 5.w),
                    //   alignment: Alignment.centerRight,
                    //   child: Obx(() {
                    //     return getSvgDropdownButton(
                    //       svgAssetPath: Asset.menufilter,
                    //       items: ctr.selectedTargetList,
                    //       selectedValue: ctr.selectedTarget.value,
                    //       onChanged: (value) {
                    //         ctr.selectedTarget.value = value!;

                    //         if (ctr.selectedTarget.value == 'Revenue Targets') {
                    //           ctr.isRevenueVisible.value = true;
                    //         } else {
                    //           ctr.isRevenueVisible.value = false;
                    //         }
                    //       },
                    //     );
                    //   }),
                    // ),
                    // getReactiveDropdown(
                    //   hint: "Select DG Sync",
                    //   items: ctr.selectedTargetList,
                    //   selectedValue: ctr.selectedTarget,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       ctr.selectedTarget = value!;
                    //     });
                    //   },
                    // ),
                    Obx(
                      () => Container(
                        width: Device.width,
                        margin: EdgeInsets.only(
                          right: 4.w,
                          left: 4.w,
                          top: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ctr.isRevenueVisible.value
                            ? buildRevenueTargetsChart(
                                data: ctr.revenueVsTargets.value,
                                ctr: ctr,
                              )
                            : buildCustomerTargetsChart(
                                data: ctr.revenueVsTargets.value,
                                ctr: ctr,
                              ),
                      ),
                    ),
                    getDynamicSizedBox(height: 12.h),
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
