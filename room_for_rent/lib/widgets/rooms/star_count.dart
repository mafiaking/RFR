import 'package:flutter/material.dart';

Widget star(int count) {
  return Stack(alignment: Alignment.center, children: [
    Image.asset(
      "assets/room_count.png",
      width: 30,
    ),
    Text(
      count.toString(),
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    )
  ]);
}
