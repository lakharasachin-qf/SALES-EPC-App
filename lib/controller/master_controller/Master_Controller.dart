import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';

void validateField({
  val,
  Rx<ValidationModel>? models, // optional
  String? errorText1,
  String? errorText2,
  String? errorText3,
  bool isotp = false,
  bool iscomman = false,
  bool isnumber = false,
  bool ispassword = false,
  bool isselectionfield = false,
  bool isEmail = false,
  bool ispincode = false,
  String? confirmpasswordctr,
  bool isconfirmpassword = false,
  bool skipEmptyCheck = false,
  String? mediumgroupvalue,
  String? rolegroupvalue,
  bool? formvalidate,
  Function()? enableBtnFunction,
  bool shouldEnableButton = true,
  required Function notifyListeners,
}) {
  // Handle radio/selection logic
  if (isselectionfield) {
    if (mediumgroupvalue == '' || rolegroupvalue == '') {
      formvalidate = false;
    } else {
      formvalidate = true;
    }
    if (shouldEnableButton && enableBtnFunction != null) {
      enableBtnFunction();
    }
    return;
  }

  // Email validation regex pattern
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  // final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]+$');

  // Only update model if it's provided
  if (models != null) {
    if (isotp) {
      if (val.isEmpty) {
        models.value = ValidationModel(val, errorText1, isValidate: false);
      } else if (val.length != 4) {
        models.value = ValidationModel(val, errorText2, isValidate: false);
      } else if (val.startsWith(' ')) {
        models.value = ValidationModel(
          val,
          "Please remove the space at the beginning.",
          isValidate: false,
        );
      } else {
        models.value = ValidationModel(val, null, isValidate: true);
      }
    } else if (iscomman) {
      if (val.isEmpty) {
        models.value = ValidationModel(val, errorText1, isValidate: false);
      } else if (val.startsWith(' ')) {
        models.value = ValidationModel(
          val,
          "Please remove the space at the beginning.",
          isValidate: false,
        );
      } else {
        models.value = ValidationModel(val, null, isValidate: true);
      }
    } else if (isEmail) {
      if (val.isEmpty) {
        models.value = ValidationModel(val, errorText1, isValidate: false);
      } else if (!val.contains('@')) {
        models.value = ValidationModel(val, errorText2, isValidate: false);
      } else if (!emailRegex.hasMatch(val)) {
        models.value = ValidationModel(val, errorText3, isValidate: false);
      } else if (val.startsWith(' ')) {
        models.value = ValidationModel(
          val,
          "Please remove the space at the beginning.",
          isValidate: false,
        );
      } else {
        models.value = ValidationModel(val, null, isValidate: true);
      }
    } else if (ispincode) {
      if (val.isEmpty) {
        models.value = ValidationModel(val, errorText1, isValidate: false);
      } else if (val.length != 6) {
        models.value = ValidationModel(val, errorText2, isValidate: false);
      } else if (val.startsWith(' ')) {
        models.value = ValidationModel(
          val,
          "Please remove the space at the beginning.",
          isValidate: false,
        );
      } else {
        models.value = ValidationModel(val, null, isValidate: true);
      }
    } else if (isnumber) {
      // Check if we should skip empty validation
      if (skipEmptyCheck) {
        // Skip empty validation if skipEmptyCheck is true
        if (val.isEmpty) {
          models.value = ValidationModel(
            val,
            null,
            isValidate: true,
          ); // Skip empty validation
        } else if (val.length != 10) {
          models.value = ValidationModel(
            val,
            errorText2,
            isValidate: false,
          ); // Length validation
        } else if (val.startsWith(' ')) {
          models.value = ValidationModel(
            val,
            "Please remove the space at the beginning.",
            isValidate: false,
          ); // Space validation
        } else {
          models.value = ValidationModel(
            val,
            null,
            isValidate: true,
          ); // If all validations pass
        }
      } else {
        // If skipEmptyCheck is false, we perform empty validation and then other checks
        if (val.isEmpty) {
          models.value = ValidationModel(
            val,
            errorText1,
            isValidate: false,
          ); // Empty validation
        } else if (val.length != 10) {
          models.value = ValidationModel(
            val,
            errorText2,
            isValidate: false,
          ); // Length validation
        } else if (val.startsWith(' ')) {
          models.value = ValidationModel(
            val,
            "Please remove the space at the beginning.",
            isValidate: false,
          ); // Space validation
        } else {
          models.value = ValidationModel(
            val,
            null,
            isValidate: true,
          ); // If all validations pass
        }
      }
    }
    //  else if (isnumber) {
    //   if (!skipEmptyCheck && val.isEmpty) {
    //     models.value = ValidationModel(val, errorText1, isValidate: false);
    //   } else if (val.length != 10) {
    //     models.value = ValidationModel(val, errorText2, isValidate: false);
    //   } else if (val.startsWith(' ')) {
    //     models.value = ValidationModel(
    //         val, "Please remove the space at the beginning.",
    //         isValidate: false);
    //   } else {
    //     models.value = ValidationModel(val, null, isValidate: true);
    //   }
    // }
    else if (ispassword) {
      if (val.isEmpty) {
        models.value = ValidationModel(val, errorText1, isValidate: false);
      } else if (val.contains(' ')) {
        models.value = ValidationModel(val, errorText2, isValidate: false);
      } else if (val.length < 8) {
        models.value = ValidationModel(val, errorText3, isValidate: false);
      }
      // else if (!passwordRegex.hasMatch(val)) {
      //   models.value = ValidationModel(
      //     val,
      //     'Must include (e.g., abc123@!).',
      //     isValidate: false,
      //   );
      // }
      else {
        models.value = ValidationModel(val, null, isValidate: true);
      }
    } else if (isconfirmpassword) {
      if (val.isEmpty) {
        models.value = ValidationModel(val, errorText1, isValidate: false);
      } else if (val.contains(' ')) {
        models.value = ValidationModel(val, errorText2, isValidate: false);
      } else if (val != confirmpasswordctr) {
        models.value = ValidationModel(val, errorText3, isValidate: false);
      }
      //  else if (!passwordRegex.hasMatch(val)) {
      //   models.value = ValidationModel(
      //     val,
      //     'Must include (e.g., abc123@!).',
      //     isValidate: false,
      //   );
      // }
      else {
        models.value = ValidationModel(val, null, isValidate: true);
      }
    } else {
      models.value = ValidationModel(val, null, isValidate: true);
    }
  }

  if (shouldEnableButton && enableBtnFunction != null) {
    enableBtnFunction();
  }

  notifyListeners();
}
