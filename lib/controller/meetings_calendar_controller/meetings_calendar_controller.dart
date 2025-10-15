import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:intl/intl.dart';
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/dialogs/loading_indicator.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/controller/master_controller/Master_Controller.dart';
import 'package:sales_app/models/MeetingCalendarModel.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';
import '../../api_handle/Repository.dart';
import '../../models/fillter_model.dart' hide Result;

class MeetingsCalendarController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiLoading.obs;
  RxString message = ''.obs;
  RxBool isTextEmpty = false.obs;

  void clearSearch() {
    searchCtr.clear();
    filteredMeetingsList.assignAll(meetingsList);
    isTextEmpty.value = false;
    update();
  }

  late TextEditingController statusCtr, searchCtr, dateCtr, reasonCtr, notesCtr;

  late FocusNode statusNode, dateNode, searchNode, reasonNode, notesNode;

  var statusModel = ValidationModel(null, null, isValidate: false).obs;
  var dateModel = ValidationModel(null, null, isValidate: false).obs;
  var reasonModel = ValidationModel(null, null, isValidate: false).obs;
  var notesModel = ValidationModel(null, null, isValidate: false).obs;

  RxBool isStartDateActive = true.obs;
  RxBool isStartDateSelected = false.obs;
  RxBool isDistrictSelected = false.obs;
  RxBool isClusterSelected = false.obs;
  RxList<Category> districtList = <Category>[].obs;
  RxList<Category> clustersList = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();

    statusCtr = TextEditingController();
    dateCtr = TextEditingController();
    reasonCtr = TextEditingController();
    notesCtr = TextEditingController();
    searchCtr = TextEditingController();

    statusNode = FocusNode();
    dateNode = FocusNode();
    reasonNode = FocusNode();
    notesNode = FocusNode();
    searchNode = FocusNode();

    searchCtr.addListener(() {
      filterMeetings(searchCtr.text);
    });
  }

  @override
  void onClose() {
    statusCtr.dispose();
    dateCtr.dispose();
    reasonCtr.dispose();
    notesCtr.dispose();
    searchCtr.dispose();

    statusNode.dispose();
    dateNode.dispose();
    reasonNode.dispose();
    notesNode.dispose();
    searchNode.dispose();

    super.onClose();
  }

  void unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void resetForm() {
    unfocusAll();
    update();
  }

  RxList<MeetingData> meetingsList = <MeetingData>[].obs;
  RxList<MeetingData> filteredMeetingsList = <MeetingData>[].obs;
  RxString nextPageURL = "".obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt fromItem = 0.obs;
  final RxInt toItem = 0.obs;

  var isCustomerLoading = false.obs;

  Future<void> getMeetingsListApi({
    required BuildContext context,
    int page = 1,
    bool? hideLoading,
    bool isApplyFilter = false,
    bool isInitialLoad = false,
  }) async {
    User? userData = await UserPreferences().getSignInInfo();

    if (hideLoading == false) {
      state.value = ScreenState.apiLoading;
    }
    if (isInitialLoad == true) {
      isCustomerLoading(true);
    }

    if (isInitialLoad && !isApplyFilter) {
      resetForm();
    }

    try {
      if (networkManager.connectionType.value == 0) {
        if (isInitialLoad == true) {
          isCustomerLoading(false);
        }
        showDialogForScreen(
          context,
          'Meetings Calendar Screen',
          Connection.noConnection,
          callback: Get.back,
        );
        return;
      }

      final apiUrl =
          "${ApiUrl.getMeetingsCalendarList}?user_id=${userData?.userId ?? 1}&page=$page&per_page=10";

      // ✅ Build query string dynamically
      // final queryString = buildCustomerQuery(userData: userData!, page: page);
      // final apiUrl = "${ApiUrl.getMeetingsCalendarList}?$queryString";

      logcat("MeetingsCalendarURL:", apiUrl);

      final response = await Repository.get({}, apiUrl, allowHeader: true);

      isCustomerLoading(false);
      if (isInitialLoad == true) {
        isCustomerLoading(false);
      }
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == "success") {
          state.value = ScreenState.apiSuccess;
          message.value = '';
          final model = MeetingCalendarModel.fromJson(responseData);
          meetingsList.clear();
          filteredMeetingsList.clear();
          if (model.result!.data!.isNotEmpty) {
            meetingsList.addAll(model.result!.data!);
            filteredMeetingsList.addAll(meetingsList);
            meetingsList.refresh();
            filteredMeetingsList.refresh();
            currentPage.value = model.result!.pagination!.page!;
            lastPage.value = model.result!.pagination!.lastPage!;
            totalItems.value = model.result!.pagination!.total!;
            const int perPage = 10;
            fromItem.value = (currentPage.value - 1) * perPage + 1;
            toItem.value = currentPage.value * perPage > totalItems.value
                ? totalItems.value
                : currentPage.value * perPage;
          } else {
            currentPage.value = 1;
            lastPage.value = 1;
            totalItems.value = 0;
            fromItem.value = 0;
            toItem.value = 0;
          }
        } else {
          message.value = responseData['message'];
          showDialogForScreen(
            context,
            'Meetings Calendar Screen',
            responseData['message'],
            callback: Get.back,
          );
        }
      } else {
        state.value = ScreenState.apiError;
        message.value = APIResponseHandleText.serverError;
        showDialogForScreen(
          context,
          'Meetings Calendar Screen',
          responseData['message'] ?? ServerError.servererror,
          callback: () {
            getUnauthenticatedUser(
              context,
              responseData['message'],
              "Unauthenticated user",
            );
          },
        );
      }
    } catch (e) {
      logcat("Exception", e);
      if (isInitialLoad == true) {
        isCustomerLoading(false);
      }
      state.value = ScreenState.apiError;
    }
  }

  String buildCustomerQuery({required User userData, required int page}) {
    final queryParams = <String>[];

    queryParams.add('user_id=${userData.userId}');
    queryParams.add('page=$page');
    queryParams.add('per_page=10');

    return queryParams.join('&');
  }

  final RxList<String> customerHeaders = <String>[
    "Sr No.",
    "Lead Id",
    "Contact Person",
    "Latest Appointment",
    "Status",
    "Action",
  ].obs;

  // "Contacted",

  // Provide all customer data without pagination
  List<List<String?>> get meetingsData {
    if (filteredMeetingsList.isEmpty) return [];

    return filteredMeetingsList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;
      final formattedLiveAt = e.scheduledAt!.isNotEmpty
          ? DateFormat('dd-MM-yyyy').format(DateTime.parse(e.scheduledAt!))
          : '';

      return [
        index.toString(),
        e.leadId.toString(),
        e.contactPersonName,
        formattedLiveAt,
        e.meetingStatus!.toString().capitalize,
        "",
      ];
    }).toList();
  }

  void filterMeetings(String query) {
    logcat("filterMeetings::", query.toString());
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      filteredMeetingsList.assignAll(meetingsList);
      isTextEmpty.value = false;
      return;
    }
    logcat("filter::", query.toString());

    filteredMeetingsList.assignAll(
      meetingsList.where((lead) {
        final formattedLiveAt = lead.scheduledAt!.isNotEmpty
            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(lead.scheduledAt!))
            : '';

        logcat("meetingStatus::", lead.meetingStatus!.toLowerCase().toString());
        final values = [
          lead.leadId.toString(),
          lead.contactPersonName,
          formattedLiveAt,
          lead.meetingStatus!.toLowerCase().toString(),
        ];
        return values.any((value) => value!.toLowerCase().contains(lowerQuery));
      }).toList(),
    );

    logcat("filterResponse::", jsonEncode(filteredMeetingsList));
    isTextEmpty.value = true;
  }

  void resetFilterFields() {
    statusCtr.clear();
    dateCtr.clear();
    reasonCtr.clear();
    notesCtr.clear();

    selectStatus.value = 'Select Status';

    statusModel.value = ValidationModel(null, null, isValidate: false);
    dateModel.value = ValidationModel(null, null, isValidate: false);
    reasonModel.value = ValidationModel(null, null, isValidate: false);
    notesModel.value = ValidationModel(null, null, isValidate: false);

    isStartDateActive.value = true;
    isStartDateSelected.value = false;
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isEditMeetingEnable.value = false;
  }

  void updateMeetings(context, MeetingData meetingsData) async {
    resetFilterFields();
    openBottomtsheetDialog(
      context,
      title: "Edit Meeting",
      widget: updateMeetingsWidget(context, meetingsData),
    );
  }

  RxBool isEditMeetingEnable = false.obs;

  void validateFields(
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
        enableSubmitButton();
      },
    );
  }

  void enableSubmitButton() {
    isEditMeetingEnable.value =
        statusModel.value.isValidate &&
        dateModel.value.isValidate &&
        reasonModel.value.isValidate;
    update();
  }

  final List<String> status = ['Select Status', 'Reschedule'];
  RxString selectStatus = 'Select Status'.obs;

  Widget updateMeetingsWidget(context, MeetingData meetingsData) {
    if (meetingsData.scheduledAt != null) {
      dateCtr.text = formatMeetingDate(meetingsData.scheduledAt);
      validateFields(
        meetingsData.scheduledAt,
        model: dateModel,
        iscomman: true,
        errorText1: "",
      );
    } else {
      dateCtr.clear();
    }

    if (meetingsData.meetingNotes != null &&
        meetingsData.meetingNotes.toString().isNotEmpty) {
      notesCtr.text = meetingsData.meetingNotes!;
    } else {
      notesCtr.clear();
    }

    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.5.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getDynamicSizedBox(height: 1.h),
          getLable("Status", isRequired: true),
          Obx(
            () => getReactiveDropdown(
              hint: "Select Status",
              items: status,
              selectedValue: selectStatus.value,
              onChanged: (value) {
                selectStatus.value = value!;
                update();
                validateFields(
                  selectStatus.value,
                  model: statusModel,
                  iscomman: true,
                  errorText1: 'Please selecte status',
                );
              },
            ),
          ),
          getDynamicSizedBox(height: 1.h),
          Obx(() {
            if (selectStatus.value.toLowerCase() == 'reschedule') {
              return Column(
                children: [
                  getTextField(
                    context: context,
                    wantLabel: true,
                    label: 'New Date',
                    ctr: dateCtr,
                    node: dateNode,
                    model: dateModel.value,
                    isRequired: true,
                    isenable: false,
                    usegesture: true,
                    isdate: true,
                    wantsuffix: true,
                    gestureFunction: () async {
                      dateCtr.text = formatMeetingDate(
                        meetingsData.scheduledAt,
                      );
                      startDate.value = dateCtr.text;
                      openDatePicker(
                        context: context,
                        title: 'Select New Date',
                        controller: dateCtr,
                        dateRx: startDate,
                        model: dateModel,
                      );
                    },
                    hint: 'Select Date',
                  ),
                  getDynamicSizedBox(height: 1.h),
                  getTextField(
                    context: context,
                    wantLabel: true,
                    label: 'Reason',
                    ctr: reasonCtr,
                    node: reasonNode,
                    model: reasonModel.value,
                    hint: 'Enter Reason',
                    function: (val) {
                      validateFields(
                        val,
                        model: reasonModel,
                        iscomman: true,
                        errorText1: 'Please Enter Reason',
                      );
                    },
                    isRequired: true,
                  ),
                  getDynamicSizedBox(height: 1.h),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          }),

          Obx(() {
            return getTextField(
              context: context,
              wantLabel: true,
              label: 'Notes',
              ctr: notesCtr,
              node: notesNode,
              model: notesModel.value,
              hint: 'Enter Notes',
              isMultipline: true,
              function: (val) {},
              isRequired: false,
            );
          }),

          getDynamicSizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: getFormButton(
                  context,
                  () {
                    Get.back();
                    isEditMeetingEnable.value = false;
                  },
                  'Cancel',
                  validate: true,
                ),
              ),
              getDynamicSizedBox(width: 3.w),
              Expanded(
                child: Obx(() {
                  return getFormButton(
                    context,
                    () {
                      if (isEditMeetingEnable.value == true) {
                        updateMeetingApi(
                          context,
                          meetingId: meetingsData.id!,
                          status: selectStatus.value.toLowerCase(),
                          newScheduledAt: dateCtr.text,
                          reason: reasonCtr.text,
                          notes: notesCtr.text,
                        );
                      }
                    },
                    "Update",
                    validate: isEditMeetingEnable.value,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  final displayFormat = DateFormat('dd-MM-yyyy hh:mm a');

  DateTime? selectedDateTime;
  final RxString startDate = ''.obs;
  void openDatePicker({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required RxString dateRx,
    required Rx<ValidationModel> model,
    bool showTimePickers = true,
    bool isEndDate = false, // Added to identify end date picker
  }) {
    showCommonDatePicker(
      context: context,
      title: title,
      disablePastDates: true,
      initialDate: dateRx.value.isNotEmpty
          ? displayFormat.parse(dateRx.value)
          : (controller.text.isNotEmpty
                ? displayFormat.parse(controller.text)
                : DateTime.now()),
      minDate: startDate.value.isNotEmpty
          ? displayFormat.parse(startDate.value)
          : null,
      showTimePickers: showTimePickers,
      onDatePicked: (DateTime date) {
        final formatted = displayFormat.format(date);
        dateRx.value = formatted;
        controller.text = formatted;
        validateFields(
          dateCtr.text,
          model: dateModel,
          iscomman: true,
          errorText1: 'Please select date',
        );
      },
    );
  }

  Future<void> updateMeetingApi(
    BuildContext context, {
    required int meetingId,
    required String status,
    required String newScheduledAt,
    required String reason,
    String? notes,
  }) async {
    var loadingIndicator = LoadingProgressDialog();
    if (networkManager.connectionType.value == 0) {
      showDialogForScreen(
        context,
        "Meetings Update",
        Connection.noConnection,
        callback: () => Get.back(),
      );
      return;
    }

    try {
      loadingIndicator.show(context, '');
      final endPoint = "${ApiUrl.getMeetingsCalendarList}/$meetingId";

      // Prepare request body
      final body = {
        'meeting_status': status.toLowerCase() == 'reschedule'
            ? "rescheduled"
            : '',
        'new_scheduled_at': toApiFormat(newScheduledAt),
        'reason': reason,
        if (notes != null) 'meeting_notes': notes,
      };

      logcat("body::", body);
      // return;
      final response = await Repository.post(body, endPoint, allowHeader: true);
      final data = jsonDecode(response.body);
      loadingIndicator.hide(context);
      if (response.statusCode == 200) {
        logcat('updateMeetingResponse', data.toString());
        if (data['status']?.toString().toLowerCase() == 'success') {
          showDialogForScreen(
            context,
            "Meeting Updated",
            data['message'] ?? "Meeting updated successfully!",
            callback: () {
              Get.back(result: true);
              getMeetingsListApi(
                context: context,
                isInitialLoad: true,
                page: 1,
                hideLoading: false,
              );
            },
          );
        } else {
          logcat("Update::", "Done");
          showErrorDialog(context, data);
          // showDialogForScreen(
          //   context,
          //   "Error",
          //   data['message'] ?? "Failed to update meeting",
          //   callback: () => Get.back(),
          // );
        }
      } else {
        logcat('Error Response', response.body);
        showErrorDialog(context, data);
        // showDialogForScreen(
        //   context,
        //   "Error",
        //   data['message']?.toString() ??
        //       data['errors']?.values.first[0]?.toString() ??
        //       'Server error',
        //   // response.body,
        //   callback: () => Get.back(),
        // );
      }
    } catch (e) {
      loadingIndicator.hide(context);
      logcat("Exception", e.toString());
      showDialogForScreen(
        context,
        "Error",
        e.toString(),
        callback: () => Get.back(),
      );
    }
  }
}
