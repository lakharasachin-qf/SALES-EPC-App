import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:sales_app/utils/log.dart';

class CalendarHelper {
  static final DeviceCalendarPlugin _deviceCalendarPlugin =
      DeviceCalendarPlugin();

  static Future<bool> checkCalendarPermission() async {
    try {
      // Step 1: Check if permission already granted
      final permissionStatus = await _deviceCalendarPlugin.hasPermissions();

      if (permissionStatus.isSuccess && (permissionStatus.data ?? false)) {
        logcat("Calendar Permission:", "Already granted");
        return true;
      }

      // Step 2: Request permission if not granted
      final requestResult = await _deviceCalendarPlugin.requestPermissions();

      if (requestResult.isSuccess && (requestResult.data ?? false)) {
        logcat("Calendar Permission:", "Granted after request");
        return true;
      } else {
        logcat("Calendar Permission:", "Denied");
        return false;
      }
    } catch (e) {
      logcat("Calendar Permission Error::", e);
      return false;
    }
  }

  static Future<void> addEvent({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    String? location,
  }) async {
    try {
      if (Platform.isAndroid) {
        /// On Android → adds silently (after permission granted)
        await addEventInCalendar(
          title: title,
          description: description,
          start: start,
          end: end,
          location: location,
        );
      } else if (Platform.isIOS) {
        /// On iOS → opens calendar confirmation UI
        // await _addEventWithConfirmation(
        //   title: title,
        //   description: description,
        //   start: start,
        //   end: end,
        //   location: location,
        // );
      } else {
        logcat("Data::", "Unsupported platform for calendar integration");
      }
    } catch (e) {
      logcat("Error adding event to calendar:::", e);
    }
  }

  static Future<void> addEventInCalendar({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    String? location,
  }) async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      final permissionResult = await _deviceCalendarPlugin.requestPermissions();
      if (!(permissionResult.data ?? false)) {
        logcat("Data::", "Calendar permission not granted");
        return;
      }
    }

    // Get available calendars
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data;
    if (calendars == null || calendars.isEmpty) {
      logcat("Data::", "No calendars found");
      return;
    }

    // Use first available calendar
    final calendarId = calendars.first.id;

    // Create event
    final event = Event(
      calendarId,
      title: title,
      description: description,
      location: location, // Assuming location is String?
      start: TZDateTime.from(start, local), // Convert to TZDateTime
      end: TZDateTime.from(end, local), // Convert to TZDateTime
      reminders: [Reminder(minutes: 30)],
    );

    // Save event
    final createResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    if (createResult!.isSuccess && createResult.data?.isNotEmpty == true) {
      logcat("Event added silently with ID:", createResult.data);
    } else {
      logcat("Failed:", "Failed to add event silently");
    }
  }

  /// Confirmation-based add (iOS)
  // static Future<void> _addEventWithConfirmation({
  //   required String title,
  //   required String description,
  //   required DateTime start,
  //   required DateTime end,
  //   String? location,
  // }) async {
  //   final event = EventModel(
  //     title: title,
  //     description: description,
  //     location: location ?? '',
  //     startDate: start,
  //     endDate: end,
  //     iosParams: const IOSParams(reminder: Duration(minutes: 30)),
  //   );

  //   final success = await Add2Calendar.addEvent2Cal(event);
  //   if (success) {
  //     print('✅ Event added to calendar with confirmation');
  //   } else {
  //     print('❌ Failed to add event to calendar');
  //   }
  // }
}

/// Helper model for add_2_calendar (iOS)
// class EventModel extends Event {
//   EventModel({
//     required super.title,
//     required super.startDate,
//     required super.endDate,
//     super.description,
//     super.location,
//     super.allDay = false,
//     super.iosParams,
//     super.androidParams,
//   });
// }
