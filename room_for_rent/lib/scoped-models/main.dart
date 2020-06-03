import 'package:scoped_model/scoped_model.dart';

import './connected_rooms.dart';

class MainModel extends Model
    with
        ConnectedRoomsModel,
        UserModel,
        RoomsModel,
        UtilityModel,
        NotificationModel {}
