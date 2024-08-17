import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/admin/answers_list.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class AdminExamListPage extends StatefulWidget {
  const AdminExamListPage({super.key});

  @override
  State<AdminExamListPage> createState() => _AdminExamListPageState();
}

class _AdminExamListPageState extends State<AdminExamListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Clrs.main,
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
              child: StreamBuilder(
            stream: Dbs.firestore.collection("exams").snapshots(),
            builder: (context, snap) {
              if (snap.data == null) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Clrs.main,
                    )));
              }
              List exams = snap.data!.docs;
              return Column(
                children: [
                  ...exams.map((exam) {
                    return ExamRow(
                      examLevel: exam.get("level"),
                      examName: exam.id,
                    );
                  })
                ],
              );
            },
          ))),
    );
  }
}

class ExamRow extends StatelessWidget {
  final String examName;
  final int examLevel;
  const ExamRow({super.key, required this.examName, required this.examLevel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AnswersListPage(
                  examName: examName,
                )));
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: Clrs.main),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(examName, style: TextStyle(color: Clrs.sec)),
              PopupMenuButton(
                  onSelected: (v) async {
                    switch (v) {
                      case "grade":
                        gradeExam(examName);
                        break;
                      case "delete":
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                content: Text(
                                    "Exam \"$examName\" will be deleted forever"),
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
                              Text("Delete",
                                  style: TextStyle(color: Clrs.main)),
                              Icon(
                                Icons.delete,
                                color: Clrs.main,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                            value: "grade",
                            child: Text("Grade Exam",
                                style: TextStyle(color: Clrs.main)))
                      ])
            ],
          )),
    );
  }
}

void gradeExam(String examName) async {
  /// grades the exam for all users
  Map questionsMarks =
      (await Dbs.firestore.doc("/exams/$examName").get()).get("marks");

  List studentsAnswers =
      (await Dbs.firestore.collection("/exams/$examName/studentAnswers").get())
          .docs;

  Map correctAnswers =
      (await Dbs.firestore.doc("/examsAnswers/$examName").get()).get("correct");

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
// if the answer is a list, then it's mcq
      if (correctAnswer.runtimeType == List<dynamic>) {
        if (correctAnswer.length >= studentAnswer.length) {
          for (int k = 0; k < studentAnswer.length; k++) {
            if (correctAnswer.contains(studentAnswer[k])) {
              grade = grade +
                  questionsMarks[answeredQuestions[j]] / correctAnswer.length;
            }
          }
        }
      } else {
        if (correctAnswer[studentsAnswers[i].id] != null) {
          // if the teacher marked it as correct, add its mark
          if (correctAnswer[studentsAnswers[i].id]['correct']) {
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

deleteExam(String examName) async {
  List<QueryDocumentSnapshot> questions =
      (await Dbs.firestore.collection("exams/$examName/questions").get()).docs;
  // delete each question
  for (int i = 0; i < questions.length; i++) {
    questions[i].reference.delete();
  }

  List<QueryDocumentSnapshot> responses =
      (await Dbs.firestore.collection("exams/$examName/studentAnswers").get())
          .docs;
  // delete each student response
  for (int i = 0; i < responses.length; i++) {
    responses[i].reference.delete();
  }

  Dbs.firestore.doc("exams/$examName").delete();
  Dbs.firestore.doc("examsAnswers/$examName").delete();
}
