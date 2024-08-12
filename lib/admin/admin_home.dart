import 'package:e_learning/admin/dashboard.dart';
import 'package:e_learning/admin/users.dart';
import 'package:e_learning/main.dart';
import 'package:flutter/material.dart';
import "../global.dart";

int activePage = 0;
bool sideBarShown = true;

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late List pages;
  @override
  void initState() {
    activePage = 0;
    sideBarShown = true;
    pages = [
      const DashboardPage(),
      const UsersPage(),
      const Placeholder(),
      const Placeholder()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // sideBarShown = MediaQuery.of(context).size.width >= 700;
    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      backgroundColor: Colors.white,
      floatingActionButton: Visibility(
        visible: !sideBarShown,
        child: IconButton(
          icon: Icon(
            Icons.arrow_right,
            color: Clrs.main,
          ),
          onPressed: () {
            setState(() {
              sideBarShown = true;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            pages[activePage],
            SideBar(
                sideBarShown: sideBarShown,
                onTap: () {
                  setState(() {});
                })
          ],
        ),
      ),
    );
  }
}

class SideBar extends StatefulWidget {
  final Function onTap;
  final bool sideBarShown;
  const SideBar({super.key, required this.onTap, required this.sideBarShown});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with TickerProviderStateMixin {
  late AnimationController sidebarAnimationCont;
  late Animation<double> sidebarAnimation;
  Duration animationDuration = const Duration(milliseconds: 150);
  bool expanded = false;
  bool textShown = false;

  List<Map> pagesButtons = [];

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
    pagesButtons = [
      {"icon": Icons.home, "text": "Home"},
      {"icon": Icons.person, "text": "Users"},
      {"icon": Icons.video_collection, "text": "Videos"},
      {"icon": Icons.assignment, "text": "HomeWork"}
    ];
    return Positioned(
        child: Visibility(
      visible: widget.sideBarShown,
      child: Container(
        decoration: BoxDecoration(
            color: Color.lerp(Clrs.main, Colors.white, .8),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: sidebarAnimation.value,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                ...pagesButtons.indexed.map((e) {
                  int i = e.$1;
                  Map data = e.$2;
                  return SideBarItem(
                      textShown: textShown,
                      itemWidth: sidebarAnimation.value,
                      icon: data["icon"],
                      text: data["text"],
                      onTap: () {
                        activePage = i;
                        if (activePage == 1) {
                          sideBarShown = false;
                        }
                        widget.onTap();
                      },
                      isActive: activePage == i);
                }),
              ],
            ),
            Column(
              children: [
                SideBarItem(
                    isActive: true,
                    icon: Icons.logout,
                    textShown: textShown,
                    itemWidth: sidebarAnimation.value,
                    text: "Log out",
                    onTap: () {
                      Dbs.auth.signOut();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const SignIn()));
                    }),
                SideBarItem(
                    isActive: true,
                    textShown: textShown,
                    itemWidth: sidebarAnimation.value,
                    icon: textShown ? Icons.fullscreen_exit : Icons.fullscreen,
                    text: "Minimise",
                    onTap: () {
                      if (!expanded) {
                        sidebarAnimationCont.forward();
                        Future.delayed(animationDuration, () {
                          expanded = !expanded;
                        });
                      } else {
                        expanded = !expanded;
                        sidebarAnimationCont.reverse();
                      }
                    }),
                SideBarItem(
                    textShown: textShown,
                    itemWidth: sidebarAnimation.value,
                    icon: Icons.arrow_left,
                    text: "Hide sidebar",
                    onTap: () {
                      sideBarShown = false;
                      widget.onTap();
                    },
                    isActive: true)
              ],
            )
          ],
        ),
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
  final bool isActive;
  const SideBarItem(
      {super.key,
      required this.textShown,
      required this.itemWidth,
      required this.icon,
      required this.text,
      required this.onTap,
      required this.isActive});

  @override
  State<SideBarItem> createState() => _SideBarItemState();
}

class _SideBarItemState extends State<SideBarItem> {
  @override
  Widget build(BuildContext context) {
    Color? c =
        widget.isActive ? Clrs.main : Color.lerp(Clrs.sec, Colors.pink, 0.2);
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
              color: c,
            ),
            SizedBox(
              width: widget.itemWidth <= 80 ? 0 : 10,
            ),
            Visibility(
                visible: widget.textShown,
                child: Text(
                  widget.text,
                  style: TextStyle(color: c),
                ))
          ],
        ),
      ),
    );
  }
}
