import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sales_app/componant/input/style.dart';
import 'package:sales_app/configs/colors_constant.dart';
import '../../configs/assets_constant.dart';
import 'package:sizer/sizer.dart';

enum FieldType { email, mobile, text, dropDownl, countryCode, search }

// ignore: must_be_immutable
class CustomFormField extends StatefulWidget {
  CustomFormField({
    super.key,
    required this.hintText,
    required this.errorText,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    required this.inputType,
    required this.node,
    this.controller,
    this.formType,
    this.isVerified,
    this.wantSuffix,
    this.isDropdown,
    this.isdown,
    this.isAdd,
    this.isStarting,
    this.isCalender,
    this.onVerifiyButtonClick,
    this.isDataValidated,
    this.onTap,
    this.onPrefixTap,
    this.isReport,
    this.isMick,
    this.isReadOnly,
    this.isPassword,
    this.onAddBtn,
    this.isVisible = true,
    this.isWhite = false,
    this.isAddressField = false,
    this.isReferenceField = false,
    this.isFromAddStory = false,
    this.isEnable = true,
    this.isCamera = false,
    this.isClose = false,
    this.fetchLocation,
    this.index,
    this.isGst,
    this.onSave,
    this.isBorderSideEnable = true,
    this.obsecuretext = false,
    this.fromObsecureText,
    this.obscureFunction,
  });

  final TextEditingController? controller;
  final String? index;
  final String hintText;
  final String? fromObsecureText;
  final FieldType? formType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final FocusNode node;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType inputType;

  final Function? onVerifiyButtonClick;
  final bool? wantSuffix;
  final bool? isDropdown;
  final bool? isdown;
  final bool? isAdd;
  final bool? isCalender;
  final bool? isStarting;
  final bool? isDataValidated;
  final bool? isPassword;
  final bool? isReport;
  final bool? isMick;
  final bool? isClose;
  final bool? isCamera;

  final Function? onTap;
  final Function? onPrefixTap;
  final Function? onAddBtn;
  final Function? onSave;
  bool isEnable = true;
  bool isFromAddStory = false;
  bool isAddressField = false;
  bool isReferenceField = false;

  bool isVisible = true;
  bool? isGst = false;
  final bool? isReadOnly;
  final bool? isWhite;
  final bool? fetchLocation;
  bool isBorderSideEnable = true;
  bool obsecuretext = false;
  final Function? obscureFunction;

  bool? isVerified = false;

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.isEnable,
      readOnly: widget.isCalender == true || widget.isReadOnly == true
          ? true
          : false,
      cursorColor: primaryColor,
      obscureText: widget.obsecuretext,
      obscuringCharacter: '*',
      onTap: () {
        if (widget.onTap != null) widget.onTap!();
      },
      onSaved: (val) {
        widget.onSave!(val);
      },
      textCapitalization: widget.isReferenceField
          ? TextCapitalization.characters
          : TextCapitalization.none,
      minLines: widget.isAddressField ? 4 : 1,
      maxLines: widget.isAddressField ? 7 : 1,
      textInputAction: widget.isAddressField
          ? TextInputAction.newline
          : TextInputAction.next,
      keyboardType: widget.inputType,
      validator: widget.validator,
      controller: widget.controller,
      textAlignVertical: widget.isAddressField
          ? TextAlignVertical.bottom
          : null,
      maxLength: widget.inputType == TextInputType.number
          ? 20
          : widget.isReferenceField
          ? 6
          : widget.isGst == true
          ? 20
          : null,
      style: widget.isVerified != null && widget.isVerified!
          ? styleTextFormFieldTextGrey()
          : styleTextFormFieldText(isWhite: widget.isWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBgColor,
        labelStyle: styleTextForFieldLabel(widget.node),
        contentPadding: EdgeInsets.only(
          left:
              widget.formType != null &&
                  widget.formType == FieldType.countryCode
              ? 2.w
              : 4.w,
          right:
              widget.formType != null &&
                  widget.formType == FieldType.countryCode
              ? 2.w
              : 4.w,
          top: Device.screenType == ScreenType.mobile ? 1.8.h : 2.5.w,
          bottom: Device.screenType == ScreenType.mobile ? 1.8.h : 2.5.w,
        ),
        hintText: widget.hintText,
        errorText: widget.errorText,
        errorStyle: styleTextForErrorFieldHint(),
        hintStyle: styleTextHintFieldLabel(isWhite: widget.isWhite),
        border: widget.isBorderSideEnable
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Device.screenType == ScreenType.mobile ? 10 : 50,
                ),
                borderSide: const BorderSide(
                  color: inputBorderColor,
                  width: 1.5,
                ),
              )
            : InputBorder.none,
        disabledBorder: widget.isBorderSideEnable
            ? OutlineInputBorder(
                borderSide: const BorderSide(
                  color: inputBorderColor,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(
                  Device.screenType == ScreenType.mobile ? 10 : 50,
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Device.screenType == ScreenType.mobile ? 10 : 50,
                ),
                borderSide: BorderSide.none,
              ),
        counterText: '',
        enabledBorder: widget.isBorderSideEnable
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Device.screenType == ScreenType.mobile ? 10 : 50,
                ),
                borderSide: const BorderSide(color: inputBorderColor),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Device.screenType == ScreenType.mobile ? 10 : 50,
                ),
                borderSide: BorderSide.none, // No border
              ),
        // prefixStyle: styleTextFormFieldText(),
        prefixIcon:
            widget.formType != null && widget.formType == FieldType.countryCode
            ? Container(
                padding: EdgeInsets.only(
                  left: Device.screenType == ScreenType.mobile ? 12 : 3.3.w,
                  bottom: 3,
                  right: Device.screenType == ScreenType.mobile ? 3 : 1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text("+", style: styleTextFormFieldText())],
                ),
              )
            : widget.formType != null && widget.formType == FieldType.search
            ? Container(
                padding: EdgeInsets.only(
                  left: Device.screenType == ScreenType.mobile ? 12 : 3.3.w,
                  bottom: 3,
                  right: Device.screenType == ScreenType.mobile ? 3 : 1,
                ),
                child: Icon(Icons.search),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minHeight: 25,
          maxHeight: 30,
        ),
        suffixIcon: widget.wantSuffix == true
            ? widget.isDropdown == true
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          alignment: Alignment.centerRight,
                          onPressed: () {
                            if (widget.onTap != null) widget.onTap!();
                          },
                          padding: EdgeInsets.only(
                            left: widget.isAdd == true
                                ? Device.screenType == ScreenType.mobile
                                      ? 5.w
                                      : 0.w
                                : 0,
                            right: widget.isAdd == false ? 3.w : 0.0,
                          ),
                          icon: SvgPicture.asset(
                            Asset.dropdown,
                            height: Device.screenType == ScreenType.mobile
                                ? 30
                                : 50,
                            width: Device.screenType == ScreenType.mobile
                                ? 30
                                : 50,
                            fit: BoxFit.scaleDown,
                          ),
                          color: black.withOpacity(0.2),
                        ),
                        widget.isAdd == true
                            ? SizedBox(
                                width: 10.w,
                                child: IconButton(
                                  onPressed: () {
                                    if (widget.obscureFunction != null) {
                                      widget.obscureFunction!();
                                    }
                                  },
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 3.w),
                                  icon: Container(
                                    height:
                                        Device.screenType == ScreenType.mobile
                                        ? 20
                                        : 30,
                                    decoration: BoxDecoration(
                                      color: black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.add, color: white),
                                  ),
                                  iconSize:
                                      Device.screenType == ScreenType.mobile
                                      ? 20
                                      : 30,
                                  color: black,
                                ),
                              )
                            : Container(),
                      ],
                    )
                  : widget.isCamera == true
                  ? GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) widget.onTap!();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: Device.screenType == ScreenType.mobile
                              ? 20.sp
                              : 18.sp,
                        ),
                      ),
                    )
                  : widget.isCalender == true
                  ? GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) widget.onTap!();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          size: Device.screenType == ScreenType.mobile
                              ? 25
                              : 35,
                        ),
                      ),
                    )
                  : widget.isPassword == true
                  ? GestureDetector(
                      onTap: () {
                        // logcat("isTap",
                        //     widget.fromObsecureText.toString());
                        if (widget.obscureFunction != null) {
                          widget.obscureFunction!();
                          // print('call');
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          widget.obsecuretext
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: grey,
                          size: Device.screenType == ScreenType.mobile
                              ? 20.sp
                              : 15.sp,
                        ),
                      ),
                    )
                  : widget.isAdd == true
                  ? GestureDetector(
                      onTap: () {
                        if (widget.onAddBtn != null) {
                          widget.onAddBtn!();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          Icons.add,
                          size: Device.screenType == ScreenType.mobile
                              ? 20.sp
                              : 15.sp,
                          color: black,
                        ),
                      ),
                    )
                  : widget.isdown == true
                  ? GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: Device.screenType == ScreenType.mobile
                              ? 30
                              : 40,
                          color: black.withOpacity(0.2),
                        ),
                      ),
                    )
                  : widget.isMick == true
                  ? GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          Icons.mic,
                          size: Device.screenType == ScreenType.mobile
                              ? 30
                              : 40,
                          color: black,
                        ),
                      ),
                    )
                  : widget.isClose == true
                  ? GestureDetector(
                      onTap: () {
                        if (widget.onPrefixTap != null) {
                          widget.onPrefixTap!();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          Icons.close,
                          size: Device.screenType == ScreenType.mobile
                              ? 20.sp
                              : 30.sp,
                          color: black,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Device.screenType == ScreenType.mobile
                              ? 0.w
                              : 3.w,
                        ),
                        child: Icon(
                          Icons.photo_size_select_actual_outlined,
                          size: Device.screenType == ScreenType.mobile
                              ? 20.sp
                              : 15.sp,
                        ),
                      ),
                    )
            : Container(width: 1),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Device.screenType == ScreenType.mobile ? 10 : 50,
          ),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Device.screenType == ScreenType.mobile ? 10 : 50,
          ),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Device.screenType == ScreenType.mobile ? 10 : 50,
          ),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
    );
  }
}
