import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sizer/sizer.dart';

Widget getAppbar({bool? isBackPressShow, Function? onBackPress}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (isBackPressShow == true) backPress(onBackPress),
      Spacer(),
      getLogo(),
    ],
  );
}

Widget getLogo() {
  return Container(
    margin: EdgeInsets.only(right: 2.w),
    padding: const EdgeInsets.all(3),
    child: SvgPicture.asset(Asset.logo, height: 3.0.h, fit: BoxFit.cover),
  );
}

Widget dashboardToolbar({Function? onClick, showFilterOption = true}) {
  return SizedBox(
    height: 6.h,
    child: Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: primaryColor),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        /// Center: Title (expanded and centered)
        Expanded(
          child: Center(
            child: Text(
              HomeScreenConst.dashboard,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: plusJakartaSansExtraBold,
                color: primaryColor,
              ),
            ),
          ),
        ),

        /// Right: Filter button (optional)
        showFilterOption == true
            ? Container(
                margin: EdgeInsets.only(right: 2.w),
                child: IconButton(
                  icon: Icon(Icons.filter_alt, color: primaryColor),
                  onPressed: () {
                    if (onClick != null) onClick();
                  },
                ),
              )
            : Container(margin: EdgeInsets.only(right: 12.w)),
      ],
    ),
  );
}

/*Debug*/
void printing() {
  print('print');
}

/*Debug*/
commonAppBar({leftBtn, leftasset, required title, double gap = 24}) {
  return Row(
    children: [
      InkWell(
        onTap: leftBtn,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 8.5.w,
          height: 4.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: SvgPicture.asset(Asset.cback, height: 2.5.h, width: 2.5.w),
        ),
      ),

      getDynamicSizedBox(width: gap.w),

      SizedBox(
        child: Text(
          textAlign: TextAlign.center,
          title,
          maxLines: 1,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontSize: 18.sp,
            fontFamily: plusJakartaSansBold,
          ),
        ),
      ),
    ],
  );
}

updatedLeftAppbar({leftBtn, leftasset, required title, double width = 22}) {
  return SafeArea(
    child: Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 8.5.w,
          height: 4.h,
          child: FloatingActionButton(
            onPressed: leftBtn,
            backgroundColor: transparent,
            elevation: 0,
            mini: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: SvgPicture.asset(Asset.back, height: 3.h, width: 3.w),
          ),
        ),
        getDynamicSizedBox(width: width.w),
        SizedBox(
          child: Text(
            textAlign: TextAlign.center,
            title,
            maxLines: 1,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 20.sp,
              fontFamily: plusJakartaSansRegular,
            ),
          ),
        ),
      ],
    ),
  );
}

updatedAppbar({leftBtn, leftasset, required title, rightBtn, rightasset}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      leftBtn != null
          ? InkWell(
              onTap: leftBtn,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 8.9.w,
                height: 5.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: SvgPicture.asset(leftasset, width: 6.w, height: 6.h),
              ),
            )
          : getDynamicSizedBox(width: 13.5.w),
      Text(
        title,
        style: TextStyle(fontSize: 17.sp, fontFamily: plusJakartaSansBold),
      ),
      rightBtn != null
          ? IconButton(
              onPressed: rightBtn,
              icon: SvgPicture.asset(rightasset, width: 3.w, height: 3.h),
            )
          : getDynamicSizedBox(width: 13.5.w),
    ],
  );
}

bool isSmallDevice(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final screenHeight = mediaQuery.size.height;
  const smallDeviceHeightThreshold = 700.0;
  return screenHeight < smallDeviceHeightThreshold;
}

getSizedBox() {
  return SizedBox(height: 1.7.h);
}

getDynamicSizedBox({height, width}) {
  return SizedBox(height: height ?? 0, width: width ?? 0);
}

checkInternet() {
  return Scaffold(
    body: SizedBox(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Asset.noInternet, height: 20.h),
            SizedBox(height: 2.h),
            Text(
              textAlign: TextAlign.center,
              "Please Check Your\nInternet Connection.",
              style: TextStyle(
                color: Colors.red,
                fontFamily: plusJakartaSansBold,
                fontSize: Device.deviceType == DeviceType.web ? 10.sp : 18.sp,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

getSizedBoxForDropDown() {
  return SizedBox(height: 0.90.h);
}

getdivider() {
  return Divider(
    height: 3.5.h,
    indent: 0.1.h,
    endIndent: 0.1.h,
    thickness: 1,
    color: primaryColor.withOpacity(0.5),
  );
}

Widget backPress(callback) {
  return SizedBox(
    width: 32,
    height: 32,
    child: FloatingActionButton(
      onPressed: callback,
      backgroundColor: primaryColor,
      elevation: 0,
      mini: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: Icon(Icons.chevron_left_rounded, color: secondaryColor),
    ),
  );
}

Widget backButtonWidget(callback, {bool isWhiteText = false}) {
  return Container(
    margin: EdgeInsets.only(
      left: Device.screenType == ScreenType.mobile ? 3.w : 2.w,
    ),
    child: IconButton(
      onPressed: callback,
      icon: SvgPicture.asset(
        Asset.arrowBack,
        color: isWhiteText ? white : black,
        height: Device.screenType == ScreenType.mobile ? 5.h : 5.h,
      ),
      padding: EdgeInsets.zero, // removes default padding
      constraints: const BoxConstraints(), // prevents extra space
      splashRadius: 24, // gives a better ripple size
    ),
  );
}

// Widget backButtonWidget(callback, {isWhiteText}) {
//   return Container(
//     margin: EdgeInsets.only(
//       left: Device.screenType == ScreenType.mobile ? 5.w : 2.w,
//     ),
//     child: GestureDetector(
//       onTap: () {
//         callback();
//       },
//       child: SvgPicture.asset(
//         Asset.arrowBack,
//         color: isWhiteText == true ? white : black,
//         height: Device.screenType == ScreenType.mobile ? 4.h : 5.h,
//       ),
//     ),
//   );
// }

getCommonToolbar(
  String title, {
  Function? onClick,
  Function? onFilterClick,
  bool showBackButton = true,
  bool isFilter = false,
  bool? isLogo,
  BuildContext? context,
  bool? isViwerScreenOpen = false,
}) {
  return SafeArea(
    child: Stack(
      children: [
        Positioned(
          left: 0,
          bottom: 0,
          top: 0,
          child: showBackButton == true
              ? backButtonWidget(onClick)
              : Container(),
        ),

        isViwerScreenOpen == true
            ? Center(
                child: Container(
                  width: 50.w,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: plusJakartaSansBold,
                      color: black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: plusJakartaSansBold,
                    color: black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
        if (isFilter == true)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                right: Device.screenType == ScreenType.mobile ? 1.w : 4.6.w,
              ),
              child: SizedBox(
                height: 6.h, // your desired height
                width: 6.h,
                child: IconButton(
                  padding: EdgeInsets.all(3.0),
                  icon: SvgPicture.asset(Asset.filter, color: primaryColor),
                  onPressed: () {
                    if (onFilterClick != null) onFilterClick();
                  },
                ),
              ),
            ),
          ),
        // Positioned(
        //   right: 0,
        //   top: 0,
        //   bottom: 0,
        //   child: Container(
        //     padding: EdgeInsets.only(
        //       right: Device.screenType == ScreenType.mobile ? 4.5.w : 4.6.w,
        //     ),
        //     child: InkWell(
        //       onTap: () {
        //         onFilterClick!();
        //       },
        //       borderRadius: const BorderRadius.all(Radius.circular(24)),
        //       child: SvgPicture.asset(
        //         Asset.filter,
        //         height: Device.screenType == ScreenType.mobile
        //             ? isSmallDevice(context!)
        //                   ? 2.6.h
        //                   : 2.7.h
        //             : 2.5.h,
        //         color: black,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    ),
  );
}
