import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sales_app/componant/input/custom_text_field.dart';
import 'package:sales_app/componant/input/form_inputs.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sizer/sizer.dart';
import '../../configs/colors_constant.dart';
import '../../configs/font_constant.dart';
import '../../configs/string_constant.dart';
import '../toolbar/toolbar.dart';

void showUpdatedMultpleSelectionPopup<T>(
  BuildContext context, {
  required List<T> list,
  required TextEditingController controller,
  required String title,
  required TextEditingController searchCtr,
  required FocusNode searchNode,
  required List<T> Function(String) filterFunction,
  required String Function(T) getTitle,
  required String Function(T) getId,
  required Function(List<T>) onSelected,
  required Function function,
}) {
  List<T> selectedItems = list.where((item) {
    final title = getTitle(item);
    return controller.text.split(', ').contains(title);
  }).toList();
  List<T> filteredList = List.from(list);
  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: (Device.screenType == ScreenType.mobile
                  ? Device.height / 1.7
                  : Device.height / 1.9),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: white,
                            fontFamily: plusJakartaSansMedium,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close, color: white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: getReactiveFormField(
                      node: searchNode,
                      controller: searchCtr,
                      hintLabel: 'Search Here',
                      onChanged: (val) {
                        filteredList = filterFunction(val!);
                        setState(() {});
                      },
                      inputType: TextInputType.text,
                      isBorderSideEnable: false,
                      formType: FieldType.search,
                    ),
                  ),

                  if (filteredList.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          AlertDialogList.emptylist,
                          style: TextStyle(
                            fontSize: 4.5.w,
                            fontFamily: plusJakartaSansBold,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 3.h),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final title = getTitle(item);
                          // final id = getId(item);
                          final isSelected = selectedItems.contains(item);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(title),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedItems.add(item);
                                } else {
                                  selectedItems.remove(item);
                                }
                                controller.text = selectedItems
                                    .map((e) => getTitle(e))
                                    .join(', ');
                                onSelected(selectedItems);
                                function(); // validation on-the-fly
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<Object?> popupDialogs(
  BuildContext context,
  title,
  subString,
  Function onClick,
) {
  return showGeneralDialog(
    barrierColor: black.withOpacity(0.6),
    transitionBuilder: (context, a1, a2, widget) {
      final curvedValue = Curves.easeInOut.transform(a1.value);
      return Transform.translate(
        offset: Offset(0, (1 - curvedValue) * 400),
        child: Opacity(
          opacity: a1.value,
          child: CupertinoAlertDialog(
            title: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                color: black,
                fontFamily: plusJakartaSansBold,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              subString,
              style: TextStyle(
                fontSize: 12.sp,
                color: black,
                fontFamily: plusJakartaSansBold,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                isDefaultAction: true,
                isDestructiveAction: true,
                child: Text(
                  Button.cancel,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: plusJakartaSansBold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  onClick();
                  Navigator.pop(context);
                },
                isDefaultAction: true,
                isDestructiveAction: true,
                child: Text(
                  Logout.yes,
                  // Button.settings,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: plusJakartaSansBold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
  );
}

fetchSelectionPopup<T>(
  BuildContext context, {
  required list,
  required controller,
  required title,
  Function? function,
  required searchCtr,
  required searchNode,
  required filterFunction,
  required String Function(T) getTitle,
  Function(T)? onSelected,
  required backBtn,
  bool isStandard = false,
}) {
  String selecteddata = controller.text;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 0.8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: white,
                            fontFamily: plusJakartaSansMedium,
                            fontSize: 18.sp,
                          ),
                        ),
                        IconButton(
                          onPressed: backBtn,
                          icon: Icon(
                            Icons.close,
                            color: white,
                            size: 22.sp,
                            weight: 600.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: getReactiveFormField(
                      node: searchNode,
                      controller: searchCtr,
                      hintLabel: "Search",
                      onChanged: (val) {
                        filterFunction(val!);
                        setState(() {});
                      },
                      inputType: TextInputType.text,
                      isBorderSideEnable: false,
                      formType: FieldType.search,
                    ),
                  ),

                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      padding: EdgeInsets.only(bottom: 10.h),
                      itemBuilder: (context, index) {
                        var data = list[index];
                        String displayData = getTitle(data);
                        return ListTile(
                          title: Text(
                            isStandard
                                ? 'Standard :- $displayData'
                                : displayData,
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: displayData == selecteddata
                                  ? primaryColor
                                  : black,
                            ),
                          ),
                          trailing: displayData == selecteddata
                              ? Icon(Icons.check, color: primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              selecteddata = displayData;
                            });

                            controller.text = displayData;
                            function?.call();
                            onSelected?.call(data);
                            backBtn();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<Future> commonDropDownDialog(
  BuildContext buildContext, {
  Widget? content,
  required String title,
  Function? onCloseClick,
}) async {
  return showModalBottomSheet(
    context: buildContext,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
    ),
    isScrollControlled: true,
    isDismissible: false,
    constraints: BoxConstraints(maxWidth: Device.width),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Wrap(
              children: [
                getDynamicSizedBox(height: 1.h),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 0.8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: plusJakartaSansMedium,
                          fontSize: 18.sp,
                          color: white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (onCloseClick != null) {
                            onCloseClick();
                          }
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.cancel,
                          size: Device.screenType == ScreenType.mobile
                              ? 22.sp
                              : 28.sp,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                ),
                getDynamicSizedBox(height: 1.h),
                content!,
              ],
            ),
          );
        },
      );
    },
  );
}

Widget setDropDownContent(
  RxList<dynamic> list,
  Widget content, {
  Widget? searchcontent,
  bool isApiIsLoading = false,
  TextEditingController? controller,
  isVerificationPopup = false,
  String? noDataLable,
}) {
  return SizedBox(
    height: (Device.screenType == ScreenType.mobile
        ? Device.height / 2
        : Device.height / 1.9),
    width: Device.width,
    child: Container(
      margin: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
      child: Column(
        children: [
          // getDividerForShowDialog(),
          searchcontent ?? Container(),
          if (list.isEmpty && isApiIsLoading == false)
            Expanded(
              child: Center(
                child: Text(
                  controller != null && controller.text.isNotEmpty
                      ? AlertDialogList.searchlist
                      : noDataLable ?? AlertDialogList.emptylist,
                  style: TextStyle(
                    fontSize: 4.5.w,
                    fontFamily: plusJakartaSansMedium,
                  ),
                ),
              ),
            )
          else if (isApiIsLoading == true)
            Expanded(
              child: Center(
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
              ),
            ),
          if (list.isNotEmpty) Expanded(child: content),
          getDynamicSizedBox(height: 1.0.h),
        ],
      ),
    ),
  );
}

getDividerForShowDialog() {
  return Divider(
    height: 0.5.h,
    indent: 0.1.h,
    endIndent: 0.1.h,
    thickness: 1,
    color: primaryColor.withOpacity(0.5),
  );
}

showDialogForScreen(
  context,
  String title,
  String message, {
  Function? callback,
  bool? isFromLogin,
}) {
  showMessage(
    context: context,
    callback: () {
      if (callback != null) {
        callback();
      }
      return true;
    },
    isFromLogin: isFromLogin,
    message: message,
    title: title,
    negativeButton: '',
    positiveButton: Button.continues,
  );
}

void showMessage({
  required BuildContext context,
  Function? callback,
  String? title,
  String? message,
  String? positiveButton,
  bool? isFromLogin,
  String? negativeButton,
  bool isTitleLeft = false, // 👈 NEW flag
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => FadeInUp(
      duration: const Duration(milliseconds: 300),
      animate: true,
      from: 30,
      child: CupertinoAlertDialog(
        title: isTitleLeft
            ? null // 👈 skip default centered title
            : Text(
                title ?? '',
                style: TextStyle(
                  fontFamily: plusJakartaSansBold,
                  fontSize: Device.screenType == ScreenType.mobile
                      ? 15.sp
                      : 8.sp,
                ),
              ),
        content: isTitleLeft
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? '',
                    style: TextStyle(
                      fontFamily: plusJakartaSansBold,
                      fontSize: Device.screenType == ScreenType.mobile
                          ? 15.sp
                          : 8.sp,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message ?? '',
                    style: const TextStyle(fontFamily: plusJakartaSansRegular),
                  ),
                ],
              )
            : Text(
                message ?? '',
                style: const TextStyle(fontFamily: plusJakartaSansRegular),
              ),
        actions: [
          if ((negativeButton ?? '').isNotEmpty)
            CupertinoDialogAction(
              child: Text(
                negativeButton!,
                style: TextStyle(
                  fontSize: Device.screenType == ScreenType.mobile
                      ? 16.sp
                      : 6.sp,
                  fontFamily: plusJakartaSansMedium,
                  color: black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          if ((positiveButton ?? '').isNotEmpty)
            CupertinoDialogAction(
              child: Text(
                positiveButton!,
                style: TextStyle(
                  fontSize: Device.screenType == ScreenType.mobile
                      ? 16.sp
                      : 10.sp,
                  fontFamily: plusJakartaSansMedium,
                  color: black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                callback?.call();
              },
            ),
        ],
      ),
    ),
  );
}

Widget getRadioButton({
  label,
  firstText,
  secondText,
  isrequired = false,
  enableFunction,
  groupvalue,
  isSelected,
  onChanged,
  required unfocused,
  notifyListeners,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      getLable(label, isRequired: isrequired),
      getDynamicSizedBox(width: 1.w),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Radio(
                value: firstText,
                groupValue: groupvalue,
                onChanged: (value) {
                  unfocused();
                  onChanged(value!);
                  isSelected = false;
                  enableFunction(groupvalue);
                  notifyListeners();
                  print(groupvalue.toString());
                },
              ),
              GestureDetector(
                onTap: () {
                  unfocused();
                  onChanged(firstText);
                  isSelected = false;
                  enableFunction(groupvalue);
                  notifyListeners();
                  print(groupvalue.toString());
                },
                child: Text(
                  firstText,
                  style: TextStyle(fontFamily: plusJakartaSansRegular),
                ),
              ),
              Radio(
                value: secondText,
                groupValue: groupvalue,
                onChanged: (value) {
                  unfocused();
                  onChanged(value!);
                  isSelected = false;
                  enableFunction(groupvalue);
                  notifyListeners();
                  print(groupvalue.toString());
                },
              ),
              GestureDetector(
                onTap: () {
                  unfocused();
                  onChanged(secondText);
                  isSelected = false;
                  enableFunction(groupvalue);
                  notifyListeners();
                },
                child: Text(
                  secondText,
                  style: TextStyle(fontFamily: plusJakartaSansRegular),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future showDropDownDialog(BuildContext context, Widget content, String title) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0XFFe3ecf3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        title: Padding(
          padding: EdgeInsets.only(
            left: Device.screenType == ScreenType.mobile ? 0.w : 2.9.w,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: plusJakartaSansMedium,
              fontSize: 20.sp,
            ),
          ),
        ),
        contentPadding: EdgeInsets.only(left: 6.7.w, top: 0.5.h, right: 6.7.w),
        content: content,
      );
    },
  );
}

void showDropdownMessage(
  BuildContext context,
  Widget content,
  String title, {
  Function? onClick,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: Padding(
              padding: EdgeInsets.only(
                left: Device.screenType == ScreenType.mobile ? 0.w : 2.9.w,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: Device.screenType == ScreenType.mobile
                          ? 7.w
                          : 2.9.w,
                      right: 10.w,
                      top: 3.h,
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: plusJakartaSansMedium,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 1.h,
                    right: 2.5.w,
                    child: GestureDetector(
                      onTap: () {
                        if (onClick != null) {
                          onClick();
                        }
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.cancel,
                        color: black,
                        size: Device.screenType == ScreenType.mobile
                            ? 24.sp
                            : 30.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            contentPadding: EdgeInsets.only(
              left: 6.7.w,
              top: 0.5.h,
              right: 6.7.w,
            ),
            content: content,
          );
        },
      );
    },
  );
}

Future<Object?> selectImageFromCameraOrGallery(
  BuildContext context, {
  Function? cameraClick,
  Function? galleryClick,
}) {
  return showGeneralDialog(
    barrierColor: black.withOpacity(0.6),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: CupertinoAlertDialog(
            title: Text(
              AlertDialogList.photo,
              style: TextStyle(
                fontSize: 18,
                color: black,
                fontFamily: plusJakartaSansMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              AlertDialogList.selectPhotoFrom,
              style: TextStyle(
                fontSize: 13,
                color: black,
                fontFamily: plusJakartaSansBold,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  cameraClick!();
                  Navigator.pop(context);
                },
                isDefaultAction: true,
                isDestructiveAction: true,
                child: Text(
                  AlertDialogList.camera,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: black,
                    fontFamily: plusJakartaSansRegular,
                    fontSize: Device.screenType == ScreenType.mobile
                        ? 13.sp
                        : 11.sp,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  galleryClick!();
                  Navigator.pop(context);
                },
                isDefaultAction: true,
                isDestructiveAction: true,
                child: Text(
                  AlertDialogList.gallery,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: black,
                    fontFamily: plusJakartaSansRegular,
                    fontSize: Device.screenType == ScreenType.mobile
                        ? 13.sp
                        : 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
  );
}

Future commonDetailsDialog(
  BuildContext context,
  String title, {
  Widget? contain,
  bool? isDescription,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: white,
        insetPadding: EdgeInsets.symmetric(
          vertical: isDescription == true
              ? Device.screenType == ScreenType.mobile
                    ? 15.h
                    : 12.h
              : Device.screenType == ScreenType.mobile
              ? 20.h
              : 20.h,
          horizontal: Device.screenType == ScreenType.mobile ? 4.h : 6.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0.0,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 3.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  SizedBox(
                    width: isSmallDevice(context) ? 65.w : 60.w,
                    child: Device.screenType == ScreenType.mobile
                        ? getText(title)
                        : getText(title),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.cancel,
                        size: Device.screenType == ScreenType.mobile
                            ? 24.0
                            : 28.0,
                        color: black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            getDynamicSizedBox(height: 0.5.h),
            getDivider(),
            getDynamicSizedBox(height: 1.h),
            contain ?? Container(),
          ],
        ),
      );
    },
  );
}

getText(String title) {
  return Text(
    title,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: plusJakartaSansRegular,
      color: black,
      fontSize: Device.screenType == ScreenType.mobile ? 15.sp : 8.sp,
      fontWeight: FontWeight.w900,
    ),
  );
}

Future getpopup(
  BuildContext context, {
  bool istimerrunout = false,
  String? title,
  String? message,
  VoidCallback? function,
}) async {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Dialog",
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, _, __) => const SizedBox(),
    transitionBuilder: (context, anim, _, child) {
      return FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: Center(
            child: Material(
              color: transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 25,
                      color: black.withOpacity(0.2),
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    if ((title ?? '').isNotEmpty)
                      Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: plusJakartaSansBold,
                          fontSize: 18,
                          color: secondaryColor,
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Message
                    if ((message ?? '').isNotEmpty)
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: plusJakartaSansRegular,
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.grey[700],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!istimerrunout)
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: secondaryColor.withOpacity(0.6),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                Logout.cancle,
                                style: TextStyle(
                                  fontFamily: plusJakartaSansMedium,
                                  fontSize: 14,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                        if (!istimerrunout) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              function?.call();
                            },
                            child: const Text(
                              Logout.title,
                              style: TextStyle(
                                fontFamily: plusJakartaSansMedium,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
