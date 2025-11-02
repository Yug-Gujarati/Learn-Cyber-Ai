import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final String fontFamily;
  final double width;
  final int maxline;
  final TextAlign ? align;

  const CustomText({super.key, required this.text, required this.fontSize, required this.textColor, required this.fontFamily, required this.width, required this.maxline, this.align});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: maxline,
        textAlign: align,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize.sp,
          fontFamily: fontFamily
        ),
      ),
    );
  }
}
