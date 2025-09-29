import 'package:flutter/material.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sizer/sizer.dart';

Widget getMaterialButton({
  required BuildContext context,
  required VoidCallback onPressed,
  required String text,
}) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return SizedBox(
    height: Device.screenType == ScreenType.mobile
        ? isSmallDevice(context)
              ? 8.h
              : 5.h
        : 5.9.h,
    width: Device.screenType == ScreenType.mobile
        ? Device.width / 1
        : Device.width / 2,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? black : white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: primaryColor,
        elevation: 0,
        shadowColor: transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: plusJakartaSansBold,
          fontSize: Device.screenType == ScreenType.mobile ? 14.sp : 9.sp,
        ),
      ),
    ),
  );
}

getFormButton(
  BuildContext context,
  Function fun,
  str, {
  required bool validate,

  double fontsize = 16,
  Color btnColor = primaryColor,
  isBorderEnable = false,
  textColor = white,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(
      Device.screenType == ScreenType.mobile ? 5.h : 1.4.h,
    ),
    focusColor: btnColor,
    hoverColor: btnColor,
    radius: 10.32,
    onTap: () {
      fun();
    },
    child: Container(
      height: Device.screenType == ScreenType.mobile
          ? isSmallDevice(context)
                ? 8.h
                : 6.h
          : 5.9.h,
      alignment: Alignment.center,
      //  padding: EdgeInsets.only(top: 1.h),
      width: Device.screenType == ScreenType.mobile
          ? Device.width / 1
          : Device.width / 2,
      decoration: BoxDecoration(
        border: Border.all(color: isBorderEnable ? customBrown : transparent),
        borderRadius: BorderRadius.circular(
          Device.screenType == ScreenType.mobile ? 1.h : 1.4.h,
        ),
        color: validate
            ? isDarkMode()
                  ? white
                  : btnColor
            : grey,
        boxShadow: [
          // BoxShadow(
          //   color: validate ? black.withOpacity(0.2) : grey.withOpacity(0.2),
          //   blurRadius: 10.0,
          //   offset: const Offset(0, 1),
          //   spreadRadius: 3.0,
          // ),
        ],
      ),
      child: Text(
        str,
        style: TextStyle(
          color: textColor,
          fontFamily: plusJakartaSansRegular,
          fontSize: Device.screenType == ScreenType.mobile
              // ignore: unnecessary_type_check
              ? (fontsize is double ? fontsize.sp : (fontsize.toDouble()).sp)
              : 9.sp,
        ),
      ),
    ),
  );
}

getMiniButton(Function fun, str, {bool? icon}) {
  return InkWell(
    onTap: () {
      fun();
    },
    child: Container(
      height: Device.screenType == ScreenType.mobile ? 5.h : 4.5.h,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 1),
      width: Device.screenType == ScreenType.mobile
          ? Device.width / 1
          : Device.width / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 1),
            spreadRadius: 3.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            str,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: white,
              fontFamily: plusJakartaSansBold,
              fontSize: Device.screenType == ScreenType.mobile ? 11.sp : 8.sp,
            ),
          ),
        ],
      ),
    ),
  );
}

getSecondaryFormButton(
  Function fun,
  str, {
  isvalidate,
  bool? isFromDialog,
  bool? isEnable,
  bool? isFromCart,
}) {
  return InkWell(
    onTap: () {
      fun();
    },
    borderRadius: const BorderRadius.all(Radius.circular(22)),
    child: Container(
      margin: EdgeInsets.only(
        top: Device.screenType == ScreenType.mobile ? 0.w : 2.h,
      ),
      padding: EdgeInsets.symmetric(
        vertical: Device.screenType == ScreenType.mobile
            ? 1.7.h
            : isFromCart == true
            ? 1.5.h
            : 1.h,
        horizontal: Device.screenType == ScreenType.mobile
            ? 5.h
            : isFromCart == true
            ? 4.h
            : 6.h,
      ),
      width: Device.screenType == ScreenType.mobile
          ? Device.width
          : isFromCart == true
          ? Device.width / 2
          : Device.width / 2.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.h),
        color: isvalidate ? lightPrimaryColor : grey,
        gradient: isvalidate
            ? const LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(0.8, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
            : null,
      ),
      child: Text(
        str,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: white,
          fontFamily: plusJakartaSansBold,
          fontWeight: FontWeight.w900,
          fontSize: isFromDialog == true
              ? 12.5.sp
              : isFromCart == true
              ? Device.screenType == ScreenType.mobile
                    ? 10.sp
                    : 9.sp
              : 13.sp,
        ),
      ),
    ),
  );
}

getButton(str, Function fun, {required bool isvalidate}) {
  return InkWell(
    onTap: () {
      fun();
    },
    child: Container(
      height: Device.screenType == ScreenType.mobile ? 13.w : 6.h,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: Device.screenType == ScreenType.mobile ? 5 : 2,
      ),
      width: Device.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.7.h),
        boxShadow: [
          BoxShadow(
            color: isvalidate == true
                ? primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 1),
            spreadRadius: 3.0,
          ),
        ],
        gradient: LinearGradient(
          colors: isvalidate == true
              ? [primaryColor, primaryColor.withOpacity(0.5)]
              : [Colors.grey, Colors.grey],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: const [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Text(
        str,
        style: TextStyle(
          color: Colors.white,
          fontFamily: plusJakartaSansBold,
          fontSize: 18.sp,
        ),
      ),
    ),
  );
}

commonBtn(str, Function fun, {required bool isvalidate}) {
  return InkWell(
    onTap: () {
      fun();
    },
    child: Container(
      height: Device.screenType == ScreenType.mobile ? 13.w : 10.h,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: Device.screenType == ScreenType.mobile ? 3 : 2,
      ),
      width: Device.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.7.h),
        boxShadow: [
          BoxShadow(
            color: isvalidate == true
                ? primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 1),
            spreadRadius: 3.0,
          ),
        ],
        gradient: LinearGradient(
          colors: isvalidate == true
              ? [primaryColor, primaryColor.withOpacity(0.5)]
              : [Colors.grey, Colors.grey],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: const [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Center(
        child: Text(
          str,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: white,
            fontFamily: plusJakartaSansBold,
            fontSize: 14.sp,
            height: 1.2,
          ),
        ),
      ),
    ),
  );
}
