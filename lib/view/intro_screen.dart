import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/utils/custome_buttom.dart';
import 'package:learning_cyber_security/utils/navigation.dart';
import 'package:learning_cyber_security/view/home_screen.dart';

import '../utils/app_colors.dart';
import '../utils/custom_text.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
                text: "Intro Screen",
                fontSize: 50,
                textColor: AppColors.primaryText,
                fontFamily: "obold",
                width: 900,
                align: TextAlign.center,
                maxline: 1),

            CustomeButtom(
                height: 100.h,
                width: 950.w,
                child: CustomText(text: "Next", fontSize: 200.sp, textColor: AppColors.primaryText, fontFamily: 'omedium', width: 900.w, maxline: 1, align: TextAlign.center,),
                onTap: (){
                  AppNavigation.NavigationPushReplacement(context, HomeScreen());
                },
                isShowAd: false,
                color: Colors.blueAccent
            )
          ],
        ),
      ),
    );
  }
}

