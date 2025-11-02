import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_cyber_security/model/content_item.dart';
import 'package:learning_cyber_security/model/subtopic_data.dart';
import 'package:learning_cyber_security/utils/app_colors.dart';
import 'package:learning_cyber_security/utils/custom_appbar.dart';
import 'package:learning_cyber_security/utils/custome_buttom.dart';
import 'package:learning_cyber_security/utils/navigation.dart';
import 'package:learning_cyber_security/view/quiz_screen.dart';
import 'package:provider/provider.dart';
import '../view_model/bookmark_provider.dart';
import '../utils/custom_text.dart';

class ContentScreen extends StatefulWidget {
  final String collectionName;
  final SubtopicData subtopic;

  const ContentScreen({
    super.key,
    required this.collectionName,
    required this.subtopic,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  @override
  void initState() {
    super.initState();
    // Debug logging
    print('Opening content: ${widget.subtopic.title}');
    print('Collection name: ${widget.collectionName}');
    print('Content items: ${widget.subtopic.content.length}');
    print('Document ID: ${widget.subtopic.documentId}');
    print('Image: ${widget.subtopic.image}');

    for (int i = 0; i < widget.subtopic.content.length; i++) {
      var item = widget.subtopic.content[i];
      print('  Item $i: type="${item.type}", hasPath=${item.path != null}, path="${item.path}"');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        bool isBookmarked = bookmarkProvider.isBookmarked(
          widget.collectionName,
          widget.subtopic.documentId,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              SizedBox(
                child: widget.subtopic.content.isEmpty
                    ? _buildEmptyState()
                    : _buildContentList(),
              ),
              Positioned(
                top: 0,
                child: CustomAppbar(
                  onTap: () {
                    AppNavigation.NavigationBack(context);
                  },
                  name: widget.subtopic.title.isNotEmpty
                      ? widget.subtopic.title
                      : 'Content',
                ),
              ),
              // Bookmark button - positioned in top right
              Positioned(
                top: 110.h,
                right: 30.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isBookmarked ? Colors.blue : Colors.grey[700]!,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.blue : Colors.white,
                      size: 70.w,
                    ),
                    onPressed: () async {
                      await bookmarkProvider.toggleBookmark(
                        collectionName: widget.collectionName,
                        documentId: widget.subtopic.documentId,
                        title: widget.subtopic.title.isNotEmpty
                            ? widget.subtopic.title
                            : widget.subtopic.documentId,
                        image: widget.subtopic.image,
                        contentCount: widget.subtopic.content.length,
                      );

                      // Show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? 'Removed from bookmarks'
                                : 'Added to bookmarks',
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor:
                          isBookmarked ? Colors.grey[800] : Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: CustomeButtom(
            height: 100.h,
            width: 950.w,
            child: CustomText(
              text: "Start Quiz",
              fontSize: 200.sp,
              textColor: AppColors.primaryText,
              fontFamily: 'omedium',
              width: 900.w,
              maxline: 1,
              align: TextAlign.center,
            ),
            onTap: () {
              print("Starting quiz for: ${widget.subtopic.documentId}");
              AppNavigation.NavigationPush(
                context,
                QuizScreen(
                  subtopicTitle: widget.subtopic.documentId,
                ),
              );
            },
            isShowAd: false,
            color: Colors.blueAccent,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.grey, size: 80),
            SizedBox(height: 20.h),
            Text(
              'No Content Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'This subtopic has no content yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 230.h, bottom: 200.h),
      itemCount: widget.subtopic.content.length,
      itemBuilder: (context, index) {
        final item = widget.subtopic.content[index];
        return ContentWidget(item: item, index: index);
      },
    );
  }
}

// Content Widget - Renders different content types
class ContentWidget extends StatelessWidget {
  final ContentItem item;
  final int index;

  const ContentWidget({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🎨 Rendering item $index: ${item.type}');

    switch (item.type.toLowerCase()) {
      case 'heading':
        return _buildHeading();
      case 'subheading':
        return _buildSubheading();
      case 'paragraph':
        return _buildParagraph();
      case 'point':
        return _buildPoint();
      case 'image':
        return _buildImage();
      default:
        return _buildUnknownType();
    }
  }

  Widget _buildHeading() {
    return Padding(
      padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
      child: Container(
        padding: EdgeInsets.only(left: 15.w, bottom: 10.h),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.blue, width: 4),
          ),
        ),
        child: Text(
          item.text ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 50.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSubheading() {
    return Padding(
      padding: EdgeInsets.only(top: 30.h, bottom: 15.h),
      child: Text(
        item.text ?? '',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 45.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildParagraph() {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.h),
      child: Text(
        item.text ?? '',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 38.sp,
          height: 1.6,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildPoint() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, left: 15.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h, right: 20.w),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              item.text ?? '',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 38.sp,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    print('🖼️ Building image - item $index');
    print('  Path: "${item.path}"');
    print('  Path null: ${item.path == null}');
    print('  Path empty: ${item.path?.isEmpty ?? true}');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: (item.path != null && item.path!.trim().isNotEmpty)
            ? _buildImageFromPath(item.path!)
            : _buildNoImagePlaceholder(),
      ),
    );
  }

  Widget _buildImageFromPath(String path) {
    bool isNetworkImage =
        path.startsWith('http://') || path.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Network image error: $error');
          return _buildImageError('Failed to load: $path');
        },
      );
    } else {
      return Image.asset(
        "assets/$path",
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Asset image error: $error');
          return _buildImageError('Asset not found: $path');
        },
      );
    }
  }

  Widget _buildImageError(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey, size: 48),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 8),
            Text(
              'No image path provided',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownType() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Container(
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Unknown content type: ${item.type}',
                style: TextStyle(color: Colors.orange[200], fontSize: 14),
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