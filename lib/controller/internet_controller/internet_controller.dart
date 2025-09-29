import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sales_app/utils/log.dart';

class InternetController extends GetxController {
  var connectivityResult = ConnectivityResult.none.obs;
  var connectionType = 0.obs;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;
  Function? statusChange;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _streamSubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateState(
        results.isNotEmpty ? results.first : ConnectivityResult.none,
      );
    });
  }

  void setStatusCallback(Function? fun) {
    statusChange = fun;
  }

  Future<void> _initConnectivity() async {
    try {
      List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      connectivityResult.value = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      logcat("Result", connectivityResult.value.toString());
    } on PlatformException catch (e) {
      logcat("EXCEPTION:", e);
    }
  }

  void _updateState(ConnectivityResult result) {
    connectivityResult.value = result;
    switch (result) {
      case ConnectivityResult.wifi:
        connectionType.value = 1;
        break;
      case ConnectivityResult.mobile:
        connectionType.value = 2;
        break;
      case ConnectivityResult.ethernet:
        connectionType.value = 3;
        break;

      case ConnectivityResult.vpn:
        connectionType.value = 4;
        break;

      case ConnectivityResult.none:
        connectionType.value = 0;
        break;
      default:
        break;
    }
    statusChange?.call();
    logcat("Network::", connectionType.value.toString());
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    super.onClose();
  }
}

// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
// import 'package:science_cafe/utils/log.dart';

// class InternetProvider extends ChangeNotifier {
//   ConnectivityResult _connectivityResult = ConnectivityResult.none;
//   int _connectionType = 0;
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription _streamSubscription;
//   Function? _statusChange;

//   InternetProvider() {
//     _initConnectivity();
//     _streamSubscription = _connectivity.onConnectivityChanged.listen(
//       (List<ConnectivityResult> results) {
//         _updateState(
//             results.isNotEmpty ? results.first : ConnectivityResult.none);
//       },
//     );
//   }

//   ConnectivityResult get connectivityResult => _connectivityResult;
//   int get connectionType => _connectionType;

//   void setStatusCallback(Function? fun) {
//     _statusChange = fun;
//     notifyListeners();
//   }

//   Future<void> _initConnectivity() async {
//     try {
//       List<ConnectivityResult> results =
//           await _connectivity.checkConnectivity();
//       _connectivityResult =
//           results.isNotEmpty ? results.first : ConnectivityResult.none;
//       logcat("Result", _connectivityResult.toString());
//       notifyListeners();
//     } on PlatformException catch (e) {
//       logcat("EXCEPTION:", e);
//     }
//   }

//   void _updateState(ConnectivityResult result) {
//     _connectivityResult = result;
//     switch (result) {
//       case ConnectivityResult.wifi:
//         _connectionType = 1;
//         break;
//       case ConnectivityResult.mobile:
//         _connectionType = 2;
//         break;
//       case ConnectivityResult.ethernet:
//         _connectionType = 3;
//         break;
//       case ConnectivityResult.none:
//         _connectionType = 0;
//         break;
//       default:
//         break;
//     }
//     _statusChange?.call();
//     logcat("Network::", _connectionType.toString());
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     _streamSubscription.cancel();
//     super.dispose();
//   }
// }
