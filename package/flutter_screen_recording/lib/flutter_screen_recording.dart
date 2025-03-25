//import 'file:D:/Workspace/flutter_screen_recording/flutter_screen_recording_platform_interface/lib/flutter_screen_recording_platform_interface.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screen_recording_platform_interface/flutter_screen_recording_platform_interface.dart';

class FlutterScreenRecording {
  static Future<bool> startRecordScreen(
    String name, {
    String? titleNotification,
    String? messageNotification,
  }) async {
    try {
      titleNotification ??= "";
      messageNotification ??= "";

      await _maybeStartFGS(titleNotification, messageNotification);
      final bool start =
          await FlutterScreenRecordingPlatform.instance.startRecordScreen(
        name,
        notificationTitle: titleNotification,
        notificationMessage: messageNotification,
      );

      return start;
    } catch (err) {
      print("startRecordScreen err");
      print(err);
    }

    return false;
  }

  static Future<bool> startRecordScreenAndAudio(
    String name, {
    String? titleNotification,
    String? messageNotification,
  }) async {
    //await _maybeStartFGS(titleNotification, messageNotification);
    final bool start = await FlutterScreenRecordingPlatform.instance
        .startRecordScreenAndAudio(name);
    return start;
  }

  static Future<String> get stopRecordScreen async {
    try {
      final String path =
          await FlutterScreenRecordingPlatform.instance.stopRecordScreen;
      if (!kIsWeb && Platform.isAndroid) {
        FlutterForegroundTask.stopService();
      }
      return path;
    } catch (err) {
      print("stopRecordScreen err");
      print(err);
    }
    return "";
  }

  static _maybeStartFGS(
    String titleNotification,
    String messageNotification,
  ) async {
    if (!kIsWeb && Platform.isAndroid) {
      // await FlutterForegroundTask.init(
      //   androidNotificationOptions: AndroidNotificationOptions(
      //     channelId: 'notification_channel_id',
      //     channelName: titleNotification,
      //     channelDescription: messageNotification,
      //     channelImportance: NotificationChannelImportance.LOW,
      //     priority: NotificationPriority.LOW,
      //     iconData: const NotificationIconData(
      //       resType: ResourceType.mipmap,
      //       resPrefix: ResourcePrefix.ic,
      //       name: 'launcher',
      //     ),
      //     buttons: [
      //       // const NotificationButton(id: 'sendButton', text: 'Send'),
      //       // const NotificationButton(id: 'testButton', text: 'Test'),
      //     ],
      //   ),
      //   iosNotificationOptions: const IOSNotificationOptions(
      //     showNotification: true,
      //     playSound: false,
      //   ),
      //   // foregroundTaskOptions: const ForegroundTaskOptions(
      //   //   interval: 5000,
      //   //   autoRunOnBoot: true,
      //   //   allowWifiLock: true,
      //   // ),
      //   // printDevLog: true,
      // );

      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'notification_channel_id',
          channelName: titleNotification,
          channelDescription: messageNotification,
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          iconData: const NotificationIconData(
            resType: ResourceType.mipmap,
            resPrefix: ResourcePrefix.ic,
            name: 'launcher',
          ),
          buttons: [
            // const NotificationButton(id: 'sendButton', text: 'Send'),
            // const NotificationButton(id: 'testButton', text: 'Test'),
          ],
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: const ForegroundTaskOptions(
          interval: 5000,
          isOnceEvent: false,
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
    }
  }

  static void globalForegroundService() {
    print("current datetime is ${DateTime.now()}");
  }
}
