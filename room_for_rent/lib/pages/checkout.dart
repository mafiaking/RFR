import 'package:flutter/material.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

import '../utils/custom_cllipper_slope.dart';
import 'package:flutter_khalti/flutter_khalti.dart';

import '../models/room.dart';
import '../pages/payment_status.dart';

class CheckOut extends StatefulWidget {
  final Room _room;

  CheckOut(this._room);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  DateTime bookingDate;

  DateTime bookingTill;

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
      productId: widget._room.id,
      productName: widget._room.title,
      amount: amount,
      customData: {
        "Email": widget._room.userEmail,
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
    final double discount = widget._room.discount;
    final double subtotal = widget._room.price;
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
                blurRadius: 5.0, color: Colors.transparent, spreadRadius: 80.0),
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
                if (bookingTill != null && bookingDate != null) {
                  print(bookingTill
                      .isAfter(bookingDate.add(Duration(days: 31)))
                      .toString());
                  if (bookingTill.isAfter(
                    bookingDate.add(
                      Duration(days: 31),
                    ),
                  )) {
                    _payViaKhalti(total, context, booked);
                  } else
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Alert!"),
                            content: Text(
                                "Room must be booked for minimum one month period."),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("ok"))
                            ],
                          );
                        });
                }
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
                height: 220.0,
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/room.png'),
              ),
            )
          : FadeInImage(
              image: NetworkImage(room.image),
              height: 220.0,
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
            widget._room.title,
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

  Widget _buildDateSelection(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Card(
        elevation: 3,
        child: InkWell(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              padding: EdgeInsets.all(5),
              child: Column(children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                ),
                Text("Booking Date"),
                bookingDate != null
                    ? Text(
                        "${bookingDate.day.toString()}/${bookingDate.month.toString()}/${bookingDate.year.toString()}")
                    : Container()
              ]),
            ),
            onTap: () {
              showDatePicker(
                helpText: "Select Date of Birth",
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(DateTime.now().year + 1),
              ).then((value) {
                setState(() {
                  bookingDate = value;
                });
              });
            }),
      ),
      Card(
        elevation: 3,
        child: InkWell(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: EdgeInsets.all(5),
            child: Column(children: [
              Icon(
                Icons.today,
                size: 20,
              ),
              Text("Booking Till"),
              bookingTill != null
                  ? Text(
                      "${bookingTill.day.toString()}/${bookingTill.month.toString()}/${bookingTill.year.toString()}")
                  : Container()
            ]),
          ),
          onTap: () {
            showDatePicker(
              helpText: "Select Date of Birth",
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 2),
            ).then((value) {
              setState(() {
                bookingTill = value;
              });
            });
          },
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text("Check Out"),
        actions: <Widget>[Icon(Icons.add_shopping_cart)],
      ),
      body: ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(10.0),
                children: <Widget>[
                  _buildRoomCard(widget._room, context),
                  SizedBox(height: 10.0),
                  _buildRoomInfo(widget._room),
                  SizedBox(height: 10.0),
                  _buildDateSelection(context)
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            _buildPriceBreakdown(context, model.bookedRoom)
          ],
        );
      }),
    );
  }
}
