import 'package:flutter/material.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:room_for_rent/widgets/rooms/rooms.dart';
import 'package:scoped_model/scoped_model.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Favorite Rooms"),
        ),
        body: model.displayedRooms.length > 0
            ? Column(children: <Widget>[Expanded(child: Rooms())])
            : Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height / 2),
                  Text("No Favorite Rooms")
                ],
              ),
      );
    });
  }
}
