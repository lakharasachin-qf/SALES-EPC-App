import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/controller/dashboard_controller/dashboard_controller.dart';
import 'package:sales_app/models/dashboard1_model.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' show max;

Widget buildCircularChart({required LeadsStatusDistribution? data}) {
  if (data == null ||
      (data.newLead == 0 &&
          data.contacted == 0 &&
          data.proposalSent == 0 &&
          data.qualified == 0 &&
          data.won == 0 &&
          data.rejected == 0)) {
    return SizedBox(
      height: 35.h,
      child: Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16.sp, color: grey),
        ),
      ),
    );
  }

  // Prepare data for the pie chart
  final List<Map<String, dynamic>> chartData = [
    {
      'status': 'New Lead',
      'percent': data.newLead,
      'color': Colors.lightBlueAccent,
    },
    {'status': 'Contacted', 'percent': data.contacted, 'color': Colors.orange},
    {
      'status': 'Proposal Sent',
      'percent': data.proposalSent,
      'color': Colors.amber,
    },
    {'status': 'Qualified', 'percent': data.qualified, 'color': Colors.green},
    {'status': 'Won', 'percent': data.won, 'color': Colors.blue},
    {'status': 'Rejected', 'percent': data.rejected, 'color': Colors.red},
  ].where((item) => ((item['percent'] as num?) ?? 0) > 0).toList();

  if (chartData.isEmpty) {
    return SizedBox(
      height: 35.h,
      child: Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16.sp, color: grey),
        ),
      ),
    );
  }

  return SizedBox(
    height: 35.h,
    width: double.infinity,
    child: Center(
      child: SfCircularChart(
        title: ChartTitle(
          text: 'Leads by Status',
          alignment: ChartAlignment.center,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.5.sp,
            fontFamily: plusJakartaSansMedium,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.right,
          overflowMode: LegendItemOverflowMode.wrap,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            fontFamily: plusJakartaSansMedium,
          ),
          iconHeight: 1.5.h,
          iconWidth: 1.5.h,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CircularSeries>[
          PieSeries<Map<String, dynamic>, String>(
            dataSource: chartData,
            xValueMapper: (Map<String, dynamic> lead, _) => lead['status'],
            yValueMapper: (Map<String, dynamic> lead, _) =>
                lead['percent'].toDouble(),
            pointColorMapper: (Map<String, dynamic> lead, _) =>
                lead['color'] as Color,
            dataLabelMapper: (Map<String, dynamic> lead, _) =>
                "${lead['percent']}%",
            radius: '85%',
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                fontFamily: plusJakartaSansMedium,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildLeadByClusterChart({required LeadsByClusterBreakdown? data}) {
  if (data == null ||
      data.labels == null ||
      data.datasets == null ||
      data.labels!.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No Lead By Cluster available',
          style: TextStyle(fontSize: 14.sp, color: grey),
        ),
      ),
    );
  }

  // Prepare data for the chart
  final List<Map<String, dynamic>> chartData = List.generate(
    data.labels!.length,
    (index) {
      return {
        'clusterName': data.labels![index],
        'leads': data.datasets!.leads![index],
        'won': data.datasets!.won![index],
        'lost': data.datasets!.lost![index],
        'ongoing': data.datasets!.ongoing![index],
      };
    },
  );

  return Center(
    child: SizedBox(
      height: 30.h,
      width: double.infinity,
      child: Center(
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Leads By Clusters',
            alignment: ChartAlignment.center,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              fontFamily: plusJakartaSansMedium,
            ),
          ),
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            overflowMode: LegendItemOverflowMode.wrap,
          ),
          primaryXAxis: CategoryAxis(
            title: AxisTitle(text: 'Clusters'),
            labelPlacement: LabelPlacement.betweenTicks,
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: const MajorGridLines(width: 0),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              fontFamily: plusJakartaSansMedium,
            ),
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            interval: 2,
            labelStyle: TextStyle(
              color: black,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              fontFamily: plusJakartaSansMedium,
            ),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            ColumnSeries<Map<String, dynamic>, String>(
              dataSource: chartData,
              xValueMapper: (Map<String, dynamic> c, _) => c['clusterName'],
              yValueMapper: (Map<String, dynamic> c, _) =>
                  c['leads'].toDouble(),
              name: 'Leads',
              color: Colors.lightBlue,
              spacing: 0.1,
              borderRadius: BorderRadius.circular(3),
              emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ColumnSeries<Map<String, dynamic>, String>(
              dataSource: chartData,
              xValueMapper: (Map<String, dynamic> c, _) => c['clusterName'],
              yValueMapper: (Map<String, dynamic> c, _) => c['won'].toDouble(),
              name: 'Won',
              color: Colors.green,
              spacing: 0.1,
              borderRadius: BorderRadius.circular(3),
              emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ColumnSeries<Map<String, dynamic>, String>(
              dataSource: chartData,
              xValueMapper: (Map<String, dynamic> c, _) => c['clusterName'],
              yValueMapper: (Map<String, dynamic> c, _) => c['lost'].toDouble(),
              name: 'Lost',
              color: Colors.red,
              spacing: 0.1,
              borderRadius: BorderRadius.circular(3),
              emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ColumnSeries<Map<String, dynamic>, String>(
              dataSource: chartData,
              xValueMapper: (Map<String, dynamic> c, _) => c['clusterName'],
              yValueMapper: (Map<String, dynamic> c, _) =>
                  c['ongoing'].toDouble(),
              name: 'Ongoing',
              color: Colors.orange,
              spacing: 0.1,
              borderRadius: BorderRadius.circular(3),
              emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildLeadsWonOverTimeChart({required LeadsWonProgressOverTime? data}) {
  if (data == null ||
      data.labels == null ||
      data.weeklyChanges == null ||
      data.labels!.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 14.sp, color: grey),
        ),
      ),
    );
  }

  // Prepare data for the chart
  final List<Map<String, dynamic>> chartData = List.generate(
    data.labels!.length,
    (index) {
      return {
        'clusterName': data.labels![index],
        'won': data.weeklyChanges![index],
      };
    },
  );

  return Center(
    child: SizedBox(
      height: 30.h,
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Leads Won Over Time',
          alignment: ChartAlignment.center,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            fontFamily: plusJakartaSansMedium,
          ),
        ),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: ''),
          labelPlacement: LabelPlacement.betweenTicks,
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum:
              (chartData.map((e) => e['won']).reduce((a, b) => a > b ? a : b) +
                      3)
                  .toDouble(),
          interval: 2,
          axisLine: const AxisLine(width: 1),
          majorGridLines: const MajorGridLines(width: 0.5),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: chartData,
            xValueMapper: (Map<String, dynamic> c, _) => c['clusterName'],
            yValueMapper: (Map<String, dynamic> c, _) => c['won'].toDouble(),
            name: 'Won',
            color: Colors.green,
            spacing: 0.3,
            borderRadius: BorderRadius.circular(4),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildRevenueTargetsChart({
  required DashboardController ctr,
  required RevenueVsTargetsComparison? data,
}) {
  if (data == null ||
      data.labels == null ||
      data.revenue == null ||
      data.labels!.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No Revenue Targets available',
          style: TextStyle(fontSize: 14.sp, color: grey),
        ),
      ),
    );
  }

  // Prepare data for the chart
  final List<Map<String, dynamic>> chartData = List.generate(
    data.labels!.length,
    (index) {
      return {
        'clusterName': data.labels![index],
        'target': data.revenue!.target![index],
        'achieved': data.revenue!.achieved![index],
      };
    },
  );

  return Stack(
    children: [
      Center(
        child: SizedBox(
          height: 30.h,
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Revenue Targets',
              alignment: ChartAlignment.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                fontFamily: plusJakartaSansMedium,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              majorTickLines: const MajorTickLines(size: 0),
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum:
                  (chartData
                              .map(
                                (e) =>
                                    (e['target'] > e['achieved']
                                            ? e['target']
                                            : e['achieved'])
                                        .toDouble(),
                              )
                              .reduce((a, b) => a > b ? a : b) *
                          1.2)
                      .toDouble(),
              numberFormat: NumberFormat.decimalPattern('en_IN'),
              axisLine: const AxisLine(width: 1),
              majorGridLines: const MajorGridLines(width: 0.5),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: chartData,
                xValueMapper: (Map<String, dynamic> r, _) => r['clusterName'],
                yValueMapper: (Map<String, dynamic> r, _) =>
                    r['target'].toDouble(),
                name: 'Target',
                color: Colors.lightBlue,
                spacing: 0.2,
                borderRadius: BorderRadius.circular(4),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: chartData,
                xValueMapper: (Map<String, dynamic> r, _) => r['clusterName'],
                yValueMapper: (Map<String, dynamic> r, _) =>
                    r['achieved'].toDouble(),
                name: 'Achieved',
                color: Colors.green,
                spacing: 0.2,
                borderRadius: BorderRadius.circular(4),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 1.h,
        right: -1.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          alignment: Alignment.centerRight,
          child: Obx(() {
            return getSvgDropdownButton(
              svgAssetPath: Asset.menufilter,
              items: ctr.selectedTargetList,
              selectedValue: ctr.selectedTarget.value,
              onChanged: (value) {
                ctr.selectedTarget.value = value!;

                if (ctr.selectedTarget.value == 'Revenue Targets') {
                  ctr.isRevenueVisible.value = true;
                } else {
                  ctr.isRevenueVisible.value = false;
                }
              },
            );
          }),
        ),
      ),
    ],
  );
}

Widget buildCustomerTargetsChart({
  required DashboardController ctr,
  required RevenueVsTargetsComparison? data,
}) {
  if (data == null ||
      data.labels == null ||
      data.customer == null ||
      data.labels!.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No Customer Targets available',
          style: TextStyle(fontSize: 14.sp, color: grey),
        ),
      ),
    );
  }

  // Prepare data for the chart
  final List<Map<String, dynamic>> chartData = List.generate(
    data.labels!.length,
    (index) {
      return {
        'clusterName': data.labels![index],
        'target': data.customer!.target![index],
        'achieved': data.customer!.achieved![index],
      };
    },
  );

  return Stack(
    children: [
      Center(
        child: SizedBox(
          height: 30.h,
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Customer Targets',
              alignment: ChartAlignment.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                fontFamily: plusJakartaSansMedium,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.betweenTicks,
              majorTickLines: const MajorTickLines(size: 0),
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum:
                  (chartData
                              .map(
                                (e) =>
                                    (e['target'] > e['achieved']
                                            ? e['target']
                                            : e['achieved'])
                                        .toDouble(),
                              )
                              .reduce((a, b) => a > b ? a : b) *
                          1.2)
                      .toDouble(),
              numberFormat: NumberFormat.decimalPattern('en_IN'),
              axisLine: const AxisLine(width: 1),
              majorGridLines: const MajorGridLines(width: 0.5),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: chartData,
                xValueMapper: (Map<String, dynamic> r, _) => r['clusterName'],
                yValueMapper: (Map<String, dynamic> r, _) =>
                    r['target'].toDouble(),
                name: 'Target',
                color: Colors.lightBlue,
                spacing: 0.2,
                borderRadius: BorderRadius.circular(4),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: chartData,
                xValueMapper: (Map<String, dynamic> r, _) => r['clusterName'],
                yValueMapper: (Map<String, dynamic> r, _) =>
                    r['achieved'].toDouble(),
                name: 'Achieved',
                color: Colors.green,
                spacing: 0.2,
                borderRadius: BorderRadius.circular(4),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 1.h,
        right: -1.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          alignment: Alignment.centerRight,
          child: Obx(() {
            return getSvgDropdownButton(
              svgAssetPath: Asset.menufilter,
              items: ctr.selectedTargetList,
              selectedValue: ctr.selectedTarget.value,
              onChanged: (value) {
                ctr.selectedTarget.value = value!;

                if (ctr.selectedTarget.value == 'Revenue Targets') {
                  ctr.isRevenueVisible.value = true;
                } else {
                  ctr.isRevenueVisible.value = false;
                }
              },
            );
          }),
        ),
      ),
    ],
  );
}
