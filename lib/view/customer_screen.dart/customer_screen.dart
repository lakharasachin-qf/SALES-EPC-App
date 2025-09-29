import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/controller/customer_controller/customer_controller.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/view/customer_screen.dart/view_customer_screen.dart';
import 'package:sizer/sizer.dart';

class Customerscreen extends StatefulWidget {
  const Customerscreen({super.key});

  @override
  State<Customerscreen> createState() => CustomerScreenState();
}

class CustomerScreenState extends State<Customerscreen> {
  final CustomerScreenController ctr = Get.put(CustomerScreenController());

  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    futureDelay(() {
      ctr.getCustomerbyID(context, 1, false, isFirstTime: true);
    }, isOneSecond: true);
  }

  final Map<String, double> columnWidths = {
    "Sr No.": 7.w,
    "Company Name": 20.w,
    "Contact Person": 20.w,
    "Mobile": 20.w,
    "Status": 20.w,
    "Live Data": 20.w,
    "Warranty Type": 20.w,
    "Expiry": 20.w,
    "Action": 20.w,
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
            "Customer List",
            onClick: () {
              Get.back();
            },
            isFilter: true,
            onFilterClick: () {
              ctr.openFilterBottomSheet(context: context);
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
                  ctr.getCustomerbyID(context, 1, false, isFirstTime: true);
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
                                                  ctr.customerList.isEmpty
                                              ? SizedBox(
                                                  width: MediaQuery.of(
                                                    context,
                                                  ).size.width,
                                                  child: Center(
                                                    child: Text(
                                                      'No customers found',
                                                      style: TextStyle(
                                                        fontSize: 16,
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
                                                  columns: ctr.customerHeaders
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
                                                  rows: ctr.customerData.asMap().entries.map((
                                                    entry,
                                                  ) {
                                                    final row = entry
                                                        .value; // row data (list of cell values)
                                                    return DataRow(
                                                      cells: row.asMap().entries.map((
                                                        cell,
                                                      ) {
                                                        final columnName =
                                                            ctr.customerHeaders[cell
                                                                .key];

                                                        if (columnName ==
                                                            "Action") {
                                                          // Custom UI for Action column
                                                          return DataCell(
                                                            Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 4.h,
                                                                    height: 4.h,
                                                                    child: IconButton(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      icon: const Icon(
                                                                        Icons
                                                                            .visibility,
                                                                        color:
                                                                            primaryColor,
                                                                      ),
                                                                      onPressed: () {
                                                                        // 👁 View action
                                                                        // ctr.viewCustomer(
                                                                        //   context,
                                                                        //   rowIndex,
                                                                        // );
                                                                        Get.to(
                                                                          ViewCustomerScreen(),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  getDynamicSizedBox(
                                                                    width: 1.w,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 4.h,
                                                                    height: 4.h,
                                                                    child: IconButton(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      icon: const Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color:
                                                                            primaryColor,
                                                                      ),
                                                                      onPressed: () {
                                                                        ctr.updateCustomer(
                                                                          context,
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  getDynamicSizedBox(
                                                                    width: 1.w,
                                                                  ),
                                                                  // SizedBox(
                                                                  //   width: 1.w,
                                                                  // ),
                                                                  // SizedBox(
                                                                  //   width: 4.h,
                                                                  //   height: 4.h,
                                                                  //   child: IconButton(
                                                                  //     padding:
                                                                  //         EdgeInsets
                                                                  //             .zero,
                                                                  //     icon: const Icon(
                                                                  //       Icons
                                                                  //           .delete,
                                                                  //       color: Colors
                                                                  //           .red,
                                                                  //     ),
                                                                  //     onPressed: () {
                                                                  //       // 🗑 Delete action
                                                                  //       // ctr.deleteCustomer(
                                                                  //       //   rowIndex,
                                                                  //       // );
                                                                  //     },
                                                                  //   ),
                                                                  // ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }

                                                        // Default case → render normal text cell
                                                        return DataCell(
                                                          SizedBox(
                                                            width:
                                                                columnWidths[columnName] ??
                                                                16.w,
                                                            child: Text(
                                                              cell.value,
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

                                                  // rows: ctr.customerData.asMap().entries.map((
                                                  //   entry,
                                                  // ) {
                                                  //   final row = entry.value;
                                                  //   return DataRow(
                                                  //     cells: row.asMap().entries.map((
                                                  //       cell,
                                                  //     ) {
                                                  //       return DataCell(
                                                  //         SizedBox(
                                                  //           width:
                                                  //               columnWidths[ctr
                                                  //                   .customerHeaders[cell
                                                  //                   .key]] ??
                                                  //               16.w,
                                                  //           child: Text(
                                                  //             cell.value,
                                                  //             style: TextStyle(
                                                  //               fontSize: 14.sp,
                                                  //             ),
                                                  //             textAlign:
                                                  //                 TextAlign
                                                  //                     .center,
                                                  //             overflow:
                                                  //                 TextOverflow
                                                  //                     .ellipsis,
                                                  //             maxLines: 2,
                                                  //           ),
                                                  //         ),
                                                  //       );
                                                  //     }).toList(),
                                                  //   );
                                                  // }).toList(),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Loader
                                  if (ctr.state.value == ScreenState.apiLoading)
                                    screnLoader(tableHeight),
                                  // Container(
                                  //   height: tableHeight,
                                  //   width: double.infinity,
                                  //   color: transparent,
                                  //   child: Center(
                                  //     child: CircularProgressIndicator(
                                  //       strokeWidth: 6,
                                  //       valueColor: AlwaysStoppedAnimation(
                                  //         primaryColor,
                                  //       ),
                                  //       backgroundColor: Colors.grey.shade200,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                      getDynamicSizedBox(height: 1.5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Obx(() {
                          if (ctr.totalItems.value == 0) {
                            return const Text(
                              "0–0 of 0",
                              style: TextStyle(fontSize: 14, color: black),
                            );
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${ctr.fromItem.value}–${ctr.toItem.value} of ${ctr.totalItems.value}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: ctr.currentPage.value > 1
                                          ? () {
                                              ctr.getCustomerbyID(
                                                context,
                                                ctr.currentPage.value - 1,
                                                false,
                                                isFirstTime: true,
                                              );
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.chevron_left,
                                        color: ctr.currentPage.value > 1
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                      ),
                                      splashRadius: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Page ${ctr.currentPage.value} of ${ctr.lastPage.value}",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    IconButton(
                                      onPressed:
                                          ctr.currentPage.value <
                                              ctr.lastPage.value
                                          ? () {
                                              ctr.getCustomerbyID(
                                                context,
                                                ctr.currentPage.value + 1,
                                                false,
                                                isFirstTime: true,
                                              );
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.chevron_right,
                                        color:
                                            ctr.currentPage.value <
                                                ctr.lastPage.value
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                      ),
                                      splashRadius: 20,
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
