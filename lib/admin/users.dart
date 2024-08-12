import 'package:e_learning/global.dart';
import 'package:flutter/material.dart';

List selectedUsers = [];

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
                bool isBlue = true;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            color: Clrs.main,
                            onPressed: () {
                              //TODO:add user
                            },
                            icon: Row(children: [
                              const Icon(Icons.add),
                              Text(
                                "New",
                                style: TextStyle(color: Clrs.main),
                              )
                            ])),
                        IconButton(
                            color: Clrs.main,
                            onPressed: () {
                              if (selectedUsers.isEmpty) {
                                return;
                              }
                              // TODO:delete users
                            },
                            icon: Row(children: [
                              const Icon(Icons.delete_outline),
                              Text(
                                "Delete",
                                style: TextStyle(color: Clrs.main),
                              )
                            ]))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    UserRow(isHeader: true, isBlue: isBlue, cells: const [
                      "Email",
                      "Role",
                      "First name",
                      "Last name"
                    ]),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...snap.data!.docs.map((user) {
                              isBlue = !isBlue;
                              return UserRow(
                                  id: user.id,
                                  isHeader: false,
                                  isBlue: isBlue,
                                  cells: [
                                    user.get("email"),
                                    user.get("role"),
                                    user.get("fName"),
                                    user.get("lName")
                                  ]);
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            )));
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
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    Color? c = Color.lerp(Clrs.main, Colors.white, widget.isBlue ? 0.9 : 1);
    Color textC = Clrs.main;
    if (widget.isHeader) {
      c = Clrs.main;
      textC = Colors.white;
    } else {
      selected = selectedUsers.contains(widget.id);
    }
    if (selected) {
      c = Clrs.sec;
    }
    return InkWell(
      onLongPress: widget.isHeader
          ? null
          : () {
              setState(() {
                if (selected) {
                  selectedUsers.remove(widget.id);
                } else {
                  selectedUsers.add(widget.id);
                }
              });
            },
      onTap: widget.isHeader
          ? null
          : () {
              setState(() {
                if (selected) {
                  selectedUsers.remove(widget.id);
                } else if (selectedUsers.isNotEmpty) {
                  selectedUsers.add(widget.id);
                }
              });
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...widget.cells.map((cell) {
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
