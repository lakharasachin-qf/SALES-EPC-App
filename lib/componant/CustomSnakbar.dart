import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/configs/colors_constant.dart';

class CustomSnackBar {
  static showCustomSnackBar({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: white,
      backgroundColor: Colors.green,
      icon: const Icon(Icons.check_circle, color: white),
    );
  }

  static showCustomErrorSnackBar({
    required String title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: white,
      backgroundColor: color ?? Colors.redAccent,
      icon: const Icon(Icons.error, color: white),
    );
  }

  static showCustomToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? Colors.green,
      onTap: (snack) {
        Get.closeAllSnackbars();
      },
      message: message,
    );
  }

  static showCustomErrorToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? Colors.redAccent,
      onTap: (snack) {
        Get.closeAllSnackbars();
      },
      message: message,
    );
  }

  void showErrorSnackbar(
    String title,
    String message, {
    bgColor = primaryColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: white,
    );
  }
}
