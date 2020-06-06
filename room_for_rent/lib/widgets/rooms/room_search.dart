import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import './room_card.dart';
import '../../models/room.dart';
import '../../scoped-models/main.dart';

class RoomSearchResult extends StatelessWidget {
  final String query;
  final MainModel model;

  RoomSearchResult(this.query, this.model);

  Widget _buildRoomList(List<Room> rooms, BuildContext context) {
    Widget roomCards;
    if (rooms.length > 0) {
      roomCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            RoomCard(rooms[index]),
        itemCount: rooms.length,
      );
    } else {
      if (query.isEmpty) {
        roomCards = Center(
            child: Text(
          "Enter something to search.",
          style: TextStyle(color: Colors.red),
        ));
      } else
        roomCards = Center(
          child: Text(
            '''Oops nothing found with "${query.toString()}"''',
            style: TextStyle(color: Colors.red),
          ),
        );
    }
    return roomCards;
  }

  List _buildRoomResultList() {
    List roomList;

    roomList = model.allRooms
        .where((Room room) => room.title.toLowerCase() == query.toLowerCase())
        .toList();

    if (query == "price low to high") {
      roomList = model.allRooms;
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (query == "price high to low") {
      roomList = model.allRooms;
      roomList.sort((a, b) => b.price.floor().compareTo(a.price.floor()));
    }
    if (query == "nearby location") {
      roomList = model.allRooms.where((Room room) {
        if (model.currentLocation != null) {
          final Distance distance = new Distance();
          final double km = distance.as(
              LengthUnit.Kilometer,
              new LatLng(model.currentLocation.latitude,
                  model.currentLocation.longitude),
              new LatLng(room.location.latitude, room.location.longitude));
          if (km.floor() < 70) {
            return true;
          } else
            return false;
        } else
          return false;
      }).toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (roomList.isEmpty) {
      roomList = model.allRooms
          .where((Room room) =>
              room.category.toLowerCase() + "s" == query.toLowerCase())
          .toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (roomList.isEmpty) {
      roomList = model.allRooms
          .where(
              (Room room) => room.category.toLowerCase() == query.toLowerCase())
          .toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (roomList.isEmpty) {
      roomList = model.allRooms
          .where((Room room) => room.description
              .toLowerCase()
              .split(" ")
              .contains(query.toLowerCase()))
          .toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (roomList.isEmpty) {
      roomList = model.allRooms
          .where((Room room) => room.location.address
              .toLowerCase()
              .split(" ")
              .contains(query.toLowerCase()))
          .toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (roomList.isEmpty) {
      roomList = model.allRooms
          .where((Room room) => room.location.address
              .toLowerCase()
              .split(',')
              .contains(query.toLowerCase()))
          .toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (roomList.isEmpty) {
      roomList = model.allRooms
          .where((Room room) => room.location.address
              .toLowerCase()
              .split(',')
              .any((String e) => e.trim() == query.toLowerCase().trim()))
          .toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (query == "all rooms" ||
        query == "all room" ||
        query == "room" ||
        query == "rooms") {
      roomList = model.allRooms;
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (query == "discount room" ||
        query == "discounted room" ||
        query == "discount rooms" ||
        query == "discount" ||
        query == "discount" ||
        query == "offer" ||
        query == "offers" ||
        query == "offer room" ||
        query == "offer rooms") {
      roomList =
          model.allRooms.where((Room room) => room.discount > 0).toList();
      roomList.sort((a, b) => a.price.floor().compareTo(b.price.floor()));
    }
    if (query.isEmpty) {
      roomList.clear();
    }
    return roomList;
  }

  @override
  Widget build(BuildContext context) {
    return _buildRoomList(_buildRoomResultList(), context);
  }
}
