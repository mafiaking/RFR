import 'package:flutter/material.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

import '../utils/custom_cllipper_slope.dart';
import 'package:flutter_khalti/flutter_khalti.dart';

import '../models/room.dart';
import '../pages/payment_status.dart';

class CheckOut extends StatelessWidget {
  final Room _room;

  CheckOut(this._room);

  void _payViaKhalti(double total, context, booked) async {
    final double amount = total * 100;
    if (amount <= 1000) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error in payment"),
              content: Text("Unable to pay this amount."),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"))
              ],
            );
          });
    }
    FlutterKhalti(
      urlSchemeIOS: "KhaltiPayFlutterExampleScheme",
      publicKey: "test_public_key_4e0a801cc701466aa75759f9bf1447c0",
      productId: _room.id,
      productName: _room.title,
      amount: amount,
      customData: {
        "Email": _room.userEmail,
      },
    ).initPayment(
      onSuccess: (data) {
        booked(true);
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (BuildContext context) => PageStatus("Sucess", "")));
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Successfully paid"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK"))
                ],
              );
            });
        print("success");
        print(data);
      },
      onError: (error) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => PageStatus("", "failed")));
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error in Payment"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK"))
                ],
              );
            });
        print("error");
        print(error);
      },
    );
  }

  Widget _buildPriceBreakdown(context, Function booked) {
    final double discount = _room.discount;
    final double subtotal = _room.price;
    final double off = subtotal * discount / 100;
    final double total = subtotal - off;
    // final DateTime date = DateTime.now();
    return ClipPath(
      clipper: SlopeTopBorderClipper(),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 5.0,
                color: Colors.grey.shade700,
                spreadRadius: 80.0),
          ],
          color: Colors.white,
        ),
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 100.0, bottom: 10.0),
        child: Column(
          children: <Widget>[
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   Text("Booking Date"),
            //   Text("${date.day}/${date.month}/${date.year}")
            // ]),
            // SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Subtotal"),
                Text("\u0930\u0942 ${subtotal.toString()}"),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Discount Offer (${discount.toString()}%)",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text("- ${off.toString()} OFF",
                    style: TextStyle(fontWeight: FontWeight.w700))
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Total"),
                Text("\u0930\u0942 ${total.toString()}"),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                _payViaKhalti(total, context, booked);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text("Proceed to Pay \u0930\u0942 ${total.toString()}  via",
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  Image.asset(
                    'assets/khalti1.png',
                    height: 45,
                    width: 80,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room, BuildContext context) {
    return Card(
      child: room.discount > 0
          ? Banner(
              message: "${room.discount.toString()}%off",
              location: BannerLocation.topStart,
              color: Theme.of(context).primaryColor,
              child: FadeInImage(
                image: NetworkImage(room.image),
                height: 230.0,
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/room.png'),
              ),
            )
          : FadeInImage(
              image: NetworkImage(room.image),
              height: 230.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/room.png'),
            ),
      shadowColor: Colors.grey.shade700,
      elevation: 20.0,
    );
  }

  Widget _buildRoomInfo(Room room) {
    return Container(
      child: DecoratedBox(
        decoration: BoxDecoration(),
        child: Column(children: [
          Text(
            _room.title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Oswald"),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            room.location.address,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.0),
          Text('Email: ${room.userEmail} ')
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: Text("Check Out"),
          actions: <Widget>[Icon(Icons.add_shopping_cart)],
        ),
        body: _room != null ? ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10.0),
                  children: <Widget>[
                    _buildRoomCard(_room, context),
                    SizedBox(height: 10.0),
                    _buildRoomInfo(_room),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              _buildPriceBreakdown(context, model.bookedRoom)
            ],
          );
        }): Text("NO ROOM SELECTED"));
  }
}
