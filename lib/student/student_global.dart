import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExamNotifier extends ChangeNotifier {
  int currentQuestion = 0;
  Map answers = {};
  // questions count
  int count = 0;

  void setQuestionsCount(int count) {
    this.count = count;
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
    if (answer == "") {
      answers.remove(question);
    } else {
      answers[question] = answer;
    }
    notifyListeners();
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
    DocumentReference studentAnswerRef = FirebaseFirestore.instance
        .collection("exams")
        .doc(exam)
        .collection(uid)
        .doc("data");

    var openTime = (await studentAnswerRef.get()).get("openTime");

    studentAnswerRef.set({"answers": answers, "openTime": openTime});

    return "Done";
  }

  String getWrittenAnswer(String question) {
    if (answers[question] == null) {
      return "";
    }
    return answers[question];
  }

  int get getCurrentQuestion => currentQuestion;
  double get getPercentageSolved => answers.length / count;
}
