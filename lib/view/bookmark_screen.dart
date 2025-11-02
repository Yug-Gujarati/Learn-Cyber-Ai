import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/bookmark_data_model.dart';
import '../view_model/bookmark_provider.dart';
import '../view_model/fetch_data_provider.dart';
import '../utils/app_colors.dart';
import '../utils/custom_text.dart';
import 'content_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Bookmarks',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              if (bookmarkProvider.bookmarksCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear all bookmarks',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Color(0xFF2D2D2D),
                        title: const Text(
                          'Clear All Bookmarks?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'This will remove all bookmarks. This action cannot be undone.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              bookmarkProvider.clearAllBookmarks();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All bookmarks cleared'),
                                  backgroundColor: Colors.grey,
                                ),
                              );
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (bookmarkProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (bookmarkProvider.bookmarks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Bookmarks Yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bookmark documents to access them quickly',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Sort bookmarks by date (newest first)
          final sortedBookmarks = bookmarkProvider.bookmarks.toList()
            ..sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedBookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = sortedBookmarks[index];
              return BookmarkCard(bookmark: bookmark);
            },
          );
        },
      ),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  final BookmarkDataModel bookmark;

  const BookmarkCard({Key? key, required this.bookmark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Fetch the document and navigate to ContentScreen
          final fetchProvider = Provider.of<FetchDataProvider>(
            context,
            listen: false,
          );

          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Loading content...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );

          try {
            final document = await fetchProvider.fetchDocument(
              bookmark.collectionName,
              bookmark.documentId,
            );

            Navigator.pop(context); // Close loading dialog

            if (document != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContentScreen(
                    collectionName: bookmark.collectionName,
                    subtopic: document,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document not found'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            Navigator.pop(context); // Close loading dialog

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading document: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bookmark.collectionName,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (bookmark.contentCount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${bookmark.contentCount} items',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, child) {
                  return IconButton(
                    icon: const Icon(Icons.bookmark),
                    color: Colors.blue,
                    onPressed: () {
                      bookmarkProvider.removeBookmark(
                        bookmark.collectionName,
                        bookmark.documentId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from bookmarks'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.grey,
                        ),
                      );
                    },
                    tooltip: 'Remove bookmark',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}