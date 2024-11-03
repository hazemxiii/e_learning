import 'package:e_learning/admin/add_exam/add_exam.dart';
import 'package:e_learning/admin/add_exam/choice_widget.dart';
import 'package:e_learning/admin/global_admin.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WrittenQuestionWidget extends StatefulWidget {
  final int questionIndex;
  const WrittenQuestionWidget({super.key, required this.questionIndex});

  @override
  State<WrittenQuestionWidget> createState() => _WrittenQuestionWidgetState();
}

class _WrittenQuestionWidgetState extends State<WrittenQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionMetaDataRow(
            questionIndex: widget.questionIndex,
          ),
          TextField(
            onChanged: (v) {
              Provider.of<AddExamNotifier>(context, listen: false)
                  .updateQuestion(widget.questionIndex, "question", v);
            },
            cursorColor: Clrs.main,
            style: TextStyle(color: Clrs.main),
            decoration: InputDecoration(
              filled: true,
              fillColor: Clrs.sec,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Clrs.main, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Clrs.sec, width: 2)),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionMetaDataRow extends StatelessWidget {
  final int questionIndex;
  const QuestionMetaDataRow({super.key, required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
                color: Clrs.main,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Text(
              "${questionIndex + 1}",
              style: TextStyle(color: Clrs.sec),
            )),
        Row(
          children: [
            Container(
                margin: const EdgeInsets.only(bottom: 5),
                width: 50,
                child: TextField(
                  onChanged: (v) {
                    Provider.of<AddExamNotifier>(context, listen: false)
                        .updateQuestion(questionIndex, "mark", int.parse(v));
                  },
                  style: TextStyle(color: Clrs.sec),
                  cursorColor: Clrs.sec,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: CustomDecoration.giveInputDecoration(
                      BorderType.under, Clrs.main,
                      label: "Mark"),
                )),
            IconButton(
                onPressed: () {
                  Provider.of<AddExamNotifier>(context, listen: false)
                      .deleteQuestion(questionIndex);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ))
          ],
        )
      ],
    );
  }
}

class McqQuestionWidget extends StatefulWidget {
  final int questionIndex;
  // if multiple choices are allowed for this question
  final bool isMulti;
  const McqQuestionWidget(
      {super.key, required this.questionIndex, required this.isMulti});

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
          QuestionMetaDataRow(questionIndex: widget.questionIndex),
          TextField(
            onChanged: (v) {
              Provider.of<AddExamNotifier>(context, listen: false)
                  .updateQuestion(widget.questionIndex, "question", v);
            },
            cursorColor: Clrs.sec,
            style: TextStyle(color: Clrs.sec),
            decoration: InputDecoration(
              filled: true,
              fillColor: Clrs.main,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Clrs.sec, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Clrs.main, width: 2)),
            ),
          ),
          AllowMultipleAnswersWidget(
            questionIndex: widget.questionIndex,
            isMulti: widget.isMulti,
          ),
          Consumer<AddExamNotifier>(builder: (context, qstn, child) {
            int choiceIndex = -1;
            return Wrap(children: [
              ...qstn.getChoices(widget.questionIndex).map((choice) {
                choiceIndex++;
                return ChoiceWidget(
                    // is a correct answer to the question
                    isCorrect:
                        qstn.choiceIsCorrect(widget.questionIndex, choiceIndex),
                    text: choice,
                    questionIndex: widget.questionIndex,
                    choiceIndex: choiceIndex,
                    offset: qstn.getOffset);
              }),
            ]);
          })
        ],
      ),
    );
  }
}

class AllowMultipleAnswersWidget extends StatefulWidget {
  final int questionIndex;
  final bool isMulti;
  const AllowMultipleAnswersWidget(
      {super.key, required this.questionIndex, required this.isMulti});

  @override
  State<AllowMultipleAnswersWidget> createState() =>
      _AllowMultipleAnswersWidgetState();
}

class _AllowMultipleAnswersWidgetState
    extends State<AllowMultipleAnswersWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("Allow Multiple Answers:", style: TextStyle(color: Clrs.main)),
        Transform.scale(
          scale: .7,
          child: Switch(
            trackColor: WidgetStatePropertyAll(Clrs.sec),
            thumbColor: WidgetStatePropertyAll(Clrs.main),
            onChanged: (v) {
              Provider.of<AddExamNotifier>(context, listen: false)
                  .toggleIsMulti(widget.questionIndex);
            },
            value: widget.isMulti,
          ),
        ),
      ],
    );
  }
}

class AddQuestionRow extends StatelessWidget {
  final ScrollController scrollController;
  const AddQuestionRow({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AddQuestionButton(
            icon: Icon(
              Icons.check_circle_outline,
              color: Clrs.main,
            ),
            onTap: () {
              addQuestion(QuestionTypes.mcq, context);
            }),
        const SizedBox(width: 3),
        AddQuestionButton(
            icon: Icon(Icons.text_format, color: Clrs.main),
            onTap: () {
              addQuestion(QuestionTypes.written, context);
            })
      ],
    );
  }

  void addQuestion(QuestionTypes type, BuildContext context) {
    Provider.of<AddExamNotifier>(context, listen: false).addQuestion(type);
    scrollToBottom();
  }

  void scrollToBottom() {
    scrollController.animateTo(scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }
}
