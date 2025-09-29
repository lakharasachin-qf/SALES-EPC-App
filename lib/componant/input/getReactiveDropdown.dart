import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:sales_app/componant/input/style.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sizer/sizer.dart';

Widget getReactiveDropdown({
  required String hint,
  required List<String> items,
  required String? selectedValue,
  required Function(String?) onChanged,
}) {
  return DropdownButtonHideUnderline(
    child: DropdownButton2(
      isExpanded: true,
      hint: Text(hint, style: styleTextHintFieldLabel()),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Device.screenType == ScreenType.mobile
                  ? Text(item, style: styleTextFormFieldText())
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 10,
                        left: 10,
                      ),
                      child: Text(item, style: styleTextFormFieldText()),
                    ),
            ),
          )
          .toList(),
      value: selectedValue,
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.only(
          left: Device.screenType == ScreenType.mobile ? 0.0 : 2.0.w,
          right: Device.screenType == ScreenType.mobile ? 3.w : 2.0.w,
          top: Device.screenType == ScreenType.mobile ? 4.5 : 1.2.w,
          bottom: Device.screenType == ScreenType.mobile ? 4.5 : 1.2.w,
        ),
        decoration: BoxDecoration(
          color: inputBgColor,
          borderRadius: BorderRadius.circular(
            Device.screenType == ScreenType.mobile ? 10 : 50,
          ),
          border: Border.all(color: inputBorderColor, width: 1.5),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: Device.screenType == ScreenType.mobile
            ? Device.height / 1.8
            : Device.height / 1,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(2.h),
          boxShadow: [
            BoxShadow(
              color: grey.withOpacity(0.2),
              blurRadius: 10.0,
              offset: const Offset(0, 1),
              spreadRadius: 3.0,
            ),
          ],
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: Device.screenType == ScreenType.mobile ? 40 : 60,
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: Device.screenType == ScreenType.mobile ? 30 : 40,
          color: black.withOpacity(0.2),
        ),
      ),
    ),
  );
}
