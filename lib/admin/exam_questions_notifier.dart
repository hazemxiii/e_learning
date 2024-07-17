import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum QuestionTypes { written, mcq }

class ExamQuestionsNotifier extends ChangeNotifier {
  List<Map> questions = [];

  void addQuestion(
    QuestionTypes type,
  ) {
    /// add an empty question with extra slots for mcq questions
    if (type == QuestionTypes.mcq) {
      questions.add({
        "question": "",
        "type": type,
        "choices": [""],
        "correct": [],
        "isMulti": false
      });
    } else if (type == QuestionTypes.written) {
      questions.add({
        "question": "",
        "type": type,
      });
    }

    notifyListeners();
  }

  void updateQuestion(int index, String key, var value) {
    /// updates the question itself
    questions[index][key] = value;
  }

  void addChoice(int index) {
    /// add an emtpy choice to the mcq
    questions[index]['choices'].add("");
    notifyListeners();
  }

  Future<String> sendExam() async {
    /// sends the exam to the db
    if (questions.isEmpty) {
      return "Exam must contain at least 1 question";
    }
    FirebaseFirestore db = FirebaseFirestore.instance;
    final batch = db.batch();

    String id = DateTime.now().toString();
    final exam = db.collection("exams").doc(id);
    final examAnswers = db.collection("examsAsnwers").doc(id);

// create the documents for the exam and a separate one for answers
    exam.set({"time": id});
    examAnswers.set({"time": id});
    for (int i = 0; i < questions.length; i++) {
      Map questionMap = questions[i];
      String question = questionMap['question'];

      final questionRef = exam.collection("questions").doc(question);
      final questionAnswerRef =
          examAnswers.collection("questions").doc(question);

      if (question == "") {
        return "Question $i is missing";
      }

      QuestionTypes type = questionMap['type'];
      if (type == QuestionTypes.mcq) {
        List choices = questionMap['choices'];
        List correct = questionMap['correct'];

        if (choices.length < 3) {
          return "Question $i doesn't have enough choices ";
        }

        if (correct.isEmpty) {
          return "Select correct answers for question $i";
        }

// don't take the last element of choices as it's an emtpy one
        batch.set(questionRef,
            {"choices": choices.sublist(0, choices.length - 1), "type": "mcq"});
        batch.set(questionAnswerRef, {"correct": correct});
      } else {
        batch.set(questionRef, {"type": "written"});
      }
    }
    batch.commit().then((_) {}, onError: (e) {
      return e.toString();
    });

    return "Saved";
  }

  void updateChoice(int index, int choiceIndex, String value) {
    /// update the text of a choice
    List choices = questions[index]['choices'];
    choices[choiceIndex] = value;
    // if it's the last choice being updated, add an empty one at the end
    if (choiceIndex == choices.length - 1) {
      choices.add("");
    }
    notifyListeners();
  }

  void deleteChoice(int index, int choiceIndex) {
    /// deletes a choice
    List choices = questions[index]['choices'];
    if (choiceIndex < choices.length - 1) {
      choices.removeAt(choiceIndex);
    }

    notifyListeners();
  }

  void selectChoice(int index, int choiceIndex, bool select) {
    /// mark a choice as a correct answer
    String choice = questions[index]['choices'][choiceIndex];
    // add it if it's multiple selection or mark it as the whole correct answers if it's signle selection
    if (questions[index]["isMulti"]) {
      if (select) {
        questions[index]['correct'].add(choice);
      } else {
        questions[index]['correct'].remove(choice);
      }
    } else {
      if (select) {
        questions[index]['correct'] = [choice];
      }
    }
    notifyListeners();
  }

  bool choiceIsCorrect(int index, int choiceIndex) {
    /// returns if this choice is a correct answer
    String choice = questions[index]['choices'][choiceIndex];
    return questions[index]['correct'].contains(choice);
  }

  void toggleIsMulti(int index) {
    /// toggle multiple correct answers for a question
    questions[index]['isMulti'] = !questions[index]['isMulti'];
    notifyListeners();
  }

  List getChoices(int index) {
    return questions[index]['choices'];
  }

  List<Map> get getQuestions => questions;
}
