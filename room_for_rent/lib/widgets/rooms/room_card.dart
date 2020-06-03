import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/rooms/availabilitytag.dart';

import 'package:scoped_model/scoped_model.dart';

import './pricetag.dart';
import './location_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/room.dart';
import '../../scoped-models/main.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  RoomCard(this.room);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: AvailabilityTag(room.isBooked),
          ),
          SizedBox(width: 5.0),
          Flexible(child: TitleDefault(room.title)),
          Flexible(
            child: SizedBox(
              width: 5.0,
            ),
          ),
          Flexible(child: PriceTag(room.price.toString()))
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.info),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    model.selectRoom(room.id);
                    Navigator.pushNamed<bool>(context, '/room/' + room.id)
                        .then((_) => model.selectRoom(null));
                  }),
              IconButton(
                icon: Icon(
                    room.isFavorite ? Icons.favorite : Icons.favorite_border),
                color: Colors.red,
                onPressed: () {
                  model.selectRoom(room.id);
                  model.toggleRoomFavoriteStatus();
                },
              ),
            ]);
      },
    );
  }

  Widget _buildWithOffer(BuildContext context) {
    return Banner(
      color: Theme.of(context).primaryColor,
      message: 'offer',
      location: BannerLocation.topStart,
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      child: FadeInImage(
        image: NetworkImage(room.image),
        height: 230.0,
        fit: BoxFit.contain,
        placeholder: AssetImage('assets/room.png'),
      ),
    );
  }

  Widget _buildWithoutOffer() {
    return FadeInImage(
      image: NetworkImage(room.image),
      height: 230.0,
      fit: BoxFit.contain,
      placeholder: AssetImage('assets/room.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
              tag: room.id,
              child:
                  room.discount > 0 ? _buildWithOffer(context) : _buildWithoutOffer()),
          _buildTitlePriceRow(),
          SizedBox(height: 10.0),
          AddressTag(room.location.address),

          // Text(room.userEmail),
          _buildActionButtons(context)
        ],
      ),
    );
  }
}
