import 'package:e_learning/admin/admin_global.dart';
import 'package:flutter/material.dart';
import "package:e_learning/global.dart";
import 'package:flutter/services.dart';
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
                String result =
                    await Provider.of<AddExamNotifier>(context, listen: false)
                        .sendExam();
                if (!context.mounted) {
                  return;
                }
                // display the result returned from the saving process
                if (result == "Saved") {
                  showSendExamResult(context, "Saved",
                      "Exam saved successfully", DialogType.success);
                } else {
                  showSendExamResult(
                      context, "Error", result, DialogType.error);
                }
              },
              icon: const Icon(Icons.send))
        ],
        backgroundColor: Clrs.white,
        foregroundColor: Clrs.blue,
        title: const Text("Add Exam"),
        centerTitle: true,
      ),
      body: Consumer<AddExamNotifier>(builder: (context, questions, child) {
        // question index
        int i = 0;
        return SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(left: 10, bottom: 10),
            width: 250,
            child: TextField(
              onChanged: (v) {
                Provider.of<AddExamNotifier>(context, listen: false)
                    .updateExamName(v);
              },
              style: TextStyle(color: Clrs.blue),
              cursorColor: Clrs.blue,
              decoration: CustomDecoration.giveInputDecoration(
                  label: "Exam Name", BorderType.under, Clrs.blue, false),
            ),
          ),
          const DurationPicker(),
          const Row(children: [
            DatePicker(
              dateType: DateType.startDate,
            ),
            DatePicker(dateType: DateType.deadline)
          ]),
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
                    Provider.of<AddExamNotifier>(context, listen: false)
                        .addQuestion(QuestionTypes.mcq);
                  }),
              const SizedBox(width: 3),
              AddButtonWidget(
                  icon: Icon(Icons.text_format, color: Clrs.blue),
                  onTap: () {
                    Provider.of<AddExamNotifier>(context, listen: false)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(bottom: 5),
              width: 50,
              child: TextField(
                onChanged: (v) {
                  Provider.of<AddExamNotifier>(context, listen: false)
                      .updateQuestion(widget.index, "mark", int.parse(v));
                },
                style: TextStyle(color: Clrs.pink),
                cursorColor: Clrs.pink,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: CustomDecoration.giveInputDecoration(
                    BorderType.under, Clrs.blue, false,
                    label: "Mark"),
              )),
          TextField(
            onChanged: (v) {
              Provider.of<AddExamNotifier>(context, listen: false)
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
        ],
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
          Container(
              margin: const EdgeInsets.only(bottom: 5),
              width: 50,
              child: TextField(
                onChanged: (v) {
                  Provider.of<AddExamNotifier>(context, listen: false)
                      .updateQuestion(widget.index, "mark", int.parse(v));
                },
                style: TextStyle(color: Clrs.blue),
                cursorColor: Clrs.blue,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: CustomDecoration.giveInputDecoration(
                    BorderType.under, Clrs.pink, false,
                    label: "Mark"),
              )),
          TextField(
            onChanged: (v) {
              Provider.of<AddExamNotifier>(context, listen: false)
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
                    Provider.of<AddExamNotifier>(context, listen: false)
                        .toggleIsMulti(widget.index);
                  },
                  value: widget.isMulti,
                ),
              ),
            ],
          ),
          Consumer<AddExamNotifier>(builder: (context, qstn, child) {
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
                    offset: qstn.getOffset);
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
  final int offset;
  const ChoiceWidget({
    super.key,
    required this.index,
    required this.choiceIndex,
    required this.text,
    required this.isCorrect,
    required this.offset,
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
    try {
      controller.selection = TextSelection.collapsed(offset: widget.offset);
    } catch (e) {
      // print(e);
    }
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
                Provider.of<AddExamNotifier>(context, listen: false)
                    .selectChoice(widget.index, widget.choiceIndex, v!);
              },
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Clrs.blue, width: 2)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Clrs.pink, width: 2)),
            suffix: IconButton(
              onPressed: () {
                Provider.of<AddExamNotifier>(context, listen: false)
                    .deleteChoice(widget.index, widget.choiceIndex);
              },
              icon: Icon(
                Icons.close,
                color: Clrs.pink,
              ),
            )),
        onChanged: (v) {
          Provider.of<AddExamNotifier>(context, listen: false).updateChoice(
              widget.index,
              widget.choiceIndex,
              v,
              controller.selection.baseOffset);
        },
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  // if it's the start date or the deadline
  final DateType dateType;
  const DatePicker({super.key, required this.dateType});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  // the date will be displayed on the button when chosen
  String shownDate = "";

  @override
  void initState() {
    // if a date is not selected, display a hint to what the button does
    shownDate = widget.dateType == DateType.startDate ? "Start at" : "Deadline";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return TextButton(
        onPressed: () async {
          DateTime? date = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)));

          // if no date is selected, don't show time picker
          if (date == null) {
            return;
          }

          if (context.mounted) {
            TimeOfDay? time = await showTimePicker(
                context: context, initialTime: TimeOfDay.now());

            // if no time is selected, exit the function
            if (time == null) {
              return;
            }

            // add the time to the day
            date = date.add(Duration(hours: time.hour, minutes: time.minute));
            if (context.mounted) {
              bool valid = Provider.of<AddExamNotifier>(context, listen: false)
                  .setDate(widget.dateType, date);

              if (!valid) {
                return;
              }
            }

            setState(() {
              shownDate =
                  "${date!.day}/${date.month}/${date.year} ${time.hourOfPeriod}:${"${time.minute}".padLeft(2, "0")} ${time.period == DayPeriod.am ? "AM" : "PM"}";
            });
          }
        },
        child: Text(
          shownDate,
          style: TextStyle(color: Clrs.pink),
        ));
  }
}

class DurationPicker extends StatefulWidget {
  const DurationPicker({super.key});

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late TextEditingController durationCont;

  @override
  void initState() {
    durationCont = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    durationCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddExamNotifier>(builder: (context, examNot, child) {
      durationCont.text = "${examNot.getDuration}";
      // when changing text, all the text is selected, so remove the selection
      durationCont.selection =
          TextSelection.collapsed(offset: durationCont.text.length);
      return Row(
        children: [
          IconButton(
            onPressed: () {
              // minus one from duration
              Provider.of<AddExamNotifier>(context, listen: false)
                  .setDuration(examNot.getDuration - 1);
            },
            icon: const Icon(Icons.remove),
            color: Clrs.blue,
          ),
          SizedBox(
              width: 50,
              child: TextField(
                onChanged: (v) {
                  // if the user deletes all the text, set it to 0
                  if (v == "") {
                    Provider.of<AddExamNotifier>(context, listen: false)
                        .setDuration(0);
                  } else {
                    int? duration = int.tryParse(v);
                    // if it's not a number, change it to the last valid number
                    if (duration != null) {
                      Provider.of<AddExamNotifier>(context, listen: false)
                          .setDuration(duration);
                    } else {
                      Provider.of<AddExamNotifier>(context, listen: false)
                          .setDuration(examNot.duration);
                    }
                  }
                },
                controller: durationCont,
                style: TextStyle(color: Clrs.blue),
                decoration: CustomDecoration.giveInputDecoration(
                    BorderType.under, Clrs.pink, false,
                    focusWidth: 1),
                textAlign: TextAlign.center,
              )),
          IconButton(
            onPressed: () {
              // add 1 to the duration
              Provider.of<AddExamNotifier>(context, listen: false)
                  .setDuration(examNot.getDuration + 1);
            },
            icon: const Icon(Icons.add),
            color: Clrs.blue,
          )
        ],
      );
    });
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
    btnOkOnPress: () {},
  ).show();
}
