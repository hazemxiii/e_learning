import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class ExamPage extends StatefulWidget {
  final String name;
  const ExamPage({super.key, required this.name});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Clrs.white,
      appBar: AppBar(
        backgroundColor: Clrs.white,
        foregroundColor: Clrs.blue,
        title: Text(widget.name),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("exams")
                .doc(widget.name)
                .collection("questions")
                .get(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              List<QueryDocumentSnapshot> questions = snap.data!.docs;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...questions.map((question) {
                    if (question.get("type") == "written") {
                      return WrittenAnswerWidget(
                        question: question.id,
                      );
                    } else {
                      return McqAnswerWidget();
                    }
                  })
                ],
              );
            }),
      ),
    );
  }
}

class WrittenAnswerWidget extends StatefulWidget {
  final String question;
  const WrittenAnswerWidget({super.key, required this.question});

  @override
  State<WrittenAnswerWidget> createState() => _WrittenAnswerWidgetState();
}

class _WrittenAnswerWidgetState extends State<WrittenAnswerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              decoration: BoxDecoration(
                  color: Clrs.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Text(
                widget.question,
                style: TextStyle(color: Clrs.pink),
              )),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                style: TextStyle(color: Clrs.blue),
                cursorColor: Clrs.blue,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Clrs.pink)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 3, color: Clrs.pink))),
              ))
        ],
      ),
    );
  }
}

class McqAnswerWidget extends StatefulWidget {
  const McqAnswerWidget({super.key});

  @override
  State<McqAnswerWidget> createState() => _McqAnswerWidgetState();
}

class _McqAnswerWidgetState extends State<McqAnswerWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("MCQ");
  }
}
