import 'package:e_learning/admin/add_exam.dart';
import 'package:e_learning/admin/exam_list_admin.dart';
import 'package:e_learning/main.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Clrs.main,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    width: MediaQuery.of(context).size.width / 6 * 5,
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminExamListPage()));
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
            ),
            const SideBar()
          ],
        ),
      ),
    );
  }
}

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with TickerProviderStateMixin {
  late AnimationController sidebarAnimationCont;
  late Animation<double> sidebarAnimation;
  Duration animationDuration = const Duration(milliseconds: 150);
  bool expanded = false;
  bool textShown = false;

  @override
  void initState() {
    sidebarAnimationCont =
        AnimationController(vsync: this, duration: animationDuration);
    sidebarAnimation =
        Tween<double>(begin: 50, end: 200).animate(sidebarAnimationCont)
          ..addListener(() {
            setState(() {
              if (sidebarAnimation.value == 200) {
                textShown = true;
              } else {
                textShown = false;
              }
            });
          });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: sidebarAnimation.value,
      color: Color.lerp(Clrs.main, Colors.white, .8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SideBarItem(
                onTap: () {},
                icon: Icons.home,
                text: "Home",
                textShown: textShown,
                itemWidth: sidebarAnimation.value,
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                  onPressed: () {
                    Dbs.auth.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignIn()));
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Clrs.main,
                  )),
              IconButton(
                  onPressed: () {
                    if (!expanded) {
                      sidebarAnimationCont.forward();
                      Future.delayed(animationDuration, () {
                        expanded = !expanded;
                      });
                    } else {
                      expanded = !expanded;
                      sidebarAnimationCont.reverse();
                    }
                  },
                  icon: Icon(
                    expanded ? Icons.arrow_left : Icons.arrow_right,
                    color: Clrs.main,
                  ))
            ],
          )
        ],
      ),
    ));
  }
}

class SideBarItem extends StatefulWidget {
  final bool textShown;
  final double itemWidth;
  final IconData icon;
  final String text;
  final Function onTap;
  const SideBarItem(
      {super.key,
      required this.textShown,
      required this.itemWidth,
      required this.icon,
      required this.text,
      required this.onTap});

  @override
  State<SideBarItem> createState() => _SideBarItemState();
}

class _SideBarItemState extends State<SideBarItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.itemWidth - 10,
      child: IconButton(
        onPressed: () {
          widget.onTap();
        },
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              widget.icon,
              color: Clrs.main,
            ),
            Visibility(
                visible: widget.textShown,
                child: Text(
                  widget.text,
                  style: TextStyle(color: Clrs.main),
                ))
          ],
        ),
      ),
    );
  }
}
