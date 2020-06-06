import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/rooms/room_search.dart';
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
      return GestureDetector(
          child: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onTap: () {
            showSearch(context: context, delegate: RoomSearch(model));
          });
    });
  }
}

class RoomSearch extends SearchDelegate<String> {
  MainModel model;
  String sorting = "low to high";

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
    "discount",
    "discount room",
    "discount rooms",
    "all rooms",
    "3bhk",
    "2bhk",
    "offer rooms",
    "province No. 1",
    "province No. 2",
    "bagmati Pradesh",
    "gandaki Pradesh",
    "province No. 5",
    "karnali Pradesh",
    "sudurpashchim Pradesh",
    "biratnagar",
    "janakpur",
    "hetauda",
    "pokhara",
    "butwal",
    "birendranagar",
    "godawari",
    "kathmandu"
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
          }),
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
    return Scaffold(
      body: Column(children: [
        Container(
          height: 50,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Card(
              elevation: 3,
              child: InkWell(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.sort),
                  ),
                  onTap: () {
                    if (sorting == "low to high") {
                      query = "price high to low";
                      sorting = "high to low";
                    } else {
                      sorting = "low to high";
                      query = "price low to high";
                    }
                  }),
            ),
            Card(
              elevation: 3,
              child: InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.gps_fixed),
                ),
                onTap: () {
                  model.getCurrentLocation("search").then((response) {
                    if (response == true) {
                      query = "nearby location";
                      showResults(context);
                    }
                  });
                },
              ),
            ),
          ]),
        ),
        Expanded(child: RoomSearchResult(query, model))
      ]),
    );
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
          query = suggestionsList[index].toString();
          showResults(context);
        },
        leading: Icon(Icons.location_city),
        title: RichText(
          text: TextSpan(
              text: suggestionsList[index]
                  .substring(0, query.length)
                  .toUpperCase(),
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
