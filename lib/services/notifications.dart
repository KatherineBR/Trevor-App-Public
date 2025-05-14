import "package:firebase_messaging/firebase_messaging.dart";

class Messaging {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> mainMessaging() async {

    NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

    //print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    //print("Handling a background message: ${message.messageId}");
  }


}