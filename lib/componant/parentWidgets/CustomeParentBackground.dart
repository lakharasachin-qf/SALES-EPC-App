import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';

// ignore: must_be_immutable
class CustomParentScaffold extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget body;
  Future<bool> Function()? onWillPop;
  bool isExtendBodyScreen;
  bool isNormalScreen;
  final Widget? floatingActionBtn;
  Widget? bottomNavigationBar;
  bool isdraweruse;
  Drawer? drower;
  bool drawerEnableOpenDragGesture;
  bool extendedbodybehindappbar;
  bool resizeToAvoidBottomInset;
  Color? bgColor;
  Function()? onTap;

  CustomParentScaffold({
    this.scaffoldKey,
    super.key,
    this.onWillPop,
    required this.body,
    this.floatingActionBtn,
    this.onTap,
    this.resizeToAvoidBottomInset = true,
    this.bottomNavigationBar,
    this.isdraweruse = false,
    this.drower,
    this.isExtendBodyScreen = false,
    this.isNormalScreen = false,
    this.drawerEnableOpenDragGesture = false,
    this.extendedbodybehindappbar = false,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final InternetController internetController =
        Get.find<InternetController>();
    final Color effectiveBgColor =
        bgColor ?? Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!();
      },
      child: Obx(() {
        if (internetController.connectivityResult.value ==
            ConnectivityResult.none) {
          return checkInternet();
        }

        return PopScope(
          canPop: onWillPop == null,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            if (onWillPop != null) {
              final shouldPop = await onWillPop!();
              if (shouldPop && context.mounted) {
                Get.back();
              }
            }
          },
          child: isExtendBodyScreen
              ? SafeArea(
                  top: false,
                  child: Scaffold(
                    key: scaffoldKey,
                    drawer: isdraweruse ? drower : null,
                    floatingActionButton: floatingActionBtn,
                    drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
                    backgroundColor: effectiveBgColor,
                    extendBodyBehindAppBar: extendedbodybehindappbar,
                    resizeToAvoidBottomInset: isNormalScreen == true
                        ? false
                        : true,
                    body: body,
                  ),
                )
              : SafeArea(
                  top: false,
                  child: Scaffold(
                    key: scaffoldKey,
                    extendBodyBehindAppBar: extendedbodybehindappbar,
                    drawer: isdraweruse ? drower : null,
                    drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
                    bottomNavigationBar: bottomNavigationBar,
                    backgroundColor: effectiveBgColor,
                    body: body,
                    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
                  ),
                ),
        );
      }),
    );
  }
}
