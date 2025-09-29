import 'package:flutter/material.dart';
import 'package:sales_app/configs/colors_constant.dart';
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

Widget buildChart({required List<BilledUnit> data}) {
  if (data.isEmpty) {
    return SizedBox(
      height: 30.h,
      child: Center(
        child: Text(
          'No SGF data available',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
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
