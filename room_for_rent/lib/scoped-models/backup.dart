// import 'dart:convert';
// import 'dart:async';
// import 'dart:io';

// import 'package:location/location.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:rxdart/subjects.dart';
// import 'package:mime/mime.dart';
// import 'package:http_parser/http_parser.dart';

// import '../models/room.dart';
// import '../models/user.dart';
// import '../models/auth.dart';

// mixin ConnectedRoomsModel on Model {
//   List<Room> _rooms = [];
//   String _selRoomId;
//   User _authenticatedUser;
//   bool _isLoading = false;
// }
// mixin RoomsModel on ConnectedRoomsModel {
//   bool _showFavorites = false;

//   List<Room> get allRooms {
//     return List.from(_rooms);
//   }

//   List<Room> get displayedRooms {
//     if (_showFavorites) {
//       return _rooms.where((Room room) => room.isFavorite).toList();
//     }
//     return List.from(_rooms);
//   }

//   int get selectedRoomIndex {
//     return _rooms.indexWhere((Room room) {
//       return room.id == _selRoomId;
//     });
//   }

//   String get selectedRoomId {
//     return _selRoomId;
//   }

//   Room get selectedRoom {
//     if (selectedRoomId == null) {
//       return null;
//     }

//     return _rooms.firstWhere((Room room) {
//       return room.id == _selRoomId;
//     });
//   }

//   bool get displayFavoritesOnly {
//     return _showFavorites;
//   }

//   Future<Map<String, dynamic>> uploadImage(File image,
//       {String imagePath}) async {
//     final mimeTypeData = lookupMimeType(image.path).split('/');
//     final imageUploadRequest = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             'https://us-central1-flutter-rooms.cloudfunctions.net/storeImage'));
//     final file = await http.MultipartFile.fromPath(
//       'image',
//       image.path,
//       contentType: MediaType(
//         mimeTypeData[0],
//         mimeTypeData[1],
//       ),
//     );
//     imageUploadRequest.files.add(file);
//     if (imagePath != null) {
//       imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
//     }
//     imageUploadRequest.headers['Authorization'] =
//         'Bearer ${_authenticatedUser.token}';
//     try {
//       final streamedResponse = await imageUploadRequest.send();
//       final response = await http.Response.fromStream(streamedResponse);
//       if (response.statusCode != 200 && response.statusCode != 201) {
//         print('Something went wrong');
//         print(json.decode(response.body));
//         return null;
//       }
//       final responseData = json.decode(response.body);
//       return responseData;
//     } catch (error) {
//       print(error);
//       return null;
//     }
//   }

//   Future<bool> addRoom(
//     String title,
//     String description,
//     File image,
//     double price,
//     // LocationData locData
//   ) async {
//     _isLoading = true;
//     notifyListeners();
//     final uploadData = await uploadImage(image);

//     if (uploadData == null) {
//       print('Upload Failed!');
//       return false;
//     }
//     final Map<String, dynamic> roomData = {
//       'title': title,
//       'description': description,
//       'price': price,
//       'userEmail': _authenticatedUser.email,
//       'userId': _authenticatedUser.id,
//       'imagePath': uploadData['imagePath'],
//       'imageUrl': uploadData['imageUrl'],
//       // 'loc_lat': locData.latitude,
//       // 'loc_lng':locData.longitude
//       // 'loc_address':locData.address,
//     };
//     try {
//       final http.Response response = await http.post(
//           'https://flutter-rooms.firebaseio.com/rooms.json?auth=${_authenticatedUser.token}',
//           body: json.encode(roomData));

//       if (response.statusCode != 200 && response.statusCode != 201) {
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       final Room newRoom = Room(
//           id: responseData['name'],
//           title: title,
//           description: description,
//           image: uploadData['imageUrl'],
//           imagePath: uploadData['imagePath'],
//           price: price,
//           // location:locData,
//           userEmail: _authenticatedUser.email,
//           userId: _authenticatedUser.id);
//       _rooms.add(newRoom);
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//     // .catchError((error) {
//     //   _isLoading = false;
//     //   notifyListeners();
//     //   return false;
//     // });
//   }

//   Future<bool> updateRoom(
//     String title,
//     String description,
//     File image,
//     double price,
//     // LocationData locData
//   ) async {
//     _isLoading = true;
//     notifyListeners();
//     String imageUrl = selectedRoom.image;
//     String imagePath = selectedRoom.imagePath;
//     if (image != null) {
//       final uploadData = await uploadImage(image);
//       if (uploadData == null) {
//         print('Upload Failed!');
//         return false;
//       }
//       imageUrl = uploadData['imageUrl'];
//       imagePath = uploadData['imagePath'];
//     }
//     final Map<String, dynamic> updateData = {
//       'title': title,
//       'description': description,
//       'imageUrl': imageUrl,
//       'imagePath': imagePath,
//       'price': price,
//       // 'loc_lat':locData.latitude,
//       // 'loc_lng':locData.longitude,
//       // 'loc_address':locData.address,
//       'userEmail': selectedRoom.userEmail,
//       'userId': selectedRoom.userId
//     };
//     try {
//       await http.put(
//           'https://flutter-rooms.firebaseio.com/rooms/${selectedRoom.id}.json?auth=${_authenticatedUser.token}',
//           body: json.encode(updateData));
//       _isLoading = false;
//       final Room updatedRoom = Room(
//           id: selectedRoom.id,
//           title: title,
//           description: description,
//           image: imageUrl,
//           imagePath: imagePath,
//           price: price,
//           //  location:locData,
//           userEmail: selectedRoom.userEmail,
//           userId: selectedRoom.userId);
//       _rooms[selectedRoomIndex] = updatedRoom;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> deleteRoom() {
//     _isLoading = true;
//     final deletedRoomId = selectedRoom.id;
//     _rooms.removeAt(selectedRoomIndex);
//     _selRoomId = null;
//     notifyListeners();
//     return http
//         .delete(
//             'https://flutter-rooms.firebaseio.com/rooms/$deletedRoomId.json?auth=${_authenticatedUser.token}')
//         .then((http.Response response) {
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     }).catchError((error) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     });
//   }

//   Future<Null> fetchRooms({onlyForUser = false, clearExisting = false}) {
//     _isLoading = true;
//     if (clearExisting) {
//       _rooms = [];
//     }
//     notifyListeners();
//     return http
//         .get(
//             'https://flutter-rooms.firebaseio.com/rooms.json?auth=${_authenticatedUser.token}')
//         .then<Null>((http.Response response) {
//       final List<Room> fetchedRoomList = [];
//       final Map<String, dynamic> roomListData = json.decode(response.body);
//       if (roomListData == null) {
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }
//       roomListData.forEach((String roomId, dynamic roomData) {
//         final Room room = Room(
//             id: roomId,
//             title: roomData['title'],
//             description: roomData['description'],
//             image: roomData['imageUrl'],
//             imagePath: roomData['imagePath'],
//             price: roomData['price'],
//             // location: LocationData(
//             //     address: roomData['loc_address'],
//             //     latitude: roomData['loc_lat'],
//             //     longitude: roomData['loc_lng']),
//             userEmail: roomData['userEmail'],
//             userId: roomData['userId'],
//             isFavorite: roomData['wishlistUsers'] == null
//                 ? false
//                 : (roomData['wishlistUsers'] as Map<String, dynamic>)
//                     .containsKey(_authenticatedUser.id));
//         fetchedRoomList.add(room);
//       });
//       _rooms = onlyForUser
//           ? fetchedRoomList.where((Room room) {
//               return room.userId == _authenticatedUser.id;
//             }).toList()
//           : fetchedRoomList;
//       _isLoading = false;
//       _selRoomId = null;
//       notifyListeners();
//     }).catchError((error) {
//       _isLoading = false;
//       notifyListeners();
//       return;
//     });
//   }

//   void toggleRoomFavoriteStatus() async {
//     final bool isCurrentlyFavorite = selectedRoom.isFavorite;
//     final bool newFavoriteStatus = !isCurrentlyFavorite;
//     final Room updatedRoom = Room(
//         id: selectedRoom.id,
//         title: selectedRoom.title,
//         description: selectedRoom.description,
//         price: selectedRoom.price,
//         image: selectedRoom.image,
//         imagePath: selectedRoom.imagePath,
//         // location: selectedRoom.location,
//         userEmail: selectedRoom.userEmail,
//         userId: selectedRoom.userId,
//         isFavorite: newFavoriteStatus);
//     _rooms[selectedRoomIndex] = updatedRoom;
//     notifyListeners();
    
//     http.Response response;
//     if (newFavoriteStatus) {
//       response = await http.put(
//           'https://flutter-rooms.firebaseio.com/rooms/${selectedRoom.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
//           body: json.encode(true));
//       //to fav

//     } else {
//       response = await http.delete(
//         'https://flutter-rooms.firebaseio.com/rooms/${selectedRoom.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',

//         //to unfav
//       );
//     }
//     if (response.statusCode != 200 && response.statusCode != 201) {
//       final Room updatedRoom = Room(
//           id: selectedRoom.id,
//           title: selectedRoom.title,
//           description: selectedRoom.description,
//           price: selectedRoom.price,
//           image: selectedRoom.image,
//           imagePath: selectedRoom.imagePath,
//           // location: selectedRoom.location,
//           userEmail: selectedRoom.userEmail,
//           userId: selectedRoom.userId,
//           isFavorite: !newFavoriteStatus);
//       _rooms[selectedRoomIndex] = updatedRoom;
//       _selRoomId = null;
//       notifyListeners();
//     }
//   }

//   void selectRoom(String roomId) {
//     _selRoomId = roomId;
//     if (roomId != null) {
//       notifyListeners();
//     }
//   }

//   void toggleDisplayMode() {
//     _showFavorites = !_showFavorites;
//     notifyListeners();
//   }
// }

// mixin UserModel on ConnectedRoomsModel {
//   Timer _authTimer;
//   PublishSubject<bool> _userSubject = PublishSubject();

//   User get user {
//     return _authenticatedUser;
//   }

//   PublishSubject<bool> get userSubject {
//     return _userSubject;
//   }

//   Future<Map<String, dynamic>> authenticate(String email, String password,
//       [AuthMode mode = AuthMode.Login]) async {
//     _isLoading = true;
//     notifyListeners();
//     final Map<String, dynamic> authData = {
//       'email': email,
//       'password': password,
//       'returnSecureToken': true
//     };
//     http.Response response;
//     if (mode == AuthMode.Login) {
//       response = await http.post(
//         'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyA9dJA8CWw02sWQWisWSzGpHsKh6azxPeE',
//         body: json.encode(authData),
//         headers: {'Content-Type': 'application/json'},
//       );
//     } else {
//       response = await http.post(
//         'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyA9dJA8CWw02sWQWisWSzGpHsKh6azxPeE',
//         body: json.encode(authData),
//         headers: {'Content-Type': 'application/json'},
//       );
//     } //headers are just like map
//     final Map<String, dynamic> responseData = json.decode(response.body);
//     bool hasError = true;
//     String message = 'Something went wrong.';
//     print(responseData);
//     if (responseData.containsKey('idToken')) {
//       hasError = false;
//       message = 'Authentication succeeded!';
//       _authenticatedUser = User(
//           id: responseData['localId'],
//           email: email,
//           token: responseData['idToken']);
//       setAuthTimeout(int.parse(responseData['expiresIn']));
//       _userSubject.add(true);
//       final DateTime now = DateTime.now();
//       final DateTime expiryTime =
//           now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       //prefs is just an object which will intract with storage
//       //it is asyncronous.so we have to wait until we do not access
//       //bec requsting access and so on takes a while so we used await
//       //final SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString('token', responseData['idToken']);
//       prefs.setString('userEmail', email);
//       prefs.setString('userId', responseData['localId']);
//       prefs.setString('expiryTime', expiryTime.toIso8601String());
//     } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
//       message = 'This email already exists.';
//     } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
//       message = 'This email was not found.';
//     } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
//       message = 'The password is invalid.';
//     }
//     _isLoading = false;
//     notifyListeners();
//     return {'success': !hasError, 'message': message};
//   }

//   //print(json.decode(response.body));

//   void autoAuthenticate() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String token = prefs.getString('token');
//     final String expiryTimeString = prefs.getString('expiryTime');
//     if (token != null) {
//       final DateTime now = DateTime.now();
//       final parsedExpiryTime = DateTime.parse(expiryTimeString);
//       if (parsedExpiryTime.isBefore(now)) {
//         _authenticatedUser = null;
//         notifyListeners();
//         return;
//       }
//       final String userEmail = prefs.getString('userEmail');
//       final String userId = prefs.getString('userId');
//       final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
//       _authenticatedUser = User(id: userId, email: userEmail, token: token);
//       _userSubject.add(true);
//       setAuthTimeout(tokenLifespan);
//       notifyListeners();
//     }
//   }

//   void logout() async {
//     _authenticatedUser = null;
//     _authTimer.cancel();
//     _userSubject.add(false);
//     _selRoomId = null;
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.remove('token');
//     prefs.remove('userEmail');
//     prefs.remove('userId');

//     //_userSubject.add(false);
//     //false is not authenticated data
//   }

//   void setAuthTimeout(int time) {
//     _authTimer = Timer(Duration(seconds: time), logout);
//     // _authTimer = Timer(Duration(seconds: time), () {
//     // _authTimer = Timer(Duration(milliseconds: time * 2), () {
//     // logout();
//     // _userSubject.add(false);
//     //});
//   }
// }

// mixin UtilityModel on ConnectedRoomsModel {
//   bool get isLoading {
//     return _isLoading;
//   }
// }
