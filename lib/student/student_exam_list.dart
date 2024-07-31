import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:e_learning/student/exam.dart';
import 'package:e_learning/student/exam_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentExamListPage extends StatefulWidget {
  const StudentExamListPage({super.key});

  @override
  State<StudentExamListPage> createState() => _StudentExamListPageState();
}

class _StudentExamListPageState extends State<StudentExamListPage> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: db.collection("exams").get(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Clrs.blue,
                      ),
                    ));
              }
              List exams = snap.data!.docs;
              return Column(
                children: [
                  ...exams.map((exam) {
                    return ExamRowWidget(
                      examName: exam.id,
                      duration: exam.get("duration"),
                      startDate: exam.get("startDate"),
                      deadline: exam.get("deadline"),
                      mark: exam.get("marks")['totalMark'],
                    );
                  })
                ],
              );
            }),
      ),
    );
  }
}

class ExamRowWidget extends StatelessWidget {
  final String examName;
  final Timestamp? startDate;
  final Timestamp? deadline;
  final int duration;
  final double mark;
  const ExamRowWidget(
      {super.key,
      required this.examName,
      required this.startDate,
      required this.deadline,
      required this.duration,
      required this.mark});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // contains data about whether the exam is locked or can be opened
    List lockedData = isExamLocked(startDate, deadline);
    ExamStatus examStatus = lockedData[0];
    String hintMessage = lockedData[1];

    return InkWell(
      onTap: () {
        openExam(context, examStatus, examName, duration, uid);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Clrs.blue,
                borderRadius: const BorderRadius.all(Radius.circular(7))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  examName,
                  style: TextStyle(color: Clrs.pink),
                ),
                examStatus == ExamStatus.waiting
                    ? Icon(Icons.lock, color: Clrs.pink)
                    : FutureBuilder(
                        future: db
                            .doc("/exams/$examName/studentAnswers/$uid")
                            .get(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return Container();
                          }
                          try {
                            snap.data!.get("grade");
                          } catch (e) {
                            return Container();
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                                color: Clrs.pink,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: Text(
                              "${snap.data!.get("grade")}/$mark",
                              style: TextStyle(color: Clrs.blue),
                            ),
                          );
                        })
              ],
            ),
          ),
          Visibility(
              visible: hintMessage != "",
              child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                      color: Clrs.pink,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Text(
                    hintMessage,
                    style: TextStyle(color: Clrs.blue),
                  ))),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}

List isExamLocked(Timestamp? start, Timestamp? end) {
  DateTime now = DateTime.now();
  if (start != null) {
    if (now.isBefore(start.toDate())) {
      return [
        ExamStatus.waiting,
        "Exam starts at: ${start.toDate().toString()}"
      ];
    }
  }

  if (end != null) {
    if (now.isAfter(end.toDate())) {
      return [ExamStatus.passed, "The exam is no longer accepting answers"];
    }
  }

  return [ExamStatus.open, ""];
}

void openExam(BuildContext context, ExamStatus examStatus, String exam,
    int duration, String uid) async {
  if (examStatus == ExamStatus.waiting) return;

  FirebaseFirestore db = FirebaseFirestore.instance;

  DocumentReference userRef =
      db.collection("exams").doc(exam).collection("studentAnswers").doc(uid);

  var userDoc = await userRef.get();

  if (!userDoc.exists) {
    if (examStatus == ExamStatus.passed) {
      userRef.set({"firstOpen": null, "answers": {}});
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExamPreviewPage(examName: exam, uid: uid)));
      }
      return;
    }
    userRef.set({"firstOpen": DateTime.now(), "answers": {}});
    if (context.mounted) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ExamPage(name: exam)));
    }
    return;
  }
  if (userDoc.get("firstOpen") != null) {
    DateTime firstOpen = userDoc.get("firstOpen").toDate();
    if ((DateTime.now().difference(firstOpen).inMinutes < duration ||
            duration == 0) &&
        userDoc.get("answers") == null) {
      if (context.mounted) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExamPage(name: exam)));
      }
      return;
    }
  }

  if (context.mounted) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ExamPreviewPage(examName: exam, uid: uid)));
  }
}
