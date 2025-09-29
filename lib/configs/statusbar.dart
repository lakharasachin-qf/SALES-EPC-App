import 'package:flutter/services.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/utils/helper.dart';

class Statusbar {
  void trasparentStatusbar({isprofileScreen = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: isprofileScreen
            ? Brightness.light
            : Brightness.light,
      ),
    );
  }

  void trasparentStatusbarProfile(bool isLightStatusBar) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: isLightStatusBar
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: transparent,
        statusBarBrightness: isDarkMode() ? Brightness.dark : Brightness.light,
      ),
    );
  }

  void transparentStatusbarIsNormalScreen() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: isDarkMode()
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: transparent,
        statusBarBrightness: isDarkMode() ? Brightness.dark : Brightness.light,
      ),
    );
  }

  void transparentBottomsheetStatusbar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: transparent),
    );
  }

  void trasparentStatusbarScreen() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: black,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }
}
