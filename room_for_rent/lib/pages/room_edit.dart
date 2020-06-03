import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_for_rent/widgets/ui_elements/adapative_progress_indicator.dart';

import 'package:scoped_model/scoped_model.dart';

import '../widgets/helpers/ensure_visible.dart';
import '../widgets/form_inputs/location.dart';
import '../widgets/form_inputs/image.dart';
import '../models/room.dart';
import '../scoped-models/main.dart';
// import '../widgets/rooms/location_tag.dart';
import '../models/location_data.dart';

enum RoomCategory { single_room, double_room, flat, apartment }

class RoomEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RoomEditPageState();
  }
}

class _RoomEditPageState extends State<RoomEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();
  double discount;
  String category = "Choose room type";

  Widget _buildTitleTextField(Room room) {
    if (room == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (room != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = room.title;
    } else if (room != null && _titleTextController.text.trim() != '') {
      if (_titleTextController.text != '') {
      } else
        _titleTextController.text = _titleTextController.text;
    } else if (room == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else
      _titleTextController.text = '';
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Room Title'),
        controller: _titleTextController,
        // initialValue: room == null ? '' : room.title,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 5) {
            return 'Title is required and should be 5+ characters long.';
          }
          return null;
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Room room) {
    if (room == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (room != null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = room.description;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        maxLines: 6,
        decoration: InputDecoration(labelText: 'Room Description'),
        // initialValue: room == null ? '' : room.description,
        controller: _descriptionTextController,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 10) {
            return 'Description is required and should be 10+ characters long.';
          }
          return null;
        },
        onSaved: (String value) {
          _formData['description'] = value;
        },
      ),
    );
  }

  Widget _buildCategoryType(Room room) {
    if (room != null && category == "Choose room type") {
      category = room.category;
    }
    return Row(children: [
      Text(
        'Category (${category.toString()})',
        textAlign: TextAlign.start,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      ),
      PopupMenuButton(
          onSelected: (value) {
            setState(() {
              if (value == RoomCategory.single_room) {
                category = "Single room";
              } else if (value == RoomCategory.double_room) {
                category = "Double room";
              } else if (value == RoomCategory.flat) {
                category = "Flat";
              } else if (value == RoomCategory.apartment) {
                category = "Apartment";
              }
            });
          },
          icon: Icon(Icons.add),
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<RoomCategory>>[
              PopupMenuItem<RoomCategory>(
                value: RoomCategory.single_room,
                child: Text('Single Room'),
              ),
              PopupMenuItem<RoomCategory>(
                value: RoomCategory.double_room,
                child: Text('Double Room'),
              ),
              PopupMenuItem<RoomCategory>(
                value: RoomCategory.flat,
                child: Text('Flat'),
              ),
              PopupMenuItem<RoomCategory>(
                value: RoomCategory.apartment,
                child: Text('Apartment'),
              ),
            ];
          }),
    ]);
  }

  Widget _buildPriceTextField(Room room) {
    if (room == null && _priceTextController.text.trim() == '') {
      _priceTextController.text = '';
    } else if (room != null && _priceTextController.text.trim() == '') {
      _priceTextController.text = room.price.toString();
    }
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        focusNode: _priceFocusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Room Price (\u0930\u0942)'),
        controller: _priceTextController,
        // initialValue: room == null ? '' : room.price.toString(),
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
            return 'Price is required and should be a number.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDicountSlider(Room room) {
    if (room != null && discount == null) {
      discount = room.discount;
    } else if (room == null && discount == null) {
      discount = 0;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DecoratedBox(
        decoration: BoxDecoration(),
        child: Text(
          'Discount (${discount.floor().toString()}%)',
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ),
      Slider(
          value: discount,
          min: 0,
          max: 100,
          divisions: 20,
          label: "${discount.floor()}%",
          onChanged: (value) {
            setState(() {
              discount = value;
            });
          })
    ]);
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: AdaptiveProgressIndicator())
            : RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(model.addRoom, model.updateRoom,
                    model.selectRoom, model.selectedRoomIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Room room) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(room),
              _buildDescriptionTextField(room),
              SizedBox(height: 10.0),
              _buildCategoryType(room),
              _buildPriceTextField(room),
              SizedBox(height: 15.0),
              _buildDicountSlider(room),
              SizedBox(
                height: 10.0,
              ),
              LocationInput(_setLocation, room),
              // AddressTag('Pokhara'),
              SizedBox(height: 10.0),
              ImageInput(_setImage, room),
              SizedBox(
                height: 5.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _submitForm(
      Function addRoom, Function updateRoom, Function setSelectedRoom,
      [int selectedRoomIndex]) {
    if (!_formKey.currentState.validate() ||
        category == "Choose room type" ||
        discount == null ||
        (_formData['image'] == null && selectedRoomIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    if (selectedRoomIndex == -1) {
      addRoom(
              _titleTextController.text,
              _descriptionTextController.text,
              _formData['image'],
              double.parse(
                  _priceTextController.text.replaceFirst(RegExp(r','), '.')),
              double.parse(discount.floor().toString()),
              _formData['location'],
              category)
          .then((bool success) {
        if (success) {
          Fluttertoast.showToast(
              msg: "room succesfully added",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey.shade700,
              textColor: Colors.white,
              fontSize: 12.0);
          Navigator.pushReplacementNamed(context, '/homepage')
              .then((_) => setSelectedRoom(null))
              .then((value) {});
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('please check ur internet connection.'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Okay'),
                    )
                  ],
                );
              });
        }
      });
    } else {
      updateRoom(
              _titleTextController.text,
              _descriptionTextController.text,
              _formData['image'],
              double.parse(
                  _priceTextController.text.replaceFirst(RegExp(r','), '.')),
              double.parse(discount.floor().toString()),
              _formData['location'],
              category)
          .then((bool response) {
        if (response == true) {
          Fluttertoast.showToast(
              msg: "room succesfully updated",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey.shade700,
              textColor: Colors.white,
              fontSize: 12.0);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      Text('Succesfully Updated')
                    ],
                  ),
                  content: Text('want to edit again or leave page?'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Edit'),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Leave'),
                    )
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('please check ur internet connection.'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Okay'),
                    )
                  ],
                );
              });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedRoom);
        return model.selectedRoomIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Room'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
