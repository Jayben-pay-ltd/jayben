import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  // AndroidNotification? android = message.notification!.android;
  // AppleNotification? apple = message.notification!.apple;
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      icon: 'resource://drawable/ic_stat_jayben_logo_1_044317_copy_3',
      color: const Color.fromARGB(255, 73, 160, 86),
      notificationLayout: NotificationLayout.BigText,
      category: NotificationCategory.Message,
      id: int.parse(randomNumeric(8)),
      channelKey: 'sound_channel',
      title: notification!.title,
      displayOnBackground: true,
      displayOnForeground: true,
      body: notification.body,
      autoDismissible: false,
      criticalAlert: true,
      wakeUpScreen: true,
    ),
  );
}

class NotifFunctions {
  Future<void> mainNotif() async {
    if (kIsWeb) return;

    await [Permission.notification].request();

    if (await Permission.notification.request().isGranted) {
      AwesomeNotifications().initialize(
          'resource://drawable/ic_stat_jayben_logo_1_044317_copy_3',
          [
            NotificationChannel(
              icon: 'resource://drawable/ic_stat_jayben_logo_1_044317_copy_3',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: const Color.fromARGB(255, 73, 160, 86),
              defaultRingtoneType: DefaultRingtoneType.Notification,
              importance: NotificationImportance.High,
              channelName: 'Basic notifications',
              channelGroupKey: 'basic_tests',
              channelKey: 'sound_channel',
              ledColor: Colors.white,
              enableVibration: true,
              criticalAlerts: true,
              enableLights: true,
              playSound: true,
            ),
          ],
          channelGroups: [
            NotificationChannelGroup(
              channelGroupName: 'Basic tests',
              channelGroupKey: 'basic_tests',
            ),
          ],
          debug: false);

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      if (!kIsWeb) {
        await FirebaseMessaging.instance.requestPermission(
          criticalAlert: true,
          provisional: false,
          announcement: true,
          carPlay: true,
          sound: true,
          badge: true,
          alert: true,
        );

        await FirebaseMessaging.instance.getInitialMessage();

        // this is the function that allows app to receive
        // notifs in foregraound when app is just loaded
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // this listens to what happens when a user taps
        // a notif. Use this to route user to needed page
        // when they tap a notification
        AwesomeNotifications().setListeners(
          onActionReceivedMethod: (ReceivedAction receivedAction) async {
            print("Notification received boss onActionReceivedMethod");
            NotificationController.onActionReceivedMethod;
          },
          // there are more option you could listen to...
        );
      }
    }
  }

  Future<void> initLocalNotifications() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    if (!await Permission.notification.request().isGranted) {
      await Permission.notification.request();
    }

    if (await Permission.notification.request().isGranted) {
      // this is the function that sends the notification
      // listens to when one is received and displays it
      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) async {
          // AndroidNotification? android = message.notification!.android;
          RemoteNotification? receivedNotification = message.notification;
          print("Notification request received boss in initLocalNotifications");
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              icon: 'resource://drawable/ic_stat_jayben_logo_1_044317_copy_3',
              color: const Color.fromARGB(255, 73, 160, 86),
              notificationLayout: NotificationLayout.BigText,
              category: NotificationCategory.Message,
              title: receivedNotification!.title,
              body: receivedNotification.body,
              id: int.parse(randomNumeric(8)),
              channelKey: 'sound_channel',
              displayOnBackground: true,
              displayOnForeground: true,
              autoDismissible: false,
              criticalAlert: true,
              wakeUpScreen: true,
            ),
          );
        },
      );

      FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) async {
          // navigate to whatever page
          RemoteNotification? receivedNotification = message.notification;
          Map<String, dynamic>? payload = message.data;

          print(
              ".......................The received notification payload is ${payload["UserID"]}");
        },
      );
    }
  }

  // shows the user a notification permission
  displayNotificationRationale() async {
    // bool userAuthorized = false;
    // BuildContext context = MyApp.navigatorKey.currentContext!;
    // await showDialog(
    //     context: context,
    //     builder: (BuildContext ctx) {
    //       return AlertDialog(
    //         title: Text('Get Notified!',
    //             style: Theme.of(context).textTheme.titleLarge),
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Row(
    //               children: [
    //                 Expanded(
    //                   child: Image.asset(
    //                     'assets/animated-bell.gif',
    //                     height: height(context) * 0.3,
    //                     fit: BoxFit.fitWidth,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             const SizedBox(height: 20),
    //             Text(
    //                 'Allow Awesome Notifications to send you beautiful notifications!'),
    //           ],
    //         ),
    //         actions: [
    //           TextButton(
    //               onPressed: () {
    //                 Navigator.of(ctx).pop();
    //               },
    //               child: Text(
    //                 'Deny',
    //                 style: Theme.of(context)
    //                     .textTheme
    //                     .titleLarge
    //                     ?.copyWith(color: Colors.red),
    //               )),
    //           TextButton(
    //               onPressed: () async {
    //                 userAuthorized = true;
    //                 Navigator.of(ctx).pop();
    //               },
    //               child: Text(
    //                 'Allow',
    //                 style: Theme.of(context)
    //                     .textTheme
    //                     .titleLarge
    //                     ?.copyWith(color: Colors.deepPurple),
    //               )),
    //         ],
    //       );
    //     });
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //         id: int.parse(randomNumeric(8)),
    //         autoDismissible: false,
    //         displayOnForeground: true,
    //         displayOnBackground: true,
    //         category: NotificationCategory.Message,
    //         icon: 'resource://drawable/ic_stat_jayben_logo_1_044317_copy_3',
    //         channelKey: 'sound_channel',
    //         notificationLayout: NotificationLayout.BigText,
    //         title: receivedNotification.title,
    //         wakeUpScreen: true,
    //         criticalAlert: true,
    // customSound: 'resource://raw/cash',
    //         body: receivedNotification.body));

    return;
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //         id: int.parse(randomNumeric(8)),
    //         autoDismissible: false,
    //         displayOnForeground: true,
    //         displayOnBackground: true,
    // customSound: 'resource://raw/cash',
    //         category: NotificationCategory.Message,
    //         icon: 'resource://drawable/ic_stat_jayben_logo_1_044317_copy_3',
    //         channelKey: 'sound_channel',
    //         notificationLayout: NotificationLayout.BigText,
    //         title: receivedNotification!.title,
    //         wakeUpScreen: true,
    //         criticalAlert: true,
    //         body: receivedNotification.body));

    return;
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
    // AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //         id: int.parse(randomNumeric(8)),
    //         autoDismissible: false,
    //         displayOnForeground: true,
    //         displayOnBackground: true,
    // customSound: 'resource://raw/cash',
    //         category: NotificationCategory.Message,
    //         icon: 'resource://drawable/ic_stat_jayben_logo_1_044317_copy_3',
    //         channelKey: 'sound_channel',
    //         notificationLayout: NotificationLayout.BigText,
    //         title: receivedAction.title,
    //         wakeUpScreen: true,
    //         criticalAlert: true,
    //         body: receivedAction.body));
    return;
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    return;
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }
}

class HiveFunctions {
  Future<void> initializeHive() async {
    if (!kIsWeb) {
      Directory document = await getApplicationDocumentsDirectory();
      Hive.init(document.path);
    }
    await Hive.openBox('userInfo');
  }
}
