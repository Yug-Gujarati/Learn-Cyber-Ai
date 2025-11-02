import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/model/subtopic_data.dart';
import 'package:learning_cyber_security/model/topic_data.dart';
import 'package:learning_cyber_security/utils/custom_appbar.dart';
import 'package:learning_cyber_security/utils/custome_buttom.dart';
import 'package:learning_cyber_security/view/bookmark_screen.dart';
import 'package:learning_cyber_security/view/daily_update_screen.dart';
import 'package:learning_cyber_security/view/quiz_level_selector_screen.dart';
import 'package:learning_cyber_security/view/topic_screen.dart';
import 'package:provider/provider.dart';

import '../model/content_item.dart';
import '../utils/app_colors.dart';
import '../utils/custom_text.dart';
import '../utils/navigation.dart';
import '../view_model/fetch_data_provider.dart';
import 'ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          vSpace(100.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Cyber Learn",
                fontSize: 50,
                textColor: AppColors.primaryText,
                fontFamily: "obold",
                width: 400,
                maxline: 1,
              ),
            ],
          ),
          vSpace(200.h),
          CustomeButtom(
              height: 100.h,
              width: 950.w,
              child: CustomText(text: "Start Learn", fontSize: 200.sp, textColor: AppColors.primaryText, fontFamily: 'omedium', width: 900.w, maxline: 1, align: TextAlign.center,),
              onTap: (){
                AppNavigation.NavigationPush(context, TopicScreen());
              },
              isShowAd: false,
              color: Colors.blueAccent
          ),
          vSpace(20.h),
          CustomeButtom(
              height: 100.h,
              width: 950.w,
              child: CustomText(text: "Start Quiz", fontSize: 200.sp, textColor: AppColors.primaryText, fontFamily: 'omedium', width: 900.w, maxline: 1, align: TextAlign.center,),
              onTap: (){
                AppNavigation.NavigationPush(context, QuizLevelSelectorScreen());
              },
              isShowAd: false,
              color: Colors.blueAccent
          ),
          vSpace(20.h),
          CustomeButtom(
              height: 100.h,
              width: 950.w,
              child: CustomText(text: "AI Chat Bot", fontSize: 200.sp, textColor: AppColors.primaryText, fontFamily: 'omedium', width: 900.w, maxline: 1, align: TextAlign.center,),
              onTap: (){
                AppNavigation.NavigationPush(context, AIChatScreen());
              },
              isShowAd: false,
              color: Colors.blueAccent
          ),
          vSpace(20.h),
          CustomeButtom(
              height: 100.h,
              width: 950.w,
              child: CustomText(text: "Daily knowledge boost", fontSize: 200.sp, textColor: AppColors.primaryText, fontFamily: 'omedium', width: 900.w, maxline: 1, align: TextAlign.center,),
              onTap: (){
                AppNavigation.NavigationPush(context, DailyUpdateScreen());
              },
              isShowAd: false,
              color: Colors.blueAccent
          ),
          vSpace(20.h),
          CustomeButtom(
              height: 100.h,
              width: 950.w,
              child: CustomText(text: "Bookmarks", fontSize: 200.sp, textColor: AppColors.primaryText, fontFamily: 'omedium', width: 900.w, maxline: 1, align: TextAlign.center,),
              onTap: (){
                AppNavigation.NavigationPush(context, BookmarksScreen());
              },
              isShowAd: false,
              color: Colors.blueAccent
          ),
        ],
      ),
    );
  }
}
