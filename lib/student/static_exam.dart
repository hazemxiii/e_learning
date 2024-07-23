import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class StaticExamPage extends StatelessWidget {
  final String examName;
  final Map studentAnswers;
  const StaticExamPage(
      {super.key, required this.examName, required this.studentAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Clrs.white,
      appBar: AppBar(
        backgroundColor: Clrs.white,
        foregroundColor: Clrs.blue,
        title: Text(examName),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getExamData(examName),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            Map correctAnswers = snap.data!['answers'];
            List questions = snap.data!['questions'];

            return Column(
              children: [
                ...questions.map((question) {
                  if (question.get("type") == "written") {
                    return WrittenQuestionWidget(
                        question: question.id,
                        studentAnswer: studentAnswers[question.id],
                        teacherCorrection: "teacherCorrection");
                  }
                  return Text("MC");
                })
              ],
            );
          },
        ),
      ),
    );
  }
}

class WrittenQuestionWidget extends StatelessWidget {
  final String question;
  final String studentAnswer;
  final String teacherCorrection;
  const WrittenQuestionWidget(
      {super.key,
      required this.question,
      required this.studentAnswer,
      required this.teacherCorrection});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text(question), Text(studentAnswer), Text(teacherCorrection)],
    );
  }
}

Future<Map> getExamData(String exam) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  var answers = (await db
          .collection("examsAsnwers")
          .doc(exam)
          .collection("questions")
          .get())
      .docs;

  var questions =
      (await db.collection("exams").doc(exam).collection("questions").get())
          .docs;

  Map correctAnswers = {};

  for (int i = 0; i < answers.length; i++) {
    correctAnswers[answers[i].id] = answers[i].get("correct");
  }

  return {"questions": questions, "answers": correctAnswers};
}
