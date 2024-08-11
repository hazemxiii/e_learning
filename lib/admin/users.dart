import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: FutureBuilder(
              future: Future.value(5),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Clrs.main,
                    ),
                  );
                }
                return Text("...");
              },
            )));
  }
}
