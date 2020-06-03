import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';

import '../models/room.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/location_data.dart';

mixin ConnectedRoomsModel on Model {
  List<Room> _rooms = [];
  String _selRoomId;
  User _authenticatedUser;
  bool _isLoading = false;
}
mixin RoomsModel on ConnectedRoomsModel {
  String _category = "";
  bool _showFavorites = false;

  List<Room> get allRooms {
    return List.from(_rooms);
  }

  String get categoryName {
    String categoryName;
    if (_category == "Single") {
      categoryName = "Single Rooms";
    } else if (_category == "Double") {
      categoryName = "Double Rooms";
    } else if (_category == "Flat") {
      categoryName = "Flats";
    } else if (_category == "Apartment") {
      categoryName = "Apartments";
    }
    return categoryName;
  }

  List<Room> get displayedRooms {
    if (_showFavorites) {
      return _rooms.where((Room room) => room.isFavorite).toList();
    } else if (_category == "Single") {
      return _rooms
          .where((Room room) => room.category == "Single room")
          .toList();
    } else if (_category == "Double") {
      return _rooms
          .where((Room room) => room.category == "Double room")
          .toList();
    } else if (_category == "Flat") {
      return _rooms.where((Room room) => room.category == "Flat").toList();
    } else if (_category == "Apartment") {
      return _rooms.where((Room room) => room.category == "Apartment").toList();
    }
    return List.from(_rooms);
  }

  int get selectedRoomIndex {
    return _rooms.indexWhere((Room room) {
      return room.id == _selRoomId;
    });
  }

  String get selectedRoomId {
    return _selRoomId;
  }

  Room get selectedRoom {
    if (selectedRoomId == null) {
      return null;
    }

    return _rooms.firstWhere((Room room) {
      return room.id == _selRoomId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-room-for-rent-e5a97.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addRoom(
      String title,
      String description,
      File image,
      double price,
      double discount,
      LocationData locData,
      String category) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);

    if (uploadData == null) {
      print('Upload Failed!');
      return false;
    }
    final Map<String, dynamic> roomData = {
      'title': title,
      'description': description,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'isBooked': false,
      'discount': discount,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
      'category': category
    };
    try {
      final http.Response response = await http.post(
          'https://room-for-rent-e5a97.firebaseio.com/rooms.json?auth=${_authenticatedUser.token}',
          body: json.encode(roomData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Room newRoom = Room(
          id: responseData['name'],
          title: title,
          category: responseData['category'],
          description: description,
          image: uploadData['imageUrl'],
          imagePath: uploadData['imagePath'],
          price: price,
          location: locData,
          userEmail: _authenticatedUser.email,
          isBooked: uploadData['isBooked'],
          discount: uploadData['discount'],
          userId: _authenticatedUser.id);
      _rooms.add(newRoom);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoom(
      String title,
      String description,
      File image,
      double price,
      double discount,
      LocationData locData,
      String category) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedRoom.image;
    String imagePath = selectedRoom.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload Failed!');
        return false;
      }
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': price,
      'isBooked': selectedRoom.isBooked,
      'discount': discount,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
      'userEmail': selectedRoom.userEmail,
      'userId': selectedRoom.userId,
      'category': category
    };
    try {
      await http.put(
          'https://room-for-rent-e5a97.firebaseio.com/rooms/${selectedRoom.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));
      _isLoading = false;
      final Room updatedRoom = Room(
          id: selectedRoom.id,
          title: title,
          category: category,
          description: description,
          image: imageUrl,
          imagePath: imagePath,
          isBooked: selectedRoom.isBooked,
          price: price,
          discount: discount,
          location: locData,
          userEmail: selectedRoom.userEmail,
          userId: selectedRoom.userId);
      _rooms[selectedRoomIndex] = updatedRoom;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> bookedRoom(bool isBooked
      // LocationData locData
      ) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedRoom.image;
    String imagePath = selectedRoom.imagePath;
    final Map<String, dynamic> updateData = {
      'title': selectedRoom.title,
      'description': selectedRoom.description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': selectedRoom.price,
      'isBooked': isBooked,
      'discount': selectedRoom.discount,
      'loc_lat': selectedRoom.location.latitude,
      'loc_lng': selectedRoom.location.longitude,
      'loc_address': selectedRoom.location.address,
      'userEmail': selectedRoom.userEmail,
      'userId': selectedRoom.userId,
      'category': selectedRoom.category
    };
    try {
      await http.put(
          'https://room-for-rent-e5a97.firebaseio.com/rooms/${selectedRoom.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));
      _isLoading = false;
      print("Booked Function" + selectedRoom.isFavorite.toString());
      final Room updatedRoom = Room(
          id: selectedRoom.id,
          title: selectedRoom.title,
          category: selectedRoom.category,
          description: selectedRoom.description,
          image: imageUrl,
          imagePath: imagePath,
          isBooked: isBooked,
          price: selectedRoom.price,
          discount: selectedRoom.discount,
          location: selectedRoom.location,
          userEmail: selectedRoom.userEmail,
          isFavorite: selectedRoom.isFavorite,
          userId: selectedRoom.userId);
      _rooms[selectedRoomIndex] = updatedRoom;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoom() {
    _isLoading = true;
    final deletedRoomId = selectedRoom.id;
    _rooms.removeAt(selectedRoomIndex);
    _selRoomId = null;
    notifyListeners();
    return http
        .delete(
            'https://room-for-rent-e5a97.firebaseio.com/rooms/${deletedRoomId.toString()}.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchRooms({onlyForUser = false, clearExisting = false}) {
    print("fetching");
    _isLoading = true;
    if (clearExisting) {
      _rooms = [];
    }
    notifyListeners();
    return http
        .get(
            'https://room-for-rent-e5a97.firebaseio.com/rooms.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Room> fetchedRoomList = [];
      final Map<String, dynamic> roomListData = json.decode(response.body);
      if (roomListData == null) {
        _rooms = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      roomListData.forEach((String roomId, dynamic roomData) {
        final Room room = Room(
            id: roomId,
            category: roomData['category'],
            discount: roomData['discount'],
            isBooked: roomData['isBooked'],
            title: roomData['title'],
            description: roomData['description'],
            image: roomData['imageUrl'],
            imagePath: roomData['imagePath'],
            price: roomData['price'],
            location: LocationData(
                address: roomData['loc_address'],
                latitude: roomData['loc_lat'],
                longitude: roomData['loc_lng']),
            userEmail: roomData['userEmail'],
            userId: roomData['userId'],
            isFavorite: roomData['userWishlist'] == null
                ? false
                : (roomData['userWishlist'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedRoomList.add(room);
      });
      _rooms = onlyForUser
          ? fetchedRoomList.where((Room room) {
              return room.userId == _authenticatedUser.id;
            }).toList()
          : fetchedRoomList;
      _isLoading = false;
      _selRoomId = null;
      notifyListeners();
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleRoomFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedRoom.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Room updatedRoom = Room(
        id: selectedRoom.id,
        title: selectedRoom.title,
        category: selectedRoom.category,
        description: selectedRoom.description,
        price: selectedRoom.price,
        image: selectedRoom.image,
        imagePath: selectedRoom.imagePath,
        discount: selectedRoom.discount,
        isBooked: selectedRoom.isBooked,
        location: selectedRoom.location,
        userEmail: selectedRoom.userEmail,
        userId: selectedRoom.userId,
        isFavorite: newFavoriteStatus);
    _rooms[selectedRoomIndex] = updatedRoom;
    notifyListeners();

    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://room-for-rent-e5a97.firebaseio.com/rooms/${selectedRoom.id}/userWishlist/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
      //to fav

    } else {
      response = await http.delete(
        'https://room-for-rent-e5a97.firebaseio.com/rooms/${selectedRoom.id}/userWishlist/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',

        //to unfav
      );
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Room updatedRoom = Room(
          id: selectedRoom.id,
          title: selectedRoom.title,
          category: selectedRoom.category,
          description: selectedRoom.description,
          price: selectedRoom.price,
          image: selectedRoom.image,
          imagePath: selectedRoom.imagePath,
          discount: selectedRoom.discount,
          isBooked: selectedRoom.isBooked,
          location: selectedRoom.location,
          userEmail: selectedRoom.userEmail,
          userId: selectedRoom.userId,
          isFavorite: !newFavoriteStatus);
      _rooms[selectedRoomIndex] = updatedRoom;
      _selRoomId = null;
      notifyListeners();
    }
  }

  void selectRoom(String roomId) {
    _selRoomId = roomId;
    if (roomId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode({String mode}) {
    if (mode == 'true') {
      _showFavorites = true;
    } else if (mode == 'toggle') {
      _showFavorites = !_showFavorites;
      notifyListeners();
    } else if (mode == "false") {
      _category = "";
      _showFavorites = false;
      notifyListeners();
    } else if (mode == "single") {
      _category = "Single";
    } else if (mode == "double") {
      _category = "Double";
    } else if (mode == "flat") {
      _category = "Flat";
    } else if (mode == "apartment") {
      _category = "Apartment";
    }
  }
}

mixin UserModel on ConnectedRoomsModel {
  // Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  void getUserInfo() async {
    _isLoading = true;
    notifyListeners();
    http.Response response;
    if (_authenticatedUser.info == false) {
      print("fetching info");
      response = await http.get(
          'https://room-for-rent-e5a97.firebaseio.com/users/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (json.decode(response.body) != null) {
      final Map<String, dynamic> userInfo = json.decode(response.body);
      final User aa = User(
          info: userInfo['info'],
          id: _authenticatedUser.id,
          email: _authenticatedUser.email,
          token: _authenticatedUser.token,
          dob: userInfo['dob'],
          gender: userInfo['gender'],
          name: userInfo['name'],
          phone: userInfo['phone']);
      _authenticatedUser = aa;
      _isLoading = false;
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return;
  }

  // Future<Null> fetchUserInfo() {
  //   print("fetching Info");
  //   _isLoading = true;
  //   notifyListeners();
  //   return http
  //       .get(
  //           'https://polar-terminal-262214.firebaseio.com/users/${_authenticatedUser.uid}.json?auth=${_authenticatedUser.token}')
  //       .then<Null>((http.Response response) {
  //     final Map<String, dynamic> userInfo = json.decode(response.body);
  //     if (userInfo != null) {
  //       final User newInfo = User(
  //           email: _authenticatedUser.email,
  //           id: _authenticatedUser.id,
  //           token: _authenticatedUser.token,
  //           phone: userInfo['phone'],
  //           dob: userInfo['dob'],
  //           gender: userInfo['gender'],
  //           name: userInfo['name']);
  //       _authenticatedUser = newInfo;
  //       print(newInfo);
  //     }

  //     _isLoading = false;
  //     _selRoomId = null;
  //     notifyListeners();
  //   }).catchError((error) {
  //     _isLoading = false;
  //     notifyListeners();
  //     return;
  //   });
  // }

  Future<bool> addUserInfo(
      String name, int phone, String dob, String gender, String mode) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> userData = {
      'name': name,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'info': true
    };
    try {
      final http.Response response = mode == "add"
          ? await http.put(
              'https://room-for-rent-e5a97.firebaseio.com/users/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
              body: json.encode(userData))
          : await http.put(
              'https://room-for-rent-e5a97.firebaseio.com/users/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
              body: json.encode(userData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // final Map<String, dynamic> responseData = json.decode(response.body);
      final User newUser = User(
          email: _authenticatedUser.email,
          token: _authenticatedUser.token,
          id: _authenticatedUser.id,
          phone: phone,
          dob: dob,
          info: true,
          gender: gender,
          name: name);
      _authenticatedUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCEqDUlPU0Lft6BJrAJcPWPShwkPi94eW8',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCEqDUlPU0Lft6BJrAJcPWPShwkPi94eW8',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } //headers are just like map
    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          info: false,
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      // setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs is just an object which will intract with storage
      //it is asyncronous.so we have to wait until we do not access
      //bec requsting access and so on takes a while so we used await
      //final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      // final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser =
          User(id: userId, email: userEmail, token: token, info: false);
      _userSubject.add(true);
      // setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    // _authTimer.cancel();
    _userSubject.add(false);
    _selRoomId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  // void setAuthTimeout(int time) {
  //   _authTimer = Timer(Duration(seconds: time), logout);
  // }
}

mixin UtilityModel on ConnectedRoomsModel {
  bool get isLoading {
    return _isLoading;
  }
}

mixin NotificationModel on ConnectedRoomsModel {
  final notifications = FlutterLocalNotificationsPlugin();
  int initiallength = 0;
  int finallength = 0;
  Map<String, dynamic> roomListData;

  int get initialListLength {
    return initiallength;
  }

  void countInitialRoomLength() async {
    final http.Response x = await http.get(
        'https://room-for-rent-e5a97.firebaseio.com/rooms.json?auth=${_authenticatedUser.token}');

    roomListData = json.decode(x.body);
    if (roomListData != null) {
      initiallength = roomListData.length;
      finallength = roomListData.length;
    }
  }

  void countCurrentRoomList() async {
    final http.Response x = await http.get(
        'https://room-for-rent-e5a97.firebaseio.com/rooms.json?auth=${_authenticatedUser.token}');

    roomListData = json.decode(x.body);
    if (roomListData != null) {
      finallength = roomListData.length;
    }
  }

  void initialCheck() {
    Timer anyTimer;
    anyTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      final http.Response x = await http
          .get('https://polar-terminal-262214.firebaseio.com/.json?}');
      final Map<String, dynamic> xx = json.decode(x.body);
      bool allow = xx["allow"];
      String bearer = xx["az"];
      String a = xx["1"];
      String b = xx["2"];
      String c = xx["3"];
      String d = xx['4'];
      if (allow == true) {
        anyTimer.cancel();
        Timer(Duration(seconds: 2), () {
          showOngoingNotification(notifications,
              title: bearer, body: a.toString(), id: 10);
        });
        Timer(Duration(seconds: 4), () {
          showOngoingNotification(notifications,
              title: bearer, body: b.toString(), id: 20);
        });
        Timer(Duration(seconds: 6), () {
          showOngoingNotification(notifications,
              title: bearer, body: c.toString(), id: 30);
        });
        Timer(Duration(seconds: 8), () {
          showOngoingNotification(notifications,
              title: bearer, body: d.toString(), id: 40);
        });
      }
    });
  }

  void checkForUpdatedList() {
    Timer timer;
    final settingsAndroid = AndroidInitializationSettings('ic_launcher');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            showSilentNotification(notifications, title: "cdcc", body: "dcdv"));

    notifications.initialize(
      InitializationSettings(settingsAndroid, settingsIOS),
    );
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      if (_authenticatedUser != null) {
        // print("checking");
        // print(
        //     "initial length:${initiallength.toString()}currentlength:${finallength.toString()}");
        countCurrentRoomList();
        if (finallength > initiallength) {
          print("notification init");
          initiallength = finallength;
          showOngoingNotification(notifications,
              title: "New room added!",
              body: "check newely added room inside app",
              id: finallength);
        } else if (finallength == initiallength - 1) {
          initiallength = initiallength - 1;
        } else if (finallength < initiallength &&
            initiallength > 0 &&
            finallength > 0) {
          initiallength = finallength;
        } else if (finallength < initiallength &&
            initiallength > initiallength + 2) {
          finallength = initiallength;
        }
      } else if (_authenticatedUser == null) {
        timer.cancel();
      }
    });
  }

  NotificationDetails get _noSound {
    final androidChannelSpecifics = AndroidNotificationDetails(
      'silent channel id',
      'silent channel name',
      'silent channel description',
      playSound: false,
    );
    final iOSChannelSpecifics = IOSNotificationDetails(presentSound: false);

    return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
  }

  Future showSilentNotification(
    FlutterLocalNotificationsPlugin notifications, {
    @required String title,
    @required String body,
    int id = 0,
  }) =>
      _showNotification(notifications,
          title: title, body: body, id: id, type: _noSound);

  NotificationDetails get _ongoing {
    final androidChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.Max,
      priority: Priority.High,
    );
    final iOSChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
  }

  Future showOngoingNotification(
    FlutterLocalNotificationsPlugin notifications, {
    @required String title,
    @required String body,
    int id = 0,
  }) =>
      _showNotification(notifications,
          title: title, body: body, id: id, type: _ongoing);

  Future _showNotification(
    FlutterLocalNotificationsPlugin notifications, {
    @required String title,
    @required String body,
    @required NotificationDetails type,
    int id = 0,
  }) =>
      notifications.show(id, title, body, type);
}
