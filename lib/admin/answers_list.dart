import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/admin/grade_exam.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class AnswersListPage extends StatelessWidget {
  final String examName;
  const AnswersListPage({super.key, required this.examName});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(examName),
        backgroundColor: Colors.white,
        foregroundColor: Clrs.blue,
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: db
                  .collection("exams")
                  .doc(examName)
                  .collection("studentAnswers")
                  .get(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                List studentsAnswers = snap.data!.docs;
                return Column(
                  children: [
                    ...studentsAnswers.map((student) {
                      return StudentAnswerRow(
                          examName: examName, studentID: student.id);
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
  const StudentAnswerRow(
      {super.key, required this.studentID, required this.examName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return GradeExamPage(examName: examName, uid: studentID);
        }));
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
              Text(studentID, style: TextStyle(color: Clrs.pink)),
              PopupMenuButton(
                  onSelected: (v) {
                    // print(v);
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
                      ])
            ],
          )),
    );
  }
}
