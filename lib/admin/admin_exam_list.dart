import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: Clrs.blue),
        child: Row(
          children: [
            Text(examName),
          ],
        ));
  }
}
