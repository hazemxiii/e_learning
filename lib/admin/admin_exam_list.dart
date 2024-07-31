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
    FirebaseFirestore db = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Clrs.blue,
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
              child: FutureBuilder(
            future: db.collection("exams").get(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              List exams = snap.data!.docs;
              return Column(
                children: [
                  ...exams.map((exam) {
                    return ExamRow(
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
  const ExamRow({super.key, required this.examName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AnswersListPage(examName: examName)));
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: Clrs.blue),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(examName, style: TextStyle(color: Clrs.pink)),
              PopupMenuButton(
                  onSelected: (v) {
                    if (v == "grade") {
                      gradeExam(examName);
                    }
                  },
                  iconColor: Clrs.pink,
                  color: Clrs.pink,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delete",
                                  style: TextStyle(color: Clrs.blue)),
                              Icon(
                                Icons.delete,
                                color: Clrs.blue,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                            value: "grade",
                            child: Text("Grade Exam",
                                style: TextStyle(color: Clrs.blue)))
                      ])
            ],
          )),
    );
  }
}

void gradeExam(String examName) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Map marks = (await db.doc("/exams/$examName").get()).get("marks");

  List studentAnswers =
      (await db.collection("/exams/$examName/studentAnswers").get()).docs;

  Map correctAnswers =
      (await db.doc("/examsAnswers/$examName").get()).get("correct");

  var batch = db.batch();

  for (int i = 0; i < studentAnswers.length; i++) {
    double grade = 0;
    Map answers = studentAnswers[i].get("answers");
    List questions = answers.keys.toList();
    for (int j = 0; j < questions.length; j++) {
      var answer = answers[questions[j]];
      if (answer == null) {
        continue;
      }
      var correct = correctAnswers[questions[j]];

      if (correct.runtimeType == List<dynamic>) {
        if (correct.length >= answer.length) {
          for (int k = 0; k < answer.length; k++) {
            if (correct.contains(answer[k])) {
              grade = grade + marks[questions[j]] / correct.length;
            }
          }
        }
      } else {
        if (correct[studentAnswers[i].id]['correct']) {
          grade += marks[questions[j]];
        }
      }
    }
    DocumentReference student =
        db.doc("/exams/$examName/studentAnswers/${studentAnswers[i].id}");
    batch.update(student, {"grade": grade});
  }
  batch.commit().then((_) {}).catchError((e) => e);
}
