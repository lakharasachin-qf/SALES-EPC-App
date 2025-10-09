import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:sales_app/componant/button/form_button.dart';
import 'package:sales_app/componant/dialogs/common_date_time_picker.dart';
import 'package:sales_app/componant/dialogs/dialogs.dart';
import 'package:sales_app/componant/input/getReactiveDropdown.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/componant/widgets/widgets.dart';
import 'package:sales_app/configs/apicall_constant.dart';
import 'package:sales_app/configs/string_constant.dart';
import 'package:sales_app/controller/internet_controller/internet_controller.dart';
import 'package:sales_app/models/customer_model.dart';
import 'package:sales_app/models/customer_model_wo_p.dart';
import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/models/sign_in_form_validation.dart';
import 'package:sales_app/preference/UserPreference.dart';
import 'package:sales_app/utils/enum.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:sales_app/utils/log.dart';
import 'package:sizer/sizer.dart';
import '../../api_handle/Repository.dart';
import '../../models/fillter_model.dart' hide Result;

class MeetingData {
  String? meetingId;
  String? companyName;
  String? contactPerson;
  String? mobile;
  String? status;
  DateTime? meetingDate;
  String? meetingType;
  String? notes;

  MeetingData({
    this.meetingId,
    this.companyName,
    this.contactPerson,
    this.mobile,
    this.status,
    this.meetingDate,
    this.meetingType,
    this.notes,
  });
}

class MeetingsCalendarController extends GetxController {
  final InternetController networkManager = Get.find<InternetController>();
  Rx<ScreenState> state = ScreenState.apiSuccess.obs;
  RxString message = ''.obs;
  RxBool isTextEmpty = false.obs;

  void clearSearch() {
    searchCtr.clear();
    // filterData('');
    unfocusAll();
  }

  // 🔹 Controllers
  late TextEditingController statusCtr, searchCtr, dateCtr, reasonCtr, notesCtr;

  // 🔹 FocusNodes
  late FocusNode statusNode, dateNode, searchNode, reasonNode, notesNode;

  // 🔹 Validation Models
  var statusModel = ValidationModel(null, null, isValidate: false).obs;
  var dateModel = ValidationModel(null, null, isValidate: false).obs;
  var reasonModel = ValidationModel(null, null, isValidate: false).obs;
  var notesModel = ValidationModel(null, null, isValidate: false).obs;

  RxBool isStartDateActive = true.obs;
  RxBool isStartDateSelected = false.obs;
  RxBool isDistrictSelected = false.obs;
  RxBool isClusterSelected = false.obs;
  RxBool isFormInvalidate = false.obs;
  RxList<Category> districtList = <Category>[].obs;
  RxList<Category> clustersList = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeStaticData();
    // 🔹 Initialize Controllers
    statusCtr = TextEditingController();
    dateCtr = TextEditingController();
    reasonCtr = TextEditingController();
    notesCtr = TextEditingController();
    searchCtr = TextEditingController();

    // 🔹 Initialize FocusNodes
    statusNode = FocusNode();
    dateNode = FocusNode();
    reasonNode = FocusNode();
    notesNode = FocusNode();
    searchNode = FocusNode();
  }

  @override
  void onClose() {
    // 🔹 Dispose Controllers
    statusCtr.dispose();
    dateCtr.dispose();
    reasonCtr.dispose();
    notesCtr.dispose();
    searchCtr.dispose();

    // 🔹 Dispose FocusNodes
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

  RxList<MeetingData> meetingList = <MeetingData>[].obs;
  RxString nextPageURL = "".obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt fromItem = 0.obs;
  final RxInt toItem = 0.obs;

  var isMeetingLoading = false.obs;

  // Initialize static meeting data
  void initializeStaticData() {
    meetingList.clear();
    meetingList.addAll([
      MeetingData(
        meetingId: "MTG001",
        companyName: "Tech Corp",
        contactPerson: "John Doe",
        mobile: "123-456-7890",
        status: "Scheduled",
        meetingDate: DateTime(2025, 10, 15, 10, 0),
        meetingType: "In-Person",
        notes: "Discuss project roadmap",
      ),
      MeetingData(
        meetingId: "MTG002",
        companyName: "Innovate Ltd",
        contactPerson: "Jane Smith",
        mobile: "234-567-8901",
        status: "Rescheduled",
        meetingDate: DateTime(2025, 11, 10, 14, 0),
        meetingType: "Virtual",
        notes: "Follow-up on contract",
      ),
      MeetingData(
        meetingId: "MTG003",
        companyName: "Global Solutions",
        contactPerson: "Alice Johnson",
        mobile: "345-678-9012",
        status: "Cancelled",
        meetingDate: DateTime(2025, 12, 20, 11, 0),
        meetingType: "In-Person",
        notes: "Client unavailable",
      ),
      MeetingData(
        meetingId: "MTG004",
        companyName: "Future Tech",
        contactPerson: "Bob Wilson",
        mobile: "456-789-0123",
        status: "Scheduled",
        meetingDate: DateTime(2025, 10, 25, 15, 0),
        meetingType: "Virtual",
        notes: "Demo presentation",
      ),
      MeetingData(
        meetingId: "MTG005",
        companyName: "Star Enterprises",
        contactPerson: "Emma Brown",
        mobile: "567-890-1234",
        status: "Completed",
        meetingDate: DateTime(2025, 9, 30, 9, 0),
        meetingType: "In-Person",
        notes: "Signed agreement",
      ),
      MeetingData(
        meetingId: "MTG006",
        companyName: "NextGen Systems",
        contactPerson: "Liam Davis",
        mobile: "678-901-2345",
        status: "Scheduled",
        meetingDate: DateTime(2025, 11, 5, 13, 0),
        meetingType: "Phone Call",
        notes: "Initial consultation",
      ),
      MeetingData(
        meetingId: "MTG007",
        companyName: "Prime Innovations",
        contactPerson: "Olivia Taylor",
        mobile: "789-012-3456",
        status: "Rescheduled",
        meetingDate: DateTime(2025, 12, 15, 16, 0),
        meetingType: "Virtual",
        notes: "Review project milestones",
      ),
      MeetingData(
        meetingId: "MTG008",
        companyName: "Bright Solutions",
        contactPerson: "Noah Anderson",
        mobile: "890-123-4567",
        status: "Completed",
        meetingDate: DateTime(2025, 10, 10, 10, 30),
        meetingType: "In-Person",
        notes: "Finalized deal terms",
      ),
      MeetingData(
        meetingId: "MTG009",
        companyName: "Visionary Works",
        contactPerson: "Sophia Martinez",
        mobile: "901-234-5678",
        status: "Scheduled",
        meetingDate: DateTime(2025, 11, 25, 14, 30),
        meetingType: "Virtual",
        notes: "Product demo",
      ),
      MeetingData(
        meetingId: "MTG010",
        companyName: "Skyline Industries",
        contactPerson: "Ethan Thomas",
        mobile: "012-345-6789",
        status: "Cancelled",
        meetingDate: DateTime(2025, 12, 1, 12, 0),
        meetingType: "Phone Call",
        notes: "Client postponed",
      ),
    ]);

    // Set pagination details for static data
    totalItems.value = meetingList.length;
    currentPage.value = 1;
    lastPage.value = 1; // Static data fits in one page
    fromItem.value = 1;
    toItem.value = meetingList.length;
    nextPageURL.value = "";
    state.value = ScreenState.apiSuccess;
    update();
  }

  final Map<String, double> columnWidths = {
    "Sr No.": 7.w,
    "Meeting ID": 15.w,
    "Company Name": 20.w,
    "Contact Person": 20.w,
    "Meeting Date": 20.w,
    "Status": 15.w,
    "Action": 15.w,
  };

  final RxList<String> meetingHeaders = <String>[
    "Sr No.",
    "Meeting ID",
    "Company Name",
    "Contact Person",
    "Meeting Date",
    "Status",
    "Action",
  ].obs;
  RxList<Result> customerList = <Result>[].obs;

  var isCustomerLoading = false.obs;

  // Future<void> getCustomerbyID(
  //   BuildContext context,
  //   int currentPage,
  //   bool hideLoading, {
  //   bool isFirstTime = false,
  // }) async {
  //   User? userData = await UserPreferences().getSignInInfo();

  //   if (hideLoading == false) {
  //     state.value = ScreenState.apiLoading;
  //   }
  //   if (isFirstTime == true) {
  //     isCustomerLoading(
  //       true,
  //     ); // Assuming you have a loading state for customers
  //   }

  //   try {
  //     if (networkManager.connectionType.value == 0) {
  //       if (isFirstTime == true) {
  //         isCustomerLoading(false);
  //       }
  //       showDialogForScreen(
  //         context,
  //         'Meter Screen',
  //         Connection.noConnection,
  //         callback: () {
  //           Get.back();
  //         },
  //       );
  //       return;
  //     }

  //     var pageURL =
  //         "${ApiUrl.getcustomerbyIdwwithpagination}=${userData?.userId ?? ''}&page=$currentPage&per_page=10";
  //     var response = await Repository.get({}, pageURL, allowHeader: true);

  //     if (isFirstTime == true) {
  //       isCustomerLoading(false);
  //     }

  //     logcat("RESPONSE::", response.body);
  //     var responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       if (responseData['status'] == true) {
  //         state.value = ScreenState.apiSuccess;
  //         message.value = '';

  //         if (isFirstTime == true && customerList.isNotEmpty) {
  //           currentPage = 1;
  //           customerList.clear();
  //         }

  //         var customerListData = CustomerModel.fromJson(responseData);
  //         if (customerListData.result.isNotEmpty) {
  //           customerList.addAll(customerListData.result);
  //           customerList.refresh();
  //           update();
  //         } else {
  //           customerList.clear();
  //         }

  //         // ✅ Set pagination info
  //         this.currentPage.value = customerListData.pagination.currentPage;
  //         lastPage.value = customerListData.pagination.lastPage;
  //         totalItems.value = customerListData.pagination.total;
  //         fromItem.value = customerListData.pagination.from;
  //         toItem.value = customerListData.pagination.to;
  //         // Handle pagination
  //         if (customerListData.pagination.currentPage <
  //             customerListData.pagination.lastPage) {
  //           nextPageURL.value =
  //               "${ApiUrl.getcustomerbyIdwwithpagination}=${userData?.userId ?? ''}&page=${currentPage + 1}&per_page=10";
  //           logcat("nextPageURL-1", nextPageURL.value.toString());
  //           update();
  //         } else {
  //           nextPageURL.value = "";
  //           logcat("nextPageURL-2", nextPageURL.value.toString());
  //           update();
  //         }
  //         logcat("nextPageURL", nextPageURL.value.toString());
  //       } else {
  //         message.value = responseData['message'];
  //         showDialogForScreen(
  //           context,
  //           'Meter Screen',
  //           responseData['message'],
  //           callback: () {},
  //         );
  //       }
  //     } else {
  //       state.value = ScreenState.apiError;
  //       message.value = APIResponseHandleText.serverError;
  //       showDialogForScreen(
  //         context,
  //         'Meter Screen',
  //         responseData['message'] ?? ServerError.servererror,
  //         callback: () {
  //           getUnauthenticatedUser(
  //             context,
  //             responseData['message'],
  //             "Unauthenticated user",
  //           );
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     logcat("Exception", e);
  //     if (isFirstTime == true) {
  //       isCustomerLoading(false);
  //     }
  //     state.value = ScreenState.apiError;
  //     // message.value = ServerError.servererror;
  //     // showDialogForScreen(context, 'Meter Screen', ServerError.servererror, callback: () {});
  //   }
  // }
  // Provide all meeting data without pagination
  List<List<String>> get meetingsData {
    if (meetingList.isEmpty) return [];

    return meetingList.asMap().entries.map((entry) {
      final index = entry.key + 1 + ((currentPage.value - 1) * 10);
      final e = entry.value;

      return [
        index.toString(), // Sr No.
        e.meetingId ?? 'N/A',
        e.companyName ?? 'N/A',
        e.contactPerson ?? 'N/A',
        dateTimeFormat.format(e.meetingDate ?? DateTime.now()),
        e.status ?? 'N/A',
        "",
      ];
    }).toList();
  }

  void resetFilterFields() {
    // 🔹 Controllers
    statusCtr.clear();
    dateCtr.clear();
    reasonCtr.clear();
    notesCtr.clear();

    // 🔹 Dropdown / reactive selection
    selectStatus.value = 'Select Status';

    // 🔹 Validation Models
    statusModel.value = ValidationModel(null, null, isValidate: false);
    dateModel.value = ValidationModel(null, null, isValidate: false);
    reasonModel.value = ValidationModel(null, null, isValidate: false);
    notesModel.value = ValidationModel(null, null, isValidate: false);

    // 🔹 Other flags
    isStartDateActive.value = true;
    isStartDateSelected.value = false;
    isDistrictSelected.value = false;
    isClusterSelected.value = false;
    isFormInvalidate.value = false;
  }

  void updateMeetings(context) async {
    resetFilterFields();
    openBottomtsheetDialog(
      context,
      title: "Edit Meeting",
      widget: addFilterSheetWidget(context),
    );
  }

  final List<String> status = ['Select Status', 'Reschedule'];
  RxString selectStatus = 'Select Status'.obs;

  Widget addFilterSheetWidget(context) {
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
              },
            ),
          ),
          getDynamicSizedBox(height: 1.h),

          Obx(() {
            if (selectStatus.value == 'Reschedule') {
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
                      // openDatePicker(
                      //   context: context,
                      //   title: 'Select New Date',
                      //   controller: dateCtr,
                      //   dateRx: startDate,
                      //   model: dateModel,
                      // );
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
              isRequired: true,
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
                  },
                  'Cancel',
                  validate: true,
                ),
              ),
              getDynamicSizedBox(width: 3.w),
              Expanded(
                child: getFormButton(
                  context,
                  () {
                    Get.back();
                  },
                  "Update",
                  validate: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
      initialDate: dateRx.value.isNotEmpty
          ? dateTimeFormat.parse(dateRx.value)
          : null,
      minDate: startDate.value.isNotEmpty
          ? dateTimeFormat.parse(startDate.value)
          : null,
      showTimePickers: showTimePickers,
      onDatePicked: (DateTime date) {
        final formatted = dateTimeFormat.format(date);
        dateRx.value = formatted;
        controller.text = formatted;
        // validateFields(
        //   controller.text,
        //   iscomman: true,
        //   model: model,
        //   errorText1: showTimePickers
        //       ? 'Please choose date and time'
        //       : 'Please choose date',
        // );
      },
    );
  }

  // Common filter
  var currentFilterSource = [].obs;
  var filteredData = [].obs;
  RxString categoryId = "".obs;
  RxList<CategoryModel> warrantyType = <CategoryModel>[
    CategoryModel(id: "1", name: "Invoice"),
    CategoryModel(id: "2", name: "Bills"),
    CategoryModel(id: "3", name: "Reports"),
    CategoryModel(id: "4", name: "Others"),
  ].obs;
}
