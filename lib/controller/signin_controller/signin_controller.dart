import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/api_handle/apiCallingFormate.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sales_app/view/dashboard_screen/dashboardScreen.dart';
import '../master_controller/Master_Controller.dart';

class Signinscreencontroller extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();

  Rx<ScreenState> state = ScreenState.apiLoading.obs;

  late FocusNode emailNode, passNode;
  late TextEditingController emailCtr, passCtr;
  var emailModel = ValidationModel(null, null, isValidate: false).obs;
  var passModel = ValidationModel(null, null, isValidate: false).obs;

  RxBool isFormInvalidate = false.obs;
  var obsecureTextPass = true.obs;
  bool get isObsecurePassText => obsecureTextPass.value;
  set isObsecurePassText(bool value) => obsecureTextPass.value = value;

  void togglePassObscureText() {
    obsecureTextPass.value = !obsecureTextPass.value;
    update();
  }

  late final List<Widget> pageList;

  @override
  void onInit() {
    super.onInit();
    emailNode = FocusNode();
    passNode = FocusNode();

    emailCtr = TextEditingController();
    passCtr = TextEditingController();

    isFormInvalidate.value = false;
  }

  @override
  void onClose() {
    emailModel.value = ValidationModel(null, null, isValidate: false);
    passModel.value = ValidationModel(null, null, isValidate: false);
    isFormInvalidate.value = false;
    super.onClose();
  }

  unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    emailCtr.clear();
    passCtr.clear();
    emailNode.unfocus();
    passNode.unfocus();
    unfocusAll();

    emailModel.value = ValidationModel(null, null, isValidate: false);
    passModel.value = ValidationModel(null, null, isValidate: false);
    obsecureTextPass.value = true;
    isFormInvalidate.value = false;

    emailModel.refresh();
    passModel.refresh();
    isFormInvalidate.refresh();
    obsecureTextPass.refresh();

    update();
  }

  void enableSignUpButton() {
    if (emailModel.value.isValidate == false) {
      isFormInvalidate.value = false;
    } else if (passModel.value.isValidate == false) {
      isFormInvalidate.value = false;
    } else {
      isFormInvalidate.value = true;
    }
    update();
  }

  validateFields(
    val, {
    required Rx<ValidationModel> model,
    errorText1,
    errorText2,
    errorText3,
    iscomman = false,
    isemail = false,
    ispassword = false,
  }) {
    return validateField(
      val: val,
      models: model,
      isEmail: isemail,
      iscomman: iscomman,
      errorText1: errorText1,
      errorText2: errorText2,
      errorText3: errorText3,
      ispassword: ispassword,
      notifyListeners: () {
        refresh();
      },
      enableBtnFunction: () {
        enableSignUpButton();
      },
    );
  }

  RxString message = ''.obs;

  Future<void> loginAPI(context) async {
    commonPostApiCallFormate(
      context,
      title: 'Signin Screen',
      body: {
        "email": emailCtr.text.toString().trim(),
        "password": passCtr.text.toString().trim(),
      },
      apiEndPoint: ApiUrl.login,
      onResponse: (data) async {
        logcat('tag', 'data');
        LoginModel responseDetail = LoginModel.fromJson(data);
        UserPreferences().saveSignInInfo(responseDetail.user);
        UserPreferences().setPassword(passCtr.text);
        UserPreferences().setisLogin(true);
        logcat("LoginResponse::", jsonEncode(responseDetail.user));
        Get.offAll(() => DashboardScreen());
        // navigateToDashboardByRights(responseDetail.user.rights);
      },
      state: state,
      message: message,
      networkManager: networkManager,
      isModelResponse: true,
    );
  }
}
