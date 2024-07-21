import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:e_learning/main.dart';
import 'package:e_learning/student/exam.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Clrs.white,
        appBar: AppBar(
          backgroundColor: Clrs.white,
          foregroundColor: Clrs.blue,
          centerTitle: true,
          title: const Text("Home"),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SignIn()));
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: SingleChildScrollView(
            child: FutureBuilder(
          future: FirebaseFirestore.instance.collection("exams").get(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<QueryDocumentSnapshot> exams = snap.data!.docs;
            return Column(
              children: [
                ...exams.map((exam) => InkWell(
                    onTap: () async {
                      openExam(context, exam);
                    },
                    child: Text(exam.get("time"))))
              ],
            );
          },
        )));
  }
}

void openExam(BuildContext context, var exam) async {
  /// opens the exam or no depending on student answer time and grade status
  var studentExamData = await exam.reference
      .collection(FirebaseAuth.instance.currentUser!.uid)
      .doc("data")
      .get();

  try {
    Map answers = studentExamData.get("answers");
    print(answers);
  } catch (e) {
    //
  }

  DateTime openTime = DateTime.now();
  try {
    // stores the first time a student opens the exam
    openTime = studentExamData.get("openTime").toDate();
  } catch (e) {
    //
  }
  // if the time passed since first open is past exam time, prevent the student from changing answers
  double diff = DateTime.now().difference(openTime).inSeconds / 60;
  if (diff > exam.get("duration")) {
  } else {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ExamPage(name: exam.id, firstOpen: diff == 0)));
    }
  }
}
