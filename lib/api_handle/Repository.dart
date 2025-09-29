import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/log.dart';

class Repository {
  static final client = http.Client();

  static Uri buildUrl(String endPoint) {
    String host = ApiUrl.buildApiUrl;
    final apiPath = host + endPoint;
    logcat("API", apiPath);
    return Uri.parse(apiPath);
  }

  static get buildHeader async {
    return {HttpHeaders.contentTypeHeader: "application/json"};
  }

  static get buildMultipartHeader async {
    return {'content-type': "multipart/form-data"};
  }

  static Future<http.Response> post(
    Map<String, dynamic> body,
    String endPoint, {
    bool? allowHeader,
  }) async {
    logcat("APIURL:::", buildUrl(endPoint));

    User? user = await UserPreferences().getSignInInfo();

    String? password = await UserPreferences().getPassword();

    if (user != null) {
      print('User email: ${user.email}');
      print('User password: $password');
    }

    Map<String, String> headers = {
      'Content-Type': "application/json",
      'X-USER-EMAIL': user?.email ?? '',
      'X-USER-PASSWORD': password ?? '',
    };

    var response = await client.post(
      buildUrl(endPoint),
      body: jsonEncode(body),
      headers: allowHeader == true ? headers : await buildHeader,
    );
    return response;
  }

  static Future<http.Response> update(
    Map<String, dynamic> body,
    String endPoint, {
    bool? allowHeader,
  }) async {
    logcat("APIURL:::", buildUrl(endPoint));

    User? user = await UserPreferences().getSignInInfo();
    String? password = await UserPreferences().getPassword();

    Map<String, String> headers = {
      'Content-Type': "application/json",
      'X-USER-EMAIL': user?.email ?? '',
      'X-USER-PASSWORD': password ?? '',
    };

    var response = await client.put(
      buildUrl(endPoint),
      body: jsonEncode(body),
      headers: allowHeader == true ? headers : await buildHeader,
    );
    return response;
  }

  static Future<http.Response> get(
    Map<String, String> body,
    String endPoint, {
    bool? allowHeader,
    bool? isToken,
  }) async {
    logcat("APIURL:::", buildUrl(endPoint));

    User? user = await UserPreferences().getSignInInfo();
    String? password = await UserPreferences().getPassword();

    Map<String, String> headers = {
      'Content-Type': "multipart/form-data",
      'X-USER-EMAIL': user?.email ?? '',
      'X-USER-PASSWORD': password ?? '',
    };

    var response = await client.get(
      buildUrl(endPoint),
      headers: allowHeader == true ? headers : await buildHeader,
    );
    return response;
  }

  static Future<http.StreamedResponse> multiPartPost(
    var body,
    String endPoint, {
    bool allowHeader = false,
    http.MultipartFile? multiPart,
    List<http.MultipartFile>? multiPartData,
  }) async {
    User? user = await UserPreferences().getSignInInfo();
    String? password = await UserPreferences().getPassword();

    Map<String, String> headers = {
      'Content-Type': "multipart/form-data",
      'X-USER-EMAIL': user?.email ?? '',
      'X-USER-PASSWORD': password ?? '',
    };

    var request = http.MultipartRequest("POST", buildUrl(endPoint));
    if (allowHeader) request.headers.addAll(headers);
    if (multiPart != null) {
      request.files.add(multiPart);
      logcat("files", request.files.length);
    }
    if (multiPartData != null) {
      request.files.addAll(multiPartData);
    }
    request.fields.addAll(body);

    var response = await request.send();

    return response;
  }
}
