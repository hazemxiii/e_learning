import 'package:e_learning/admin/add_exam/add_exam.dart';
import 'package:e_learning/admin/student_exam_responses/exam_list_admin.dart';
import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Clrs.main,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            width: MediaQuery.of(context).size.width / 6 * 5,
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AdminExamListPage()));
                    },
                    child: Text(
                      "Exams List",
                      style: TextStyle(color: Clrs.sec, fontSize: 20),
                    )),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AddExamPage()));
                  },
                  icon: Icon(
                    Icons.add,
                    color: Clrs.sec,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
