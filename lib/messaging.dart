import "package:firebase_messaging/firebase_messaging.dart";
import 'chat.dart';
// importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
// importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message in foreground: ${message.data}');
    // Check if the message has the necessary data for Genesys chat
    if (message.data['conversationId'] != null) {
      // String conversationId = message.data['conversationId'];
      // String deploymentId = message.data['deploymentId'];
      navigateToChat();
    }
  });
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    // Check if the message has the necessary data for Genesys chat
    if (message.data['conversationId'] != null) {
      //String conversationId = message.data['conversationId'];
      //String deploymentId = message.data['deploymentId'];
      navigateToChat();
    }
  }

  void navigateToChat() {
    Chat chat = Chat(); 
    chat.getChat();
  }


}