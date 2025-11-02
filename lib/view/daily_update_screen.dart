import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/view_model/daily_update_provider.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';

class DailyUpdateScreen extends StatefulWidget {
  const DailyUpdateScreen({super.key});

  @override
  State<DailyUpdateScreen> createState() => _DailyUpdateScreenState();
}

class _DailyUpdateScreenState extends State<DailyUpdateScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DailyUpdateProvider>(context, listen: false).fetchLatestNews());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyUpdateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          else if (provider.dailyUpdate == null)
            _buildEmptyState()
          else
            _buildNewsContent(provider),
          Positioned(
            top: 0,
            child: CustomAppbar(
              onTap: () => Navigator.pop(context),
              name: "Daily Cyber Update",
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildNewsContent(DailyUpdateProvider provider) {
    final article = provider.dailyUpdate!;
    return ListView(
      padding: EdgeInsets.only(top: 250.h, left: 50.w, right: 50.w, bottom: 150.h),
      children: [
        _buildHeading(article.title),
        SizedBox(height: 40.h),
        _buildParagraph(article.content),
      ],
    );
  }

  Widget _buildHeading(String text) {
    return Container(
      padding: EdgeInsets.only(left: 20.w, bottom: 10.h),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.blueAccent, width: 5.w),
        ),
      ),
      child: CustomText(
          text: text,
          fontSize: 50,
          textColor: AppColors.primaryText,
          fontFamily: 'osemibold',
          width: 1080,
          maxline: 2)


    );
  }

  Widget _buildParagraph(String text) {
    // Split into small points if long
    List<String> paragraphs = text.split(RegExp(r'\.\s+'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        if (para.trim().isEmpty) return SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 25.h),
          child: Text(
            para.trim() + '.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 45.sp,
              fontFamily: 'soregular'
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_moon_outlined, color: Colors.grey, size: 100.sp),
            SizedBox(height: 40.h),
            Text(
              'No Daily Update Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 45.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Stay tuned for the latest cybersecurity insights and alerts.',
              style: TextStyle(color: Colors.grey[400], fontSize: 32.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
