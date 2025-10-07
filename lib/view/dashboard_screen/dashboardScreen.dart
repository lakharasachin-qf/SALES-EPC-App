import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/dashboard_controller/dashboard_controller.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/view/dashboard_screen/widgets/dashboard_widgets.dart';
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
      // ctr.getDashboardData(context, 1, isFirstTime: true);
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
                  // ctr.getDashboardData(context, 1, isFirstTime: true);
                  // ctr.getCurrentMonth(context);
                }, isOneSecond: false);
                _refreshController.refreshCompleted();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getDynamicSizedBox(height: 2.h),
                    // if (AppPermissions().canAddUser)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Obx(
                        () => Column(
                          children: [
                            Row(
                              children: [
                                if (ctr.isRescoTileVisible.value)
                                  Expanded(
                                    child: getContainer(
                                      titleText: HomeScreenConst.leads,
                                      items: {
                                        "Total": "18",
                                        "Won": "13",
                                        "Lost": "1",
                                        "Ongoing": "4",
                                      },
                                      imagePath: Asset.lead,
                                    ),
                                  ),
                                SizedBox(width: 4.w),
                                if (ctr.isPerformanceTileVisible.value)
                                  Expanded(
                                    child: getContainer(
                                      titleText: HomeScreenConst.conversion,
                                      items: {"Winning (%)": "72"},
                                      imagePath: Asset.conversion,
                                    ),
                                  ),
                              ],
                            ),
                            getDynamicSizedBox(height: 2.h),
                            Row(
                              children: [
                                if (ctr.isKpiRevenueTileVisible.value)
                                  Expanded(
                                    child: getContainer(
                                      titleText: HomeScreenConst.leadsCategory,
                                      items: {
                                        "Hot": "12",
                                        "Warm": "4",
                                        "Cold": "2",
                                      },
                                      imagePath: Asset.categories,
                                    ),
                                  ),
                                getDynamicSizedBox(width: 4.w),
                                if (ctr.isRevenueTileVisible.value)
                                  Expanded(
                                    child: getContainer(
                                      titleText: HomeScreenConst.revenue,
                                      items: {
                                        "Total Revenue": "\nINR 18,59,000",
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
                    // Container(
                    //   width: Device.width,
                    //   margin: EdgeInsets.only(right: 4.w, left: 4.w, top: 3.h),
                    //   decoration: BoxDecoration(
                    //     color: white,
                    //     borderRadius: BorderRadius.circular(10),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: black.withOpacity(0.05),
                    //         offset: const Offset(0, 2),
                    //         blurRadius: 4,
                    //         spreadRadius: 0,
                    //       ),
                    //     ],
                    //   ),
                    //   child: buildCircularChart(data: ctr.leadData),
                    // ),
                    // Container(
                    //   width: Device.width,
                    //   margin: EdgeInsets.only(right: 4.w, left: 4.w, top: 3.h),
                    //   decoration: BoxDecoration(
                    //     color: white,
                    //     borderRadius: BorderRadius.circular(10),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: black.withOpacity(0.05),
                    //         offset: const Offset(0, 2),
                    //         blurRadius: 4,
                    //         spreadRadius: 0,
                    //       ),
                    //     ],
                    //   ),
                    //   child: buildLeadByClusterChart(data: ctr.clusterData),
                    // ),
                    // Container(
                    //   width: Device.width,
                    //   margin: EdgeInsets.only(right: 4.w, left: 4.w, top: 3.h),
                    //   decoration: BoxDecoration(
                    //     color: white,
                    //     borderRadius: BorderRadius.circular(10),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: black.withOpacity(0.05),
                    //         offset: const Offset(0, 2),
                    //         blurRadius: 4,
                    //         spreadRadius: 0,
                    //       ),
                    //     ],
                    //   ),
                    //   child: buildLeadsWonOverTimeChart(data: ctr.leadWonData),
                    // ),
                    // Obx(() {
                    //   return Container(
                    //     width: Device.width,
                    //     margin: EdgeInsets.only(
                    //       right: 4.w,
                    //       left: 4.w,
                    //       top: 3.h,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: white,
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: black.withOpacity(0.05),
                    //           offset: const Offset(0, 2),
                    //           blurRadius: 4,
                    //           spreadRadius: 0,
                    //         ),
                    //       ],
                    //     ),
                    //     child: buildRevenueTargetsChart(data: ctr.revenuesData),
                    //   );
                    // }),
                    // Obx(
                    //   () => Container(
                    //     margin: EdgeInsets.only(
                    //       right: 4.w,
                    //       left: 4.w,
                    //       top: 3.h,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: white,
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: black.withOpacity(0.05),
                    //           offset: const Offset(0, 2),
                    //           blurRadius: 4,
                    //           spreadRadius: 0,
                    //         ),
                    //       ],
                    //     ),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         buildChart(data: ctr.paginatedChartData),
                    //         buildPaginationButtons(
                    //           currentPage: ctr.chartPage.value,
                    //           maxPage: ctr.maxChartPage,
                    //           onBack: () => ctr.chartPage.value--,
                    //           onForward: () => ctr.chartPage.value++,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Obx(
                    //   () => Container(
                    //     margin: EdgeInsets.only(
                    //       right: 4.w,
                    //       left: 4.w,
                    //       top: 2.h,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: white,
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: black.withOpacity(0.05),
                    //           offset: const Offset(0, 2),
                    //           blurRadius: 4,
                    //           spreadRadius: 0,
                    //         ),
                    //       ],
                    //     ),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         buildRevenueChart(ctr.paginatedRevenueData),
                    //         buildPaginationButtons(
                    //           currentPage: ctr.revenuePage.value,
                    //           maxPage: ctr.maxRevenuePage,
                    //           onBack: () => ctr.revenuePage.value--,
                    //           onForward: () => ctr.revenuePage.value++,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Obx(
                    //   () => Container(
                    //     margin: EdgeInsets.only(
                    //       right: 4.w,
                    //       left: 4.w,
                    //       top: 2.h,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: white,
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: black.withOpacity(0.05),
                    //           offset: const Offset(0, 2),
                    //           blurRadius: 4,
                    //           spreadRadius: 0,
                    //         ),
                    //       ],
                    //     ),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         buildUnitChart(ctr.paginatedUnitData),
                    //         buildPaginationButtons(
                    //           currentPage: ctr.unitPage.value,
                    //           maxPage: ctr.maxUnitPage,
                    //           onBack: () => ctr.unitPage.value--,
                    //           onForward: () => ctr.unitPage.value++,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Obx(
                    //   () => Container(
                    //     margin: EdgeInsets.only(
                    //       right: 4.w,
                    //       left: 4.w,
                    //       top: 2.h,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: white,
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: black.withOpacity(0.05),
                    //           offset: const Offset(0, 2),
                    //           blurRadius: 4,
                    //           spreadRadius: 0,
                    //         ),
                    //       ],
                    //     ),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         buildKpiChart(ctr.paginatedKpiData),
                    //         buildPaginationButtons(
                    //           currentPage: ctr.kpiPage.value,
                    //           maxPage: ctr.maxKpiPage,
                    //           onBack: () => ctr.kpiPage.value--,
                    //           onForward: () => ctr.kpiPage.value++,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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
