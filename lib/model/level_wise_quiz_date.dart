class LevelQuizLevel {
  final int level;
  final String title;
  final String description;
  final String category;
  final List<QuestionData> questions;

  LevelQuizLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
  });

  factory LevelQuizLevel.fromFirestore(Map<String, dynamic> json) {
    final questionList = (json['questions'] as List<dynamic>?)
        ?.map((q) => QuestionData.fromMap(q as Map<String, dynamic>))
        .toList() ??
        [];
    return LevelQuizLevel(
      level: json['level'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      questions: questionList,
    );
  }
}

class QuestionData {
  final String question;
  final List<String> options;
  final String answer;

  QuestionData({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuestionData.fromMap(Map<String, dynamic> json) {
    return QuestionData(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? '',
    );
  }
}
