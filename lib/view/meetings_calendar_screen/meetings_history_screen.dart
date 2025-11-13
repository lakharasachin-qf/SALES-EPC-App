import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/controller/meetings_calendar_controller/meetings_history_controller.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';

class MeetingsHistoryScreen extends StatefulWidget {
  final String meetingId;
  const MeetingsHistoryScreen({super.key, required this.meetingId});

  @override
  State<MeetingsHistoryScreen> createState() => CustomerScreenState();
}

class CustomerScreenState extends State<MeetingsHistoryScreen> {
  final MeetingsHistoryController ctr = Get.put(MeetingsHistoryController());

  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    logcat('widget.meetingId', widget.meetingId);
    // Initialize with static data if provided, else fetch from API
    futureDelay(() {
      ctr.getMeetingHistory(
        context: context,
        isInitialLoad: true,
        page: 1,
        hideLoading: false,
        meetingId: widget.meetingId,
      );
    }, milliseconds: false);
  }

  final Map<String, double> columnWidths = {
    "Sr No.": 7.w,
    "Contacted": 20.w,
    "Status": 20.w,
    "From": 20.w,
    "To": 20.w,
    "Reason": 20.w,
    "Action By": 20.w,
  };

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
            "Meeting History",
            onClick: () {
              Get.back();
            },
            context: context,
          ),
          getDynamicSizedBox(height: 2.h),
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
                  ctr.currentPage.value = 1;
                  ctr.getMeetingHistory(
                    context: context,
                    isInitialLoad: true,
                    page: 1,
                    hideLoading: false,
                    meetingId: widget.meetingId,
                  );
                }, isOneSecond: false);
                _refreshController.refreshCompleted();
              },
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getDynamicSizedBox(height: 1.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Obx(() {
                            double tableHeight = 60.h;
                            return SizedBox(
                              height: tableHeight,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: tableHeight,
                                        ),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            dataTableTheme: DataTableThemeData(
                                              headingRowHeight: 7.h,
                                              dataRowMinHeight: 5.h,
                                              dataRowMaxHeight: 5.h,
                                            ),
                                          ),
                                          child:
                                              ctr.state.value ==
                                                      ScreenState.apiSuccess &&
                                                  ctr.meetingsList.isEmpty
                                              ? SizedBox(
                                                  width: MediaQuery.of(
                                                    context,
                                                  ).size.width,
                                                  child: Center(
                                                    child: Text(
                                                      'No Meeting History found',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : DataTable(
                                                  columnSpacing: 1.w,
                                                  headingRowColor:
                                                      WidgetStateColor.resolveWith(
                                                        (states) =>
                                                            primaryColor,
                                                      ),
                                                  headingTextStyle: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.sp,
                                                    color: white,
                                                  ),
                                                  dataTextStyle: TextStyle(
                                                    fontSize: 12.sp,
                                                  ),
                                                  columns: ctr.headers
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                        return DataColumn(
                                                          label: SizedBox(
                                                            width:
                                                                columnWidths[entry
                                                                    .value] ??
                                                                16.w,
                                                            child: Text(
                                                              entry.value,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16.sp,
                                                                color: white,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                      .toList(),
                                                  rows: ctr.meetingsHistoryData.asMap().entries.map((
                                                    entry,
                                                  ) {
                                                    final row = entry.value;
                                                    return DataRow(
                                                      cells: row.asMap().entries.map((
                                                        cell,
                                                      ) {
                                                        return DataCell(
                                                          SizedBox(
                                                            width:
                                                                columnWidths[ctr
                                                                    .headers[cell
                                                                    .key]] ??
                                                                16.w,
                                                            child: Text(
                                                              cell.value ?? '-',
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    );
                                                  }).toList(),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (ctr.state.value == ScreenState.apiLoading)
                                    screnLoader(tableHeight),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      getDynamicSizedBox(height: 1.5.h),
                      Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 0.w),
                        child: Obx(() {
                          return Container(
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.list_alt_rounded,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Showing ${ctr.fromItem.value}–${ctr.toItem.value}",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "of ${ctr.totalItems.value}",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: ctr.currentPage.value > 1
                                          ? () => ctr.getMeetingHistory(
                                              context: context,
                                              page: ctr.currentPage.value - 1,
                                              isInitialLoad: true,
                                              hideLoading: false,
                                              meetingId: widget.meetingId,
                                            )
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ctr.currentPage.value > 1
                                            ? primaryColor
                                            : Colors.grey.shade300,
                                        minimumSize: const Size(36, 36),
                                        shape: const CircleBorder(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                      ),
                                      child: Text(
                                        "Page ${ctr.currentPage.value}/${ctr.lastPage.value}",
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          ctr.currentPage.value <
                                              ctr.lastPage.value
                                          ? () => ctr.getMeetingHistory(
                                              context: context,
                                              page: ctr.currentPage.value + 1,
                                              isInitialLoad: false,
                                              hideLoading: false,
                                              meetingId: widget.meetingId,
                                            )
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ctr.currentPage.value <
                                                ctr.lastPage.value
                                            ? primaryColor
                                            : Colors.grey.shade300,
                                        minimumSize: const Size(36, 36),
                                        shape: const CircleBorder(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      getDynamicSizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
