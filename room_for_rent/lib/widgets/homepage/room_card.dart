import 'package:flutter/material.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

import '../ui_elements/title_default.dart';
import '../../models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  RoomCard(this.room);

  Widget _buildTitlePriceRow(BuildContext context) {
    double discountPrice = room.discount != null
        ? room.discount > 0 ? room.price - room.price * room.discount / 100 : 0
        : 0;
    return Container(
        padding: EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TitleDefault(
                  room.title,
                ),
                ScopedModelDescendant<MainModel>(builder:
                    (BuildContext context, Widget child, MainModel model) {
                  return InkWell(
                      child: Icon(Icons.info),
                      onTap: () {
                        model.selectRoom(room.id);
                        Navigator.pushNamed<bool>(context, '/room/' + room.id)
                            .then((_) => model.selectRoom(null));
                      });
                }),
              ],
            ),
            room.discount != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      room.discount == 0
                          ? Text(
                              "\u0930\u0942${room.price.toString()}/-",
                            )
                          : Row(
                              children: <Widget>[
                                Text(
                                  "\u0930\u0942${room.price.toString()}/-",
                                  style: TextStyle(
                                      decoration: TextDecoration.lineThrough),
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  "\u0930\u0942${discountPrice.toString()}/-",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                      Text(room.category)
                    ],
                  )
                : LinearProgressIndicator(),
          ],
        ));
  }

  Widget _buildWithOffer(BuildContext context) {
    return Banner(
      color: Theme.of(context).primaryColor,
      message: 'offer',
      location: BannerLocation.topStart,
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      child: FadeInImage(
        image: NetworkImage(room.image),
        height: 150.0,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
        placeholder: AssetImage('assets/homepage_card.png'),
      ),
    );
  }

  Widget _buildWithoutOffer(BuildContext context) {
    return FadeInImage(
      image: NetworkImage(room.image),
      height: 150.0,
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
      placeholder: AssetImage('assets/homepage_card.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          room.discount != null
              ? room.discount > 0
                  ? _buildWithOffer(context)
                  : _buildWithoutOffer(context)
              : _buildWithoutOffer(context),
          _buildTitlePriceRow(context),
          Flexible(child: Text(room.location.address))
        ],
      ),
    );
  }
}
