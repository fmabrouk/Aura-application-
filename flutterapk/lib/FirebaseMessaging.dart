import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

//Début d'implémentation des notifications push
//Uniquement pour les notifications de fréquence
//Aidé par ce tuto : https://www.youtube.com/watch?v=UBq8tNhX_dM

class FirebaseMessagingDemo extends StatefulWidget {
  const FirebaseMessagingDemo({Key key}) : super(key: key);

  @override
  State<FirebaseMessagingDemo> createState() => _FirebaseMessagingState();
}

class _FirebaseMessagingState extends State<FirebaseMessagingDemo> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  initState() {
    super.initState();
    _settings();
    _getToken();
    _ontokenRefresh();
  }

  _getToken() {
    _firebaseMessaging.getToken().then((token) {
      print("Device Token: $token");
    });
  }

  _settings() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  _ontokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.
      print(' FCM TOKEN : $fcmToken');
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
      print('ERROR MESSAGE : $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
