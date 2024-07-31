import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class GradeExamPage extends StatefulWidget {
  final String examName;
  final String uid;
  const GradeExamPage({super.key, required this.examName, required this.uid});

  @override
  State<GradeExamPage> createState() => _GradeExamPageState();
}

class _GradeExamPageState extends State<GradeExamPage> {
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
              return Column(
                children: [
                  ...questions.map((question) {
                    if (question.get("type") == "mcq") {
                      return McqQuestion(
                        question: question.id,
                        choices: question.get("choices"),
                        correct: correctAnswers[question.id],
                        studentAnswers: studentAnswers[question.id] ?? [],
                      );
                    } else {
                      Map answerData =
                          correctAnswers[question.id][widget.uid] ?? {};
                      return WrittenQuestion(
                        uid: widget.uid,
                        examName: widget.examName,
                        question: question.id,
                        studentAnswer: studentAnswers[question.id] ?? "",
                        correct: answerData['correct'],
                        correction: answerData['correction'] ?? "",
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
  final List correct;
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

          if (correct.contains(choice)) {
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
  late TextEditingController correctionCont;

  @override
  void initState() {
    correctionCont = TextEditingController(text: widget.correction);
    correct = widget.correct;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isCorrect = false;
    bool isWrong = false;

    if (correct != null) {
      if (correct == true) {
        isCorrect = true;
      } else {
        isWrong = true;
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
        TextField(
          controller: correctionCont,
          onChanged: (v) {
            if (correct != null) {
              setState(() {
                correct = null;
              });
            }
          },
          style: TextStyle(color: Clrs.blue),
          cursorColor: Clrs.blue,
          decoration: CustomDecoration.giveInputDecoration(
              textC: Clrs.blue,
              hint: "Correct the question",
              BorderType.under,
              Clrs.pink,
              false),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
                color: isCorrect ? Colors.green : Colors.white,
                onPressed: () async {
                  bool saved = await markQuestion(context, widget.examName,
                      widget.uid, widget.question, correctionCont.text, true);

                  if (saved) {
                    setState(() {
                      correct = true;
                    });
                  }
                },
                child: Icon(
                  Icons.check,
                  color: !isCorrect ? Colors.green : Colors.white,
                )),
            const SizedBox(width: 10),
            MaterialButton(
                color: isWrong ? Colors.red : Colors.white,
                onPressed: () async {
                  bool saved = await markQuestion(context, widget.examName,
                      widget.uid, widget.question, correctionCont.text, false);

                  if (saved) {
                    setState(() {
                      correct = false;
                    });
                  }
                },
                child: Icon(
                  Icons.close,
                  color: !isWrong ? Colors.red : Colors.white,
                ))
          ],
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

  Map studentAnswers = (await db
          .collection("exams")
          .doc(examName)
          .collection("studentAnswers")
          .doc(uid)
          .get())
      .get("answers");

  Map correctAnswers =
      (await db.collection("examsAnswers").doc(examName).get()).get("correct");

  return {
    "questions": questions,
    "correct": correctAnswers,
    "student": studentAnswers
  };
}

Future<bool> markQuestion(BuildContext context, String examName, String uid,
    String question, String correction, bool correct) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  DocumentReference answerDoc = db.doc("/examsAnswers/$examName");

  Map answers = (await answerDoc.get()).get("correct");

  if (answers[question][uid] == null) {
    answers[question][uid] = {};
  }

  answers[question][uid]["correct"] = correct;
  answers[question][uid]["correction"] = correction;

  answerDoc.update({"correct": answers}).then((v) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Saved")));
    return true;
  }).catchError((e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Failed")));
    return false;
  });

  return true;
}
