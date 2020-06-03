import 'package:flutter/material.dart';

class TitleDefault extends StatelessWidget {
  final String title;

  TitleDefault(this.title);

  @override
  Widget build(BuildContext context) {
    final deviceHight = MediaQuery.of(context).size.height;
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: deviceHight > 500 ? 20.0 : 15.0, fontWeight: FontWeight.bold, fontFamily: 'Oswald'),
    );
  }
}
