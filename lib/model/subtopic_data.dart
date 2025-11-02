import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_item.dart';

class SubtopicData {
  final String documentId;
  final String title;
  final String image;
  final String key;
  final List<ContentItem> content;

  SubtopicData({
    required this.documentId,
    required this.title,
    required this.image,
    required this.key,
    required this.content,
  });

  factory SubtopicData.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      print('📄 Parsing document: ${doc.id}');
      String title = data['title']?.toString() ?? '';
      String image = data['image']?.toString() ?? '';
      String key = data['key']?.toString() ?? '';

      List<ContentItem> contentList = [];

      if (data.containsKey('content') && data['content'] != null) {
        var contentData = data['content'];
        print('📝 Content type: ${contentData.runtimeType}');

        // FIXED: Handle JSON string properly
        if (contentData is String) {
          print('⚠️ Content is a JSON STRING, parsing...');
          try {
            // Decode the JSON string
            var decoded = json.decode(contentData);
            print('✅ JSON decoded successfully');

            // The decoded data should be a Map
            if (decoded is Map) {
              // Extract the content array from the decoded map
              if (decoded.containsKey('content') && decoded['content'] is List) {
                contentData = decoded['content'];
                print('✅ Extracted content array with ${contentData.length} items');
              } else {
                print('❌ Decoded JSON does not contain content array');
                contentData = [];
              }
            } else if (decoded is List) {
              contentData = decoded;
              print('✅ Decoded directly to list with ${contentData.length} items');
            }
          } catch (e) {
            print('❌ JSON parsing failed: $e');
            print('Content preview: ${contentData.length > 200 ? contentData.substring(0, 200) : contentData}');
            contentData = [];
          }
        }

        // Now process the content list
        if (contentData is List) {
          print('✅ Processing ${contentData.length} content items');

          for (int i = 0; i < contentData.length; i++) {
            try {
              var item = contentData[i];

              Map<String, dynamic> itemMap;
              if (item is Map<String, dynamic>) {
                itemMap = item;
              } else if (item is Map) {
                itemMap = Map<String, dynamic>.from(item);
              } else {
                print('  ⚠️ Item $i is not a Map, skipping');
                continue;
              }

              ContentItem contentItem = ContentItem.fromMap(itemMap);
              contentList.add(contentItem);
              print('  ✅ Item $i: ${contentItem.type}');
            } catch (e) {
              print('  ❌ Error parsing item $i: $e');
            }
          }
        } else {
          print('❌ Content is not a List after parsing!');
          print('   Type: ${contentData.runtimeType}');
        }
      } else {
        print('⚠️ No content field in document');
      }

      print('✅ Parsed ${contentList.length} content items');

      return SubtopicData(
        documentId: doc.id,
        title: title,
        image: image,
        key: key,
        content: contentList,
      );
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR in SubtopicData.fromFirestore: $e');
      print('Stack trace: $stackTrace');
      print('Document ID: ${doc.id}');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image': image,
      'key': key,
      'content': content.map((item) => item.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'SubtopicData(documentId: $documentId, title: $title, key: $key, contentItems: ${content.length})';
  }
}