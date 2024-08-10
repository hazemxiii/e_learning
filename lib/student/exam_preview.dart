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
        title: Text(widget.examName),
        backgroundColor: Colors.white,
        foregroundColor: Clrs.main,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: getExamAnswers(widget.examName, widget.uid),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Clrs.main,
                    ),
                  ),
                );
              }
              List questions = snap.data!['questions'];
              Map correctAnswers = snap.data!["correct"];
              Map studentAnswers = snap.data!["student"];
              bool examIsGraded = snap.data!['graded'];
              double grade = snap.data!['grade'];
              double totalGrade = snap.data!['total'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: examIsGraded,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: grade / totalGrade > .5
                                ? Colors.green
                                : Colors.red,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          style: const TextStyle(color: Colors.white),
                          "$grade/$totalGrade",
                        ),
                      )),
                  ...questions.map((question) {
                    if (question.get("type") == "mcq") {
                      return McqQuestion(
                        question: question.id,
                        choices: question.get("choices"),
                        correct: correctAnswers[question.id],
                        studentAnswers: studentAnswers[question.id] ?? [],
                      );
                    } else {
                      Map answerData = {};
                      if (correctAnswers.isNotEmpty) {
                        answerData =
                            correctAnswers[question.id][widget.uid] ?? {};
                      }
                      return WrittenQuestion(
                        uid: widget.uid,
                        examName: widget.examName,
                        question: question.id,
                        studentAnswer: studentAnswers[question.id] ?? "",
                        correct: examIsGraded ? answerData['correct'] : null,
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Clrs.main,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Text(
              question,
              style: TextStyle(color: Clrs.sec),
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
                  backC = Clrs.main;
                }
              } else {
                if (studentAnswers.contains(choice)) {
                  backC = Colors.red;
                }
              }
            } else {
              if (studentAnswers.contains(choice)) {
                backC = Clrs.main;
              }
            }
            return Container(
                constraints: const BoxConstraints(minWidth: 100),
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Clrs.main),
                    color: backC,
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: Text(choice, style: TextStyle(color: Clrs.sec)));
          })
        ]),
        const SizedBox(height: 15),
      ]),
    );
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Clrs.main,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Text(
                widget.question,
                style: TextStyle(color: Clrs.sec),
              )),
          const SizedBox(height: 5),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Text(widget.studentAnswer,
                  style: const TextStyle(color: Colors.white))),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: BorderDirectional(
                    bottom: BorderSide(color: Clrs.sec, width: 3))),
            child: Text(
              "Comment: ${widget.correction}",
              style: TextStyle(color: Clrs.main),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

Future<Map> getExamAnswers(String examName, String uid) async {
  List questions = (await Dbs.firestore
          .collection("exams")
          .doc(examName)
          .collection("questions")
          .get())
      .docs;

  var studentAnswerDoc = await Dbs.firestore
      .collection("exams")
      .doc(examName)
      .collection("studentAnswers")
      .doc(uid)
      .get();

  Map? studentAnswers = studentAnswerDoc.get("answers");
  Map correctAnswers = {};
  bool graded = true;
  double totalMark = 0;
  double grade = 0;

// if there is no grade (exam is not graded yet) do not give the correct answer, it will raise an error before getting it
  try {
    grade = studentAnswerDoc.get("grade");
    correctAnswers =
        (await Dbs.firestore.collection("examsAnswers").doc(examName).get())
            .get("correct");
    totalMark = (await Dbs.firestore.doc("/exams/$examName").get())
        .get("marks")['totalMark'];
  } catch (e) {
    graded = false;
  }

  return {
    "questions": questions,
    "correct": correctAnswers,
    "student": studentAnswers,
    "graded": graded,
    "grade": grade,
    "total": totalMark
  };
}
