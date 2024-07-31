import 'package:e_learning/global.dart';
import 'package:e_learning/main.dart';
import 'package:e_learning/student/student_exam_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    pages = const [StudentExamListPage(), Text("1")];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Clrs.white,
        appBar: AppBar(
          backgroundColor: Clrs.white,
          foregroundColor: Clrs.blue,
          centerTitle: true,
          title: const Text("Home"),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
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
            unselectedItemColor: Clrs.pink,
            selectedItemColor: Clrs.blue,
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
