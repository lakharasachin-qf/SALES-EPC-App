import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sales_app/componant/CustomSnakbar.dart';
import 'package:sales_app/componant/dialogs/fullscreen.dart';
import 'package:sales_app/componant/dialogs/pdfviewer_screen.dart';
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
