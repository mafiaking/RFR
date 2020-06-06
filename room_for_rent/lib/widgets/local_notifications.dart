import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:room_for_rent/pages/notification_page.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class LocalNotifications extends StatefulWidget {
  @override
  _LocalNotificationsState createState() => _LocalNotificationsState();
}

class _LocalNotificationsState extends State<LocalNotifications> {
  final notifications = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    final settingsAndroid = AndroidInitializationSettings('ic_launcher');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationList()),
      );

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return ListView(
          children: <Widget>[
            title('Basics'),
            RaisedButton(
              child: Text('Show notification'),
              onPressed: () => model.showOngoingNotification(notifications,
                  title: 'Tite', body: 'Body'),
            ),
            RaisedButton(
              child: Text('Replace notification'),
              onPressed: () => model.showOngoingNotification(notifications,
                  title: 'ReplacedTitle', body: 'ReplacedBody'),
            ),
            RaisedButton(
              child: Text('Other notification'),
              onPressed: () => model.showOngoingNotification(notifications,
                  title: 'OtherTitle', body: 'OtherBody', id: 20),
            ),
            const SizedBox(height: 32),
            title('Feautures'),
            RaisedButton(
              child: Text('Silent notification'),
              onPressed: () => model.showSilentNotification(notifications,
                  title: 'SilentTitle', body: 'SilentBody', id: 30),
            ),
            const SizedBox(height: 32),
            title('Cancel'),
            RaisedButton(
              child: Text('Cancel all notification'),
              onPressed: notifications.cancelAll,
            ),
            RaisedButton(
              child: Text('Test'),
              onPressed: () async {
                // model.getCurrentLocation("init");
                print(model.currentLocation);
                // double clat1 = 26.9742872;
                // double clong1 = 79.8071751;
                // double clat2 = 21.4269339;
                // double clong2 = 86.9944317;

                // final Distance distance = new Distance( );

                // final double km = distance.as(
                //     LengthUnit.Kilometer,
                //     new LatLng(26.9742872, 79.8071751),
                //     new LatLng(21.4269339, 86.9944317));
                // print(km.floor());
                //Haversine manual approach
                // double diff = clong2 - clong1;
                // var lat1 = clat1 * pi / 180;
                // var lat2 = clat2 * pi / 180;
                // var rdiff = diff * pi / 180;

                // var x = sin(lat1) * sin(lat2);
                // var y = cos(lat1) * cos(lat2) * cos(rdiff);

                // var d = 3963.0 * acos(x + y);
                // d = d * 1.609344;

                // print(d);
              },
            ),
          ],
        );
      }));

  Widget title(String text) => Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      );
}
