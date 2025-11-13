import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/AppPermissions.dart';
import 'package:sales_app/view/dashboard_screen/dashboardScreen.dart';
import 'package:sales_app/view/signin_screen/signin_screen.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    User? userData = await UserPreferences().getSignInInfo();
    bool islogin = await UserPreferences().getLogin();

    if (islogin && userData != null) {
      // AppPermissions().setRights(userData.rights);
      // Load rights inside AppPermissions
      await AppPermissions().loadRights();
      Get.offAll(() => DashboardScreen());
      // Get.offAll(() => MapDrawingScreen());
    } else {
      Get.offAll(() => const Signinscreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    Statusbar().trasparentStatusbar();
    return Container(
      width: 150.w,
      height: 150.h,
      color: white,
      child: Center(
        child: Image.asset(Asset.logoPng, fit: BoxFit.cover, width: 150),
      ),
    );
  }
}
