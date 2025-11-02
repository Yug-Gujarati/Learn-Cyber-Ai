import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/utils/custom_text.dart';
import 'package:learning_cyber_security/view/intro_screen.dart';
import 'package:learning_cyber_security/view/language_screen.dart';

import '../utils/app_colors.dart';
import '../utils/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    navigation();

  }

  Future<void> navigation() async{
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBhsdL0RVkYz0Q_2CgjNJNPSCk8mHTo5c4",
        appId: "1:379091877737:android:893fd1e7e3f28800adc7f8",
        messagingSenderId: "XXX",
        projectId: "learningcyber-e4175",
      ),
    ).then((value) {
      /// add this line to enable firebase crashlytics

      log("Firebase Initialized");
    });
    Future.delayed(Duration(seconds: 3), () {
      AppNavigation.NavigationPushReplacement(
        context, LanguageScreen()
      );
    },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
                text: "Splash Screen",
                fontSize: 50,
                textColor: AppColors.primaryText,
                fontFamily: "obold",
                width: 900,
                align: TextAlign.center,
                maxline: 1)

          ],
        ),
      ),
    );
  }
}
