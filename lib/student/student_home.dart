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
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ExamPage(name: exam.id)));
                    },
                    child: Text(exam.get("time"))))
              ],
            );
          },
        )));
  }
}
