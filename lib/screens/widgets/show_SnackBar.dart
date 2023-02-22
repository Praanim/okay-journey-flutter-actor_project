import 'package:actor_project/colors.dart';
import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String text,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: mainColor,
      content: Text(
        text,
        style: TextStyle(color: Colors.white),
      )));
}
