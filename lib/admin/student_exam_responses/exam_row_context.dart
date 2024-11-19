import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class ExamRowContext extends StatelessWidget {
  final String examName;
  const ExamRowContext({super.key, required this.examName});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        onSelected: (v) async {
          switch (v) {
            case "grade":
              gradeExam(examName);
              break;
            case "delete":
              showDeleteDialog(context);
              break;
          }
        },
        iconColor: Clrs.sec,
        color: Clrs.sec,
        itemBuilder: (context) => [
              PopupMenuItem(
                value: "delete",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delete", style: TextStyle(color: Clrs.main)),
                    Icon(
                      Icons.delete,
                      color: Clrs.main,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                  value: "grade",
                  child: Text("Grade Exam", style: TextStyle(color: Clrs.main)))
            ]);
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Text("Exam \"$examName\" will be deleted forever"),
            actions: [
              MaterialButton(
                  textColor: Colors.white,
                  color: Clrs.main,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              MaterialButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    deleteExam(examName);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Delete"))
            ],
          );
        });
  }

  deleteExam(String examName) async {
    List<QueryDocumentSnapshot> questions = await getExamQuestions();
    deleteDocuments(questions);

    List<QueryDocumentSnapshot> responses = await getExamResponses();
    deleteDocuments(responses);

    Dbs.firestore.doc("exams/$examName").delete();
    Dbs.firestore.doc("examsAnswers/$examName").delete();
  }

  Future<List<QueryDocumentSnapshot>> getExamQuestions() async {
    return (await Dbs.firestore.collection("exams/$examName/questions").get())
        .docs;
  }

  Future<List<QueryDocumentSnapshot>> getExamResponses() async {
    return (await Dbs.firestore
            .collection("exams/$examName/studentAnswers")
            .get())
        .docs;
  }

  void deleteDocuments(List<QueryDocumentSnapshot> documents) {
    for (int i = 0; i < documents.length; i++) {
      documents[i].reference.delete();
    }
  }

  void gradeExam(String examName) async {
    Map questionsMarks = await getQuestionsMarks(examName);

    List studentsAnswers = await getStudentsAnswers(examName);

    Map correctAnswers = await getCorrectAnswers(examName);

    var batch = Dbs.firestore.batch();
    // loop each student
    for (int i = 0; i < studentsAnswers.length; i++) {
      double grade = 0;
      Map studentAnswers = studentsAnswers[i].get("answers");
      List answeredQuestions = studentAnswers.keys.toList();
      for (int j = 0; j < answeredQuestions.length; j++) {
        var studentAnswer = studentAnswers[answeredQuestions[j]];
        // if the user didn't answer the question, don't mark it
        if (studentAnswer == null) {
          continue;
        }
        var correctAnswer = correctAnswers[answeredQuestions[j]];
        if (isMcq(correctAnswer)) {
          grade += markMcq(correctAnswer, studentAnswer,
              questionsMarks[answeredQuestions[j]]);
        } else {
          if (correctAnswer[studentsAnswers[i].id] != null) {
            // if the teacher marked it as correct, add its mark
            if (didTeacherMarkWrittenQuestion(
                correctAnswer, studentAnswers[i].id)) {
              grade += questionsMarks[answeredQuestions[j]];
            }
          }
        }
      }
      DocumentReference student = Dbs.firestore
          .doc("/exams/$examName/studentAnswers/${studentsAnswers[i].id}");
      batch.update(student, {"grade": grade});
    }
    DocumentReference examRef = Dbs.firestore.doc("exams/$examName");
    batch.update(examRef, {"marked": true});
    batch.commit().then((_) {}).catchError((e) => e);
  }

  Future<Map> getQuestionsMarks(String examName) async {
    return (await Dbs.firestore.doc("/exams/$examName").get()).get("marks");
  }

  Future<List> getStudentsAnswers(String examName) async {
    return (await Dbs.firestore
            .collection("/exams/$examName/studentAnswers")
            .get())
        .docs;
  }

  Future<Map> getCorrectAnswers(String examName) async {
    return (await Dbs.firestore.doc("/examsAnswers/$examName").get())
        .get("correct");
  }

  bool isMcq(dynamic correctAnswer) {
    return correctAnswer.runtimeType == List<dynamic>;
  }

  double markMcq(List correctAnswer, List studentAnswer, double questionMark) {
    double grade = 0;
    if (correctAnswer.length >= studentAnswer.length) {
      for (int k = 0; k < studentAnswer.length; k++) {
        if (correctAnswer.contains(studentAnswer[k])) {
          grade = grade + questionMark / correctAnswer.length;
        }
      }
    }
    return grade;
  }

  bool didTeacherMarkWrittenQuestion(Map correctAnswer, String question) {
    return correctAnswer[question]['correct'];
  }
}
