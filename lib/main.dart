import 'package:e_learning/admin/admin_home.dart';
import 'package:e_learning/admin/global_admin.dart';
import 'package:e_learning/student/student_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'global.dart';
import "package:provider/provider.dart";

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? user = Dbs.auth.currentUser;
  Widget home = const SignIn();
  if (user != null) {
    if (await isAdmin(user.uid)) {
      home = const AdminHomePage();
    } else {
      home = const StudentHomePage();
    }
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AddExamNotifier()),
      // ChangeNotifierProvider(create: (context) => ExamNotifier())
    ],
    child: MyApp(home: home),
  ));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: home,
    );
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
                        UserCredential credentials = await Dbs.auth
                            .signInWithEmailAndPassword(
                                email: userNameCont.text,
                                password: passCont.text);
                        bool admin = await isAdmin(credentials.user!.uid);
                        if (admin) {
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
                          vertical: 10, horizontal: 50),
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

Future<bool> isAdmin(String uid) async {
  return (await Dbs.firestore.doc("users/$uid").get()).get("role") == "admin";
}
