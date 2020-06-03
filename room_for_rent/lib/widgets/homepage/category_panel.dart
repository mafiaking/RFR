import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/rooms/star_count.dart';
import '../../models/room.dart';
import 'package:room_for_rent/scoped-models/main.dart';

class Category extends StatefulWidget {
  final MainModel model;

  Category(this.model);
  @override
  _CategoryState createState() => _CategoryState();
}

Widget _buildSingleTile(MainModel model, BuildContext context) {
  final int singlecount = model.allRooms
      .where((Room room) => room.category == "Single room")
      .toList()
      .length;
  return InkWell(
      onTap: () {
        model.toggleDisplayMode(mode: "false");
        model.toggleDisplayMode(mode: "single");
        Navigator.pushNamed(context, '/category')
            .then((value) => model.toggleDisplayMode(mode: "false"));
      },
      child: Container(
        height: 80,
        width: 80,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Image.asset(
                  "assets/cat_single.png",
                  width: 60,
                ),
                star(singlecount)
              ],
            ),
            Text("Single Room", style: TextStyle(fontSize: 12))
          ],
        ),
      ));
}

Widget _buildDoubleTile(MainModel model, BuildContext context) {
  final int doublecount = model.allRooms
      .where((Room room) => room.category == "Double room")
      .toList()
      .length;
  return InkWell(
    onTap: () {
      model.toggleDisplayMode(mode: "false");
      model.toggleDisplayMode(mode: "double");
      Navigator.pushNamed(context, '/category')
          .then((value) => model.toggleDisplayMode(mode: "false"));
    },
    child: Container(
      height: 80,
      width: 80,
      child: Column(
        children: <Widget>[
          Stack(children: [
            Image.asset(
              "assets/cat_double.png",
              width: 60,
            ),
            star(doublecount)
          ]),
          Text("Double Room", style: TextStyle(fontSize: 12))
        ],
      ),
    ),
  );
}

Widget _buildApartmentTile(MainModel model, BuildContext context) {
  final int apartmentcount = model.allRooms
      .where((Room room) => room.category == "Apartment")
      .toList()
      .length;
  return InkWell(
    onTap: () {
      model.toggleDisplayMode(mode: "false");
      model.toggleDisplayMode(mode: "apartment");
      Navigator.pushNamed(context, '/category')
          .then((value) => model.toggleDisplayMode(mode: "false"));
    },
    child: Container(
      height: 80,
      width: 80,
      child: Column(
        children: <Widget>[
          Stack(children: [
            Image.asset(
              "assets/cat_apartment.png",
              width: 60,
            ),
            star(apartmentcount)
          ]),
          Text("Apartment", style: TextStyle(fontSize: 12))
        ],
      ),
    ),
  );
}

Widget _buildFlatTile(MainModel model, BuildContext context) {
  final int flatcount = model.allRooms
      .where((Room room) => room.category == "Flat")
      .toList()
      .length;
  return InkWell(
    onTap: () {
      model.toggleDisplayMode(mode: "false");
      model.toggleDisplayMode(mode: "flat");
      Navigator.pushNamed(context, '/category')
          .then((value) => model.toggleDisplayMode(mode: "false"));
    },
    child: Container(
      height: 80,
      width: 80,
      child: Column(
        children: <Widget>[
          Stack(children: [
            Image.asset(
              "assets/cat_flat.png",
              width: 60,
            ),
            star(flatcount)
          ]),
          Text("Flat", style: TextStyle(fontSize: 12))
        ],
      ),
    ),
  );
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.only( left: 35, right: 35),
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text("Category"),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildSingleTile(widget.model, context),
                _buildDoubleTile(widget.model, context)
              ],
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildApartmentTile(widget.model, context),
                _buildFlatTile(widget.model, context)
              ],
            )
          ],
        ),
      ),
    );
  }
}
