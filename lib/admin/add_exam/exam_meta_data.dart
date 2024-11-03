import 'package:e_learning/admin/global_admin.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExamInfoInput extends StatelessWidget {
  final int level;
  const ExamInfoInput({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, bottom: 10),
          width: 250,
          child: TextField(
            onChanged: (v) {
              Provider.of<AddExamNotifier>(context, listen: false)
                  .updateExamName(v);
            },
            style: TextStyle(color: Clrs.main),
            cursorColor: Clrs.main,
            decoration: CustomDecoration.giveInputDecoration(
              label: "Exam Name",
              BorderType.under,
              Clrs.main,
            ),
          ),
        ),
        const SizedBox(width: 10),
        LevelDropdown(
          level: level,
        )
      ],
    );
  }
}

class LevelDropdown extends StatelessWidget {
  final int level;
  const LevelDropdown({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        padding: const EdgeInsets.all(5),
        value: level,
        items: [
          ...StudentLevels.levels.keys.toList().map((levelNumber) {
            return DropdownMenuItem(
                value: levelNumber,
                child: Text(StudentLevels.levels[levelNumber].toString(),
                    style: TextStyle(color: Clrs.main)));
          }),
        ],
        onChanged: (v) {
          Provider.of<AddExamNotifier>(context, listen: false).setLevel(v!);
        });
  }
}

class DatePicker extends StatefulWidget {
  final DateType dateType;
  const DatePicker({super.key, required this.dateType});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  String displayedDate = "";

  @override
  void initState() {
    displayedDate =
        widget.dateType == DateType.startDate ? "Start at" : "Deadline";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: pickDate,
        child: Text(
          displayedDate,
          style: TextStyle(color: Clrs.sec),
        ));
  }

  void pickDate() async {
    DateTime now = DateTime.now();
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)));

    if (date == null) {
      return;
    }

    pickTime(date);
  }

  void pickTime(DateTime date) async {
    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time == null) {
      return;
    }

    date = date.add(Duration(hours: time.hour, minutes: time.minute));
    if (!isDateValid(date)) {
      return;
    }

    updateDisplayedDate(date, time);
  }

  bool isDateValid(DateTime date) {
    return Provider.of<AddExamNotifier>(context, listen: false)
        .setDate(widget.dateType, date);
  }

  void updateDisplayedDate(DateTime date, TimeOfDay time) {
    setState(() {
      displayedDate =
          "${date.day}/${date.month}/${date.year} ${time.hourOfPeriod}:${"${time.minute}".padLeft(2, "0")} ${time.period == DayPeriod.am ? "AM" : "PM"}";
    });
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
              Provider.of<AddExamNotifier>(context, listen: false)
                  .setDuration(examNot.getDuration - 1);
            },
            icon: const Icon(Icons.remove),
            color: Clrs.main,
          ),
          SizedBox(
              width: 50,
              child: TextField(
                onChanged: (v) {
                  updateDuration(v, examNot.examDuration);
                },
                controller: durationCont,
                style: TextStyle(color: Clrs.main),
                decoration: CustomDecoration.giveInputDecoration(
                    BorderType.under, Clrs.sec,
                    focusWidth: 1),
                textAlign: TextAlign.center,
              )),
          IconButton(
            onPressed: () {
              Provider.of<AddExamNotifier>(context, listen: false)
                  .setDuration(examNot.getDuration + 1);
            },
            icon: const Icon(Icons.add),
            color: Clrs.main,
          )
        ],
      );
    });
  }

  void updateDuration(String durationAsString, int oldDuration) {
    // if the user deletes all the text, set it to 0
    if (durationAsString == "") {
      Provider.of<AddExamNotifier>(context, listen: false).setDuration(0);
    } else {
      int? duration = int.tryParse(durationAsString);
      // if it's not a number, change it to the last valid number
      if (duration != null) {
        Provider.of<AddExamNotifier>(context, listen: false)
            .setDuration(duration);
      } else {
        Provider.of<AddExamNotifier>(context, listen: false)
            .setDuration(oldDuration);
      }
    }
  }
}
