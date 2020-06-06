import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:scoped_model/scoped_model.dart';

import '../../scoped-models/main.dart';

class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            model.logout();
            Fluttertoast.showToast(
                msg: "logged out succesfully",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey.shade700,
                textColor: Colors.white,
                fontSize: 12.0);
          },
        );
      },
    );
  }
}
