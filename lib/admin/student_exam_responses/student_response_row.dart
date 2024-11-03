import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/admin/student_exam_responses/grade_exam.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class StudentAnswerRow extends StatelessWidget {
  final String examName;
  final String studentID;
  final double? grade;
  // the name is a list containing first, last name
  final List studentName;
  final bool showGrade;
  const StudentAnswerRow(
      {super.key,
      required this.studentID,
      required this.examName,
      required this.grade,
      required this.showGrade,
      required this.studentName});

  @override
  Widget build(BuildContext context) {
    String fName = studentName[0];
    String lName = studentName[1];
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return GradeExamPage(
              examName: examName, uid: studentID, fName: fName, lName: lName);
        }));
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
              Text("$fName $lName", style: TextStyle(color: Clrs.sec)),
              Row(
                children: [
                  Visibility(
                    visible: showGrade,
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Clrs.sec,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "$grade",
                          style: TextStyle(color: Clrs.main),
                        )),
                  ),
                  ExamResponseContext(
                    examName: examName,
                    studentID: studentID,
                  )
                ],
              )
            ],
          )),
    );
  }
}

class ExamResponseContext extends StatelessWidget {
  final String examName;
  final String studentID;
  const ExamResponseContext(
      {super.key, required this.examName, required this.studentID});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        onSelected: (v) {
          switch (v) {
            case "delete":
              deleteResponse(examName, studentID);
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
            ]);
  }

  void deleteResponse(String examName, String uid) async {
    var batch = Dbs.firestore.batch();
    batch.delete(Dbs.firestore.doc("/exams/$examName/studentAnswers/$uid"));

    DocumentReference correctRef = Dbs.firestore.doc("/examsAnswers/$examName");

    // delete only the user id from correct written questions
    Map correct = (await correctRef.get()).get("correct");

    for (int i = 0; i < correct.entries.length; i++) {
      correct[correct.entries.elementAt(i).key]!.remove(uid);
    }
    batch.update(correctRef, {"correct": correct});

    batch.commit().then((_) {}).catchError((e) => e);
  }
}
