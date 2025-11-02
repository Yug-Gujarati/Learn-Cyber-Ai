// quiz_level_selector_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:learning_cyber_security/view_model/level_quiz_provider.dart';
import '../utils/app_colors.dart';
import '../utils/custom_appbar.dart';
import '../utils/navigation.dart';
import 'level_quiz_screen.dart';

class QuizLevelSelectorScreen extends StatelessWidget {
  const QuizLevelSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          SizedBox(
            child: Consumer<LevelQuizProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                final levels = provider.levels;
                return ListView.builder(
                  padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 230.h),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return GestureDetector(
                      onTap: () {
                        provider.selectLevel(index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelQuizScreen(levelIndex: index),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  level.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            child: CustomAppbar(
              onTap: () {
                AppNavigation.NavigationBack(context);
              },
              name: 'Quiz Levels',
            ),
          ),
        ],
      ),
    );
  }
}
