import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'Repository.dart';

commonPostApiCallFormate(
  context, {
  String? title,
  Map<String, dynamic>? body,
  required Function(Map<String, dynamic>) onResponse,
  String? apiEndPoint,
  bool? allowHeader,
  InternetController? networkManager,
  Function? apisLoading,
  bool? isModelResponse = false,
  bool? isGetBackEnable = false,
  bool? isFromMultiBackEnable = false,
  bool? isFromSocialLogin = false,
  Rx<ScreenState>? state,
  RxString? message,
  Function? onClick,
  isShowDialog = true,
}) async {
  var loadingIndicator = LoadingProgressDialog();

  try {
    if (networkManager!.connectionType.value == 0) {
      loadingIndicator.hide(context);
      showDialogForScreen(
        context,
        title!,
        Connection.noConnection,
        callback: () {
          Get.back();
        },
      );
      return;
    }

    if (apisLoading != null) {
      state?.value = ScreenState.apiLoading;
      apisLoading(true);
    } else {
      loadingIndicator.show(context, '');
    }

    var response = await Repository.post(
      body!,
      apiEndPoint!,
      allowHeader: allowHeader,
    );

    if (apisLoading != null) {
      state?.value = ScreenState.apiSuccess;
      apisLoading(false);
    } else {
      loadingIndicator.hide(context);
    }

    var data = jsonDecode(response.body);
    logcat("RESPONSE ::::::", data);
    logcat("response.statusCode ::::::", response.statusCode);

    if (response.statusCode == 200) {
      logcat("RESPONSE::STATUS", 200);
      message?.value = '';
      if (data['status'] == 'success' || true) {
        if (isModelResponse == true) {
          onResponse(data);
        } else {
          showDialogForScreen(
            context,
            title!,
            data['message'],
            callback: () {
              onResponse(data);
            },
          );
        }
      }
    } else {
      print('common post api else case');
      state?.value = ScreenState.apiError;
      message?.value = APIResponseHandleText.serverError;

      showDialogForScreen(
        context,
        title ?? 'Error',
        data['message']?.toString() ??
            data['errors']?.values.first[0]?.toString() ??
            'Server error',
        callback: () {
          if (onClick != null) {
            onClick();
            return;
          }

          getUnauthenticatedUser(
            context,
            data['message']?.toString() ??
                data['errors']?.values.first[0]?.toString() ??
                'Unauthenticated user',
            "Unauthenticated user",
          );
        },
      );
    }
  } catch (e) {
    print('common post api catch case');
    state?.value = ScreenState.apiError;
    logcat("Exception", e);

    if (e is TimeoutException) {
      if (isShowDialog == true) {
        showDialogForScreen(
          context,
          title!,
          "Request timed out. Please try again.",
          callback: () {},
        );
      }
    } else {
      // if (isShowDialog == true) {
      //   showDialogForScreen(
      //     context,
      //     title ?? 'Error',
      //     Connection.servererror,
      //     callback: () {},
      //   );
      // }
    }

    if (apisLoading != null) {
      apisLoading(false);
    } else {
      loadingIndicator.hide(context);
    }
  }
}

void commonGetApiCallFormate(
  context, {
  String? title,
  required Function(Map<String, dynamic>) onResponse,
  String? apiEndPoint,
  bool? allowHeader,
  Function? apisLoading,
  InternetController? networkManager,
  bool? isFromPartyList,
  Rx<ScreenState>? state,
  RxString? message,
  isShowDialog = true,
}) async {
  try {
    if (apisLoading != null) apisLoading(true);
    state?.value = ScreenState.apiLoading;

    if (networkManager!.connectionType.value == 0) {
      if (apisLoading != null) apisLoading(false);
      showDialogForScreen(
        context,
        title!,
        Connection.noConnection,
        callback: () {
          Get.back();
        },
      );
      return;
    }

    var response = await Repository.get({}, apiEndPoint!, allowHeader: true);

    if (apisLoading != null) apisLoading(false);

    var responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      state?.value = ScreenState.apiSuccess;
      message?.value = '';

      if (responseData['status']?.toString().toLowerCase() == 'success') {
        onResponse(responseData);
        print('common get api if case');
      } else {
        message?.value = responseData['message'];
        showDialogForScreen(
          context,
          title!,
          responseData['message'],
          callback: () {},
        );
      }
    } else {
      print('common get api else case');
      state?.value = ScreenState.apiError;
      message?.value = APIResponseHandleText.serverError;
      getUnauthenticatedUser(
        context,
        responseData['message'] ?? '',
        "Unauthenticated user",
      );
    }
  } catch (e) {
    print('common get api catch block');
    state?.value = ScreenState.apiError;
    logcat("Exception", e);

    if (isShowDialog == true) {
      showDialogForScreen(
        context,
        title ?? "Error",
        e.toString(),
        callback: () {},
      );
    }

    if (apisLoading != null) apisLoading(false);
  }
}
  // on http.ClientException catch (e) {
  //   print('common get api client exception case');
  //   logcat("ClientException", e.toString());
  //   state?.value = ScreenState.apiError;

  //   if (isShowDialog == true) {
  //     showDialogForScreen(
  //       context,
  //       title!,
  //       "Connection error. Please try again.",
  //       callback: () {},
  //     );
  //   }
  // } catch (e) {
  //   print('common get api catch case');
  //   state?.value = ScreenState.apiError;
  //   if (apisLoading != null) apisLoading(false);
  //   logcat('Exception', e);
  // }

