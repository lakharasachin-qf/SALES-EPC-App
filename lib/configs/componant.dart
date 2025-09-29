import 'package:flutter/material.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sizer/sizer.dart';

void navigateAndRemove(context, widget) => Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => widget),
  (route) => false,
);

void navigateTo(context, widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));

Widget login(context) => Text(
  'Login',
  style: TextStyle(
    color: white,
    fontSize: 36.0.sp,
    fontWeight: FontWeight.w700,
  ),
);

Widget askToCreate(context) => Text(
  "Don't have an account?",
  style: TextStyle(color: black, fontSize: 14.0.sp),
);

Widget loading = SizedBox(
  width: 35.0.sp,
  height: 35.0.sp,
  child: const CircularProgressIndicator(color: Colors.orange),
);
