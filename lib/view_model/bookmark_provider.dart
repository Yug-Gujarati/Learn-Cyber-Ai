import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/bookmark_data_model.dart';

class BookmarkProvider extends ChangeNotifier{
  static const String _bookmarksKey = 'bookmarked_documents';

  Map<String, BookmarkDataModel> _bookmarks = {};
  bool _isLoading = false;

  BookmarkProvider() {
    loadBookmarks();
  }

  bool get isLoading => _isLoading;

  // Get all bookmarks as a list
  List<BookmarkDataModel> get bookmarks => _bookmarks.values.toList();

  // Get bookmarks count
  int get bookmarksCount => _bookmarks.length;

  // Check if a document is bookmarked
  bool isBookmarked(String collectionName, String documentId) {
    String key = _makeKey(collectionName, documentId);
    return _bookmarks.containsKey(key);
  }

  // Add bookmark
  Future<void> addBookmark({
    required String collectionName,
    required String documentId,
    required String title,
    String? image,
    int? contentCount,
  }) async {
    try {
      String key = _makeKey(collectionName, documentId);

      BookmarkDataModel bookmark = BookmarkDataModel(
        collectionName: collectionName,
        documentId: documentId,
        title: title,
        image: image,
        contentCount: contentCount,
        bookmarkedAt: DateTime.now(),
      );

      _bookmarks[key] = bookmark;
      await _saveBookmarks();
      notifyListeners();

      print('✅ Bookmark added: $title');
    } catch (e) {
      print('❌ Error adding bookmark: $e');
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(String collectionName, String documentId) async {
    try {
      String key = _makeKey(collectionName, documentId);

      if (_bookmarks.containsKey(key)) {
        _bookmarks.remove(key);
        await _saveBookmarks();
        notifyListeners();

        print('✅ Bookmark removed');
      }
    } catch (e) {
      print('❌ Error removing bookmark: $e');
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark({
    required String collectionName,
    required String documentId,
    required String title,
    String? image,
    int? contentCount,
  }) async {
    if (isBookmarked(collectionName, documentId)) {
      await removeBookmark(collectionName, documentId);
    } else {
      await addBookmark(
        collectionName: collectionName,
        documentId: documentId,
        title: title,
        image: image,
        contentCount: contentCount,
      );
    }
  }

  // Load bookmarks from shared preferences
  Future<void> loadBookmarks() async {
    try {
      _isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? bookmarksJson = prefs.getString(_bookmarksKey);

      if (bookmarksJson != null && bookmarksJson.isNotEmpty) {
        Map<String, dynamic> decoded = json.decode(bookmarksJson);

        _bookmarks = decoded.map((key, value) {
          return MapEntry(
            key,
            BookmarkDataModel.fromMap(value as Map<String, dynamic>),
          );
        });

        print('📚 Loaded ${_bookmarks.length} bookmarks from local storage');
      } else {
        print('📚 No bookmarks found in local storage');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading bookmarks: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save bookmarks to shared preferences
  Future<void> _saveBookmarks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> toSave = _bookmarks.map((key, value) {
        return MapEntry(key, value.toMap());
      });

      String bookmarksJson = json.encode(toSave);
      await prefs.setString(_bookmarksKey, bookmarksJson);

      print('💾 Saved ${_bookmarks.length} bookmarks to local storage');
    } catch (e) {
      print('❌ Error saving bookmarks: $e');
    }
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      _bookmarks.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
      notifyListeners();

      print('🗑️ All bookmarks cleared');
    } catch (e) {
      print('❌ Error clearing bookmarks: $e');
    }
  }

  // Helper to create unique key
  String _makeKey(String collectionName, String documentId) {
    return '$collectionName::$documentId';
  }
}