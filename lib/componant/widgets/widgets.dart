import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sizer/sizer.dart';
import '../../configs/colors_constant.dart';
import '../../configs/font_constant.dart';

String formatText(String text) {
  if (text.isEmpty) return '';
  return text
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');
}

Widget deleteWidget(
  BuildContext context, {
  title,
  required cancelBtn,
  required deleletBtn,
  required setStateTrigger,
}) {
  return SingleChildScrollView(
    padding: EdgeInsets.only(bottom: 2.h, left: 6.w, right: 6.w, top: 2.h),
    child: SizedBox(
      width: Device.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(
                fontFamily: plusJakartaSansRegular,
                fontSize: 18.sp,
              ),
            ),
          ),

          getDynamicSizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Row(
              children: [
                Expanded(
                  child: getFormButton(
                    isBorderEnable: true,
                    btnColor: transparent,
                    textColor: secondaryColor,
                    context,
                    () {
                      cancelBtn();
                      Navigator.of(context).pop();
                    },
                    'Cancel',
                    validate: true,
                  ),
                ),
                getDynamicSizedBox(width: 4.w),

                Expanded(
                  child: getFormButton(
                    context,
                    () {
                      deleletBtn();
                      Navigator.of(context).pop();
                    },
                    'Delete',
                    validate: true,
                  ),
                ),
              ],
            ),
          ),
          getDynamicSizedBox(height: 3.h),
        ],
      ),
    ),
  );
}

getleftsidebackbtn({
  required backFunction,
  title,
  istitle = true,
  isbussinessScreen = false,
  isShare = false,
  shareCallBack,
}) {
  return Row(
    children: [
      GestureDetector(
        onTap: backFunction,
        child: Container(
          margin: isbussinessScreen
              ? EdgeInsets.only(top: 1.h, right: 5.w, bottom: 1.h)
              : EdgeInsets.only(top: 2.h, bottom: 2.h),
          // color: Colors.yellow,
          // padding: EdgeInsets.all(5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: SvgPicture.asset(
              Asset.arrowBack,
              colorFilter: const ColorFilter.mode(white, BlendMode.srcIn),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      if (istitle == true) getDynamicSizedBox(width: 2.w),
      if (istitle == true)
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: plusJakartaSansBold, fontSize: 18.sp),
        ),
      if (isShare == true) getDynamicSizedBox(width: 16.w),
      if (isShare == true)
        GestureDetector(onTap: shareCallBack, child: Icon(Icons.share)),
    ],
  );
}

Widget getListViewBuilder({
  required int itemCount,
  required Widget Function(int index) itemBuilder,

  ScrollPhysics scrollphysics = const NeverScrollableScrollPhysics(),
  Axis scrollDirection = Axis.vertical,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
}) {
  return ListView.builder(
    scrollDirection: scrollDirection,
    padding: padding,
    itemCount: itemCount,
    shrinkWrap: true,
    physics: scrollphysics,
    itemBuilder: (context, index) => itemBuilder(index),
  );
}

getTitle({required title, double size = 18}) {
  return Container(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: TextStyle(fontFamily: plusJakartaSansBold, fontSize: size.sp),
    ),
  );
}

void openBottomtsheet(
  BuildContext context, {
  double bordradius = 12,
  required Widget widget,
  VoidCallback? onClosing,
  Color barrierColor = Colors.black54,
  bool useRootNav = false,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(bordradius)),
    ),
    isScrollControlled: true,
    enableDrag: true, // 👈 Enable drag-to-close
    useRootNavigator: useRootNav,
    backgroundColor: white,
    useSafeArea: true,
    barrierColor: barrierColor,
    builder: (BuildContext context) {
      return widget;
    },
  ).whenComplete(() {
    if (onClosing != null) {
      onClosing(); // 👈 Trigger onClosing when bottom sheet is dismissed
    }
  });
}

openBottomtsheetDialog(
  BuildContext context, {
  required Widget widget,
  String? title = '',
  VoidCallback? onClosing,
  bool useRootNav = false,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    useSafeArea: true,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(13.w)),
    ),
    isScrollControlled: true,
    enableDrag: true, // 👈 Enable drag-to-close
    useRootNavigator: useRootNav,
    backgroundColor: white,
    barrierColor: Colors.black54,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              color: white,
              child: Wrap(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.w),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.w),
                            ),
                          ),
                          padding: EdgeInsets.only(top: 2.5.h, bottom: 2.h),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              title!,
                              style: TextStyle(
                                color: white,
                                fontSize: 18.sp,
                                fontFamily: plusJakartaSansBold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () {
                            if (onClosing != null) {
                              onClosing(); // 👈 Trigger onClosing when bottom sheet is dismissed
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: white,
                                  size: Device.screenType == ScreenType.mobile
                                      ? 25
                                      : 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  widget,
                ],
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    if (onClosing != null) {
      // onClosing(); // 👈 Trigger onClosing when bottom sheet is dismissed
    }
  });
}

Widget getCommonFormButton(
  Function fun,
  String str, {
  bool? isWhite,
  bool isValidate = true,
}) {
  return SizedBox(
    height: 6.5.h,
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        // backgroundColor: primaryColor, // Matches the purple in the screenshot
        backgroundColor: isValidate == true ? primaryColor : grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 5,
        shadowColor: primaryColor.withOpacity(0.3),
      ),
      onPressed: () => fun(),
      child: Center(
        child: Text(
          str,
          style: TextStyle(
            color: white,
            fontFamily: plusJakartaSansBold,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
      ),
    ),
  );
}

Widget getappLine() {
  return Container(height: 0.2.h, width: Device.width, color: primaryColor);
}

Widget getpageList({required String asset, required String text}) {
  return Column(
    children: [
      Image.asset(asset, height: 10.h, width: 10.h),
      Text(
        text,
        style: TextStyle(fontFamily: plusJakartaSansRegular, fontSize: 18.sp),
      ),
    ],
  );
}

Widget getCustomDivider() {
  return Container(
    decoration: BoxDecoration(
      color: lightGreyDivider,
      borderRadius: BorderRadius.circular(5),
    ),
    width: 15.w,
    height: 0.6.h,
  );
}

Future getpopup(
  BuildContext context, {
  bool istimerrunout = false,
  String? title,
  String? message,
  VoidCallback? function,
}) async {
  return showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(
          message ?? '',
          style: TextStyle(fontFamily: plusJakartaSansMedium),
        ),
        actions: [
          if (!istimerrunout)
            CupertinoDialogAction(
              child: Text('Cancel', style: TextStyle(color: black)),
              onPressed: () => Get.back(),
            ),
          CupertinoDialogAction(
            child: Text('Confirm', style: TextStyle(color: green)),
            onPressed: () {
              Get.back();
              function?.call(); // null-safe call
            },
          ),
        ],
      );
    },
  );
}

Widget screnLoader(double? height) {
  return Container(
    height: height,
    width: double.infinity,
    color: transparent,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 6,
        valueColor: AlwaysStoppedAnimation(primaryColor),
        backgroundColor: Colors.grey.shade200,
      ),
    ),
  );
}

Widget showSelectedTextInDialog({name, modelId, storeId}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Text(
          name,
          style: TextStyle(
            fontFamily: plusJakartaSansRegular,
            fontSize: Device.screenType == ScreenType.mobile ? 16.sp : 14.sp,
            fontWeight: modelId == storeId ? FontWeight.w700 : null,
            color: modelId == storeId ? secondaryColor : black,
          ),
        ),
      ),
      if (storeId != null && modelId == storeId)
        Container(
          width: 1.h,
          height: 1.h,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
    ],
  );
}

PreferredSizeWidget getTabbar({
  isanalysisScreen = false,
  required controller,
  required tabs,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(7.h),
    child: ClipRRect(
      child: Container(
        height: 6.h,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(color: transparent),
        child: Stack(
          children: [
            Container(
              height: 7.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: black),
              ),
            ),
            Positioned(
              top: 0.h,
              bottom: 0.h,
              right: 0.w,
              left: 0.w,
              child: SizedBox(
                height: 7.h,
                child: TabBar(
                  tabAlignment: isanalysisScreen ? TabAlignment.start : null,
                  indicatorPadding: EdgeInsets.zero,
                  isScrollable: isanalysisScreen ? true : false,
                  padding: EdgeInsets.all(0),
                  dividerColor: transparent,
                  controller: controller,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: tabBarColor,
                  ),
                  unselectedLabelColor: black,
                  labelColor: tabBarTitle,
                  labelStyle: TextStyle(
                    fontSize: 17.sp,
                    fontFamily: plusJakartaSansBold,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStatePropertyAll(transparent),
                  labelPadding: EdgeInsets.symmetric(horizontal: 3.w),
                  tabs: tabs,
                  // tabtitles.map((title) => Tab(text: title)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void unfocusAll(context) {
  FocusScope.of(context).unfocus();
}

Widget getTextField({
  String? label,
  required String hint,
  required FocusNode node,
  required TextEditingController ctr,
  required dynamic model,
  function,
  bool isNumeric = false,
  bool isNumber = false,
  bool wantsuffix = false,
  bool ispass = false,
  bool isenable = true,
  bool isdropdown = false,
  bool isdate = false,
  bool usegesture = false,
  bool isBorderSideEnable = false,
  bool isRequired = false,
  bool isMultipline = false,
  bool isCheckBox = false,
  bool isCamera = false,
  Widget? checkBoxWidget,
  int numberofDigit = 10,
  Function? gestureFunction,

  bool isobscure = false,
  Function? obscureFunction,
  bool useOnChanged = true,
  bool? isVerified = false,

  bool isAdd = false,
  Function? onAddBtn,
  Function? ontap,
  required BuildContext context,
  // 👇 New parameter
  bool wantLabel = true,
}) {
  Widget formfield = getReactiveFormField(
    isDropdown: isdropdown,
    isEnable: isenable,
    isCamera: isCamera,
    node: node,
    controller: ctr,
    hintLabel: hint,
    onAddBtn: onAddBtn,
    isDate: isdate,
    isCalender: isdate,
    onChanged: useOnChanged ? (val) => function(val) : (val) {},
    errorText: model.error,
    isAdd: isAdd,
    isAddress: isMultipline,
    inputType: isMultipline
        ? TextInputType.multiline
        : isNumber || isNumeric
        ? TextInputType.number
        : TextInputType.text,
    inputFormatters: isNumber
        ? []
        : isNumeric
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(numberofDigit),
          ]
        : [],
    wantSuffix: wantsuffix,
    isPass: ispass,
    isWhite: true,
    isBorderSideEnable: isBorderSideEnable,
    obscuretext: isobscure,
    obscureTextFunction: obscureFunction,
    onTap: ontap,
    isVerified: isVerified,
  );

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (wantLabel && label != null)
        isCheckBox
            ? Row(
                children: [
                  getLable(
                    label,
                    isRequired: isRequired,
                    isVerified: isVerified,
                  ),
                  SizedBox(width: 0.5.w),
                  if (checkBoxWidget != null) checkBoxWidget,
                ],
              )
            : getLable(label, isRequired: isRequired, isVerified: isVerified),
      usegesture
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (gestureFunction != null) {
                  gestureFunction();
                }
              },
              child: formfield,
            )
          : formfield,
    ],
  );
}

Widget commonListDevider() => Container(
  margin: EdgeInsets.symmetric(vertical: 1.w),
  height: 0.1.h,
  decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(10),
  ),
);

getLable(
  String title, {
  bool? isFromVisitReport,
  bool? isFromRetailer,
  bool isRequired = false,
  isVerified = false,
}) {
  return Container(
    margin: isFromRetailer != null && isFromRetailer == true
        ? EdgeInsets.only(left: 9.w, right: 9.w)
        : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: TextStyle(
                  color: isVerified ? grey : black,
                  fontFamily: plusJakartaSansBold,
                  fontSize: Device.screenType == ScreenType.mobile
                      ? 16.sp
                      : 8.5.sp,
                ),
              ),
              if (isRequired)
                TextSpan(
                  text: SigninScreenConst.required,
                  style: TextStyle(color: red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        if (isFromVisitReport == null)
          SizedBox(
            height: Device.screenType == ScreenType.mobile ? 0.5.h : 0.2.h,
          ),
      ],
    ),
  );
}

DataColumn setColumn(title) {
  return DataColumn(
    label: Expanded(
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: plusJakartaSansBold,
            fontSize: 2.h,
            color: white,
          ),
        ),
      ),
    ),
  );
}

getCommonLableWithButton(
  String title, {
  bool isRequired = false,
  Function? onClick,

  required isAddShow,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: TextStyle(
                  color: black,
                  fontFamily: plusJakartaSansBold,
                  fontSize: Device.screenType == ScreenType.mobile
                      ? 16.sp
                      : 8.5.sp,
                ),
              ),
              if (isRequired)
                TextSpan(
                  text: SigninScreenConst.required,
                  style: TextStyle(color: red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
      if (isAddShow == true)
        Container(
          margin: EdgeInsets.only(right: 2.w),
          child: IconButton(
            icon: Icon(
              Icons.add_circle_rounded,
              color: primaryColor,
              size: 20.sp,
            ),
            onPressed: () {
              if (onClick != null) onClick();
            },
          ),
        ),
    ],
  );
}

Widget getLogo(islogo) {
  return Container(
    margin: EdgeInsets.only(left: 3.w),
    child: GestureDetector(
      onTap: () {
        islogo();
      },
      child: Container(
        padding: EdgeInsets.only(left: 1.w, right: 1.w),
        margin: EdgeInsets.only(right: 5.w, left: 4.w),
        height: 3.5.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: Image(image: AssetImage(Asset.logoIcon)),
      ),
    ),
  );
}

Widget noDataFoundWidget({bool? isFromBlog}) {
  return SizedBox(
    height: isFromBlog == true ? Device.height / 1.4 : Device.height / 1.2,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Common.datanotfound,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: plusJakartaSansMedium,
              fontSize: 12.sp,
              color: black,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget getDivider() {
  return Divider(height: 0.1.h, color: grey);
}

Widget headerDivider() {
  return Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: grey,
    ),
    height: 5.h,
    width: 0.1.w,
  );
}

getBgDividerWeb(Color? selectedColor, {size}) {
  return Container(
    width: size,
    height: 0.3.h,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      color: selectedColor,
    ),
  );
}

Widget getFooterLogoWeb() {
  return FadeInLeft(child: SvgPicture.asset(Asset.logo, width: 120));
}

getFloatingActionButton({Function? onClick}) {
  return FloatingActionButton(
    backgroundColor: primaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    onPressed: () {
      onClick!();
    },
    child: Icon(
      Icons.add,
      color: white,
      size: Device.screenType == ScreenType.mobile ? null : 3.h,
    ),
  );
}

getEmptyListUi() {
  return SizedBox(
    height: Device.height / 1.5,
    child: Center(
      child: Text(
        Common.datanotfound,
        style: TextStyle(
          fontFamily: plusJakartaSansMedium,
          fontSize: 12.sp,
          color: black,
        ),
      ),
    ),
  );
}

Widget getSvgAsset(imageUrl, height, width, {ColorFilter? color}) {
  return SvgPicture.asset(
    imageUrl,
    height: height,
    width: width,
    colorFilter: color,
    fit: BoxFit.contain,
  );
}

Widget getImageAsset(imageUrl, height, width, {Color? color}) {
  return Image.asset(
    imageUrl,
    height: height,
    width: width,
    color: color,
    fit: BoxFit.cover,
  );
}

Widget buildSelectableRow(String title, bool isSelected) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 17.sp,
          color: isSelected ? primaryColor : black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      if (isSelected) Icon(Icons.check, color: primaryColor, size: 20.sp),
    ],
  );
}
