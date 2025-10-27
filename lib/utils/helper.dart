import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/componant/CustomSnakbar.dart';
import 'package:sales_app/componant/dialogs/customDialog.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart'
    show showDialogForScreen;
import 'package:sales_app/componant/dialogs/fullscreen.dart';
import 'package:sales_app/componant/dialogs/pdfviewer_screen.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/view/signin_screen/signin_screen.dart';

void navigateToDashboardByRights(List<String> rights) {
  Get.to(() => Signinscreen());
}

bool isDarkMode() {
  return false;
}

getUnauthenticatedUser(BuildContext context, String key, String value) {
  if (key == value) {
    Navigator.pop(context);
    // UserPreferences().logout();
    // Get.offAll(const Signinscreen());
    return;
  }
}

Future<DateTime?> getDateTimePicker(context) async {
  DateTime? value = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1950),
    lastDate: DateTime(2100),
  );
  return value;
}

futureDelay(
  Function onPerform, {
  bool? fromSplash = false,
  bool? isOneSecond = false,
  bool? milliseconds = false,
}) async {
  return Future.delayed(
    fromSplash == true
        ? const Duration(seconds: 3)
        : isOneSecond == true
        ? const Duration(seconds: 1)
        : milliseconds == true
        ? const Duration(milliseconds: 200)
        : Duration.zero,
    () => onPerform(),
  );
}

String formatScheduleDate(String dateStr) {
  try {
    final dateTime = DateTime.parse(dateStr);
    return DateFormat("yyyy-MM-dd'T'HH:mm").format(dateTime);
  } catch (e) {
    return ""; // or handle invalid date
  }
}

futureOrderDelay(Function onPerform) async {
  return await Future.delayed(
    const Duration(milliseconds: 100),
    () => onPerform(),
  );
}

screenOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void hideKeyboard(context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

// Function to load the PNG image from the assets folder
Future<Uint8List> loadImageFromAssets(String assetName) async {
  final ByteData data = await rootBundle.load('assets/pngs/$assetName');
  return data.buffer.asUint8List();
}

Duration getAnimationDuration() {
  return const Duration(milliseconds: 10); // or any desired duration
}

void viewNetworkFile(BuildContext context, String imageUrl) {
  if (imageUrl.isNotEmpty) {
    final String extension = imageUrl.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      Get.to(
        () => FullScreenImage(
          isLocalFile: false,
          title: imageUrl.split('/').last,
          imageUrl: imageUrl,
        ),
      );
    } else if (extension == 'pdf') {
      Get.to(
        () => PdfViewerScreen(
          isLocalFile: false,
          title: imageUrl.split('/').last,
          pdfUrl: imageUrl,
        ),
      );
    } else {
      CustomSnackBar().showErrorSnackbar('Error', 'Unsupported file type');
    }
  } else {
    CustomSnackBar().showErrorSnackbar('Error', 'No file found');
  }
}

/// Converts a display date string to API format
String toApiFormat(String displayDate) {
  final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  final displayFormat = DateFormat('dd-MM-yyyy hh:mm a');

  if (displayDate.isEmpty) return '';
  try {
    DateTime parsedDate = displayFormat.parse(displayDate);
    return dateTimeFormat.format(parsedDate);
  } catch (e) {
    logcat("Date conversion error:", e);
    return '';
  }
}

String formatMeetingDate(String? scheduledAt) {
  if (scheduledAt == null || scheduledAt.isEmpty) return '';
  try {
    final date = DateTime.parse(scheduledAt);
    return DateFormat('dd-MM-yyyy hh:mm a').format(date);
  } catch (_) {
    return scheduledAt;
  }
}

/// Helper to safely parse a date string
DateTime? parseDate(String? date) {
  if (date == null || date.isEmpty) return null;
  try {
    return DateTime.parse(date);
  } catch (_) {
    return null;
  }
}

/// Helper to format a date in dd-MM-yyyy format
String formatDate(String? date) {
  final parsedDate = parseDate(date);
  if (parsedDate == null) return '';
  return DateFormat('dd-MM-yyyy').format(parsedDate);
}

String formatCustomerScheduleDate(String? scheduledDate) {
  if (scheduledDate == null || scheduledDate.isEmpty) return '';
  try {
    // Parse input in dd-MM-yyyy format
    final inputFormat = DateFormat('dd-MM-yyyy');
    final date = inputFormat.parse(scheduledDate);
    // Convert to yyyy-MM-dd format
    final outputFormat = DateFormat('yyyy-MM-dd');
    return outputFormat.format(date);
  } catch (e) {
    // If parsing fails, just return the original
    return scheduledDate;
  }
}

Future<void> fetchLocationTracking(
  context,
  Function onClick, {
  Function? getLatLongData,
}) async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await popupDialogs(
      context,
      LocationsDialog.servicesDisabled,
      LocationsDialog.enableLocation,
      () {
        onClick(false);
        Geolocator.openLocationSettings();
      },
    );
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      // showErrorSnackbar("Permissions", 'Location permissions are denied');
      return;
    }
  }

  // Position position = await Geolocator.getCurrentPosition(
  //   desiredAccuracy: LocationAccuracy.high,
  // );
  // Fetch location safely
  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    logcat("Location fetch failed", e.toString());
    // You can also show a toast instead of crashing
    // showCustomToast(context, "Failed to get location");
    return;
  }

  // UserPreferences().setLat(position.latitude.toString());
  // UserPreferences().setLong(position.longitude.toString());
  String? fullAddress = "";
  // ✅ Reverse geocoding
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      fullAddress =
          "${place.name ?? ''}, "
                  "${place.street ?? ''}, "
                  "${place.subLocality ?? ''}, "
                  "${place.locality ?? ''}, "
                  "${place.administrativeArea ?? ''}, "
                  "${place.postalCode ?? ''}, "
                  "${place.country ?? ''}"
              .replaceAll(', ,', ',')
              .trim();

      logcat("FullLocation:", fullAddress);
    }
  } catch (e) {
    logcat("Reverse geocoding failed", e.toString());
  }

  if (getLatLongData != null) {
    getLatLongData(
      position.latitude.toString(),
      position.longitude.toString(),
      fullAddress, // Pass the fullAddress
    );
  }

  logcat("Latitude:", position.latitude);
  logcat("Longitude:", position.longitude);
}

void showErrorDialog(BuildContext context, Map<String, dynamic> data) {
  String errorMessage = 'Server error';

  // Try first error from 'errors' first
  if (data['errors'] != null && data['errors'] is Map) {
    final errorsMap = data['errors'] as Map;
    if (errorsMap.isNotEmpty) {
      final firstErrorList = errorsMap.values.first;
      if (firstErrorList is List && firstErrorList.isNotEmpty) {
        errorMessage = firstErrorList.first.toString();
      }
    }
  }
  // Fallback to 'message' if no errors
  else if (data['message'] != null && data['message'].toString().isNotEmpty) {
    errorMessage = data['message'].toString();
  }

  showDialogForScreen(context, 'Add Lead', errorMessage, callback: () {});
}
