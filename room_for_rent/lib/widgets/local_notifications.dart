import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        MaterialPageRoute(builder: (context) => SecondPage(payload: payload)),
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
              onPressed: () {
                Fluttertoast.showToast(
                    msg: "succesfully added",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey.shade700,
                    textColor: Colors.white,
                    fontSize: 12.0);
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
