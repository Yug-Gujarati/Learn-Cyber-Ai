class DailyUpdate {
  final String title;
  final String content;

  DailyUpdate({
    required this.title,
    required this.content
  });

  factory DailyUpdate.fromJson(Map<String, dynamic> json) {
    return DailyUpdate(
      title: json['title'] ?? "No Title",
      content: json['content'] ?? "No Content"
    );
  }
}