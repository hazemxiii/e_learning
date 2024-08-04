import 'package:e_learning/admin/admin_home.dart';
import 'package:e_learning/admin/admin_global.dart';
import 'package:e_learning/student/student_global.dart';
import 'package:e_learning/student/student_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'global.dart';
import "package:provider/provider.dart";

/*
e43304113@gmail.com
*/

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AddExamNotifier()),
      ChangeNotifierProvider(create: (context) => ExamNotifier())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const MaterialApp(
        home: SignIn(),
      );
    } else {
      return MaterialApp(
        home: user.email == "e43304113@gmail.com"
            ? const AdminHomePage()
            : const StudentHomePage(),
      );
    }
  }
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late TextEditingController userNameCont;
  late TextEditingController passCont;
  late bool hidePass;
  // to check if there's an error in login
  bool isError = false;

  @override
  void initState() {
    userNameCont = TextEditingController(text: "e43304113@gmail.com");
    passCont = TextEditingController(text: "123456");
    hidePass = true;
    super.initState();
  }

  @override
  void dispose() {
    userNameCont.dispose();
    passCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UnderlineInputBorder focusedBorder = UnderlineInputBorder(
    //     borderSide:
    //         BorderSide(color: isError ? Colors.red : Clrs.blue, width: 3));

    // UnderlineInputBorder enabledBorder = UnderlineInputBorder(
    //     borderSide: BorderSide(color: isError ? Colors.red : Clrs.blue));

    List borders = CustomDecoration.giveInputDecoration(
        BorderType.under, Clrs.main, true,
        error: isError);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          constraints: const BoxConstraints(maxWidth: 500),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Unlock Your Potential",
                  style: TextStyle(
                      color: Clrs.main,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              TextFormField(
                style: TextStyle(color: Clrs.sec),
                cursorColor: Clrs.sec,
                controller: userNameCont,
                // decoration: InputDecoration(
                //     enabledBorder: enabledBorder,
                //     focusedBorder: focusedBorder,
                //     label: Text(
                //       "UserName",
                //       style: TextStyle(color: Clrs.blue),
                //     )),
                decoration: CustomDecoration.giveInputDecoration(
                    label: "UserName",
                    BorderType.under,
                    Clrs.main,
                    false,
                    textC: Clrs.sec,
                    error: isError),
              ),
              const SizedBox(height: 5),
              TextFormField(
                style: TextStyle(color: Clrs.sec),
                controller: passCont,
                obscureText: hidePass,
                cursorColor: Clrs.sec,
                decoration: InputDecoration(
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePass = !hidePass;
                        });
                      },
                      icon: Icon(
                        hidePass ? Icons.visibility : Icons.visibility_off,
                        color: Clrs.sec,
                      ),
                    ),
                    enabledBorder: borders[0],
                    focusedBorder: borders[1],
                    label: Text(
                      "Password",
                      style: TextStyle(color: Clrs.main),
                    )),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      try {
                        UserCredential credentials = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: userNameCont.text,
                                password: passCont.text);
                        if (credentials.user!.email == "e43304113@gmail.com") {
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminHomePage()));
                          }
                        } else {
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const StudentHomePage()));
                          }
                        }
                      } on FirebaseAuthException {
                        setState(() {
                          isError = true;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                        color: Clrs.main,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 150),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login,
                            color: Clrs.sec,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text("Login", style: TextStyle(color: Clrs.sec))
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
