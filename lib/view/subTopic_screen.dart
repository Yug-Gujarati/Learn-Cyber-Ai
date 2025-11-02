import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/model/subtopic_data.dart';
import 'package:learning_cyber_security/utils/app_colors.dart';
import 'package:learning_cyber_security/utils/custom_appbar.dart';
import 'package:learning_cyber_security/utils/custom_text.dart';
import 'package:learning_cyber_security/utils/navigation.dart';
import 'package:learning_cyber_security/view/content_screen.dart';

class SubtopicScreen extends StatefulWidget {
  final String collectionName;
  final List<SubtopicData> subtopics;

  const SubtopicScreen({
    super.key,
    required this.collectionName,
    required this.subtopics,
  });

  @override
  State<SubtopicScreen> createState() => _SubtopicScreenState();
}

class _SubtopicScreenState extends State<SubtopicScreen> {
  @override
  void initState() {
    super.initState();
    print('📚 Opened topic: ${widget.collectionName}');
    print('📋 Total subtopics: ${widget.subtopics.length}');

    // Log all subtopics
    for (int i = 0; i < widget.subtopics.length; i++) {
      print('  Subtopic ${i + 1}: ${widget.subtopics[i].title} (${widget.subtopics[i].content.length} items)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          vSpace(100.h),
          CustomAppbar(
            onTap: () {
              AppNavigation.NavigationBack(context);
            },
            name: "Explore all content",
          ),


          Expanded(
            child: widget.subtopics.isEmpty
                ? _buildEmptyState()
                : _buildSubtopicList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              color: Colors.grey,
              size: 80,
            ),
            SizedBox(height: 20.h),
            CustomText(
                text:  'No Subtopics Found',
                fontSize: 40,
                textColor: AppColors.primaryText,
                fontFamily: 'oregular',
                width: 500,
                maxline: 1
            ),

            SizedBox(height: 10.h),
            CustomText(
                text:  'This topic has no subtopics yet',
                fontSize: 40,
                textColor: AppColors.primaryText,
                fontFamily: 'oregular',
                width: 500,
                maxline: 1
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSubtopicList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
      itemCount: widget.subtopics.length,
      itemBuilder: (context, index) {
        final subtopic = widget.subtopics[index];
        return SubtopicCard(
          subtopic: subtopic,
          collectionName: widget.collectionName,
          index: index,
        );
      },
    );
  }
}

// Subtopic Card Widget
class SubtopicCard extends StatelessWidget {
  final SubtopicData subtopic;
  final String collectionName;
  final int index;

  const SubtopicCard({
    Key? key,
    required this.subtopic,
    required this.collectionName,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('📖 Tapped on subtopic: ${subtopic.title}');
        print('📝 Content items: ${subtopic.content.length}');

        // Navigate to ContentScreen
        AppNavigation.NavigationPush(
          context,
          ContentScreen(
            collectionName: collectionName,
            subtopic: subtopic,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.backgroundColor,
        ),
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(25.h),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 1.5),
              ),
              child: Center(
                child:  CustomText(
                    text:  '${index + 1}',
                    fontSize: 30,
                    textColor: AppColors.primaryText,
                    fontFamily: 'oregular',
                    width: 50,
                    maxline: 1,
                  align: TextAlign.center,

                ),

              ),
            ),
            SizedBox(width: 25.w),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: subtopic.title.isNotEmpty
                        ? subtopic.title
                        : subtopic.documentId,
                    fontSize: 42,
                    textColor: AppColors.primaryText,
                    fontFamily: 'omedium',
                    width: 700,
                    maxline: 3,
                  ),

                ],
              ),
            ),

            // Arrow icon
            Container(
              padding: EdgeInsets.all(8.w),

              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.green,
                size: 50.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function
Widget vSpace(double height) => SizedBox(height: height);