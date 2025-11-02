import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/utils/app_colors.dart';
import 'package:learning_cyber_security/view/splash_screen.dart';
import 'package:learning_cyber_security/view_model/ai_chat_provider.dart';
import 'package:learning_cyber_security/view_model/bookmark_provider.dart';
import 'package:learning_cyber_security/view_model/daily_update_provider.dart';
import 'package:learning_cyber_security/view_model/fetch_data_provider.dart';
import 'package:learning_cyber_security/view_model/level_quiz_provider.dart';
import 'package:learning_cyber_security/view_model/quiz_provider.dart';
import 'package:provider/provider.dart';


void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FetchDataProvider>(
          create: (_) => FetchDataProvider(),
        ),
        ChangeNotifierProvider<LevelQuizProvider>(
          create: (_) => LevelQuizProvider(),
        ),
        ChangeNotifierProvider<AIChatProvider>(
          create: (_) => AIChatProvider(),
        ),
        ChangeNotifierProvider<DailyUpdateProvider>(
          create: (_) => DailyUpdateProvider(),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundColor,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: SplashScreen(),
      ),
    );
  }
}

