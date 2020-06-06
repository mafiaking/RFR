import 'package:flutter/material.dart';
import 'package:room_for_rent/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';
import './room_edit.dart';
import '../scoped-models/main.dart';

//khalti
//import 'package:flutter_khalti/flutter_khalti.dart';
//test_secret_key_ba2cf7b0b3414c75ae8997888c2f094a
//test_public_key_4e0a801cc701466aa75759f9bf1447c0
//flutter_khalti: ^0.3.0

class RoomListPage extends StatefulWidget {
  final MainModel model;

  RoomListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _RoomListPageState();
  }
}

class _RoomListPageState extends State<RoomListPage> {
  @override
  initState() {
    widget.model.fetchRooms(onlyForUser: true, clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectRoom(model.allRooms[index].id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return RoomEditPage();
            },
          ),
        ).then((_) {
          model.selectRoom(null);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? AdaptiveProgressIndicator()
            : ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(model.allRooms[index].title),
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.endToStart) {
                        model.selectRoom(model.allRooms[index].id);
                        model.deleteRoom();
                      } else if (direction == DismissDirection.startToEnd) {
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
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(model.allRooms[index].image),
                          ),
                          title: Text(model.allRooms[index].title),
                          subtitle: Text(
                              '\u0930\u0942 ${model.allRooms[index].price.toString()}'),
                          trailing: _buildEditButton(context, index, model),
                        ),
                        Divider()
                      ],
                    ),
                  );
                },
                itemCount: model.allRooms.length,
              );
      },
    );
  }
}
