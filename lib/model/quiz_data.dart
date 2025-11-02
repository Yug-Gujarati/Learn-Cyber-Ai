// question_data.dart
import 'dart:convert';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionData {
  final String question;
  final List<String> options;
  final String answer;

  QuestionData({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuestionData.fromMap(Map<String, dynamic> map) {
    return QuestionData(
      question: map['question']?.toString() ?? '',
      options: map['options'] is List
          ? List<String>.from(map['options'])
          : [],
      answer: map['answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }

  @override
  String toString() {
    return 'QuestionData(question: $question, options: ${options.length}, answer: $answer)';
  }
}




class QuizData {
  final String documentId;
  final String quizTitle;
  final List<QuestionData> questions;

  QuizData({
    required this.documentId,
    required this.quizTitle,
    required this.questions,
  });

  factory QuizData.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      print('📝 Parsing quiz document: ${doc.id}');
      print('📋 Raw data: $data');

      // Parse quiz title
      String quizTitle = data['quizTitle']?.toString() ?? '';

      // Parse questions array
      List<QuestionData> questionsList = [];

      if (data.containsKey('quiz') && data['quiz'] != null) {
        var quizData = data['quiz'];
        print('📝 Quiz field type: ${quizData.runtimeType}');

        // Handle if quiz is a JSON string
        if (quizData is String) {
          print('⚠️ Quiz is a STRING (JSON), attempting to parse...');
          try {
            var decoded = json.decode(quizData);
            print('✅ JSON decoded successfully');
            quizData = decoded;
          } catch (e) {
            print('❌ Failed to parse JSON string: $e');
          }
        }

        // Extract quiz data
        if (quizData is Map) {
          // Get quizTitle if it exists
          if (quizData.containsKey('quizTitle')) {
            quizTitle = quizData['quizTitle']?.toString() ?? quizTitle;
          }

          // Get questions array
          if (quizData.containsKey('questions') && quizData['questions'] is List) {
            var questionsData = quizData['questions'] as List;
            print('✅ Found ${questionsData.length} questions');

            for (int i = 0; i < questionsData.length; i++) {
              try {
                var item = questionsData[i];

                Map<String, dynamic> itemMap;
                if (item is Map<String, dynamic>) {
                  itemMap = item;
                } else if (item is Map) {
                  itemMap = Map<String, dynamic>.from(item);
                } else {
                  print('  ⚠️ Question $i is not a Map, skipping');
                  continue;
                }

                QuestionData question = QuestionData.fromMap(itemMap);
                questionsList.add(question);
                print('  ✅ Question $i parsed: ${question.question.substring(0, question.question.length > 30 ? 30 : question.question.length)}...');
              } catch (e) {
                print('  ❌ Error parsing question $i: $e');
              }
            }
          } else {
            print('❌ No questions array found in quiz data');
          }
        }
      } else {
        print('⚠️ No quiz field found in document');
      }

      print('✅ Total questions parsed: ${questionsList.length}');

      return QuizData(
        documentId: doc.id,
        quizTitle: quizTitle,
        questions: questionsList,
      );
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR in QuizData.fromFirestore: $e');
      print('Stack trace: $stackTrace');
      print('Document ID: ${doc.id}');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'quizTitle': quizTitle,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'QuizData(documentId: $documentId, title: $quizTitle, questions: ${questions.length})';
  }
}