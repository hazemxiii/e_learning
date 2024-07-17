import 'package:e_learning/admin/exam_questions_notifier.dart';
import 'package:flutter/material.dart';
import "package:e_learning/global.dart";
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddExamPage extends StatefulWidget {
  const AddExamPage({super.key});

  @override
  State<AddExamPage> createState() => _AddExamPageState();
}

class _AddExamPageState extends State<AddExamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Clrs.white,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                String result = await Provider.of<ExamQuestionsNotifier>(
                        context,
                        listen: false)
                    .sendExam();
                if (!context.mounted) {
                  return;
                }
                // display the result returned from the saving process
                if (result == "Saved") {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.rightSlide,
                    title: 'Saved',
                    desc: 'Exam saved successfully',
                    btnOkOnPress: () {},
                  ).show();
                } else {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.rightSlide,
                    title: 'Error',
                    desc: result,
                    btnOkOnPress: () {},
                  ).show();
                }
              },
              icon: const Icon(Icons.send))
        ],
        backgroundColor: Clrs.white,
        foregroundColor: Clrs.blue,
        title: const Text("Add Exam"),
        centerTitle: true,
      ),
      body:
          Consumer<ExamQuestionsNotifier>(builder: (context, questions, child) {
        // question index
        int i = 0;
        return SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...questions.getQuestions.map((question) {
            if (question['type'] == QuestionTypes.mcq) {
              return McqQuestionWidget(
                  index: i++, isMulti: question['isMulti']);
            }
            return WrittenQuestionWidget(index: i++);
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AddButtonWidget(
                  icon: Icon(
                    Icons.square_outlined,
                    color: Clrs.blue,
                  ),
                  onTap: () {
                    Provider.of<ExamQuestionsNotifier>(context, listen: false)
                        .addQuestion(QuestionTypes.mcq);
                  }),
              const SizedBox(width: 3),
              AddButtonWidget(
                  icon: Icon(Icons.text_format, color: Clrs.blue),
                  onTap: () {
                    Provider.of<ExamQuestionsNotifier>(context, listen: false)
                        .addQuestion(QuestionTypes.written);
                  })
            ],
          )
        ]));
      }),
    );
  }
}

class WrittenQuestionWidget extends StatefulWidget {
  final int index;
  const WrittenQuestionWidget({super.key, required this.index});

  @override
  State<WrittenQuestionWidget> createState() => _WrittenQuestionWidgetState();
}

class _WrittenQuestionWidgetState extends State<WrittenQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: TextField(
        onChanged: (v) {
          Provider.of<ExamQuestionsNotifier>(context, listen: false)
              .updateQuestion(widget.index, "question", v);
        },
        cursorColor: Clrs.blue,
        style: TextStyle(color: Clrs.blue),
        decoration: InputDecoration(
          filled: true,
          fillColor: Clrs.pink,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Clrs.blue, width: 2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Clrs.pink, width: 2)),
        ),
      ),
    );
  }
}

class McqQuestionWidget extends StatefulWidget {
  final int index;
  final bool isMulti;
  const McqQuestionWidget(
      {super.key, required this.index, required this.isMulti});

  @override
  State<McqQuestionWidget> createState() => _McqQuestionWidgetState();
}

class _McqQuestionWidgetState extends State<McqQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) {
              Provider.of<ExamQuestionsNotifier>(context, listen: false)
                  .updateQuestion(widget.index, "question", v);
            },
            cursorColor: Clrs.pink,
            style: TextStyle(color: Clrs.pink),
            decoration: InputDecoration(
              filled: true,
              fillColor: Clrs.blue,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Clrs.pink, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Clrs.blue, width: 2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Allow Multiple Answers:",
                  style: TextStyle(color: Clrs.blue)),
              Transform.scale(
                scale: .7,
                child: Switch(
                  trackColor: WidgetStatePropertyAll(Clrs.pink),
                  thumbColor: WidgetStatePropertyAll(Clrs.blue),
                  onChanged: (v) {
                    Provider.of<ExamQuestionsNotifier>(context, listen: false)
                        .toggleIsMulti(widget.index);
                  },
                  value: widget.isMulti,
                ),
              ),
            ],
          ),
          Consumer<ExamQuestionsNotifier>(builder: (context, qstn, child) {
            int choiceIndex = -1;
            return Wrap(children: [
              ...qstn.getChoices(widget.index).map((choice) {
                choiceIndex++;
                return ChoiceWidget(
                  // is a correct answer to the question
                  isCorrect: qstn.choiceIsCorrect(widget.index, choiceIndex),
                  text: choice,
                  index: widget.index,
                  choiceIndex: choiceIndex,
                );
              }),
            ]);
          })
        ],
      ),
    );
  }
}

class AddButtonWidget extends StatefulWidget {
  final Function onTap;
  final Icon icon;
  const AddButtonWidget({super.key, required this.onTap, required this.icon});

  @override
  State<AddButtonWidget> createState() => _AddButtonWidgetState();
}

class _AddButtonWidgetState extends State<AddButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap();
      },
      child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Clrs.pink,
              borderRadius: const BorderRadius.all(Radius.circular(999))),
          child: widget.icon),
    );
  }
}

class ChoiceWidget extends StatefulWidget {
  final int index;
  final int choiceIndex;
  final String text;
  final bool isCorrect;
  const ChoiceWidget({
    super.key,
    required this.index,
    required this.choiceIndex,
    required this.text,
    required this.isCorrect,
  });

  @override
  State<ChoiceWidget> createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
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
    // set text from the notifier and send the cursor to the end of the text
    controller.text = widget.text;
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    return Container(
      margin: const EdgeInsets.only(right: 5),
      constraints: const BoxConstraints(maxWidth: 200),
      child: TextField(
        cursorColor: Clrs.blue,
        style: TextStyle(color: Clrs.blue),
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Checkbox(
              activeColor: Clrs.pink,
              value: widget.isCorrect,
              onChanged: (v) {
                Provider.of<ExamQuestionsNotifier>(context, listen: false)
                    .selectChoice(widget.index, widget.choiceIndex, v!);
              },
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Clrs.blue, width: 2)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Clrs.pink, width: 2)),
            suffix: IconButton(
              onPressed: () {
                Provider.of<ExamQuestionsNotifier>(context, listen: false)
                    .deleteChoice(widget.index, widget.choiceIndex);
              },
              icon: Icon(
                Icons.close,
                color: Clrs.pink,
              ),
            )),
        onChanged: (v) {
          Provider.of<ExamQuestionsNotifier>(context, listen: false)
              .updateChoice(widget.index, widget.choiceIndex, v);
        },
      ),
    );
  }
}
