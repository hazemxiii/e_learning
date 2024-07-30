import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class ExamPreviewPage extends StatefulWidget {
  final String examName;
  final String uid;
  const ExamPreviewPage({super.key, required this.examName, required this.uid});

  @override
  State<ExamPreviewPage> createState() => _ExamPreviewPageState();
}

class _ExamPreviewPageState extends State<ExamPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.uid),
        backgroundColor: Colors.white,
        foregroundColor: Clrs.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: getExamAnswers(widget.examName, widget.uid),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              List questions = snap.data!['questions'];
              Map correctAnswers = snap.data!["correct"];
              Map studentAnswers = snap.data!["student"];
              bool graded = snap.data!['graded'];
              double grade = snap.data!['grade'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: grade > -1,
                      child: Text(
                        "$grade",
                      )),
                  ...questions.map((question) {
                    if (question.get("type") == "mcq") {
                      return McqQuestion(
                        question: question.id,
                        choices: question.get("choices"),
                        correct: correctAnswers[question.id],
                        studentAnswers: studentAnswers[question.id],
                      );
                    } else {
                      Map answerData = studentAnswers[question.id];
                      return WrittenQuestion(
                        uid: widget.uid,
                        examName: widget.examName,
                        question: question.id,
                        studentAnswer: answerData["studentAnswer"],
                        correct: graded ? answerData['correct'] : null,
                        correction: graded
                            ? answerData['correction']
                            : "Teacher correction should appear here when the exam is marked",
                      );
                    }
                  })
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class McqQuestion extends StatelessWidget {
  final String question;
  final List choices;
  final List? correct;
  final List studentAnswers;
  const McqQuestion(
      {super.key,
      required this.question,
      required this.choices,
      required this.correct,
      required this.studentAnswers});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Clrs.blue,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Text(
            question,
            style: TextStyle(color: Clrs.pink),
          )),
      const SizedBox(height: 5),
      Wrap(children: [
        ...choices.map((choice) {
          Color backC = Colors.white;
          if (correct != null) {
            if (correct!.contains(choice)) {
              if (studentAnswers.contains(choice)) {
                backC = Colors.green;
              } else {
                backC = Clrs.blue;
              }
            } else {
              if (studentAnswers.contains(choice)) {
                backC = Colors.red;
              }
            }
          } else {
            if (studentAnswers.contains(choice)) {
              backC = Clrs.blue;
            }
          }
          return Container(
              constraints: const BoxConstraints(minWidth: 100),
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Clrs.blue),
                  color: backC,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Text(choice, style: TextStyle(color: Clrs.pink)));
        })
      ]),
      const SizedBox(height: 15),
    ]);
  }
}

class WrittenQuestion extends StatefulWidget {
  final String uid;
  final String examName;
  final String question;
  final String studentAnswer;
  final String correction;
  final bool? correct;

  const WrittenQuestion(
      {super.key,
      required this.question,
      required this.studentAnswer,
      required this.correction,
      required this.correct,
      required this.examName,
      required this.uid});

  @override
  State<WrittenQuestion> createState() => _WrittenQuestionState();
}

class _WrittenQuestionState extends State<WrittenQuestion> {
  bool? correct;

  @override
  void initState() {
    correct = widget.correct;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isCorrect = false;

    if (correct != null) {
      if (correct == true) {
        isCorrect = true;
      }
    }

    return Column(
      children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Clrs.blue,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Text(
              widget.question,
              style: TextStyle(color: Clrs.pink),
            )),
        const SizedBox(height: 5),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Clrs.pink,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child:
                Text(widget.studentAnswer, style: TextStyle(color: Clrs.blue))),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: BorderDirectional(
                  bottom: BorderSide(color: Clrs.pink, width: 3))),
          child: Text(
            widget.correction,
            style: TextStyle(color: Clrs.blue),
          ),
        ),
        const SizedBox(height: 5),
        Visibility(
          visible: widget.correct != null,
          child: Container(
              color: Colors.white,
              child: isCorrect
                  ? const Icon(Icons.check, color: Colors.green)
                  : const Icon(
                      Icons.close,
                      color: Colors.red,
                    )),
        )
      ],
    );
  }
}

Future<Map> getExamAnswers(String examName, String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  List questions =
      (await db.collection("exams").doc(examName).collection("questions").get())
          .docs;

  var studentAnswerDoc = await db
      .collection("exams")
      .doc(examName)
      .collection("studentAnswers")
      .doc(uid)
      .get();

  Map? studentAnswers = studentAnswerDoc.get("answers");
  Map correctAnswers = {};

  bool graded = true;
  double grade = -1;

  try {
    grade = studentAnswerDoc.get("grade");
    correctAnswers = (await db.collection("examsAnswers").doc(examName).get())
        .get("correct");
  } catch (e) {
    graded = false;
  }

  return {
    "questions": questions,
    "correct": correctAnswers,
    "student": studentAnswers,
    "graded": graded,
    "grade": grade
  };
}
