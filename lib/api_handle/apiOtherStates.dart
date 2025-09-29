import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sizer/sizer.dart';

Widget apiOtherStates(
  state,
  controller,
  RxList<dynamic> list,
  Function onClick,
) {
  if (state == ScreenState.apiLoading) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 30,
          width: 30,
          child: LoadingAnimationWidget.discreteCircle(
            color: primaryColor,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget? button;
  if (list.isEmpty) {
    Container();
  }
  if (state == ScreenState.noDataFound) {
    // button = getMiniButton(() {
    //   Get.back();
    // }, BottomConstant.back);
  }
  if (state == ScreenState.noNetwork) {
    button = getMiniButton(() {
      onClick();
    }, BottomConstant.tryAgain);
  }

  if (state == ScreenState.apiError) {
    button = getMiniButton(() {
      // Get.back();
      onClick();
    }, BottomConstant.tryAgain);
  }
  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      child: controller.message.value.isNotEmpty
          ? Text(
              controller.message.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: plusJakartaSansMedium,
                fontSize: 12.sp,
                color: black,
              ),
            )
          : button,
    ),
  );
}
