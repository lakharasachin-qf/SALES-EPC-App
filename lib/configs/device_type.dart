import 'package:flutter/material.dart';

class DeviceScreenType {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
}
