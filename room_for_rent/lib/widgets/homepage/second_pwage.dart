import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/local_notifications.dart';

class SecondNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: LocalNotifications(),
    );
  }
}
