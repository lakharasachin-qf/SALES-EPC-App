import 'package:flutter/material.dart';
import 'package:sales_app/componant/CustomSnakbar.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

// Define date format for yyyy-MM-dd HH:mm
final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
final dateFormat = DateFormat('yyyy-MM-dd');

typedef OnDatePicked = void Function(DateTime pickedDate);

Future<void> showCommonDatePicker({
  required BuildContext context,
  required String title,
  DateTime? initialDate,
  DateTime? minDate, // Restrict minimum selectable date
  required OnDatePicked onDatePicked,
  bool showTimePickers = false,
  bool disablePastDates = false,
}) async {
  // Initialize selectedDate to track new selection
  DateTime? selectedDate = initialDate;
  DateTime now = DateTime.now();

  DateTime firstAllowedDate = disablePastDates
      ? DateTime(now.year, now.month, now.day)
      : (minDate ?? DateTime(2000));

  // Determine effective initialDate
  DateTime effectiveInitialDate;

  if (initialDate == null) {
    // No initial date given
    effectiveInitialDate = (minDate != null && minDate.isAfter(now))
        ? minDate
        : now;
  } else {
    // Initial date exists
    if (minDate != null && initialDate.isBefore(minDate)) {
      effectiveInitialDate = minDate;
    } else {
      effectiveInitialDate = initialDate;
    }
  }

  // ✅ Fix: make sure effectiveInitialDate is not before firstAllowedDate
  if (effectiveInitialDate.isBefore(firstAllowedDate)) {
    effectiveInitialDate = firstAllowedDate;
  }

  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: effectiveInitialDate,
    // firstDate: minDate ?? DateTime(2000),
    firstDate: firstAllowedDate,
    lastDate: DateTime(2100),
    locale: const Locale('en', 'GB'),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: white,
            surface: white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontFamily: plusJakartaSansMedium,
              ),
            ),
          ),
        ),
        child: Localizations.override(
          context: context,
          locale: const Locale('en', 'GB'),
          child: child,
        ),
      );
    },
  );

  if (pickedDate != null) {
    selectedDate = pickedDate;

    if (showTimePickers) {
      final TimeOfDay? pickedTime = await showRestrictedTimePicker(
        context: context,
        selectedDate: selectedDate,
        primaryColor: primaryColor,
        white: white,
        black: black,
        lightGrey: lightGrey,
        plusJakartaSansMedium: plusJakartaSansMedium,
        plusJakartaSansBold: plusJakartaSansBold,
      );
      // Show time picker with time from selectedDate or initialDate or 00:00
      // final TimeOfDay? pickedTime = await showTimePicker(
      //   // ignore: use_build_context_synchronously
      //   context: context,
      //   initialTime: TimeOfDay.fromDateTime(selectedDate),
      //   helpText: 'Select Time',
      //   cancelText: 'Cancel',
      //   confirmText: 'OK',
      //   builder: (BuildContext context, Widget? child) {
      //     return Theme(
      //       data: Theme.of(context).copyWith(
      //         colorScheme: ColorScheme.light(
      //           primary: primaryColor,
      //           onPrimary: white,
      //           surface: white,
      //           onSurface: Colors.black87,
      //         ),
      //         textButtonTheme: TextButtonThemeData(
      //           style: TextButton.styleFrom(
      //             foregroundColor: primaryColor,
      //             textStyle: TextStyle(
      //               fontSize: 16.sp,
      //               fontFamily: plusJakartaSansMedium,
      //             ),
      //           ),
      //         ),
      //         timePickerTheme: TimePickerThemeData(
      //           helpTextStyle: TextStyle(
      //             fontSize: 16.sp,
      //             fontFamily: plusJakartaSansBold,
      //             color: black,
      //           ),
      //           backgroundColor: white,
      //           hourMinuteColor: white,
      //           hourMinuteTextColor: black,
      //           hourMinuteShape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12),
      //             side: BorderSide(color: primaryColor.withValues(alpha:0.3)),
      //           ),
      //           dayPeriodColor: primaryColor.withValues(alpha:0.1),
      //           dayPeriodTextColor: black,
      //           dialHandColor: primaryColor,
      //           dialBackgroundColor: lightGrey.withValues(alpha:0.2),
      //           entryModeIconColor: primaryColor,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(20),
      //           ),
      //         ),
      //       ),
      //       child: child!,
      //     );
      //   },
      // );

      if (pickedTime != null) {
        // Combine date and time
        final combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDatePicked(combinedDateTime);
      }
    } else {
      // Use selected date with time from initialDate or 00:00
      final combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        initialDate?.hour ?? 0,
        initialDate?.minute ?? 0,
      );
      onDatePicked(combinedDateTime);
    }
  }
}

Future<TimeOfDay?> showRestrictedTimePicker({
  required BuildContext context,
  required DateTime selectedDate,
  required Color primaryColor,
  required Color white,
  required Color black,
  required Color lightGrey,
  required String plusJakartaSansMedium,
  required String plusJakartaSansBold,
}) async {
  final now = DateTime.now();
  final isToday =
      selectedDate.year == now.year &&
      selectedDate.month == now.month &&
      selectedDate.day == now.day;

  // Default time: current time if today, else 9:00 AM
  TimeOfDay initialTime = isToday
      ? TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 10)))
      : TimeOfDay(hour: now.hour, minute: now.minute);

  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    // initialTime: initialTime,
    initialTime: initialTime,
    helpText: 'Select Time',
    cancelText: 'Cancel',
    confirmText: 'OK',
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: white,
            surface: white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: TextStyle(
                fontSize: 16,
                fontFamily: plusJakartaSansMedium,
              ),
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            helpTextStyle: TextStyle(
              fontSize: 16,
              fontFamily: plusJakartaSansBold,
              color: black,
            ),
            backgroundColor: white,
            hourMinuteColor: white,
            hourMinuteTextColor: black,
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
            ),
            dayPeriodColor: primaryColor.withValues(alpha: 0.1),
            dayPeriodTextColor: black,
            dialHandColor: primaryColor,
            dialBackgroundColor: lightGrey.withValues(alpha: 0.2),
            entryModeIconColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  // Validate: prevent past time if today
  if (isToday && pickedTime != null) {
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      CustomSnackBar().showErrorSnackbar(
        'Time',
        'Please select a future time.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text(""), duration: Duration(seconds: 2)),
      // );
      // Reopen picker politely
      return await showRestrictedTimePicker(
        context: context,
        selectedDate: selectedDate,
        primaryColor: primaryColor,
        white: white,
        black: black,
        lightGrey: lightGrey,
        plusJakartaSansMedium: plusJakartaSansMedium,
        plusJakartaSansBold: plusJakartaSansBold,
      );
    }
  }

  return pickedTime;
}

Future<void> showCommonDatePickers({
  required BuildContext context,
  required String title,
  DateTime? initialDate,
  DateTime? minDate, // Restrict minimum selectable date
  required OnDatePicked onDatePicked,
  bool showTimePickers = false,
  bool isStartDate = false,
  bool isEndDate = false,
  bool disablePastDates = false,
}) async {
  // Initialize selectedDate to track new selection
  DateTime? selectedDate = initialDate; // Initialize with initialDate

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AlertDialog(
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
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: SfDateRangePicker(
                key: ValueKey(
                  'datePicker_${DateTime.now().millisecondsSinceEpoch}',
                ),
                selectionMode: DateRangePickerSelectionMode.single,
                // Set initialSelectedDate to highlight prefilled date
                initialSelectedDate: initialDate,
                // Use initialDate for display, or current date if null
                initialDisplayDate: initialDate ?? DateTime.now(),
                // Set minimum date if provided (e.g., for end date to be >= start date)
                minDate: disablePastDates ? DateTime.now() : minDate,
                selectableDayPredicate: (DateTime date) {
                  if (isStartDate) {
                    return date.weekday == DateTime.monday;
                  }
                  if (isEndDate) {
                    return date.weekday == DateTime.sunday;
                  }
                  return true;
                },
                onSelectionChanged:
                    (DateRangePickerSelectionChangedArgs args) async {
                      if (args.value is DateTime) {
                        selectedDate = args.value;
                      }
                    },
                showTodayButton: false,
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
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: black, fontFamily: plusJakartaSansMedium),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (selectedDate != null) {
              if (showTimePickers) {
                // Show time picker with time from selectedDate or initialDate or 00:00
                final TimeOfDay? picked = await showTimePicker(
                  context: dialogContext,
                  initialTime: selectedDate != null
                      ? TimeOfDay.fromDateTime(selectedDate!)
                      : initialDate != null
                      ? TimeOfDay.fromDateTime(initialDate)
                      : const TimeOfDay(hour: 0, minute: 0),
                  helpText: 'Select Time',
                  cancelText: 'Cancel',
                  confirmText: 'OK',
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: plusJakartaSansMedium,
                            ),
                          ),
                        ),
                        timePickerTheme: TimePickerThemeData(
                          helpTextStyle: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: plusJakartaSansBold,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.white,
                          hourMinuteColor: white,
                          hourMinuteTextColor: Colors.black,
                          hourMinuteShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          dayPeriodColor: primaryColor.withValues(alpha: 0.1),
                          dayPeriodTextColor: Colors.black,
                          dialHandColor: primaryColor,
                          dialBackgroundColor: lightGrey.withValues(alpha: 0.2),
                          entryModeIconColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  // Combine date and time
                  final combinedDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    picked.hour,
                    picked.minute,
                  );
                  onDatePicked(combinedDateTime);
                  Navigator.of(dialogContext).pop();
                }
              } else {
                // Use selected date with time from initialDate or 00:00
                final combinedDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  initialDate?.hour ?? 0,
                  initialDate?.minute ?? 0,
                );
                onDatePicked(combinedDateTime);
                Navigator.of(dialogContext).pop();
              }
            }
          },
          child: const Text(
            'OK',
            style: TextStyle(color: black, fontFamily: plusJakartaSansMedium),
          ),
        ),
      ],
    ),
  );
}

typedef OnTimePicked = void Function(TimeOfDay pickedTime);

Future<void> showCommonTimePicker({
  required BuildContext context,
  required String title,
  TimeOfDay? initialTime,
  required OnTimePicked onTimePicked,
  VoidCallback? backBtn,
}) async {
  // Show time picker with prefilled initialTime or 00:00 if null
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime ?? const TimeOfDay(hour: 0, minute: 0),
    helpText: title,
    cancelText: 'Cancel',
    confirmText: 'OK',
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontFamily: plusJakartaSansMedium,
              ),
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            helpTextStyle: TextStyle(
              fontSize: 16.sp,
              fontFamily: plusJakartaSansBold,
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            hourMinuteColor: white,
            hourMinuteTextColor: Colors.black,
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
            ),
            dayPeriodColor: primaryColor.withValues(alpha: 0.1),
            dayPeriodTextColor: Colors.black,
            dialHandColor: primaryColor,
            dialBackgroundColor: lightGrey.withValues(alpha: 0.2),
            entryModeIconColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    onTimePicked(picked);
  } else {
    if (backBtn != null) backBtn();
  }
}
