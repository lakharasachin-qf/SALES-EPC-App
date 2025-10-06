import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/models/ClusterData.dart';
import 'package:sales_app/models/LeadData.dart';
import 'package:sales_app/models/dashboard1_model.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' show max;

Widget buildPaginationButtons({
  required int currentPage,
  required int maxPage,
  required VoidCallback onBack,
  required VoidCallback onForward,
}) {
  return Align(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left_sharp),
          onPressed: currentPage > 0 ? onBack : null,
        ),
        Text(
          'Page ${currentPage + 1} of $maxPage',
          style: TextStyle(fontSize: 14.sp),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right_sharp),
          onPressed: currentPage < maxPage - 1 ? onForward : null,
        ),
      ],
    ),
  );
}

Widget buildCircularChart({required List<LeadData> data}) {
  if (data.isEmpty) {
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
          PieSeries<LeadData, String>(
            dataSource: data,
            xValueMapper: (LeadData lead, _) => lead.status,
            yValueMapper: (LeadData lead, _) => lead.percent,
            pointColorMapper: (LeadData lead, _) => lead.color,
            dataLabelMapper: (LeadData lead, _) => "${lead.percent}%",
            radius: '85%', // makes chart bigger
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

Widget buildLeadByClusterChart({required List<ClusterData> data}) {
  if (data.isEmpty) {
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

  return Center(
    child: SizedBox(
      height: 30.h,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: Device.width,
          // width: max(data.length * 50, 300).toDouble(),
          child: SfCartesianChart(
            // enableSideBySideSeriesPlacement: true,
            title: ChartTitle(
              text: 'Leads By Clusters',
              alignment: ChartAlignment.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFamily: plusJakartaSansMedium,
              ),
            ),
            // tooltipBehavior: TooltipBehavior(
            //   enable: true,
            //   builder:
            //       (
            //         dynamic data,
            //         dynamic point,
            //         dynamic series,
            //         int pointIndex,
            //         int seriesIndex,
            //       ) {
            //         return _buildTooltipContent(
            //           label: data.customerShortName,
            //           actual: data.actual,
            //           target: data.target,
            //         );
            //       },
            // ),
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
              // title: AxisTitle(text: 'Count'),
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
              ColumnSeries<ClusterData, String>(
                dataSource: data,
                xValueMapper: (ClusterData c, _) => c.clusterName,
                yValueMapper: (ClusterData c, _) => c.leads,
                name: 'Leads',
                color: Colors.lightBlue,
                spacing: 0.1,
                borderRadius: BorderRadius.circular(3),
                emptyPointSettings: EmptyPointSettings(
                  mode: EmptyPointMode.zero,
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  // labelAlignment: ChartDataLabelAlignment.top,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ColumnSeries<ClusterData, String>(
                dataSource: data,
                xValueMapper: (ClusterData c, _) => c.clusterName,
                yValueMapper: (ClusterData c, _) => c.won,
                name: 'Won',
                color: Colors.green,
                spacing: 0.1,
                borderRadius: BorderRadius.circular(3),
                emptyPointSettings: EmptyPointSettings(
                  mode: EmptyPointMode.zero,
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  // labelAlignment: ChartDataLabelAlignment.top,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ColumnSeries<ClusterData, String>(
                dataSource: data,
                xValueMapper: (ClusterData c, _) => c.clusterName,
                yValueMapper: (ClusterData c, _) => c.lost,
                name: 'Lost',
                color: Colors.red,
                spacing: 0.1,
                borderRadius: BorderRadius.circular(3),
                emptyPointSettings: EmptyPointSettings(
                  mode: EmptyPointMode.zero,
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  // labelAlignment: ChartDataLabelAlignment.top,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ColumnSeries<ClusterData, String>(
                dataSource: data,
                xValueMapper: (ClusterData c, _) => c.clusterName,
                yValueMapper: (ClusterData c, _) => c.ongoing,
                name: 'Ongoing',
                color: Colors.orange,
                spacing: 0.1,
                borderRadius: BorderRadius.circular(3),
                emptyPointSettings: EmptyPointSettings(
                  mode: EmptyPointMode.zero,
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  // labelAlignment: ChartDataLabelAlignment.top,
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
    ),
  );
}

Widget buildLeadsWonOverTimeChart({required List<LeadsWonData> data}) {
  if (data.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      ),
    );
  }

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
          maximum: (data.map((e) => e.won).reduce((a, b) => a > b ? a : b) + 3)
              .toDouble(),
          interval: 2,
          axisLine: const AxisLine(width: 1),
          majorGridLines: const MajorGridLines(width: 0.5),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<LeadsWonData, String>(
            dataSource: data,
            xValueMapper: (LeadsWonData c, _) => c.clusterName,
            yValueMapper: (LeadsWonData c, _) => c.won,
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

Widget buildRevenueTargetsChart({required List<RevenueData> data}) {
  if (data.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No Revenue Targets available',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      ),
    );
  }

  return Center(
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
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum:
              (data
                          .map(
                            (e) =>
                                e.target > e.achieved ? e.target : e.achieved,
                          )
                          .reduce((a, b) => a > b ? a : b) *
                      1.2)
                  .toDouble(), // add headroom
          numberFormat: NumberFormat.decimalPattern('en_IN'),
          axisLine: const AxisLine(width: 1),
          majorGridLines: const MajorGridLines(width: 0.5),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<RevenueData, String>(
            dataSource: data,
            xValueMapper: (RevenueData r, _) => r.clusterName,
            yValueMapper: (RevenueData r, _) => r.target,
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
          ColumnSeries<RevenueData, String>(
            dataSource: data,
            xValueMapper: (RevenueData r, _) => r.clusterName,
            yValueMapper: (RevenueData r, _) => r.achieved,
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
  );
}

Widget buildChart({required List<BilledUnit> data}) {
  if (data.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No SGF data available',
          style: TextStyle(fontSize: 16.sp, color: grey),
        ),
      ),
    );
  }

  return SizedBox(
    height: 30.h,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: max(data.length * 50, 300).toDouble(),
        child: SfCartesianChart(
          title: ChartTitle(text: 'SGF → Actual Vs Target'),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder:
                (
                  dynamic data,
                  dynamic point,
                  dynamic series,
                  int pointIndex,
                  int seriesIndex,
                ) {
                  return _buildTooltipContent(
                    label: data.customerShortName,
                    actual: data.actual,
                    target: data.target,
                  );
                },
          ),
          legend: const Legend(isVisible: true),
          primaryXAxis: CategoryAxis(
            labelPlacement: LabelPlacement.betweenTicks,
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
            labelRotation: 45,
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: const MajorGridLines(width: 0),
            labelStyle: const TextStyle(fontSize: 10),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'SGF'),
            minimum: 0,
            maximum: 13,
            interval: 1,
            labelStyle: const TextStyle(fontSize: 10),
          ),
          series: <CartesianSeries>[
            LineSeries<BilledUnit, String>(
              name: 'Target',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.target.toDouble(),
              color: Colors.orange,
              markerSettings: const MarkerSettings(isVisible: true),
              enableTooltip: true,
            ),
            ColumnSeries<BilledUnit, String>(
              name: 'Actual',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.actual,
              color: primaryColor,
              spacing: 0.2,
              enableTooltip: true,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildRevenueChart(List<BilledUnit> data) {
  if (data.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No revenue data available',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      ),
    );
  }

  // Calculate max actual value
  final maxActual = data.map((e) => e.actual).reduce((a, b) => a > b ? a : b);
  final yAxisMax = (maxActual * 2).ceilToDouble();

  return SizedBox(
    height: 30.h,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: max(data.length * 50, 300).toDouble(),
        child: SfCartesianChart(
          title: ChartTitle(text: 'Revenue → Actual Vs Target'),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder:
                (
                  dynamic data,
                  dynamic point,
                  dynamic series,
                  int pointIndex,
                  int seriesIndex,
                ) {
                  return _buildTooltipContent(
                    label: data.customerShortName,
                    actual: data.actual,
                    target: data.target,
                  );
                },
          ),
          legend: const Legend(isVisible: true),
          primaryXAxis: CategoryAxis(
            labelPlacement: LabelPlacement.betweenTicks,
            labelRotation: 45,
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: const MajorGridLines(width: 0),
            labelStyle: const TextStyle(fontSize: 10),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Amount'),
            minimum: 0,
            maximum: yAxisMax,
            interval: yAxisMax / 10,
            labelStyle: const TextStyle(fontSize: 10),
          ),
          series: <CartesianSeries>[
            ColumnSeries<BilledUnit, String>(
              name: 'Target',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.target.toDouble(),
              color: Colors.orange,
              enableTooltip: true,
            ),
            ColumnSeries<BilledUnit, String>(
              name: 'Actual',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.actual,
              color: primaryColor,
              enableTooltip: true,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                builder: (dynamic d, _, __, ___, ____) {
                  final percentage = d.target == 0
                      ? 0
                      : (d.actual / d.target * 100);
                  return Transform.translate(
                    offset: const Offset(0, -6),
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Text(
                        '${percentage.ceil()}%',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildUnitChart(List<BilledUnit> data) {
  if (data.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No billed units data available',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      ),
    );
  }

  // Calculate max actual value
  final maxActual = data.map((e) => e.actual).reduce((a, b) => a > b ? a : b);
  final yAxisMax = (maxActual * 2).ceilToDouble();

  return SizedBox(
    height: 30.h,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: max(data.length * 50, 300).toDouble(),
        child: SfCartesianChart(
          title: ChartTitle(text: 'Billed Units → Actual Vs Target'),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder:
                (
                  dynamic data,
                  dynamic point,
                  dynamic series,
                  int pointIndex,
                  int seriesIndex,
                ) {
                  return _buildTooltipContent(
                    label: data.customerShortName,
                    actual: data.actual,
                    target: data.target,
                  );
                },
          ),
          legend: const Legend(isVisible: true),
          primaryXAxis: CategoryAxis(
            labelPlacement: LabelPlacement.betweenTicks,
            labelRotation: 45,
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: const MajorGridLines(width: 0),
            labelStyle: const TextStyle(fontSize: 10),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Units'),
            minimum: 0,
            maximum: yAxisMax,
            interval: yAxisMax / 10,
            labelStyle: const TextStyle(fontSize: 10),
          ),
          series: <CartesianSeries>[
            ColumnSeries<BilledUnit, String>(
              name: 'Target',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.target.toDouble(),
              color: Colors.orange,
              enableTooltip: true,
            ),
            ColumnSeries<BilledUnit, String>(
              name: 'Actual',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.actual,
              color: primaryColor,
              enableTooltip: true,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                builder: (dynamic d, _, __, ___, ____) {
                  final percentage = d.target == 0
                      ? 0
                      : (d.actual / d.target * 100);
                  return Transform.translate(
                    offset: const Offset(0, -6),
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Text(
                        '${percentage.ceil()}%',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildKpiChart(List<BilledUnit> data) {
  if (data.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No KPI data available',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      ),
    );
  }

  // Calculate max actual value
  final maxActual = data.map((e) => e.actual).reduce((a, b) => a > b ? a : b);
  final yAxisMax = (maxActual * 2).ceilToDouble();

  return SizedBox(
    height: 30.h,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: max(data.length * 50, 300).toDouble(),
        child: SfCartesianChart(
          title: ChartTitle(text: 'KPI (Revenue/MW) → Actual Vs Target'),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder:
                (
                  dynamic data,
                  dynamic point,
                  dynamic series,
                  int pointIndex,
                  int seriesIndex,
                ) {
                  return _buildTooltipContent(
                    label: data.customerShortName,
                    actual: data.actual,
                    target: data.target,
                  );
                },
          ),
          legend: const Legend(isVisible: true),
          primaryXAxis: CategoryAxis(
            labelPlacement: LabelPlacement.betweenTicks,
            labelRotation: 45,
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: const MajorGridLines(width: 0),
            labelStyle: const TextStyle(fontSize: 10),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Revenue/MW'),
            minimum: 0,
            maximum: yAxisMax,
            interval: yAxisMax / 10,
            labelStyle: const TextStyle(fontSize: 10),
          ),
          series: <CartesianSeries>[
            ColumnSeries<BilledUnit, String>(
              name: 'Target',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.target.toDouble(),
              color: Colors.orange,
              enableTooltip: true,
            ),
            ColumnSeries<BilledUnit, String>(
              name: 'Actual',
              dataSource: data,
              xValueMapper: (d, _) => d.customerShortName,
              yValueMapper: (d, _) => d.actual,
              color: primaryColor,
              enableTooltip: true,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                builder: (dynamic d, _, __, ___, ____) {
                  final percentage = d.target == 0
                      ? 0
                      : (d.actual / d.target * 100);
                  return Transform.translate(
                    offset: const Offset(0, -6),
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Text(
                        '${percentage.ceil()}%',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTooltipContent({
  required String label,
  required num actual,
  required num target,
}) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      'Label: $label\nTarget: $target\nActual: $actual',
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );
}
