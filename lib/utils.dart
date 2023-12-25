import 'package:flutter/material.dart';

Widget formatText(String text, TextStyle? style, Alignment alignment) {
  return Align(
    alignment: alignment,
    child: Text(text, style: style),
  );
}
