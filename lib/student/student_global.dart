import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class ExamNotifier extends ChangeNotifier {
  int currentQuestion = 0;
  Map answers = {};
  Duration? end;
  int endMinutes = 0;
  int endSeconds = 0;
  // questions count
  int count = 0;
  double legendHeight = 0;
  void setQuestionsCount(int count) {
    this.count = count;
  }

  void setEnd(Duration end) {
    this.end = end;
    endMinutes = end.inMinutes;
    endSeconds = end.inSeconds - endMinutes * 60;
    notifyListeners();
    decrementTime();
  }

  void decrementTime() {
    if (endMinutes <= 0 && endSeconds <= 0) return;

    endSeconds--;
    if (endSeconds < 0) {
      endSeconds = 59;
      endMinutes = endMinutes - 1;
    }
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), decrementTime);
  }

  void setLegendHeight(double height) {
    legendHeight = height;
    notifyListeners();
  }

  bool isAnswered(String question) {
    return answers[question] != null;
  }

  void goToQuestion(int index) {
    currentQuestion = index;
    notifyListeners();
  }

  void selectAnswer(String question, String answer, bool isMulti) {
    /// selects/deleselects mcq choices
    // if it's a single-answer-question, change the whole answer. Otherwise, delete or select the answer
    if (!isMulti) {
      answers[question] = [answer];
    } else {
      if (answers[question] == null) {
        answers[question] = [answer];
      } else {
        if (isSelected(question, answer)) {
          answers[question].remove(answer);
          // if the question has no answers, remove it from answered questions
          if (answers[question].isEmpty) {
            answers.remove(question);
          }
        } else {
          answers[question].add(answer);
        }
      }
    }
    notifyListeners();
  }

  void changeWrittenAnswer(String question, String answer) {
    /// change written questions answers as the student type
    // if the question has no answers, remove it from answered questions
    String oldAnswer = answers[question] ?? "";
    if (answer == "") {
      answers.remove(question);
      notifyListeners();
    } else {
      answers[question] = answer;
    }
    if (oldAnswer == "") {
      notifyListeners();
    }
    // notifyListeners();
  }

  bool isSelected(String question, String answer) {
    if (answers[question] == null) {
      return false;
    }

    if (answers[question].contains(answer)) {
      return true;
    }
    return false;
  }

  void nextQuestion() {
    if (currentQuestion >= count - 1) {
      return;
    }
    currentQuestion++;
    notifyListeners();
  }

  void prevQuestion() {
    if (currentQuestion < 1) {
      return;
    }
    currentQuestion--;
    notifyListeners();
  }

  Future<String> sendExam(String uid, String exam, bool force) async {
    if (getPercentageSolved != 1 && !force) {
      return "There are ${(1 - getPercentageSolved) * count} questions unsolved. Are you sure you want to submit?";
    }
    DocumentReference studentAnswerRef = Dbs.firestore
        .collection("exams")
        .doc(exam)
        .collection("studentAnswers")
        .doc(uid);

    studentAnswerRef.update({"answers": answers, "submit": true});

    return "Saved";
  }

  String getWrittenAnswer(String question) {
    if (answers[question] == null) {
      return "";
    }
    return answers[question];
  }

  void delete() {
    currentQuestion = 0;
    answers = {};
    end = null;
    endMinutes = 0;
    endSeconds = 0;
    count = 0;
    legendHeight = 0;
  }

  @override
  void dispose() {
    delete();
    super.dispose();
  }

  int get getCurrentQuestion => currentQuestion;
  double get getPercentageSolved => answers.length / count;
  double get getLegendHeight => legendHeight;
  String get getEndMinutes => end != null ? "$endMinutes".padLeft(2, "0") : "∞";
  String get getEndSeconds => end != null ? "$endSeconds".padLeft(2, "0") : "∞";
}
