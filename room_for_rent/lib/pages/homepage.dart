import 'package:animations/animations.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:room_for_rent/pages/favorite.dart';
import 'package:room_for_rent/pages/notification_page.dart';
import 'package:room_for_rent/pages/profile.dart';
import 'package:room_for_rent/pages/rooms_admin.dart';
import 'package:room_for_rent/utils/search_deligate.dart';
import 'package:room_for_rent/widgets/homepage/room_card.dart';
import 'package:room_for_rent/widgets/homepage/second_pwage.dart';
import 'package:room_for_rent/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

import '../widgets/homepage/category_panel.dart';
import '../models/room.dart';

class HomePage extends StatefulWidget {
  final MainModel model;

  HomePage(this.model);
  @override
  _HomePageState createState() => _HomePageState();
}

Widget _sliverAppBar(BuildContext context) {
  return SliverAppBar(
    automaticallyImplyLeading: false,
    expandedHeight: 100,
    pinned: true,
    // centerTitle: true,
    // title: Container(
    //   child: RoomSearchIcon(),
    // ),
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "ROOM FOR RENT",
          ),
          RoomSearchIcon()
        ],
      ),
      background: Container(
        // padding: EdgeInsets.all(20),
        color: Colors.red,
        // child: Align(
        //     alignment: Alignment.center,
        //     child: Text(
        //       "making room renting easy",
        //       style: TextStyle(color: Colors.white),
        //     )),
      ),
    ),
  );
}

Widget _buildRoomList(List<Room> rooms, bool isLoading) {
  Widget roomCards;
  if (rooms.length > 0) {
    roomCards = SliverFixedExtentList(
      itemExtent: 250,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => RoomCard(rooms[index]),
        childCount: rooms.length,
      ),
    );
  } else if (isLoading) {
    roomCards = SliverFixedExtentList(
      itemExtent: 250,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => AdaptiveProgressIndicator(),
        childCount: 1,
      ),
    );
  } else
    roomCards = SliverFixedExtentList(
      itemExtent: 250,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => Center(
            child: Text(
          "Oops No Room Found!",
          style: TextStyle(color: Colors.red),
        )),
        childCount: 1,
      ),
    );
  return roomCards;
}

Widget _buildSliverPage() {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            _sliverAppBar(context),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: model.isLoading
                        ? LinearProgressIndicator(
                            backgroundColor: Colors.blue,
                          )
                        : Container(),
                  ),
                  Category(model),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        SecondNotificationPage()));
                          },
                          child: Text("Just for you"),
                        ),
                        FlatButton(
                          onPressed: () {
                            model.toggleDisplayMode(mode: "false");
                            Navigator.pushReplacementNamed(context, '/list')
                                .then((value) => model.selectRoom(null));
                          },
                          child: Text("View All"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            ScopedModelDescendant<MainModel>(
                builder: (BuildContext context, Widget child, MainModel model) {
              return _buildRoomList(model.allRooms, model.isLoading);
            }),
          ],
        ),
        onRefresh: model.fetchRooms);
  });
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    widget.model.fetchRooms().then((value) {
      if (widget.model.user.info == false) {
        widget.model.getUserInfo();
        widget.model.getUserNotification();
      }
    });

    super.initState();
  }

  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    _buildSliverPage(),
    Favorite(),
    NotificationList(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      setState(() {
        widget.model.toggleDisplayMode(mode: "true");
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.model.toggleDisplayMode(mode: "false");
          Navigator.pushNamed(context, '/admin')
              .then((value) => widget.model.selectRoom(null));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        height: 50,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        index: _selectedIndex,
        items: <Widget>[
          Icon(
            Icons.home,
            color: Colors.blue,
          ),
          Icon(Icons.favorite, color: Colors.red),
          Icon(
            Icons.notifications_active,
            color: Colors.orange,
          ),
          Icon(
            Icons.person,
            color: Colors.pink,
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
