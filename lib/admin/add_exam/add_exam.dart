import 'package:e_learning/admin/add_exam/exam_meta_data.dart';
import 'package:e_learning/admin/add_exam/question_widget.dart';
import 'package:e_learning/admin/global_admin.dart';
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
  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: sendExam, icon: const Icon(Icons.send))
        ],
        backgroundColor: Colors.white,
        foregroundColor: Clrs.main,
        title: const Text("Add Exam"),
        centerTitle: true,
      ),
      body: Consumer<AddExamNotifier>(builder: (context, questions, child) {
        int questionIndex = 0;
        return SingleChildScrollView(
            controller: scrollController,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ExamInfoInput(
                level: questions.level,
              ),
              const DurationPicker(),
              const Row(children: [
                DatePicker(
                  dateType: DateType.startDate,
                ),
                DatePicker(dateType: DateType.deadline)
              ]),
              ...questions.getQuestions.map((question) {
                if (isMcq(question['type'])) {
                  return McqQuestionWidget(
                      questionIndex: questionIndex++,
                      isMulti: question['isMulti']);
                }
                return WrittenQuestionWidget(questionIndex: questionIndex++);
              }),
              AddQuestionRow(
                scrollController: scrollController,
              ),
              const SizedBox(height: 20)
            ]));
      }),
    );
  }

  bool isMcq(QuestionTypes type) {
    return type == QuestionTypes.mcq;
  }

  void sendExam() async {
    String result =
        await Provider.of<AddExamNotifier>(context, listen: false).sendExam();
    if (examSavedSuccessfully(result)) {
      showSendExamResult(
          // ignore: use_build_context_synchronously
          context,
          "Saved",
          "Exam saved successfully",
          DialogType.success);
    } else {
      // ignore: use_build_context_synchronously
      showSendExamResult(context, "Error", result, DialogType.error);
    }
  }

  bool examSavedSuccessfully(String result) {
    return result == "Saved";
  }
}

class AddQuestionButton extends StatelessWidget {
  final Function onTap;
  final Icon icon;
  const AddQuestionButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Clrs.sec,
              borderRadius: const BorderRadius.all(Radius.circular(999))),
          child: icon),
    );
  }
}

void showSendExamResult(
    BuildContext context, String title, String desc, DialogType type) {
  AwesomeDialog(
    context: context,
    dialogType: type,
    animType: AnimType.rightSlide,
    title: title,
    desc: desc,
    btnOkOnPress: type == DialogType.success
        ? () {
            Navigator.of(context).pop();
          }
        : () {},
  ).show();
}
