import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/utils/app_colors.dart';
import 'package:learning_cyber_security/utils/custom_text.dart';

class CustomAppbar extends StatelessWidget {
  final Function onTap;
  final String name;
  const CustomAppbar({super.key, required this.onTap, required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30.r),
        bottomRight: Radius.circular(30.r),
      ),
      child: Container(
        width: 1080.w,
        height: 200.h,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.only(top: 100.h),
            width: double.infinity,

            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    onTap();
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left_sharp,
                    color: AppColors.backIcon,
                    size: 100.w,
                  ),
                ),
                Spacer(),
                CustomText(
                    text: name,
                    fontSize: 50,
                    textColor: AppColors.primaryText,
                    fontFamily: "obold",
                    width: 750,
                    align: TextAlign.center,

                    maxline: 1),
                Spacer(),
                hSpace(130.w)

              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget vSpace(double height) => SizedBox(height: height);

Widget hSpace(double width) => SizedBox(width: width);