import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum BorderType { out, under }

enum QuestionTypes { written, mcq }

enum DateType { startDate, deadline }

enum ExamStatus { passed, waiting, open }

class Dbs {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;
}

class Clrs {
  static Color main = const Color.fromRGBO(128, 147, 241, 1);
  static Color sec = const Color.fromRGBO(255, 202, 212, 1);
}

class CustomDecoration {
  static dynamic giveInputDecoration(
      BorderType type, Color color, bool justBorders,
      {double width = 1,
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
