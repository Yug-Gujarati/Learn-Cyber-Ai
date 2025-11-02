class BookmarkDataModel {
  final String collectionName;
  final String documentId;
  final String title;
  final String? image;
  final int? contentCount;
  final DateTime bookmarkedAt;

  BookmarkDataModel({
    required this.collectionName,
    required this.documentId,
    required this.title,
    this.image,
    this.contentCount,
    required this.bookmarkedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionName': collectionName,
      'documentId': documentId,
      'title': title,
      'image': image,
      'contentCount': contentCount,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
    };
  }

  factory BookmarkDataModel.fromMap(Map<String, dynamic> map) {
    return BookmarkDataModel(
      collectionName: map['collectionName'] ?? '',
      documentId: map['documentId'] ?? '',
      title: map['title'] ?? '',
      image: map['image'],
      contentCount: map['contentCount'],
      bookmarkedAt: DateTime.parse(map['bookmarkedAt']),
    );
  }
}