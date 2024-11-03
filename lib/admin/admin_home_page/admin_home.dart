import 'package:e_learning/admin/admin_home_page/sidebar.dart';
import 'package:e_learning/admin/dashboard.dart';
import 'package:e_learning/admin/files_list_admin.dart';
import 'package:e_learning/admin/users.dart';
import 'package:flutter/material.dart';
import "../../global.dart";

// int activePage = 0;
// bool sideBarShown = true;

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
    pages = [
      const DashboardPage(),
      const UsersPage(),
      const FilesListPage(),
      const Placeholder()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                onPageChanged: () {
                  setState(() {});
                })
          ],
        ),
      ),
    );
  }
}
