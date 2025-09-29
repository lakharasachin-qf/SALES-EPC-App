import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/controller/customer_controller/customer_controller.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void openCustomerDatePicker(
  BuildContext context, {
  required bool isStart,
  required CustomerScreenController ctr,
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
