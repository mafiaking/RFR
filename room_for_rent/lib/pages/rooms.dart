import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/ui_elements/aboutus_dialogue.dart';
import 'package:room_for_rent/widgets/ui_elements/adapative_progress_indicator.dart';

import 'package:scoped_model/scoped_model.dart';

import '../widgets/rooms/rooms.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import '../scoped-models/main.dart';

class RoomsPage extends StatefulWidget {
  final MainModel model;

  RoomsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _RoomsPageState();
  }
}

class _RoomsPageState extends State<RoomsPage> {
  @override
  initState() {
    widget.model.fetchRooms();
    super.initState();
  }

  Widget _buildSideDrawer(BuildContext context, Function selRoom) {
    return Drawer(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Choose'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/homepage');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Rooms'),
            onTap: () {
              selRoom(null);
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text("Favorite"),
            onTap: () {
              Navigator.pop(context);
              widget.model.toggleDisplayMode(mode: "true");
              Navigator.pushNamed(context, '/favorite').then(
                  (value) => widget.model.toggleDisplayMode(mode: "false"));
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
    ));
  }

  Widget _buildRoomsList() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = Center(child: Text('No Rooms Found!'));
        if (model.displayedRooms.length > 0 && !model.isLoading) {
          content = Rooms();
        } else if (model.isLoading) {
          content = Center(child: AdaptiveProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: model.fetchRooms,
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        drawer: _buildSideDrawer(context, model.selectRoom),
        appBar: AppBar(
          title: Text('EasyList'),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(model.displayFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () {
                model.toggleDisplayMode(mode: "toggle");
              },
            ),
          ],
        ),
        body: _buildRoomsList(),
      );
    });
  }
}
