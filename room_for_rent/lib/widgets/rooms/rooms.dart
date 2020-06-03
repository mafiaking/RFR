import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './room_card.dart';
import '../../models/room.dart';
import '../../scoped-models/main.dart';

class Rooms extends StatelessWidget {
  Widget _buildRoomList(List<Room> rooms) {
    Widget roomCards;
    if (rooms.length > 0) {
      roomCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            RoomCard(rooms[index]),
        itemCount: rooms.length,
      );
    } else {
      roomCards = Container();
    }
    return roomCards;
  }

  @override
  Widget build(BuildContext context) {
    print('[Rooms Widget] build()');
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      return  _buildRoomList(model.displayedRooms);
    },);
  }
}
