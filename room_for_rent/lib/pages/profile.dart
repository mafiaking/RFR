import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_for_rent/scoped-models/main.dart';
import 'package:room_for_rent/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfilePage extends StatefulWidget {
  final String datetofetch = '';
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _profileformKey = GlobalKey<FormState>();
  TextEditingController dobController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  DateTime datetofetch = DateTime.now();
  String gender = "";
  @override
  Widget build(BuildContext context) {
    final Color color1 = Color(0xffFC5CF0);
    final Color color2 = Color(0xffFE8852);

    void _openUserInfoInputSheet(
        BuildContext context, MainModel model, String mode) {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0)),
                ),
                height: 400,
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key: _profileformKey,
                  child: Column(children: [
                    Text(
                      mode == "add" ? "Add User Info" : "Edit User Info",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              icon: Icon(
                                Icons.edit,
                                color: Colors.red,
                              ),
                            ),
                            validator: (String value) {
                              if (value.isEmpty || value.length < 5) {
                                return 'Name is invalid';
                              }
                              return null;
                            },
                          ),
                          Container(
                            height: 70.0,
                            child: TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone No',
                                icon: Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                ),
                              ),
                              validator: (String value) {
                                if (value.isEmpty ||
                                    value.trim().length != 10) {
                                  return 'Phone no is invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TextFormField(
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'Enter or Choose DOB';
                                    } else if (value.trim().length != 10) {
                                      return 'DOB is invalid';
                                    } else if (value.split('/').length != 3) {
                                      return 'Incorrect format';
                                    } else if (int.parse(DateTime.now()
                                                .year
                                                .toString()) -
                                            int.parse(value
                                                .split('/')
                                                .last
                                                .toString()) <
                                        12) {
                                      return 'Age must be 12+';
                                    }
                                    return null;
                                  },
                                  controller: dobController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'DOB',
                                    icon: Icon(
                                      Icons.cake,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.date_range,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    showDatePicker(
                                            helpText: "Select Date of Birth",
                                            context: context,
                                            initialDate: datetofetch,
                                            firstDate: DateTime(
                                                DateTime.now().year - 98),
                                            lastDate: DateTime(
                                                DateTime.now().year + 1))
                                        .then((value) {
                                      setState(() {
                                        dobController.text =
                                            '${value.day.toString().length == 1 ? 0 : ''}${value.day}/${value.month.toString().length == 1 ? 0 : ''}${value.month}/${value.year}';
                                      });
                                    });
                                  })
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: gender == "female"
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )
                                        : Icon(Icons.clear),
                                  ),
                                  label: Image.asset(
                                    "assets/female.png",
                                    width: 25,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    gender = "female";
                                  });
                                },
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              GestureDetector(
                                child: Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: gender == "male"
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )
                                        : Icon(Icons.clear),
                                  ),
                                  label: Image.asset(
                                    "assets/male.png",
                                    width: 25,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    gender = "male";
                                  });
                                },
                              )
                            ],
                          ),
                          SizedBox(height: 5.0),
                          ScopedModelDescendant<MainModel>(builder:
                              (BuildContext context, Widget child,
                                  MainModel model) {
                            return model.isLoading
                                ? AdaptiveProgressIndicator()
                                : RaisedButton(
                                    onPressed: () {
                                      if (!_profileformKey.currentState
                                              .validate() ||
                                          gender == '') {
                                        return;
                                      } else
                                        mode == 'add'
                                            ? model
                                                .addUserInfo(
                                                    nameController.text,
                                                    int.parse(
                                                        phoneController.text),
                                                    dobController.text,
                                                    gender,
                                                    "Add")
                                                .then((bool success) {
                                                if (success) {
                                                  Navigator.pop(context);

                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "user info succesfully added",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.grey.shade700,
                                                      textColor: Colors.white,
                                                      fontSize: 12.0);
                                                } else {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Something went wrong"),
                                                          content: Text(
                                                              "try again?"),
                                                          actions: <Widget>[
                                                            FlatButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Text("ok"))
                                                          ],
                                                        );
                                                      });
                                                }
                                              })
                                            : model.addUserInfo(
                                                nameController.text,
                                                int.parse(phoneController.text),
                                                dobController.text,
                                                gender,
                                                "Edit")
                                          ..then((bool success) {
                                            if (success) {
                                              Navigator.pop(context);

                                              Fluttertoast.showToast(
                                                  msg:
                                                      "user info succesfully updated",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.grey.shade700,
                                                  textColor: Colors.white,
                                                  fontSize: 12.0);
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Something went wrong"),
                                                      content:
                                                          Text("try again?"),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text("ok"))
                                                      ],
                                                    );
                                                  });
                                            }
                                          });
                                    },
                                    child: Text(
                                      mode == "add" ? "Save" : "Update",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: Color(0xffFE8852),
                                  );
                          })
                        ],
                      ),
                    )
                  ]),
                ),
              );
            });
          });
    }

    Widget _buildAppBar(MainModel model) {
      return AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.power_settings_new,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("Do you want to logout?"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No")),
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                model.logout();
                              },
                              child: Text("Yes")),
                        ]);
                  });
            }),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          model.user.info == false
              ? Row(
                  children: <Widget>[
                    Text(
                      "ADD INFO",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            datetofetch = DateTime.now();
                          });
                          _openUserInfoInputSheet(context, model, "add");
                        })
                  ],
                )
              : Row(
                  children: <Widget>[
                    Text(
                      "EDIT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            datetofetch = DateTime.tryParse(
                                "${model.user.dob.split('/').last.toString()}-${model.user.dob[3]}${model.user.dob[4]}-${model.user.dob.split('/').first.toString()} 00:00:00.000");
                            nameController.text = model.user.name;
                            gender = model.user.gender;
                            dobController.text = model.user.dob;
                            phoneController.text = model.user.phone.toString();
                          });

                          _openUserInfoInputSheet(context, model, "edit");
                        })
                  ],
                )
        ],
      );
    }

    Widget _buildUserInfoBox(MainModel model) {
      return Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(20.0),
          height: 210,
          width: 230,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.mail,
                  color: Colors.orange,
                ),
                title: Text(model.user.email),
              ),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.blue,
                ),
                title: model.user.info
                    ? Text(model.user.phone.toString())
                    : Text("NA"),
              ),
              ListTile(
                leading: Icon(
                  Icons.cake,
                  color: Colors.pink,
                ),
                title: model.user.info ? Text(model.user.dob) : Text("NA"),
              )
            ],
          ),
        ),
      );
    }

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 360,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50.0),
                          bottomRight: Radius.circular(50.0)),
                      gradient: LinearGradient(
                          colors: [color1, color2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 70),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: model.isLoading
                                    ? Container(
                                        color: Colors.white,
                                        child: AdaptiveProgressIndicator())
                                    : Image(
                                        image: model.user.info == true
                                            ? model.user.gender == "male"
                                                ? AssetImage(
                                                    "assets/male_user.png")
                                                : AssetImage(
                                                    "assets/female_user.png")
                                            : AssetImage(
                                                "assets/default_user.png"),
                                      ),
                              ),
                            ),
                          ),
                          model.user.info
                              ? Text(
                                  model.user.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              : Icon(Icons.person),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildAppBar(model),
              ],
            ),
            SizedBox(height: 20.0),
            _buildUserInfoBox(model),
            SizedBox(height: 20.0),
          ],
        ),
      );
    });
  }
}
