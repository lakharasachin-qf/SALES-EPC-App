import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/parentWidgets/CustomeParentBackground.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/assets_constant.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/configs/statusbar.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/signin_controller/signin_controller.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sizer/sizer.dart';
import 'package:sizer/sizer.dart' as sizer;

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final Signinscreencontroller ctr = Get.put(Signinscreencontroller());

  @override
  Widget build(BuildContext context) {
    Statusbar().trasparentStatusbar();
    return CustomParentScaffold(
      isExtendBodyScreen: false,
      isNormalScreen: true,
      extendedbodybehindappbar: false,
      resizeToAvoidBottomInset: true,
      onWillPop: () {
        return Future.value(false);
      },
      onTap: () {
        hideKeyboard(context);
      },
      body: SizedBox(
        height: Device.height,
        width: Device.width,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 3.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 23.h,
                  width: 23.h,
                  child: Image.asset(
                    Asset.logoPng,
                    height: Device.height,
                    width: Device.width,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: black.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Column(
                    children: [
                      /// Email
                      Obx(() {
                        return getTextField(
                          context: context,
                          wantLabel: true,
                          isRequired: true,
                          label: 'Email',
                          hint: SigninScreenConst.emailAddressHint,
                          node: ctr.emailNode,
                          ctr: ctr.emailCtr,
                          model: ctr.emailModel.value,
                          function: (val) {
                            ctr.validateFields(
                              val,
                              isemail: true,
                              model: ctr.emailModel,
                              errorText1: SigninScreenConst.enterEmail,
                              errorText2: SigninScreenConst.emailcontain,
                              errorText3: SigninScreenConst.invalidEmailFormat,
                            );
                          },
                        );
                      }),
                      getDynamicSizedBox(height: 1.h),
                      Obx(() {
                        return getTextField(
                          context: context,
                          wantLabel: true,
                          label: 'Password',
                          hint: SigninScreenConst.passwordHint,
                          ctr: ctr.passCtr,
                          node: ctr.passNode,
                          model: ctr.passModel.value,
                          isRequired: true,
                          function: (val) {
                            ctr.validateFields(
                              val,
                              ispassword: true,
                              model: ctr.passModel,
                              errorText1: SigninScreenConst.errorPasswordHint,
                              errorText2: SigninScreenConst.hintSpaceNotAllowed,
                              errorText3: SigninScreenConst.validPasswordHint,
                            );
                          },
                          isNumeric: false,
                          wantsuffix: true,
                          ispass: true,
                          isobscure: ctr.isObsecurePassText,
                          obscureFunction: () {
                            ctr.togglePassObscureText();
                          },
                        );
                      }),
                      getDynamicSizedBox(height: 3.h),
                      Obx(() {
                        return getFormButton(
                          context,
                          () {
                            if (ctr.isFormInvalidate.value == true) {
                              ctr.loginAPI(context);
                            }
                          },
                          Button.login,
                          validate: ctr.isFormInvalidate.value,
                        );
                      }),
                      getDynamicSizedBox(height: 2.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
