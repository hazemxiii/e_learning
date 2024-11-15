import 'package:flutter/material.dart';
import "package:e_learning/global.dart";

class AddExamNotifier extends ChangeNotifier {
  List<Map> questions = [];
  int examDuration = 0;
  String examName = "";
  DateTime? startDate;
  DateTime? deadline;
  // to return the cursor where it was when editing a choice
  int offset = 0;
  int level = 0;

  void setLevel(int level) {
    this.level = level;
    notifyListeners();
  }

  void setDuration(int duration) {
    // if the duration is larger than the difference between start and deadline dates, don't change it
    if (startDate != null && deadline != null) {
      if (deadline!.difference(startDate!).inMinutes < duration) {
        return;
      }
    }

    if (duration >= 0) {
      examDuration = duration;
    }
    notifyListeners();
  }

  bool setDate(DateType type, DateTime date) {
    // check if the difference between dates is not negative
    if (type == DateType.startDate) {
      if (deadline != null) {
        Duration diff = deadline!.difference(date);
        if (diff.isNegative) {
          return false;
        }
        // if the difference is smaller than the duration, change the duration to fit in the difference
        if (diff.inMinutes < examDuration) {
          examDuration = diff.inMinutes;
          notifyListeners();
        }
      }
      startDate = date;
    } else if (type == DateType.deadline) {
      if (startDate != null) {
        Duration diff = date.difference(startDate!);
        if (diff.isNegative) {
          return false;
        }
        if (diff.inMinutes < examDuration) {
          examDuration = diff.inMinutes;
          notifyListeners();
        }
      }

      deadline = date;
    }

    return true;
  }

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
        "isMulti": false,
        "mark": 1
      });
    } else if (type == QuestionTypes.written) {
      questions.add({"question": "", "type": type, "mark": 1});
    }

    // totalMark++;

    notifyListeners();
  }

  void updateQuestion(int index, String key, var value) {
    questions[index][key] = value;
  }

  void deleteQuestion(int index) {
    questions.removeAt(index);
    notifyListeners();
  }

  void addChoice(int index) {
    /// add an emtpy choice to the mcq
    questions[index]['choices'].add("");
    notifyListeners();
  }

  Future<String> sendExam() async {
    /// sends the exam to the db
    if (examName == "") {
      return "Exam must have a unique non-empty name";
    }

    bool nameExists = (await Dbs.firestore.doc("exams/$examName").get()).exists;
    if (nameExists) {
      return "Duplicated exam name";
    }

    if (questions.isEmpty) {
      return "Exam must contain at least 1 question";
    }
    final batch = Dbs.firestore.batch();

    final examRef = Dbs.firestore.collection("exams").doc(examName);
    final examAnswersRef =
        Dbs.firestore.collection("examsAnswers").doc(examName);

    // create the documents for the exam and a separate one for answers
    batch.set(examRef, {
      "duration": examDuration,
      "startDate": startDate,
      "deadline": deadline,
      "marked": false
    });
    Map correctAnswers = {};
    Map marks = {"totalMark": 0};

    for (int i = 0; i < questions.length; i++) {
      Map questionMap = questions[i];
      String question = questionMap['question'];

      if (question == "") {
        return "Question ${i + 1} is missing";
      }
      final questionRef = examRef.collection("questions").doc(question);

      // add marks to a dictionary and update total mark with each question
      marks[question] = questionMap['mark'];
      marks["totalMark"] += marks[question];

      QuestionTypes type = questionMap['type'];
      if (type == QuestionTypes.mcq) {
        List choices = questionMap['choices'];
        List correct = questionMap['correct'];
        bool isMulti = questionMap['isMulti'];

        if (choices.length < 3) {
          return "Question ${i + 1} doesn't have enough choices ";
        }

        if (correct.isEmpty) {
          return "Select correct answers for question ${i + 1}";
        }

        // don't take the last element of choices as it's an emtpy one
        batch.set(questionRef, {
          "choices": choices.sublist(0, choices.length - 1),
          "type": "mcq",
          "isMulti": isMulti
        });
        correctAnswers[question] = correct;
      } else {
        correctAnswers[question] = {};
        batch.set(questionRef, {"type": "written"});
      }
    }
    batch.update(examRef, {"marks": marks, "level": level});
    batch.set(examAnswersRef, {"correct": correctAnswers});
    batch.commit().then((_) {}, onError: (e) {
      return e.toString();
    });

    // set things back to what they were so it doesn't interfere with next sent exam
    questions = [];
    examDuration = 0;
    examName = "";
    startDate;
    deadline;
    offset = 0;
    level = 0;

    return "Saved";
  }

  void updateChoice(int index, int choiceIndex, String value, int offset) {
    /// update the text of a choice
    List choices = questions[index]['choices'];
    choices[choiceIndex] = value;
    // if it's the last choice being updated, add an empty one at the end
    if (choiceIndex == choices.length - 1) {
      choices.add("");
    }
    this.offset = offset;
    notifyListeners();
  }

  void updateExamName(String name) {
    /// changes the exam name whenever the user types
    examName = name;
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
  int get getDuration => examDuration;
  int get getOffset => offset;
}
