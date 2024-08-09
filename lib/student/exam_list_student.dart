import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:e_learning/student/exam.dart';
import 'package:e_learning/student/exam_preview.dart';
import 'package:e_learning/student/student_global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentExamListPage extends StatefulWidget {
  const StudentExamListPage({super.key});

  @override
  State<StudentExamListPage> createState() => _StudentExamListPageState();
}

class _StudentExamListPageState extends State<StudentExamListPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: getExams(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Clrs.main,
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
    String uid = Dbs.auth.currentUser!.uid;

    // contains data about whether the exam is locked or can be opened
    List lockedData = isExamLocked(startDate, deadline);
    ExamStatus examStatus = lockedData[0];
    String hintMessage = lockedData[1];

    return InkWell(
      onTap: () {
        openExam(context, examStatus, examName, duration, uid, deadline);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Clrs.main,
                borderRadius: const BorderRadius.all(Radius.circular(7))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  examName,
                  style: TextStyle(color: Clrs.sec),
                ),
                examStatus == ExamStatus.waiting
                    ? Icon(Icons.lock, color: Clrs.sec)
                    : FutureBuilder(
                        future: Dbs.firestore
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
                                color: Clrs.sec,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: Text(
                              "${snap.data!.get("grade")}/$mark",
                              style: TextStyle(color: Clrs.main),
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
                      color: Clrs.sec,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Text(
                    hintMessage,
                    style: TextStyle(color: Clrs.main),
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
    int duration, String uid, Timestamp? deadline) async {
  if (examStatus == ExamStatus.waiting) return;

  DocumentReference userRef = Dbs.firestore
      .collection("exams")
      .doc(exam)
      .collection("studentAnswers")
      .doc(uid);

  var userDoc = await userRef.get();

  if (!userDoc.exists) {
    if (examStatus == ExamStatus.passed) {
      userRef.set({"firstOpen": null, "answers": {}, "submit": false});
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExamPreviewPage(examName: exam, uid: uid)));
      }
      return;
    }
    DateTime now = DateTime.now();
    userRef.set({"firstOpen": now, "answers": {}, "submit": false});
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
                create: (_) => ExamNotifier(),
                child: ExamPage(
                  name: exam,
                  firstOpen: now,
                  duration: duration,
                  deadline: deadline,
                ),
              )));
    }
    return;
  }
  if (userDoc.get("submit")) {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ExamPreviewPage(examName: exam, uid: uid)));
    }
    return;
  }

  if (userDoc.get("firstOpen") != null) {
    DateTime now = DateTime.now();
    deadline = deadline ?? Timestamp.fromDate(now);
    DateTime firstOpen = userDoc.get("firstOpen").toDate();
    if ((now.difference(firstOpen).inMinutes < duration || duration == 0) &&
        !now.isAfter(deadline.toDate())) {
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
                  create: (_) => ExamNotifier(),
                  child: ExamPage(
                    name: exam,
                    firstOpen: firstOpen,
                    duration: duration,
                    deadline:
                        deadline == Timestamp.fromDate(now) ? null : deadline,
                  ),
                )));
      }
      return;
    }
  }

  if (context.mounted) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ExamPreviewPage(examName: exam, uid: uid)));
  }
}

Future<QuerySnapshot> getExams() async {
  int level =
      (await Dbs.firestore.doc("users/${Dbs.auth.currentUser!.uid}").get())
          .get("level");
  var result = Dbs.firestore
      .collection("exams")
      .where("level", whereIn: [0, level]).get();

  return result;
}
