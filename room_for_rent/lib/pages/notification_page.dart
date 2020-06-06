import 'package:flutter/material.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:room_for_rent/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Notifications"),
            automaticallyImplyLeading: false,
          ),
          body: RefreshIndicator(
              child: model.isLoading
                  ? Center(child: AdaptiveProgressIndicator())
                  : ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return model.notification != null
                            ? model.notification.availability
                                ? Dismissible(
                                    key: Key(model.notification.title),
                                    onDismissed: (DismissDirection direction) {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        model.deleteNotification();
                                        model.getUserNotification();
                                      } else if (direction ==
                                          DismissDirection.startToEnd) {
                                        print('Swiped start to end');
                                      } else {
                                        print('Other swiping');
                                      }
                                    },
                                    background: Container(
                                        color: Colors.red,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Icon(Icons.delete),
                                        )),
                                    child: Column(
                                      children: <Widget>[
                                        Card(
                                          elevation: 3,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "assets/logo_small.png"),
                                            ),
                                            title:
                                                Text(model.notification.title),
                                            subtitle:
                                                Text(model.notification.body),
                                          ),
                                        ),
                                        // Divider()
                                      ],
                                    ),
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Center(
                                      child: Text(
                                          "No notification avilable swipe to refresh."),
                                    ),
                                  )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Center(
                                  child: Text(
                                      "No notification avilable swipe to refresh."),
                                ),
                              );
                      },
                      itemCount: 1,
                    ),
              onRefresh: model.getUserNotification),
        );
      });
}
