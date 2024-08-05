import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:e_learning/student/student_global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExamPage extends StatefulWidget {
  final String name;
  const ExamPage({
    super.key,
    required this.name,
  });

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                String uid = Dbs.auth.currentUser!.uid;
                String result =
                    await Provider.of<ExamNotifier>(context, listen: false)
                        .sendExam(uid, widget.name, false);
                if (context.mounted) {
                  showAwesomeDialog(context, widget.name, uid, result);
                }
              },
              icon: const Icon(Icons.send))
        ],
        backgroundColor: Colors.white,
        foregroundColor: Clrs.main,
        title: Text(widget.name),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: Dbs.firestore
                .collection("exams")
                .doc(widget.name)
                .collection("questions")
                .get(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Clrs.main,
                    )));
              }

              List<QueryDocumentSnapshot> questions = snap.data!.docs;
              return Consumer<ExamNotifier>(builder: (context, examNot, child) {
                int questionIndex = examNot.currentQuestion;
                Provider.of<ExamNotifier>(context, listen: false)
                    .setQuestionsCount(questions.length);

                return Column(
                  children: [
                    LinearProgressIndicator(
                      color: Clrs.main,
                      backgroundColor: Color.lerp(Colors.white, Clrs.main, 0.2),
                      value: examNot.getPercentageSolved,
                    ),
                    questions[questionIndex].get("type") == "written"
                        ? WrittenAnswerWidget(
                            answer: examNot
                                .getWrittenAnswer(questions[questionIndex].id),
                            question: questions[questionIndex].id)
                        : McqAnswerWidget(
                            question: questions[questionIndex].id,
                            choices: questions[questionIndex].get("choices"),
                            isMulti: questions[questionIndex].get("isMulti"),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            color: Clrs.main,
                            onPressed: () {
                              Provider.of<ExamNotifier>(context, listen: false)
                                  .prevQuestion();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new_sharp,
                              color: Clrs.sec,
                            )),
                        IconButton(
                            color: Clrs.main,
                            onPressed: () {
                              Provider.of<ExamNotifier>(context, listen: false)
                                  .nextQuestion();
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios_sharp,
                              color: Clrs.sec,
                            ))
                      ],
                    )
                  ],
                );
              });
            }),
      ),
    );
  }
}

class WrittenAnswerWidget extends StatefulWidget {
  final String question;
  final String answer;
  const WrittenAnswerWidget(
      {super.key, required this.question, required this.answer});

  @override
  State<WrittenAnswerWidget> createState() => _WrittenAnswerWidgetState();
}

class _WrittenAnswerWidgetState extends State<WrittenAnswerWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.answer;
    controller.selection =
        TextSelection.collapsed(offset: widget.answer.length);
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
                  color: Clrs.main,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Text(
                widget.question,
                style: TextStyle(color: Clrs.sec),
              )),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                controller: controller,
                onChanged: (v) {
                  Provider.of<ExamNotifier>(context, listen: false)
                      .changeWrittenAnswer(widget.question, v);
                },
                style: TextStyle(color: Clrs.main),
                cursorColor: Clrs.main,
                decoration: InputDecoration(
                    hintText: "Write your answer here",
                    hintStyle: TextStyle(color: Clrs.sec),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Clrs.sec)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 3, color: Clrs.sec))),
              ))
        ],
      ),
    );
  }
}

class McqAnswerWidget extends StatefulWidget {
  final String question;
  final List choices;
  final bool isMulti;
  const McqAnswerWidget(
      {super.key,
      required this.question,
      required this.choices,
      required this.isMulti});

  @override
  State<McqAnswerWidget> createState() => _McqAnswerWidgetState();
}

class _McqAnswerWidgetState extends State<McqAnswerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          decoration: BoxDecoration(
              color: Clrs.sec,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Text(
            widget.question,
            style: TextStyle(color: Clrs.main),
          )),
      Wrap(
        children: [
          ...widget.choices.map((choice) {
            return InkWell(
              onTap: () {
                Provider.of<ExamNotifier>(context, listen: false)
                    .selectAnswer(widget.question, choice, widget.isMulti);
              },
              child: Consumer<ExamNotifier>(builder: (context, examNot, child) {
                bool isSelected = examNot.isSelected(widget.question, choice);
                return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Color.lerp(Colors.white, Clrs.main, 0.2),
                        border: Border.all(
                            width: 3,
                            color: Color.lerp(Colors.white, Clrs.main,
                                isSelected ? 1 : 0.2)!),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        CustomCheckWidget(
                            isSelected: isSelected,
                            isMulti: widget.isMulti,
                            question: widget.question,
                            choice: choice),
                        const SizedBox(width: 10),
                        Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(choice,
                                style: TextStyle(color: Clrs.main))),
                      ],
                    ));
              }),
            );
          })
        ],
      )
    ]);
  }
}

class CustomCheckWidget extends StatefulWidget {
  final bool isMulti;
  final String question;
  final String choice;
  final bool isSelected;
  const CustomCheckWidget(
      {super.key,
      required this.isMulti,
      required this.question,
      required this.choice,
      required this.isSelected});

  @override
  State<CustomCheckWidget> createState() => _CustomCheckWidgetState();
}

class _CustomCheckWidgetState extends State<CustomCheckWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
          color: Clrs.sec,
          borderRadius:
              BorderRadius.all(Radius.circular(widget.isMulti ? 0 : 999))),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: widget.isSelected ? Clrs.main : Clrs.sec,
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.isMulti ? 0 : 999))),
        ),
      ),
    );
  }
}

void showAwesomeDialog(
    BuildContext context, String exam, String uid, String result) {
  AwesomeDialog(
    context: context,
    dialogType: result == "Done" ? DialogType.success : DialogType.warning,
    animType: AnimType.rightSlide,
    title: 'Result',
    desc: result,
    // the ok button either resends the exam when the student doesn't answer all questions, or just dismiss
    btnOkOnPress: result == "Done"
        ? () {}
        : () async {
            String result =
                await Provider.of<ExamNotifier>(context, listen: false)
                    .sendExam(uid, exam, true);
            if (context.mounted) {
              showAwesomeDialog(context, exam, uid, result);
            }
          },
    // the cancel button will only show when there're questions unanswered
    btnCancelOnPress: result == "Done" ? null : () {},
  ).show();
}
