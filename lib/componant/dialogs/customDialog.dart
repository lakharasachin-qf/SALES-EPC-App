import 'package:flutter/cupertino.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/font_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sizer/sizer.dart' as sizer;

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
                fontFamily: plusJakartaSansMedium,
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
                  onClick();
                  Navigator.pop(context);
                  // if (isFromPayment != true) {
                  //   UserPreferences().logout();
                  //   Get.offAll(const LoginScreen());
                  // }
                },
                isDefaultAction: true,
                isDestructiveAction: true,
                child: Text(
                  Logout.yes,
                  style: TextStyle(
                    fontSize: 15,
                    color: black,
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
