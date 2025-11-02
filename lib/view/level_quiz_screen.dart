// level_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:learning_cyber_security/utils/app_colors.dart';
import 'package:learning_cyber_security/utils/custom_appbar.dart';
import 'package:learning_cyber_security/utils/navigation.dart';
import 'package:learning_cyber_security/view_model/level_quiz_provider.dart';

class LevelQuizScreen extends StatelessWidget {
  final int levelIndex;

  const LevelQuizScreen({
    Key? key,
    required this.levelIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelQuizProvider>(
      builder: (context, provider, child) {
        final level = provider.currentLevel;

        print("🔍 Current Level Index: ${provider.currentQuestionIndex}");
        print("📝 Current Level: ${level?.title}");
        print("❓ Questions count: ${level?.questions.length}");

        if (level == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: Text(
                'No quiz found!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return WillPopScope(
          onWillPop: () async {
            if (provider.showResults || !provider.hasProgress()) {
              return true;
            }
            _showExitConfirmation(context);
            return false;
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Column(
              children: [
                vSpace(100.h),
                CustomAppbar(
                  onTap: () {
                    if (provider.showResults || !provider.hasProgress()) {
                      AppNavigation.NavigationBack(context);
                    } else {
                      _showExitConfirmation(context);
                    }
                  },
                  name: level.title,
                ),
                Expanded(
                  child: provider.showResults ? _ResultsScreen() : _QuizScreen(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Exit Quiz?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppNavigation.NavigationBack(context);
            },
            child: Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Quiz Screen Widget
class _QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(30.w),
            child: _QuestionContent(),
          ),
        ),
        _NavigationButtons(),
      ],
    );
  }
}

// Progress Bar Widget
class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${provider.answeredCount}/${provider.totalQuestions} answered',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 30.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.progressPercentage,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// Question Content Widget
class _QuestionContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();
    final question = provider.currentQuestion;

    if (question == null) return SizedBox.shrink();
    print("❓ Current Question: ${question.question}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${provider.currentQuestionIndex + 1} of ${provider.totalQuestions}',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 35.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(25.h),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Text(
            question.question,
            style: TextStyle(
              color: Colors.white,
              fontSize: 42.sp,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 30.h),
        ...question.options.asMap().entries.map((entry) {
          return _OptionCard(
            option: entry.value,
            index: entry.key,
          );
        }).toList(),
      ],
    );
  }
}

// Option Card Widget
class _OptionCard extends StatelessWidget {
  final String option;
  final int index;

  const _OptionCard({
    required this.option,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();
    final isSelected = provider.getUserAnswer(provider.currentQuestionIndex) == option;

    return GestureDetector(
      onTap: () => provider.selectAnswer(option),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(25.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[800]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 35.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontSize: 38.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 25.w,
              ),
          ],
        ),
      ),
    );
  }
}

// Navigation Buttons Widget
class _NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();

    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (!provider.isFirstQuestion) ...[
            Expanded(
              child: _PreviousButton(),
            ),
            SizedBox(width: 20.w),
          ],
          Expanded(
            child: _NextSubmitButton(),
          ),
        ],
      ),
    );
  }
}

// Previous Button Widget
class _PreviousButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<LevelQuizProvider>();

    return GestureDetector(
      onTap: provider.previousQuestion,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 20),
            SizedBox(width: 10.w),
            Text(
              'Previous',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Next/Submit Button Widget
class _NextSubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();

    return GestureDetector(
      onTap: () {
        if (provider.isLastQuestion && provider.canSubmit) {
          provider.submitQuiz();
        } else if (!provider.isLastQuestion) {
          provider.nextQuestion();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: (provider.isLastQuestion && provider.canSubmit)
                ? [Colors.green, Colors.green[700]!]
                : [Colors.blue, Colors.blue[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (provider.isLastQuestion && provider.canSubmit)
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.isLastQuestion
                  ? (provider.canSubmit ? 'Submit Quiz' : 'Answer All')
                  : 'Next',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              provider.isLastQuestion ? Icons.check : Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Results Screen Widget
class _ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(30.w),
      child: Column(
        children: [
          _ScoreCard(),
          SizedBox(height: 40.h),
          Text(
            'Review Answers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          ...provider.currentLevel!.questions.asMap().entries.map((entry) {
            return _ReviewCard(questionIndex: entry.key);
          }).toList(),
          SizedBox(height: 30.h),
          _ActionButtons(),
        ],
      ),
    );
  }
}

// Score Card Widget
class _ScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();

    return Container(
      padding: EdgeInsets.all(40.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: provider.hasPassed
              ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.05)]
              : [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: provider.hasPassed ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            provider.hasPassed ? Icons.emoji_events : Icons.refresh,
            color: provider.hasPassed ? Colors.green : Colors.orange,
            size: 80,
          ),
          SizedBox(height: 20.h),
          Text(
            provider.hasPassed ? 'Congratulations!' : 'Keep Learning!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 55.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'Your Score',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 35.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '${provider.scorePercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: provider.hasPassed ? Colors.green : Colors.orange,
              fontSize: 80.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '${provider.correctAnswers} out of ${provider.totalQuestions} correct',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 38.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// Review Card Widget
class _ReviewCard extends StatelessWidget {
  final int questionIndex;

  const _ReviewCard({required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelQuizProvider>();
    final question = provider.currentLevel!.questions[questionIndex];
    final userAnswer = provider.getUserAnswer(questionIndex);
    final isCorrect = provider.isAnswerCorrect(questionIndex);

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(25.h),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCorrect ? 'Correct' : 'Incorrect',
                  style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Text(
                'Q${questionIndex + 1}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            question.question,
            style: TextStyle(
              color: Colors.white,
              fontSize: 38.sp,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          SizedBox(height: 15.h),
          if (userAnswer != null) ...[
            Text(
              'Your answer:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 32.sp,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              userAnswer,
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (!isCorrect) ...[
            SizedBox(height: 10.h),
            Text(
              'Correct answer:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 32.sp,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              question.answer,
              style: TextStyle(
                color: Colors.green,
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Action Buttons Widget
class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<LevelQuizProvider>();

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: provider.retakeQuiz,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.white, size: 20),
                  SizedBox(width: 10.w),
                  Text(
                    'Retake Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: GestureDetector(
            onTap: () => AppNavigation.NavigationBack(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue[700]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home, color: Colors.white, size: 20),
                  SizedBox(width: 10.w),
                  Text(
                    'Finish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget vSpace(double height) => SizedBox(height: height);