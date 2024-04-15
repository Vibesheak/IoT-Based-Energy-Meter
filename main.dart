import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:vibesheak_s_application11/presentation/activity_tracker_screen/activity_tracker_screen.dart';
import 'core/app_export.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  ///Please update theme as per your need if required.
  ThemeHelper().changeTheme('primary');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: MyHomePage(),
          theme: theme,
          title: 'vibesheak_s_application11',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.activityTrackerScreen,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
