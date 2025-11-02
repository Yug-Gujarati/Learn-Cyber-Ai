// level_quiz_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/level_wise_quiz_date.dart';

class LevelQuizProvider extends ChangeNotifier {
  // State variables
  List<LevelQuizLevel> _levels = [];
  bool _isLoading = true;
  String? _error;

  // Quiz state
  int _currentLevelIndex = 0;
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  bool _showResults = false;
  int _correctAnswers = 0;
  bool _isSubmitting = false;

  LevelQuizProvider() {
    fetchLevelQuizzes();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LevelQuizLevel> get levels => _levels;
  int get totalLevels => _levels.length;

  LevelQuizLevel? get currentLevel =>
      _levels.isNotEmpty ? _levels[_currentLevelIndex] : null;

  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, String> get userAnswers => _userAnswers;
  bool get showResults => _showResults;
  int get correctAnswers => _correctAnswers;
  bool get isSubmitting => _isSubmitting;

  QuestionData? get currentQuestion =>
      currentLevel != null ? currentLevel!.questions[_currentQuestionIndex] : null;

  int get totalQuestions => currentLevel?.questions.length ?? 0;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get canSubmit => _userAnswers.length == totalQuestions;

  double get progressPercentage =>
      totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0;
  double get scorePercentage =>
      totalQuestions > 0 ? (_correctAnswers / totalQuestions) * 100 : 0;
  bool get hasPassed => scorePercentage >= 70;

  // ADDED: Getter for answered count (from quiz_provider)
  int get answeredCount => _userAnswers.length;

  // Fetch all level quizzes
  Future<void> fetchLevelQuizzes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('levelWiseQuiz').get();

      _levels = snapshot.docs.map((doc) {
        // Parse the stringified JSON field
        final quizString = doc['quiz'] as String? ?? '{}';
        final quizDataMap = jsonDecode(quizString) as Map<String, dynamic>;
        return LevelQuizLevel.fromFirestore(quizDataMap);
      }).toList();

      // Sort levels by extracting the level number from title
      _levels.sort((a, b) {
        // Extract numbers from titles like "Level 1", "Level 2", etc.
        final numA = _extractLevelNumber(a.title);
        final numB = _extractLevelNumber(b.title);
        return numA.compareTo(numB);
      });

      _error = null;
      print('✅ Loaded ${_levels.length} levels (sorted)');
    } catch (e, st) {
      _error = 'Failed to load quizzes: $e';
      print('❌ $e');
      print(st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to extract level number from title
  int _extractLevelNumber(String title) {
    // Try to find numbers in the title
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(title);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }
    return 0;
  }

  // Select a level
  void selectLevel(int index) {
    if (index < 0 || index >= _levels.length) return;
    _currentLevelIndex = index;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _showResults = false;
    _correctAnswers = 0;
    notifyListeners();
  }

  // Select an answer for current question
  void selectAnswer(String answer) {
    if (currentLevel == null) return;
    _userAnswers[_currentQuestionIndex] = answer;
    print('✅ Selected answer for Q${_currentQuestionIndex + 1}: $answer');
    notifyListeners();
  }

  // Navigate to next question
  void nextQuestion() {
    if (currentLevel == null) return;
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      print('➡️ Moved to question ${_currentQuestionIndex + 1}');
      notifyListeners();
    }
  }

  // Navigate to previous question
  void previousQuestion() {
    if (currentLevel == null) return;
    if (!isFirstQuestion) {
      _currentQuestionIndex--;
      print('⬅️ Moved to question ${_currentQuestionIndex + 1}');
      notifyListeners();
    }
  }

  // Jump to specific question
  void goToQuestion(int index) {
    if (currentLevel == null) return;
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      print('🎯 Jumped to question ${_currentQuestionIndex + 1}');
      notifyListeners();
    }
  }

  // Submit the quiz
  void submitQuiz() {
    if (currentLevel == null || !canSubmit) {
      print('⚠️ Cannot submit: Not all questions answered');
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    _correctAnswers = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (_userAnswers[i] == currentLevel!.questions[i].answer) {
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

  // Retake quiz
  void retakeQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _showResults = false;
    _correctAnswers = 0;
    _isSubmitting = false;

    print('🔄 Quiz reset - Ready to retake');
    notifyListeners();
  }

  // Helper - get unanswered questions
  List<int> getUnansweredQuestions() {
    List<int> unanswered = [];
    for (int i = 0; i < totalQuestions; i++) {
      if (!_userAnswers.containsKey(i)) {
        unanswered.add(i);
      }
    }
    return unanswered;
  }

  // Get user's answer for a question
  String? getUserAnswer(int questionIndex) {
    return _userAnswers[questionIndex];
  }

  // Get correct answer for a question
  String? getCorrectAnswer(int questionIndex) {
    if (currentLevel == null) return null;
    return currentLevel!.questions[questionIndex].answer;
  }

  // ============================================================
  // ADDED FUNCTIONS FROM quiz_provider.dart
  // ============================================================

  // Check if a specific question is answered
  bool isQuestionAnswered(int index) {
    return _userAnswers.containsKey(index);
  }

  // Check if a specific answer is correct
  bool isAnswerCorrect(int questionIndex) {
    if (currentLevel == null) return false;
    return _userAnswers[questionIndex] ==
        currentLevel!.questions[questionIndex].answer;
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
    if (currentLevel == null) return {};
    return {
      'levelIndex': _currentLevelIndex,
      'currentQuestionIndex': _currentQuestionIndex,
      'userAnswers': _userAnswers,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Restore progress (for future persistence feature)
  void restoreProgress(Map<String, dynamic> progress) {
    if (currentLevel == null) return;
    if (progress['levelIndex'] == _currentLevelIndex) {
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
    print('🧹 LevelQuizProvider disposed');
    super.dispose();
  }
}