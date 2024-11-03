import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/admin/student_exam_responses/student_response_row.dart';
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

  void showDidntAnswer(BuildContext context, String examName) async {
    /// shows users who didn't answer the exam
    int examLevel =
        (await Dbs.firestore.doc("/exams/$examName").get()).get("level");

    List<DocumentSnapshot> allEligibleStudents =
        await getAllEligibleStudents(examLevel);

    List<String> answered = await getStudentsWhoAnswered(examName);

    showDidntAnswerDialog(allEligibleStudents, answered);
  }

  Future<Map> getExamResponses(String examName, bool withGrades) async {
    List<QueryDocumentSnapshot> responses = [];
    if (!withGrades) {
      responses = await getResponsesWithoutGrade(examName);
    } else {
      responses = await getResponsesWithGrade(examName);
    }

    Map studentNames = await getStudentNames(responses);

    return {"names": studentNames, "responses": responses};
  }

  Future<List<QueryDocumentSnapshot>> getResponsesWithGrade(
      String examName) async {
    return (await Dbs.firestore
            .collection("exams")
            .doc(examName)
            .collection("studentAnswers")
            .orderBy("grade", descending: true)
            .get())
        .docs;
  }

  Future<List<QueryDocumentSnapshot>> getResponsesWithoutGrade(
      String examName) async {
    return (await Dbs.firestore
            .collection("exams")
            .doc(examName)
            .collection("studentAnswers")
            .where("answer")
            .get())
        .docs;
  }

  Future<List<DocumentSnapshot>> getAllEligibleStudents(int examLevel) async {
    if (examLevel != 0) {
      return (await Dbs.firestore
              .collection("users")
              .where("level", whereIn: [examLevel]).get())
          .docs;
    } else {
      return (await Dbs.firestore
              .collection("users")
              .where("level", isGreaterThanOrEqualTo: 0)
              .get())
          .docs;
    }
  }

  Future<List<String>> getStudentsWhoAnswered(String examName) async {
    return (await Dbs.firestore
            .collection("/exams/$examName/studentAnswers")
            .get())
        .docs
        .map(
          (e) => e.id,
        )
        .toList();
  }

  Future<Map> getStudentNames(List responses) async {
    Map names = {};
    for (int i = 0; i < responses.length; i++) {
      DocumentSnapshot student =
          await Dbs.firestore.doc("/users/${responses[i].id}").get();
      names[responses[i].id] = [student.get("fName"), student.get("lName")];
    }
    return names;
  }

  void showDidntAnswerDialog(List allEligibleStudents, List answered) {
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
