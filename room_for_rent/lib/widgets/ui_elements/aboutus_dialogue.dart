import 'package:flutter/material.dart';

class AboutUsDialogue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationIcon: Image.asset(
        "assets/logo_small.png",
        width: 30,
      ),
      applicationLegalese: "All rights reserved\nSujata Regmi",
      applicationName: "Room for Rent",
      applicationVersion: "1.0.0+1",
    );
  }
}
