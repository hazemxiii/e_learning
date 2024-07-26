import 'package:e_learning/admin/add_exam.dart';
import 'package:e_learning/admin/admin_exam_list.dart';
import 'package:e_learning/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "../global.dart";

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Clrs.blue,
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
                        style: TextStyle(color: Clrs.pink, fontSize: 20),
                      )),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AddExamPage()));
                    },
                    icon: Icon(
                      Icons.add,
                      color: Clrs.pink,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}