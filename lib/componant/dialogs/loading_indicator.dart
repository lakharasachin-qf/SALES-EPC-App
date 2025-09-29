import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/utils/log.dart';

import 'package:sizer/sizer.dart';

class LoadingProgressDialog {
  show(BuildContext buildContext, message) {
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      barrierColor: black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                color: white,
              ),
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: LoadingAnimationWidget.discreteCircle(
                      color: primaryColor,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  hide(BuildContext context) async {
    Navigator.pop(context);
  }
}

class LoadingProgressDialogs {
  final GlobalKey<State> _key = GlobalKey<State>();
  OverlayEntry? _overlayEntry;

  show(BuildContext context, message) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            logcat("BEEEEPPP", 'DONEEEE');
            hide(context);
            Navigator.pop(context);
            return true; // Allow navigation back
          },
          child: Container(
            height: Device.height,
            width: Device.width,
            color: black.withOpacity(0.3),
            child: Center(
              child: Material(
                color: transparent,
                child: Container(
                  key: _key,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: white,
                          ),
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(10),
                          child: LoadingAnimationWidget.discreteCircle(
                            color: primaryColor,
                            size: 35,
                          ),
                        ),
                      ),
                      Text(message),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  hide(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

apiResponseLoader(bool isVisible) {
  return isVisible == true
      ? Center(
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
        )
      : Container();
}
