import 'package:e_learning/global.dart';
import 'package:e_learning/main.dart';
import 'package:flutter/material.dart';

int activePage = 0;
bool sideBarShown = true;

class SideBar extends StatefulWidget {
  final Function onPageChanged;
  final bool sideBarShown;
  const SideBar(
      {super.key, required this.onPageChanged, required this.sideBarShown});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with TickerProviderStateMixin {
  late AnimationController sidebarAnimationCont;
  late Animation<double> sidebarAnimation;
  Duration animationDuration = const Duration(milliseconds: 150);
  // bool expanded = false;
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
            SideBarPages(
              onPageChanged: widget.onPageChanged,
              width: sidebarAnimation.value,
              isTextShown: textShown,
            ),
            SideBarActions(
              isTextShown: textShown,
              sidebarAnimation: sidebarAnimation,
              animationDuration: animationDuration,
              sidebarAnimationCont: sidebarAnimationCont,
              onPageChanged: widget.onPageChanged,
            )
          ],
        ),
      ),
    ));
  }
}

class SideBarPages extends StatelessWidget {
  final Function onPageChanged;
  final double width;
  final bool isTextShown;
  const SideBarPages(
      {super.key,
      required this.onPageChanged,
      required this.width,
      required this.isTextShown});

  @override
  Widget build(BuildContext context) {
    List pagesButtons = [
      {"icon": Icons.home, "text": "Home"},
      {"icon": Icons.person, "text": "Users"},
      {"icon": Icons.video_collection, "text": "Videos"},
      {"icon": Icons.assignment, "text": "HomeWork"}
    ];
    return Column(
      children: [
        ...pagesButtons.indexed.map((e) {
          int i = e.$1;
          Map data = e.$2;
          return SideBarItem(
              textShown: isTextShown,
              itemWidth: width,
              icon: data["icon"],
              text: data["text"],
              onTap: () {
                activePage = i;
                sideBarShown = false;
                onPageChanged();
              },
              isActive: activePage == i);
        }),
      ],
    );
  }
}

class SideBarActions extends StatelessWidget {
  final bool isTextShown;
  final Animation sidebarAnimation;
  final AnimationController sidebarAnimationCont;
  final Function onPageChanged;
  final Duration animationDuration;
  const SideBarActions(
      {super.key,
      required this.isTextShown,
      required this.sidebarAnimation,
      required this.sidebarAnimationCont,
      required this.onPageChanged,
      required this.animationDuration});

  static bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SideBarItem(
            isActive: true,
            icon: Icons.logout,
            textShown: isTextShown,
            itemWidth: sidebarAnimation.value,
            text: "Log out",
            onTap: () {
              Dbs.auth.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignIn()));
            }),
        SideBarItem(
            isActive: true,
            textShown: isTextShown,
            itemWidth: sidebarAnimation.value,
            icon: isTextShown ? Icons.fullscreen_exit : Icons.fullscreen,
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
            textShown: isTextShown,
            itemWidth: sidebarAnimation.value,
            icon: Icons.arrow_left,
            text: "Hide sidebar",
            onTap: () {
              sideBarShown = false;
              onPageChanged();
            },
            isActive: true)
      ],
    );
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
