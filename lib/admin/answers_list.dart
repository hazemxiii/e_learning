import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/admin/grade_exam.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class AnswersListPage extends StatefulWidget {
  final String examName;
  const AnswersListPage({super.key, required this.examName});

  @override
  State<AnswersListPage> createState() => _AnswersListPageState();
}

class _AnswersListPageState extends State<AnswersListPage> {
  bool gradesShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.examName),
        backgroundColor: Colors.white,
        foregroundColor: Clrs.main,
        actions: [
          TextButton(
              onPressed: () {
                showDidntAnswer(context, widget.examName);
              },
              child: Text(
                "Didn't answer",
                style: TextStyle(color: Clrs.main),
              )),
          Switch(
              thumbColor: WidgetStatePropertyAll(Clrs.main),
              value: gradesShown,
              trackColor: WidgetStatePropertyAll(Clrs.sec),
              onChanged: (v) {
                setState(() {
                  gradesShown = v;
                });
              })
        ],
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: getExamResponses(widget.examName, gradesShown),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done ||
                    !snap.hasData) {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Clrs.main,
                        ),
                      ));
                }
                // TODO: fix the null here
                List studentsAnswers = snap.data!['responses'];
                Map studentNames = snap.data!['names'];
                return Column(
                  children: [
                    ...studentsAnswers.map((student) {
                      return StudentAnswerRow(
                        examName: widget.examName,
                        studentID: student.id,
                        studentName: studentNames[student.id],
                        showGrade: gradesShown,
                        grade: student.data()["grade"],
                      );
                    })
                  ],
                );
              },
            ),
          )),
    );
  }
}

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
                  PopupMenuButton(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                          ]),
                ],
              )
            ],
          )),
    );
  }
}

Future<Map> getExamResponses(String examName, bool withGrades) async {
  List<QueryDocumentSnapshot> responses = [];
  Map studentNames = {};

  if (!withGrades) {
    responses = (await Dbs.firestore
            .collection("exams")
            .doc(examName)
            .collection("studentAnswers")
            .where("answer")
            .get())
        .docs;
  } else {
    responses = (await Dbs.firestore
            .collection("exams")
            .doc(examName)
            .collection("studentAnswers")
            .orderBy("grade", descending: true)
            .get())
        .docs;
  }
  for (int i = 0; i < responses.length; i++) {
    DocumentSnapshot student =
        await Dbs.firestore.doc("/users/${responses[i].id}").get();
    studentNames[responses[i].id] = [
      student.get("fName"),
      student.get("lName")
    ];
  }

  return {"names": studentNames, "responses": responses};
}

void deleteResponse(String examName, String uid) async {
  // since there are multiple files to delete, place them in a batch
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

void showDidntAnswer(BuildContext context, String examName) async {
  /// shows users who didn't answer the exam
  int examLevel =
      (await Dbs.firestore.doc("/exams/$examName").get()).get("level");

// students who are supposed to answer the exam
  List<DocumentSnapshot> allEligibleStudents = [];
  if (examLevel != 0) {
    allEligibleStudents = (await Dbs.firestore
            .collection("users")
            .where("level", whereIn: [examLevel]).get())
        .docs;
  } else {
    allEligibleStudents = (await Dbs.firestore
            .collection("users")
            .where("level", isGreaterThanOrEqualTo: 0)
            .get())
        .docs;
  }

  List<String> answered =
      (await Dbs.firestore.collection("/exams/$examName/studentAnswers").get())
          .docs
          .map(
            (e) => e.id,
          )
          .toList();

  if (context.mounted) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ...allEligibleStudents.map((e) {
                    if (!answered.contains(e.id)) {
                      return Text(e.get("email"));
                    }
                    return Container();
                  })
                ],
              ),
            ),
          );
        });
  }
}
