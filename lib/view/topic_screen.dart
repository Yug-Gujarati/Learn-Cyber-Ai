import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/utils/app_colors.dart';
import 'package:learning_cyber_security/utils/custom_appbar.dart';
import 'package:learning_cyber_security/utils/custom_text.dart';
import 'package:learning_cyber_security/utils/navigation.dart';
import 'package:learning_cyber_security/view/subTopic_screen.dart' hide vSpace;
import 'package:provider/provider.dart';

import '../model/topic_data.dart';
import '../view_model/fetch_data_provider.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          vSpace(100.h),
          CustomAppbar(
              onTap: () {
                 Navigator.pop(context);
              },
              name: "Topics"
          ),
          Expanded(
            child: Consumer<FetchDataProvider>(
              builder: (context, value, child) {
                // Loading state
                if (value.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(
                          color: Colors.white,
                          radius: 20,
                        ),
                        SizedBox(height: 16),
                        CustomText(
                            text: 'Loading topics...',
                            fontSize: 40,
                            textColor: AppColors.primaryText,
                            fontFamily: 'oregular',
                            width: 500,
                            maxline: 1
                        ),

                      ],
                    ),
                  );
                }

                // Error state
                if (value.error.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          CustomText(
                              text: 'Error Loading Data',
                              fontSize: 40,
                              textColor: AppColors.primaryText,
                              fontFamily: 'oregular',
                              width: 500,
                              maxline: 1
                          ),

                          const SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              value.error,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton.icon(
                            onPressed: () => value.fetchAllCollections(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty state
                if (value.topics.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_off,
                            color: Colors.grey,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          CustomText(
                              text: 'No Topics Found',
                              fontSize: 40,
                              textColor: AppColors.primaryText,
                              fontFamily: 'oregular',
                              width: 500,
                              maxline: 1
                          ),

                          const SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomText(
                                text: "Something went wrong, please check your internet connection",
                                fontSize: 50.sp,
                                textColor: AppColors.primaryText,
                                fontFamily: 'omedium',
                                width: 600,
                                maxline: 2),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => value.fetchAllCollections(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Success state - show list of topics
                return RefreshIndicator(
                  onRefresh: () => value.fetchAllCollections(),
                  color: Colors.blue,
                  child: ListView.builder(
                    padding: EdgeInsets.all(30.w),
                    itemCount: value.topics.length,
                    itemBuilder: (context, index) {
                      final topic = value.topics[index];
                      return TopicCard(topic: topic);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Topic Card Widget - Click to see subtopics
class TopicCard extends StatelessWidget {
  final TopicData topic;

  const TopicCard({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigation.NavigationPush(
          context,
          SubtopicScreen(
            collectionName: topic.collectionName,
            subtopics: topic.documents,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(30.h),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.folder,
                color: Colors.blue,
                size: 35.w,
              ),
            ),
            SizedBox(width: 25.w),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: topic.collectionName,
                    fontSize: 42,
                    textColor: AppColors.primaryText,
                    fontFamily: 'omedium',
                    width: 750,
                    maxline: 2,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: '${topic.documents.length} subtopic${topic.documents.length != 1 ? 's' : ''}',
                    fontSize: 35,
                    textColor: AppColors.primaryText.withOpacity(0.6),
                    fontFamily: 'oregular',
                    width: 750,
                    maxline: 1,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.blue,
              size: 50.w,
            ),
          ],
        ),
      ),
    );
  }
}