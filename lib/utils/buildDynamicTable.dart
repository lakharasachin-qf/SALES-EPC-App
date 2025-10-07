// Common reusable table widget
import 'package:flutter/material.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sizer/sizer.dart';

Widget buildDynamicTable<T>({
  required List<T> data,
  required List<DataColumn> columns,
  required List<String> Function(T) getValues,
  required void Function(int, T)? onEdit,
  required void Function(int)? onDelete,
}) {
  List<DataRow> rows = [];
  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final values = getValues(item);

    rows.add(
      DataRow(
        cells: [
          DataCell(
            Center(
              child: Text(
                (i + 1).toString(),
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: plusJakartaSansBold,
                  fontSize: 15.5.sp,
                ),
              ),
            ),
          ), // Sr. No.
          DataCell(
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 4.h,
                    height: 4.h,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        if (onEdit != null) onEdit(i, item);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 4.h,
                    height: 4.h,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete, color: red),
                      onPressed: () {
                        if (onDelete != null) onDelete(i);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Other dynamic cells
          ...values.map(
            (val) => DataCell(
              Center(
                child: Text(
                  val,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: plusJakartaSansBold,
                    fontSize: 15.5.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  return DataTable(
    dataTextStyle: TextStyle(
      fontFamily: plusJakartaSansBold,
      fontSize: 2.h,
      color: black,
    ),
    columnSpacing: 13,
    horizontalMargin: 13,
    columns: columns,
    headingRowColor: MaterialStateProperty.all(primaryColor),
    headingTextStyle: const TextStyle(
      fontFamily: plusJakartaSansBold,
      color: white,
    ),
    border: TableBorder.all(
      color: grey,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(1.h),
        topRight: Radius.circular(1.h),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    showBottomBorder: true,
    rows: rows,
  );
}
