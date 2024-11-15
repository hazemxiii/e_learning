import 'package:e_learning/global.dart';
import 'package:e_learning/main.dart';
import 'package:e_learning/student/exam_list_student.dart';
import 'package:e_learning/student/files_list_student.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  late List<Widget> pages;
  int activePage = 0;

  @override
  void initState() {
    pages = const [StudentExamListPage(), FilesListStudentPage()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Clrs.main,
          centerTitle: true,
          title: const Text("Home"),
          actions: [
            IconButton(
              onPressed: () {
                Dbs.auth.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SignIn()));
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: activePage,
            backgroundColor: Colors.white,
            unselectedItemColor: Clrs.sec,
            selectedItemColor: Clrs.main,
            onTap: (v) {
              setState(() {
                activePage = v;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.book), label: "Exams"),
              BottomNavigationBarItem(icon: Icon(Icons.school), label: "Temp")
            ]),
        body: pages[activePage]);
  }
}
