// quiz_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_cyber_security/model/quiz_data.dart';

class QuizProvider extends ChangeNotifier {
  final String subtopicTitle;

  QuizProvider({required this.subtopicTitle}) {
    _loadQuizData();
  }

  // State variables - Quiz Data Loading
  QuizData? _quizData;
  bool _isLoading = true;
  String? _error;

  // State variables - Quiz Progress
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  bool _showResults = false;
  int _correctAnswers = 0;
  bool _isSubmitting = false;

  // Getters - Loading State
  QuizData? get quizData => _quizData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasQuiz => _quizData != null && _quizData!.questions.isNotEmpty;

  // Getters - Quiz State
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, String> get userAnswers => _userAnswers;
  bool get showResults => _showResults;
  int get correctAnswers => _correctAnswers;
  bool get isSubmitting => _isSubmitting;

  int get totalQuestions => _quizData?.questions.length ?? 0;
  int get answeredCount => _userAnswers.length;

  QuestionData? get currentQuestion =>
      hasQuiz ? _quizData!.questions[_currentQuestionIndex] : null;
  String? get currentAnswer => _userAnswers[_currentQuestionIndex];

  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get canSubmit => _userAnswers.length == totalQuestions;

  double get progressPercentage =>
      totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0;
  double get scorePercentage =>
      totalQuestions > 0 ? (_correctAnswers / totalQuestions) * 100 : 0;
  bool get hasPassed => scorePercentage >= 70;

  // Load quiz data from Firestore
  Future<void> _loadQuizData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading quiz for: $subtopicTitle');

      // Primary Strategy: Fetch by document ID (since document name = subtopic name)
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('TopicWiseQuiz')
          .doc(subtopicTitle)
          .get();

      if (docSnapshot.exists) {
        _quizData = QuizData.fromFirestore(docSnapshot);
        _error = null;
        print('✅ Quiz loaded successfully!');
        print('📝 Quiz title: ${_quizData!.quizTitle}');
        print('❓ Total questions: ${_quizData!.questions.length}');
      } else {
        // Fallback Strategy: Try with " - Quiz" suffix in document ID
        print('⚠️ Document not found, trying with " - Quiz" suffix...');
        String quizDocId = '$subtopicTitle - Quiz';

        DocumentSnapshot fallbackDoc = await FirebaseFirestore.instance
            .collection('TopicWiseQuiz')
            .doc(quizDocId)
            .get();

        if (fallbackDoc.exists) {
          _quizData = QuizData.fromFirestore(fallbackDoc);
          _error = null;
          print('✅ Quiz loaded with suffix!');
          print('📝 Quiz title: ${_quizData!.quizTitle}');
          print('❓ Total questions: ${_quizData!.questions.length}');
        } else {
          // Last Resort: Search by quizTitle field
          print('⚠️ Trying query by quizTitle field...');
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('TopicWiseQuiz')
              .where('quizTitle', isEqualTo: subtopicTitle)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            _quizData = QuizData.fromFirestore(querySnapshot.docs.first);
            _error = null;
            print('✅ Quiz loaded by query!');
            print('📝 Quiz title: ${_quizData!.quizTitle}');
            print('❓ Total questions: ${_quizData!.questions.length}');
          } else {
            _error = 'No quiz found for "$subtopicTitle"';
            print('❌ $_error');
            _logAvailableQuizzes();
          }
        }
      }
    } catch (e, stackTrace) {
      _error = 'Failed to load quiz: ${e.toString()}';
      print('❌ Error loading quiz: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to log available quizzes (for debugging)
  Future<void> _logAvailableQuizzes() async {
    try {
      final allQuizzes = await FirebaseFirestore.instance
          .collection('TopicWiseQuiz')
          .limit(10)
          .get();

      print('📚 Available quizzes in Firestore:');
      for (var doc in allQuizzes.docs) {
        final data = doc.data();
        print('  - Doc ID: ${doc.id}');
        print('    Quiz Title: ${data['quizTitle'] ?? 'No title'}');
      }
    } catch (e) {
      print('⚠️ Could not fetch available quizzes: $e');
    }
  }

  // Retry loading quiz
  Future<void> retryLoadQuiz() async {
    await _loadQuizData();
  }

  // Select an answer for current question
  void selectAnswer(String answer) {
    if (!hasQuiz) return;
    _userAnswers[_currentQuestionIndex] = answer;
    print('✅ Selected answer for Q${_currentQuestionIndex + 1}: $answer');
    notifyListeners();
  }

  // Navigate to next question
  void nextQuestion() {
    if (!hasQuiz) return;
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      print('➡️ Moved to question ${_currentQuestionIndex + 1}');
      notifyListeners();
    }
  }

  // Navigate to previous question
  void previousQuestion() {
    if (!hasQuiz) return;
    if (!isFirstQuestion) {
      _currentQuestionIndex--;
      print('⬅️ Moved to question ${_currentQuestionIndex + 1}');
      notifyListeners();
    }
  }

  // Jump to specific question
  void goToQuestion(int index) {
    if (!hasQuiz) return;
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      print('🎯 Jumped to question ${_currentQuestionIndex + 1}');
      notifyListeners();
    }
  }

  // Submit the quiz and calculate results
  void submitQuiz() {
    if (!hasQuiz || !canSubmit) {
      print('⚠️ Cannot submit: Not all questions answered');
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    // Calculate score
    _correctAnswers = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (_userAnswers[i] == _quizData!.questions[i].answer) {
        _correctAnswers++;
      }
    }

    _showResults = true;
    _isSubmitting = false;

    print('📊 Quiz completed!');
    print('✅ Correct answers: $_correctAnswers/$totalQuestions');
    print('📈 Score: ${scorePercentage.toStringAsFixed(1)}%');
    print(hasPassed ? '🎉 PASSED!' : '📚 Keep learning!');

    notifyListeners();
  }

  // Retake the quiz (reset everything)
  void retakeQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _showResults = false;
    _correctAnswers = 0;
    _isSubmitting = false;

    print('🔄 Quiz reset - Ready to retake');
    notifyListeners();
  }

  // Check if a specific question is answered
  bool isQuestionAnswered(int index) {
    return _userAnswers.containsKey(index);
  }

  // Check if a specific answer is correct
  bool isAnswerCorrect(int questionIndex) {
    if (!hasQuiz) return false;
    return _userAnswers[questionIndex] ==
        _quizData!.questions[questionIndex].answer;
  }

  // Get user's answer for a specific question
  String? getUserAnswer(int questionIndex) {
    return _userAnswers[questionIndex];
  }

  // Get correct answer for a specific question
  String? getCorrectAnswer(int questionIndex) {
    if (!hasQuiz) return null;
    return _quizData!.questions[questionIndex].answer;
  }

  // Get all unanswered question indices
  List<int> getUnansweredQuestions() {
    List<int> unanswered = [];
    for (int i = 0; i < totalQuestions; i++) {
      if (!_userAnswers.containsKey(i)) {
        unanswered.add(i);
      }
    }
    return unanswered;
  }

  // Auto-advance to next question after selecting answer (optional feature)
  void selectAnswerAndAdvance(String answer,
      {Duration delay = const Duration(milliseconds: 500)}) {
    selectAnswer(answer);

    if (!isLastQuestion) {
      Future.delayed(delay, () {
        if (!_showResults) {
          nextQuestion();
        }
      });
    }
  }

  // Get quiz statistics
  Map<String, dynamic> getQuizStats() {
    return {
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredCount,
      'correctAnswers': _correctAnswers,
      'incorrectAnswers': totalQuestions - _correctAnswers,
      'scorePercentage': scorePercentage,
      'passed': hasPassed,
      'currentQuestion': _currentQuestionIndex + 1,
    };
  }

  // Save progress (for future persistence feature)
  Map<String, dynamic> saveProgress() {
    if (!hasQuiz) return {};
    return {
      'quizId': _quizData!.documentId,
      'currentQuestionIndex': _currentQuestionIndex,
      'userAnswers': _userAnswers,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Restore progress (for future persistence feature)
  void restoreProgress(Map<String, dynamic> progress) {
    if (!hasQuiz) return;
    if (progress['quizId'] == _quizData!.documentId) {
      _currentQuestionIndex = progress['currentQuestionIndex'] ?? 0;
      _userAnswers = Map<int, String>.from(progress['userAnswers'] ?? {});
      print(
          '🔄 Progress restored: Question ${_currentQuestionIndex + 1}, ${_userAnswers.length} answers');
      notifyListeners();
    }
  }

  // Clear answer for current question
  void clearCurrentAnswer() {
    _userAnswers.remove(_currentQuestionIndex);
    print('🗑️ Cleared answer for question ${_currentQuestionIndex + 1}');
    notifyListeners();
  }

  // Check if there are any answers to prevent accidental exit
  bool hasProgress() {
    return _userAnswers.isNotEmpty;
  }

  @override
  void dispose() {
    print('🧹 QuizProvider disposed');
    super.dispose();
  }
}