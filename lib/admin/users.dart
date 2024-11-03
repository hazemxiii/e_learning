import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// to apply an option for multiple users
List selectedUsers = [];
// to check if there's only student selected, admins, or both
int selectedStudentNum = 0;

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> with TickerProviderStateMixin {
  late AnimationController addUserAnimationCont;
  late Animation addUserAnimation;
  late TextEditingController passwordCont;

  @override
  void initState() {
    addUserAnimationCont = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    addUserAnimation =
        Tween<double>(begin: -300, end: 0).animate(addUserAnimationCont)
          ..addListener(() {
            setState(() {});
          });

    passwordCont = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        Container(
            padding: const EdgeInsets.all(15),
            child: StreamBuilder(
              stream: Dbs.firestore.collection("users").snapshots(),
              builder: (context, snap) {
                if (snap.data == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Clrs.main,
                    ),
                  );
                }
                // rows of the table aren't all the same color
                bool isBlue = true;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OptionsRow(
                      addUserAnimationCont: addUserAnimationCont,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: passwordCont,
                            style: TextStyle(color: Clrs.sec),
                            cursorColor: Clrs.sec,
                            decoration: CustomDecoration.giveInputDecoration(
                              radius: 10,
                              BorderType.out,
                              Clrs.sec,
                              hint: "Password",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    UserRow(isHeader: true, isBlue: isBlue, cells: const [
                      "Email",
                      "Role",
                      "First name",
                      "Last name",
                      "Level",
                      "Password"
                    ]),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...snap.data!.docs.map((user) {
                              isBlue = !isBlue;
                              String role = user.get("role");
                              return UserRow(
                                  id: user.id,
                                  isHeader: false,
                                  isBlue: isBlue,
                                  cells: [
                                    user.get("email"),
                                    role,
                                    user.get("fName"),
                                    user.get("lName"),
                                    role == "student"
                                        ? StudentLevels
                                            .levels[user.get("level")]
                                        : "",
                                    user.data()['password'] ?? ""
                                  ]);
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            )),
        Positioned(
            bottom: addUserAnimation.value,
            child: AddUserDrawer(
              animationController: addUserAnimationCont,
              passwordCont: passwordCont,
            ))
      ],
    ));
  }
}

class UserRow extends StatefulWidget {
  final List cells;
  final bool isBlue;
  final bool isHeader;
  final String? id;
  const UserRow(
      {super.key,
      required this.cells,
      required this.isBlue,
      required this.isHeader,
      this.id});

  @override
  State<UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<UserRow> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    Color? c = Color.lerp(Clrs.main, Colors.white, widget.isBlue ? 0.9 : 1);
    Color textC = Clrs.main;
    if (widget.isHeader) {
      c = Clrs.main;
      textC = Colors.white;
    } else {
      isSelected = selectedUsers.contains(widget.id);
    }
    if (isSelected) {
      c = Clrs.sec;
    }
    return InkWell(
      onLongPress: widget.isHeader
          ? null
          : () {
              setState(() {
                toggleSelectUser(widget.id!, widget.cells[1]);
              });
            },
      onTap: widget.isHeader
          ? null
          : () {
              // single press will only work if the user is selected or multi selection is active
              if (isSelected || selectedUsers.isNotEmpty) {
                setState(() {
                  toggleSelectUser(widget.id!, widget.cells[1]);
                });
              }
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...widget.cells.map((cell) {
            // if it's the first cell on the left or the last on the right to give them border radius
            bool isLeftMost = cell == widget.cells.first;
            bool isRightMost = cell == widget.cells.last;
            return Container(
              padding: const EdgeInsets.only(left: 5),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: c,
                  borderRadius: widget.isHeader
                      ? BorderRadius.only(
                          topLeft: Radius.circular(isLeftMost ? 5 : 0),
                          topRight: Radius.circular(isRightMost ? 5 : 0))
                      : null),
              height: 30,
              width: (MediaQuery.of(context).size.width - 30) /
                  widget.cells.length,
              child: Text(
                overflow: TextOverflow.ellipsis,
                cell,
                style: TextStyle(color: textC),
              ),
            );
          })
        ],
      ),
    );
  }
}

class OptionsRow extends StatefulWidget {
  final AnimationController addUserAnimationCont;
  const OptionsRow({
    super.key,
    required this.addUserAnimationCont,
  });

  @override
  State<OptionsRow> createState() => _OptionsRowState();
}

class _OptionsRowState extends State<OptionsRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: [
          IconButton(
              color: Clrs.main,
              onPressed: () {
                widget.addUserAnimationCont.forward();
              },
              icon: Wrap(children: [
                const Icon(Icons.add),
                Text(
                  "New",
                  style: TextStyle(color: Clrs.main),
                )
              ])),
          // IconButton(
          //     color: Colors.red,
          //     onPressed: () {
          //       if (selectedUsers.isNotEmpty) {
          //         deleteUsers(context);
          //       }
          //     },
          //     icon: const Wrap(children: [
          //       Icon(Icons.delete_outline),
          //       Text(
          //         "Delete",
          //         style: TextStyle(color: Colors.red),
          //       )
          //     ])),
          IconButton(
              color: Clrs.main,
              onPressed: () {
                if (selectedStudentNum == selectedUsers.length &&
                    selectedUsers.isNotEmpty) {
                  changeStudentLevel(true);
                }
              },
              icon: Wrap(children: [
                const Icon(Icons.arrow_upward),
                Text(
                  "Level Up",
                  style: TextStyle(color: Clrs.main),
                )
              ])),
          IconButton(
              color: Clrs.main,
              onPressed: () {
                if (selectedStudentNum == selectedUsers.length &&
                    selectedUsers.isNotEmpty) {
                  changeStudentLevel(false);
                }
              },
              icon: Wrap(children: [
                const Icon(Icons.arrow_downward),
                Text(
                  "Level down",
                  style: TextStyle(color: Clrs.main),
                )
              ]))
        ],
      ),
    );
  }
}

class AddUserDrawer extends StatefulWidget {
  final AnimationController animationController;
  final TextEditingController passwordCont;
  const AddUserDrawer(
      {super.key,
      required this.animationController,
      required this.passwordCont});

  @override
  State<AddUserDrawer> createState() => _AddUserDrawerState();
}

class _AddUserDrawerState extends State<AddUserDrawer> {
  late TextEditingController emailCont;
  late TextEditingController fNameCont;
  late TextEditingController lNameCont;
  String role = "student";
  int level = 1;

  @override
  void initState() {
    emailCont = TextEditingController();
    fNameCont = TextEditingController();
    lNameCont = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailCont.dispose();
    fNameCont.dispose();
    lNameCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 300,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Clrs.sec,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  color: Clrs.main,
                  onPressed: () async {
                    bool created = await createUser(
                        context,
                        emailCont.text,
                        fNameCont.text,
                        lNameCont.text,
                        role,
                        level,
                        widget.passwordCont.text);
                    if (created) {
                      emailCont.text = "";
                      fNameCont.text = "";
                      lNameCont.text = "";
                      role = "student";
                      level = 1;
                      widget.animationController.reverse();
                    }
                  },
                  icon: Row(
                    children: [
                      const Icon(Icons.save),
                      Text(
                        "Save",
                        style: TextStyle(color: Clrs.main),
                      )
                    ],
                  )),
              IconButton(
                  color: Clrs.main,
                  onPressed: () {
                    widget.animationController.reverse();
                  },
                  icon: Row(
                    children: [
                      const Icon(Icons.cancel),
                      Text(
                        "Cancel",
                        style: TextStyle(color: Clrs.main),
                      )
                    ],
                  ))
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: emailCont,
                  style: TextStyle(color: Clrs.main),
                  cursorColor: Clrs.main,
                  decoration: CustomDecoration.giveInputDecoration(
                    hint: "Email",
                    BorderType.under,
                    Clrs.main,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              DropdownButton(
                  value: role,
                  items: [
                    DropdownMenuItem(
                        value: "student",
                        child: Text(
                          "Student",
                          style: TextStyle(color: Clrs.main),
                        )),
                    DropdownMenuItem(
                        value: "admin",
                        child: Text(
                          "Admin",
                          style: TextStyle(color: Clrs.main),
                        ))
                  ],
                  onChanged: (v) {
                    setState(() {
                      role = v!;
                    });
                  })
            ],
          ),
          Row(
            children: [
              SizedBox(
                  width: 100,
                  child: TextField(
                    controller: fNameCont,
                    style: TextStyle(color: Clrs.main),
                    cursorColor: Clrs.main,
                    decoration: CustomDecoration.giveInputDecoration(
                      hint: "First name",
                      BorderType.under,
                      Clrs.main,
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: lNameCont,
                  style: TextStyle(color: Clrs.main),
                  cursorColor: Clrs.main,
                  decoration: CustomDecoration.giveInputDecoration(
                    hint: "Last name",
                    BorderType.under,
                    Clrs.main,
                  ),
                ),
              )
            ],
          ),
          Visibility(
            visible: role == "student",
            child: Row(
              children: [
                DropdownButton(
                    value: level,
                    items: List.generate(6, (i) {
                      return DropdownMenuItem(
                          value: i + 1,
                          child: Text(
                            StudentLevels.levels[i + 1]!,
                            style: TextStyle(color: Clrs.main),
                          ));
                    }),
                    onChanged: (v) {
                      setState(() {
                        level = v!;
                      });
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }
}

void toggleSelectUser(String id, String role) {
  if (selectedUsers.contains(id)) {
    selectedUsers.remove(id);
    if (role == "student") {
      selectedStudentNum--;
    }
  } else {
    selectedUsers.add(id);
    if (role == "student") {
      selectedStudentNum++;
    }
  }
}

Future<bool> createUser(BuildContext context, String email, String fName,
    String lName, String role, int level, String oldPassword) async {
  // the email of the admin that create the user
  String oldEmail = Dbs.auth.currentUser!.email!;
  // sign in to check the password the user provided is correct
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    print(prefs.getString("pass"));
    await Dbs.auth.signInWithEmailAndPassword(
        email: oldEmail, password: prefs.getString("pass")!);
  } on FirebaseAuthException {
    if (context.mounted) {
      showAwesomeDialog(context, "Password incorrect");
    }
    return false;
  }

  if (email == "" || fName == "" || lName == "") {
    if (context.mounted) {
      showAwesomeDialog(context, "No field can be left blank");
    }
    return false;
  }
  // the random password for the user
  String password = "";
  String domain = "@elearning.com";
  // chars we don't want to show up in the random password that lies between the ascii range we want
  List invalidChars = [
    "'",
    "(",
    ")",
    ":",
    ";",
    "`",
    ",",
    "-",
    ".",
    "[",
    "]",
    "\\"
  ];
  while (password.length < 13) {
    String ascii = String.fromCharCode(Random().nextInt(122 - 35) + 35);
    if (!invalidChars.contains(ascii)) {
      password += ascii;
    }
  }
  // create the user
  UserCredential? credentials;
  try {
    credentials = await Dbs.auth.createUserWithEmailAndPassword(
        email: "$email$domain", password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == "email-already-in-use" && context.mounted) {
      showAwesomeDialog(context, "Duplicated email");
    }
    return false;
  }

  String uid = credentials.user!.uid;
  if (credentials.user != null) {
    DocumentReference userDoc = Dbs.firestore.doc("users/$uid");
    var batch = Dbs.firestore.batch();
    batch.set(userDoc, {
      "email": "$email$domain",
      "fName": fName,
      "lName": lName,
      "role": role
    });
    if (role == "student") {
      batch.update(userDoc, {"level": level});
    }

    try {
      await Dbs.auth.signInWithEmailAndPassword(
          email: oldEmail, password: prefs.getString("pass")!);
    } on FirebaseAuthException {
      //
    }
    batch.commit().then((v) {}).catchError((e) {
      // print(e);
    });

    // sign in again in the old account
    if (context.mounted) {
      showCopyPassword(context, password);
    }
    return true;
  }
  return false;
}

void showAwesomeDialog(BuildContext context, String desc) {
  AwesomeDialog(
          context: context,
          title: "Couldn't create user",
          desc: desc,
          width: MediaQuery.of(context).size.width / 2,
          titleTextStyle: TextStyle(color: Clrs.main),
          descTextStyle: TextStyle(color: Clrs.sec),
          dialogType: DialogType.error)
      .show();
}

void showCopyPassword(BuildContext context, String password) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Clrs.sec,
          content: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            children: [
              Text(
                "User created with password:",
                style: TextStyle(color: Clrs.main),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Clrs.main,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: IconButton(
                  color: Clrs.sec,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: password));
                    Navigator.of(context).pop();
                  },
                  icon: Wrap(
                    children: [
                      Text(
                        password,
                        style: TextStyle(color: Clrs.sec),
                      ),
                      const Icon(Icons.copy)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

void deleteUsers(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            content:
                Text("You're about to delete ${selectedUsers.length} users"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Clrs.main),
                  )),
              TextButton(
                  onPressed: () async {
                    for (int i = 0; i < selectedUsers.length; i++) {
                      // String uid = selectedUsers[i];
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          ));
}

void changeStudentLevel(bool isUp) async {
  var batch = Dbs.firestore.batch();
  for (int i = 0; i < selectedUsers.length; i++) {
    String uid = selectedUsers[i];
    DocumentReference studentDocRef = Dbs.firestore.doc("users/$uid");
    DocumentSnapshot studentDoc = await studentDocRef.get();
    int oldLevel = studentDoc.get("level");
    if (isUp && oldLevel < 6) {
      batch.update(studentDocRef, {"level": oldLevel + 1});
    } else if (!isUp && oldLevel > 1) {
      batch.update(studentDocRef, {"level": oldLevel - 1});
    }
  }
  batch.commit().then((v) {}).catchError((e) => e);
}
