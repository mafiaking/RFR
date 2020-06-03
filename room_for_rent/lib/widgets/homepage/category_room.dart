import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:room_for_rent/widgets/rooms/rooms.dart';

class CategoryRooms extends StatefulWidget {
  @override
  _CategoryRooms createState() => _CategoryRooms();
}

class _CategoryRooms extends State<CategoryRooms> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(title: Text(model.categoryName.toString())),
        body: model.displayedRooms.length > 0
            ? Rooms()
            : Center(
                child: Text(
                "rooms not available \n of this category",
                textAlign: TextAlign.center,
              )),
      );
    });
  }
}
