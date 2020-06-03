import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as geoloc;

import '../helpers/ensure_visible.dart';
import '../../models/location_data.dart';
import '../../models/room.dart';
import '../../shared/global_config.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Room room;

  LocationInput(this.setLocation, this.room);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  Uri _staticMapUri;
  LocationData _locationData;
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.room != null) {
      _getStaticMap(widget.room.location.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address,
      {bool geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https("api.opencagedata.com", '/geocode/v1/json',
          {'q': address, 'key': opencageapikey, 'pretty': "1"});
      try {
        final http.Response response = await http.get(uri);
        final decodedResponse = json.decode(response.body);
        final String decodedAddressString =
            decodedResponse['results'][0]['formatted'];
        final decodedCoordinates = decodedResponse['results'][0]['geometry'];
        _locationData = LocationData(
            address: decodedAddressString,
            latitude: decodedCoordinates['lat'],
            longitude: decodedCoordinates['lng']);
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Could not fetch location!"),
                content: Text(
                    "Please check internet and try again.\nError: ${e.toString()}"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Okay"))
                ],
              );
            });
      }
    } else if (lat == null && lng == null) {
      _locationData = widget.room.location;
    } else {
      _locationData =
          LocationData(address: address, latitude: lat, longitude: lng);
    }
    if (mounted) {
      try {
        final StaticMapProvider staticMapViewProvider =
            StaticMapProvider(mapquestapikey);
        final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers([
          Marker('position', 'Position', _locationData.latitude,
              _locationData.longitude)
        ],
            center: Location(_locationData.latitude, _locationData.longitude),
            width: 500,
            height: 300,
            maptype: StaticMapViewType.map);
        widget.setLocation(_locationData);

        setState(() {
          _addressInputController.text = _locationData.address;
          _staticMapUri = staticMapUri;
        });
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Could not locate on map!"),
                content: Text(
                    "Please check ur internet connection.\nError: ${e.toString()}"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Okay"))
                ],
              );
            });
      }
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final uri = Uri.https("api.opencagedata.com", '/geocode/v1/json', {
      'q': '${lat.toString()} ${lng.toString()}',
      'key': opencageapikey,
      'pretty': '1'
    });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final de1 = decodedResponse['results'][0]['formatted'];
    final decodedAddressString =
        '${decodedResponse['results'][0]['components']['county']}, ${de1.toString()}';
    return decodedAddressString;
  }

  void _getUserLocation() async {
    final location = geoloc.Location();

    try {
      final currentLocation = await location.getLocation();
      final address = await _getAddress(
          currentLocation.latitude, currentLocation.longitude);
      _getStaticMap(address,
          geocode: false,
          lat: currentLocation.latitude,
          lng: currentLocation.longitude);
    } catch (error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Could not fetch Location'),
              content: Text(
                'Please add an address manually!',
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found.';
              }
              return null;
            },
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(height: 10.0),
        GestureDetector(
          onTap: () {
            _getUserLocation();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.gps_fixed),
              SizedBox(
                width: 10,
              ),
              Text("Locate User")
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString())
      ],
    );
  }
}
