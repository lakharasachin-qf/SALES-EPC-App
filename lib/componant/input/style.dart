import 'package:flutter/material.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sizer/sizer.dart';

styleTextFormFieldText({isWhite}) {
  return TextStyle(
    fontFamily: plusJakartaSansRegular,
    color: black,
    fontWeight: FontWeight.w300,
    fontSize: Device.screenType == ScreenType.mobile ? 16.sp : 9.sp,
  );
}

styleTextForFieldLabel(usernameNode) {
  return TextStyle(
    fontFamily: plusJakartaSansRegular,
    color: usernameNode.hasFocus ? primaryColor : black,
    fontSize: 12.sp,
  );
}

styleTextFormFieldTextGrey() {
  return TextStyle(
    fontFamily: plusJakartaSansRegular,
    color: grey,
    fontWeight: FontWeight.w300,
    fontSize: Device.screenType == ScreenType.mobile ? 16.sp : 9.sp,
  );
}

styleTextForErrorFieldHint() {
  return TextStyle(
    fontSize: Device.screenType == ScreenType.mobile ? 15.sp : 10.sp,
    fontFamily: plusJakartaSansRegular,
    color: red,
  );
}

styleTextHintFieldLabel({isWhite}) {
  return TextStyle(
    fontFamily: plusJakartaSansRegular,
    fontWeight: FontWeight.w500,
    fontSize: Device.screenType == ScreenType.mobile ? 16.sp : 9.sp,
    color: bluishGrey,
  );
}

styleTextForFieldHintDropDown() {
  return TextStyle(
    fontFamily: plusJakartaSansRegular,
    fontWeight: FontWeight.w500,
    fontSize: Device.screenType == ScreenType.mobile ? 12.sp : 9.sp,
    color: const Color.fromARGB(255, 145, 145, 145),
  );
}

styleTextForFieldHint() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: Device.screenType == ScreenType.mobile ? 12.sp : 8.sp,
    color: const Color.fromARGB(255, 145, 145, 145),
  );
}

styleTitle() {
  return TextStyle(
    fontFamily: plusJakartaSansExtraBold,
    color: headingTextColor,
    fontWeight: FontWeight.w900,
    fontSize: Device.screenType == ScreenType.mobile ? 26.sp : 22.sp,
  );
}

styleTitleSubtaxt() {
  return TextStyle(
    fontFamily: plusJakartaSansExtraBold,
    color: headingTextColor,
    fontWeight: FontWeight.w600,
    fontSize: 11.sp,
  );
}

styleForBottomTextOne(context) {
  return TextStyle(
    fontSize: Device.screenType == ScreenType.mobile ? 11.sp : 8.sp,
    fontWeight: FontWeight.w100,
    fontFamily: plusJakartaSansRegular,
    color: secondaryColor,
  );
}

styleForBottomTextTwo() {
  return TextStyle(
    fontSize: Device.screenType == ScreenType.mobile ? 11.sp : 8.sp,
    fontWeight: FontWeight.w600,
    fontFamily: plusJakartaSansRegular,
    color: secondaryColor,
  );
}

styleDidtReceiveOTP(context) {
  return TextStyle(
    fontSize: Device.screenType == ScreenType.mobile ? 11.5.sp : 9.sp,
    fontWeight: FontWeight.w100,
    fontFamily: plusJakartaSansRegular,
    color: labelTextColor,
  );
}

styleResentButton() {
  return TextStyle(
    fontSize: Device.screenType == ScreenType.mobile ? 11.5.sp : 9.sp,
    fontFamily: plusJakartaSansMedium,
    color: secondaryColor,
  );
}
