import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:room_for_rent/scoped-models/main.dart';

class RoomSearchIcon extends StatefulWidget {
  @override
  _RoomSearchIconState createState() => _RoomSearchIconState();
}

class _RoomSearchIconState extends State<RoomSearchIcon> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Align(
          alignment: Alignment.topRight,
          child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                print("Searching");
                showSearch(context: context, delegate: RoomSearch(model));
              }));
    });
  }
}

class RoomSearch extends SearchDelegate<String> {
  MainModel model;

  RoomSearch(this.model);
  final List serachQueries = [
    "flat",
    "flats",
    "apartment",
    "apartments",
    "single room",
    "single",
    "single rooms",
    "double room",
    "double",
    "double rooms",
    "room",
    "rooms",
    "disount",
    "discount room",
    "discount rooms",
    "all rooms"
  ];

  final roomCategories = [
    "flat",
    "apartment",
    "single room",
    "double room",
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
        child: Container(
      height: 100,
      width: 100,
      child: Text(query),
      color: Colors.red,
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionsList = query.isEmpty
        ? roomCategories
        : serachQueries
            .where((e) => e.startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
        leading: Icon(Icons.location_city),
        title: RichText(
          text: TextSpan(
              text: suggestionsList[index].substring(0, query.length),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: suggestionsList[index].substring(query.length),
                    style: TextStyle(color: Colors.grey))
              ]),
        ),
      ),
      itemCount: suggestionsList.length,
    );
  }
}
