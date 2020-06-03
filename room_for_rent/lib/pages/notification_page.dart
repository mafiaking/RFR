import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final String payload;

  const SecondPage({
    @required this.payload,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Notification"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Second page - Payload:',
                // style: Theme.of(context).textTheme.headline1,
              ),
              const SizedBox(height: 8),
              Text(
                payload,
                // style: Theme.of(context).textTheme.headline2,
              ),
            ],
          ),
        ),
      );
}
