import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

enum BorderType { out, under }

enum QuestionTypes { written, mcq }

enum DateType { startDate, deadline }

enum ExamStatus { passed, waiting, open }

enum RowType { header, normal }

enum FileExt { img, dir, vid, file, loading }

class Dbs {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static Reference storage = FirebaseStorage.instance.ref();
}

class Clrs {
  static Color main = const Color.fromRGBO(128, 147, 241, 1);
  // static Color sec = const Color.fromRGBO(255, 202, 212, 1);
  static Color sec = const Color.fromRGBO(0, 20, 39, 1);
}

class StudentLevels {
  static Map levels = {
    0: "All",
    1: "1st prep",
    2: "2nd prep",
    3: "3rd prep",
    4: "1st sec",
    5: "2nd sec",
    6: "3rd sec"
  };
}

class CustomDecoration {
  static dynamic giveInputDecoration(BorderType type, Color color,
      {double width = 1,
      bool justBorders = false,
      Color fill = Colors.transparent,
      double radius = 0,
      String label = "",
      String hint = "",
      bool error = false,
      Color? textC,
      double? focusWidth}) {
    textC ??= color;

    focusWidth ??= width + 2;

    BorderSide side = BorderSide(
      color: error ? Colors.red : color,
      width: width,
    );

    BorderSide sideFocus = BorderSide(
      color: error ? Colors.red : color,
      width: focusWidth,
    );

    TextStyle hintStyle =
        TextStyle(color: Color.lerp(Colors.white, textC, 0.7));

    InputBorder enabledBorder = type == BorderType.out
        ? OutlineInputBorder(
            borderSide: side, borderRadius: BorderRadius.circular(radius))
        : UnderlineInputBorder(
            borderSide: side, borderRadius: BorderRadius.circular(radius));

    InputBorder focusBorder = type == BorderType.out
        ? OutlineInputBorder(
            borderSide: side, borderRadius: BorderRadius.circular(radius))
        : UnderlineInputBorder(
            borderSide: sideFocus, borderRadius: BorderRadius.circular(radius));

    if (justBorders) {
      return [enabledBorder, focusBorder];
    }

    return InputDecoration(
        labelStyle: hintStyle,
        hintStyle: hintStyle,
        label: label == "" ? null : Text(label),
        hintText: hint,
        fillColor: fill,
        filled: fill != Colors.transparent,
        enabledBorder: enabledBorder,
        focusedBorder: focusBorder);
  }
}

class FileData {
  static Map<FileExt, IconData> icons = {
    FileExt.dir: Icons.folder,
    FileExt.file: Icons.insert_drive_file,
    FileExt.img: Icons.image,
    FileExt.vid: Icons.video_file
  };
}
