import 'package:flutter/material.dart';

import '../../models/room.dart';

class CheckOutButton extends StatefulWidget {
  final Room room;

  CheckOutButton(this.room);
  @override
  _CheckOutButton createState() => _CheckOutButton();
}

Widget _buildPaymentButtonifAvailable(BuildContext context, Room room) {
  return Row(
    children: <Widget>[
      Text(
        "Booking In Advance",
        style: TextStyle(
            color: Colors.green, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 40.0),
      MaterialButton(
        onPressed: () => Navigator.pushNamed(context, '/checkout'),
        color: Colors.green,
        child: Row(children: [Text("Checkout"), Icon(Icons.shopping_cart)]),
      ),
    ],
  );
}

Widget _buildNotAvailablePanel() {
  return Row(children: <Widget>[
    Text(
      "Sorry Not Available",
      style: TextStyle(
          color: Colors.red, fontSize: 18.0, fontWeight: FontWeight.bold),
    ),
    SizedBox(width: 100.0),
    Image.asset(
      "assets/sad.png",
      width: 30,
    ),
  ]);
}

class _CheckOutButton extends State<CheckOutButton> {
  @override
  Widget build(BuildContext context) {
    
    return widget.room.isBooked
        ? _buildNotAvailablePanel()
        : _buildPaymentButtonifAvailable(context, widget.room);
  }
}
