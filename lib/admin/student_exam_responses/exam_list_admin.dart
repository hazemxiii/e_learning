import 'package:e_learning/admin/student_exam_responses/answers_list.dart';
import 'package:e_learning/admin/student_exam_responses/exam_row_context.dart';
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
              ExamRowContext(
                examName: examName,
              ),
            ],
          )),
    );
  }
}
