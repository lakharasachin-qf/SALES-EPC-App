import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/view/splash_screen/splash_screen.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await screenOrientations();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final internetController = Get.put(InternetController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          enableLog: true,
          title: AppConstant.name,
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          defaultTransition: Transition.fadeIn,
        );
      },
    );
  }
}
