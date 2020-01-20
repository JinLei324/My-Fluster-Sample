import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:groomlyfe/global/data.dart';
import 'package:groomlyfe/util/state_widget.dart';
import 'package:groomlyfe/ui/theme.dart';
import 'package:groomlyfe/ui/screens/home.dart';
import 'package:groomlyfe/ui/screens/splash.dart';
import 'package:groomlyfe/ui/screens/sign_in.dart';
import 'package:groomlyfe/ui/screens/sign_up.dart';
import 'package:groomlyfe/ui/screens/forgot_password.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class MyApp extends StatelessWidget {
  _run_notification() {
    firebaseMessaging.configure(
//        onBackgroundMessage:Platform.isIOS ? null : myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) {
      print('On Launch: ' + message.toString());
    }, onMessage: (Map<String, dynamic> message) {
      print('On Message: ' + message.toString());
    }, onResume: (Map<String, dynamic> message) {
      print('On Resume: ' + message.toString());
    });
  }

  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    print("_+_+_+_+_+_+");
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      firebaseMessaging
          .requestNotificationPermissions(const IosNotificationSettings(
        badge: true,
        sound: true,
        alert: true,
      ));
      firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }

    firebaseMessaging.getToken().then((token) {
      print(token);
    });
    _run_notification();
    return MaterialApp(
      title: 'MyApp Title',
      theme: buildTheme(),
      //onGenerateRoute: Navigation.router.generator,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Splash(),
        '/home': (context) => HomeScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}

void main() async {
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(stateWidget));
}
