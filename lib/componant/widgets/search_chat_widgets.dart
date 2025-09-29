import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:sales_app/componant/input/style.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sizer/sizer.dart';

setSearchBar(
  context,
  controller,
  String tag, {
  Function? onCancleClick,
  Function? onClearClick,
  bool? isCancle,
}) {
  return FadeInLeft(
    child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(
                Device.screenType == ScreenType.mobile ? 5.h : 6.h,
              ),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.05),
                  blurRadius: 10.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Device.screenType == ScreenType.mobile ? 0.w : 1.2.w,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: Device.screenType == ScreenType.mobile
                  ? 3.8.w
                  : 4.0.w,
              vertical: Device.screenType == ScreenType.mobile ? 0.8.h : 1.5.h,
            ),
            child: TextFormField(
              controller: controller,
              cursorColor: primaryColor,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.start,
              onEditingComplete: () {},
              onChanged: (val) {},
              style: styleTextFormFieldText(isWhite: true),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                fillColor: white.withOpacity(0.1),
                prefixIcon: Icon(
                  Icons.search,
                  color: black,
                  size: Device.screenType == ScreenType.mobile ? 20 : 25,
                ),
                labelStyle: styleTextForFieldHint(),
                suffixIcon: GestureDetector(
                  onTap: () {
                    onClearClick!();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: Icon(
                      Icons.cancel,
                      color: black,
                      size: Device.screenType == ScreenType.mobile ? 20 : 25,
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.only(
                  top: Device.screenType == ScreenType.mobile ? 0.7.h : 0.8.h,
                  bottom: Device.screenType == ScreenType.mobile
                      ? 0.7.h
                      : 1.6.h,
                ),
                hintText: SearchScreenConstant.hint,
                hintStyle: styleTextForFieldHint(),
                border: InputBorder.none,
                alignLabelWithHint: true,
              ),
            ),
          ),
        ),
        if (isCancle == true)
          FadeInRight(
            child: GestureDetector(
              onTap: () {
                onCancleClick!();
              },
              child: Container(
                padding: EdgeInsets.only(right: 5.w),
                child: Text(
                  SearchScreenConstant.cancle,
                  style: TextStyle(
                    fontFamily: plusJakartaSansRegular,
                    color: black,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
