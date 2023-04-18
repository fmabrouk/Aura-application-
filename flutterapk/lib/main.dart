import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/carteScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/drawerScreens/politiqueScreen.dart';
import './providers/UserProvider.dart';
import 'screens/drawerScreens/aProposScreen.dart';
import 'screens/drawerScreens/conditionScreen.dart';
import 'screens/drawerScreens/contacterScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/homeScreen.dart';
import 'screens/authentificationScreen/LoginScreen.dart';
import 'screens/authentificationScreen/SignConfirmScreen.dart';
import './providers/commentProvider.dart';
import './providers/tagProvider.dart';
import './providers/articleProvider.dart';
import './providers/markerProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'providers/favoriteProvider.dart';
import 'screens/authentificationScreen/SignScreen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  runZonedGuarded(() async {
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'basic_channel',
          defaultColor: Color.fromRGBO(209, 62, 150, 1),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          channelDescription: '',
          onlyAlertOnce: true)
    ]);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => MarkerProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ArticleProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TagProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FavoriteProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CommentaireProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AURA',
        theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'myriad'),
        home: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              FirebaseCrashlytics.instance.log(snapshot.data.toString());
              if (snapshot.data.emailVerified) {
                return CarteScreen(
                  auth: true,
                  login: snapshot.data,
                  trade: false,
                );
              }
            }
            if (snapshot.hasError) {
              print(snapshot.error);
            }
            return HomeScreen();
          },
        ),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          SignConfirmScreen.routeName: (ctx) => SignConfirmScreen(),
          SignScreen.routeName: (ctx) => SignScreen(),
          ConditionScreen.routeName: (ctx) => ConditionScreen(),
          ContacterScreen.routeName: (ctx) => ContacterScreen(),
          AProposScreen.routeName: (ctx) => AProposScreen(),
          PolitiqueScreen.routeName: (ctx) => PolitiqueScreen(),
        },
      ),
    );
  }
}
