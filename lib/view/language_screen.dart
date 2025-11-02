import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/view/intro_screen.dart';

import '../utils/app_colors.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/navigation.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
                text: "Language Screen",
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
                  AppNavigation.NavigationPushReplacement(context, IntroScreen());
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

