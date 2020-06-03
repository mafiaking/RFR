import 'package:flutter/material.dart';

class PageStatus extends StatelessWidget {
  final String succes;
  final String failed;

  PageStatus(this.succes, this.failed);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Status")),
      body: Center(child: Text(succes + failed)),
    );
  }
}
