import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/ui_elements/aboutus_dialogue.dart';

import './room_edit.dart';
import './room_list.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import '../scoped-models/main.dart';

class RoomsAdminPage extends StatelessWidget {
  final MainModel model;

  RoomsAdminPage(this.model);

  Widget _buildSideDrawer(BuildContext context, MainModel model) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Choose'),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/homepage');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.shop),
              title: Text('All Rooms'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/list');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favorite"),
              onTap: () {
                Navigator.pop(context);
                model.toggleDisplayMode(mode: "true");
                Navigator.pushNamed(context, '/favorite')
                    .then((value) => model.toggleDisplayMode(mode: "false"));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AboutUsDialogue();
                    });
              },
            ),
            Divider(),
            LogoutListTile()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildSideDrawer(context, model),
        appBar: AppBar(
          title: Text('Manage Rooms'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Room',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Rooms',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[RoomEditPage(), RoomListPage(model)],
        ),
      ),
    );
  }
}
