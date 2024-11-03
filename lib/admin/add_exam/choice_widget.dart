import 'package:e_learning/admin/global_admin.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChoiceWidget extends StatefulWidget {
  final int questionIndex;
  final int choiceIndex;
  final String text;
  final bool isCorrect;
  // to get the position of the cursor in the choice
  final int offset;
  const ChoiceWidget({
    super.key,
    required this.questionIndex,
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
    setChoiceText();
    return Container(
      margin: const EdgeInsets.only(right: 5),
      constraints: const BoxConstraints(maxWidth: 200),
      child: TextField(
        cursorColor: Clrs.main,
        style: TextStyle(color: Clrs.main),
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Checkbox(
              activeColor: Clrs.sec,
              value: widget.isCorrect,
              onChanged: (v) {
                Provider.of<AddExamNotifier>(context, listen: false)
                    .selectChoice(widget.questionIndex, widget.choiceIndex, v!);
              },
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Clrs.main, width: 2)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Clrs.sec, width: 2)),
            suffix: IconButton(
              onPressed: () {
                Provider.of<AddExamNotifier>(context, listen: false)
                    .deleteChoice(widget.questionIndex, widget.choiceIndex);
              },
              icon: Icon(
                Icons.close,
                color: Clrs.sec,
              ),
            )),
        onChanged: (v) {
          Provider.of<AddExamNotifier>(context, listen: false).updateChoice(
              widget.questionIndex,
              widget.choiceIndex,
              v,
              controller.selection.baseOffset);
        },
      ),
    );
  }

  void setChoiceText() {
    // set text from the notifier and send the cursor to the end of the text
    controller.text = widget.text;
    try {
      controller.selection = TextSelection.collapsed(offset: widget.offset);
    } catch (e) {
      // print(e);
    }
  }
}
