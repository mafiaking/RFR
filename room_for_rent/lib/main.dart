import 'package:flutter/material.dart';
import 'package:room_for_rent/pages/checkout.dart';
import 'package:room_for_rent/pages/favorite.dart';
import 'package:room_for_rent/pages/homepage.dart';
import 'package:room_for_rent/widgets/homepage/category_room.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';
// import 'package:flutter/rendering.dart';

import './pages/auth.dart';
import './pages/rooms_admin.dart';
import './pages/rooms.dart';
import './pages/room.dart';
import './scoped-models/main.dart';
import './models/room.dart';
import './widgets/helpers/custom_route.dart';
import './shared/global_config.dart';
import './shared/adaptive_theme.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  MapView.setApiKey(apiKey);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.initialCheck();
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
      if (_isAuthenticated == true) {
        _model.countInitialRoomLength();
        _model.checkForUpdatedList();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('building main page');
    return ScopedModel<MainModel>(
      model: _model,
      // child: !_isAuthenticated ?MaterialApp():MaterialApp(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // debugShowMaterialGrid: true,
        theme: getAdaptiveThemeData(context),
        // home: AuthPage(),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : HomePage(_model),
          '/list': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : RoomsPage(_model),
          '/category': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : CategoryRooms(),
          '/homepage': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : HomePage(_model),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : RoomsAdminPage(_model),
          '/checkout': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : CheckOut(_model.selectedRoom),
          '/favorite': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : Favorite(),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => AuthPage(),
            );
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'room') {
            final String roomId = pathElements[2];
            final Room room = _model.allRooms.firstWhere((Room room) {
              return room.id == roomId;
            });
            return CustomRoute<bool>(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : RoomPage(room),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : RoomsPage(_model));
        },
      ),
    );
  }
}
