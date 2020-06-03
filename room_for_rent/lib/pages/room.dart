import 'dart:async';

import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/rooms/checkout_button.dart';

import 'package:map_view/map_view.dart';
import 'package:room_for_rent/widgets/rooms/location_tag.dart';

import '../widgets/ui_elements/title_default.dart';
import '../widgets/rooms/room_fab.dart';
import '../models/room.dart';

class RoomPage extends StatelessWidget {
  final Room room;

  RoomPage(this.room);
  final MapViewType _type = MapViewType.normal;

  void _showMap() {
    final List<Marker> markers = <Marker>[
      Marker('position', room.title, room.location.latitude,
          room.location.longitude)
    ];
    final cameraPosition = CameraPosition(
        Location(room.location.latitude, room.location.longitude), 14.0);
    final mapView = MapView();
    mapView.show(
        MapOptions(
            initialCameraPosition: cameraPosition,
            mapViewType: _type,
            title: 'Room Location'),
        toolbarActions: [
          ToolbarAction('Close', 1),
        ]);
    mapView.onToolbarAction.listen((int id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_) {
      mapView.setMarkers(markers);
    });
  }

  Widget _buildAddressPriceRow(String address, double price) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(onTap: _showMap, child: AddressTag(address)),
        Text(
          '\u0930\u0942 ' + price.toString() + "/month",
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(room.title),
                background: Hero(
                  tag: room.id,
                  child: FadeInImage(
                    image: NetworkImage(room.image),
                    height: 300.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/room.png'),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          room.isBooked
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 2.5),
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Text(
                                    'Booked',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 2.5),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Text(
                                    'Available',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                          SizedBox(width: 10.0),
                          TitleDefault(room.title)
                        ]),
                  ),
                  _buildAddressPriceRow(room.location.address, room.price),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      room.description,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: RoomFAB(room),
        persistentFooterButtons: [CheckOutButton(room)],
      ),
    );
  }
}
