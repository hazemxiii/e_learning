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
                if (snap.connectionState != ConnectionState.done) {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Clrs.main,
                        ),
                      ));
                }
                List studentsAnswers = snap.data!['responses'];
                Map names = snap.data!['names'];
                return Column(
                  children: [
                    ...studentsAnswers.map((student) {
                      return StudentAnswerRow(
                        examName: widget.examName,
                        studentID: student.id,
                        name: names[student.id],
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
  final List name;
  final bool showGrade;
  const StudentAnswerRow(
      {super.key,
      required this.studentID,
      required this.examName,
      required this.grade,
      required this.showGrade,
      required this.name});

  @override
  Widget build(BuildContext context) {
    String fName = name[0];
    String lName = name[1];
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
  FirebaseFirestore db = FirebaseFirestore.instance;

  List responses = [];
  Map names = {};

  if (!withGrades) {
    responses = (await db
            .collection("exams")
            .doc(examName)
            .collection("studentAnswers")
            .get())
        .docs;
  } else {
    responses = (await db
            .collection("exams")
            .doc(examName)
            .collection("studentAnswers")
            .orderBy("grade", descending: true)
            .get())
        .docs;
  }

  names = (await db.doc("/users/public").get()).get("names");

  return {"names": names, "responses": responses};
}

void deleteResponse(String examName, String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  var batch = db.batch();
  batch.delete(db.doc("/exams/$examName/studentAnswers/$uid"));

  DocumentReference correctRef = db.doc("/examsAnswers/$examName");

  Map correct = (await correctRef.get()).get("correct");

  for (int i = 0; i < correct.entries.length; i++) {
    correct[correct.entries.elementAt(i).key]!.remove(uid);
  }
  batch.update(correctRef, {"correct": correct});

  batch.commit().then((_) {}).catchError((e) => e);
}
