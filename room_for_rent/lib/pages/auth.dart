import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../widgets/ui_elements/adapative_progress_indicator.dart';
import '../scoped-models/main.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  bool _obscurePass = true;
  bool _obscureConPass = true;

  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    super.initState();
  }

  Widget _buildTopDesign() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.4,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDD2C00),
              Color(0xFFEF5350),
              Color(0xFFFF7043),
            ],
            //stops: [0.1, 0.4, 0.7, 0.9],
          ),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(90))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/logo.png',
              height: 100.0,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 13),
              child: Text(
                'Room For Rent',
                style: TextStyle(
                    color: Colors.white, fontSize: 25, fontFamily: 'Oswald'),
                //fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.2,
        height: 50,
        padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
        child: TextFormField(
          decoration: InputDecoration(
            icon: Icon(
              Icons.email,
              color: Colors.black,
            ),
            // labelText: 'E-Mail',
            hintText: 'E-mail',

            // filled: true,
            // fillColor: Colors.white
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          onSaved: (String value) {
            _formData['email'] = value.trim();
          },
        ));
  }

  Widget _buildPasswordTextField() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 50,
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: TextFormField(
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  if (_obscurePass == true) {
                    _obscurePass = false;
                  } else {
                    _obscurePass = true;
                  }
                });
              },
              icon: Icon(
                _obscurePass == true
                    ? Icons.remove_red_eye
                    : Icons.visibility_off,
              )),
          icon: Icon(
            Icons.lock_open,
            color: Colors.black,
          ),
          // labelText: 'Password',
          hintText: 'Password',
          // filled: true,
          // fillColor: Colors.white
        ),
        // keyboardType: TextInputType.visiblePassword,
        obscureText: _obscurePass,
        controller: _passwordTextController,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return 'Password invalid';
          }
          return null;
        },
        onSaved: (String value) {
          _formData['password'] = value;
        },
      ),
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width / 1.2,
          height: 50,
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: TextFormField(
            decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        if (_obscureConPass == true) {
                          _obscureConPass = false;
                        } else {
                          _obscureConPass = true;
                        }
                      });
                    },
                    icon: Icon(
                      _obscureConPass == true
                          ? Icons.remove_red_eye
                          : Icons.visibility_off,
                    )),
                icon: Icon(
                  Icons.lock_outline,
                  color: Colors.black,
                ),
                hintText: 'Confirm Password'
                // labelText: 'Confirm Password',
                // filled: true,
                // fillColor: Colors.white
                ),
            obscureText: _obscureConPass,
            validator: (String value) {
              if (_passwordTextController.text != value &&
                  _authMode == AuthMode.Signup) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptSwitch() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 32),
      child: SwitchListTile(
        value: _formData['acceptTerms'],
        onChanged: (bool value) {
          setState(() {
            _formData['acceptTerms'] = value;
          });
        },
        title: Text('Accept Terms'),
      ),
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate() || !_formData['acceptTerms']) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    successInformation = await authenticate(
        _formData['email'], _formData['password'], _authMode);
    if (successInformation['success']) {
      // Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An Error Occurred!'),
            content: Text(successInformation['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(children: <Widget>[
            _buildTopDesign(),
            Container(
              height: MediaQuery.of(context).size.height / 0.75,
              width: targetWidth,
              padding: EdgeInsets.only(top: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildEmailTextField(),
                    _buildPasswordTextField(),
                    _authMode == AuthMode.Login
                        ? Container()
                        : _buildPasswordConfirmTextField(),
                    SizedBox(height: 10.0),
                    _buildAcceptSwitch(),
                    FlatButton(
                      child: Text(
                          'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                      onPressed: () {
                        if (_authMode == AuthMode.Login) {
                          setState(() {
                            _authMode = AuthMode.Signup;
                          });
                          _controller.forward();
                        } else {
                          setState(() {
                            _authMode = AuthMode.Login;
                          });
                          _controller.reverse();
                        }
                      },
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (BuildContext context, Widget child,
                          MainModel model) {
                        return model.isLoading
                            ? AdaptiveProgressIndicator()
                            : RaisedButton(
                                textColor: Colors.white,
                                child: Text(
                                  _authMode == AuthMode.Login
                                      ? 'LOGIN'
                                      : 'SIGNUP',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () =>
                                    _submitForm(model.authenticate),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
