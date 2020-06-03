import 'package:flutter/material.dart';

class User {
  bool info = false;
  final String id;
  final String email;
  final String token;
  final String gender;
  final int phone;
  final String name;
  final String dob;

  User(
      {@required this.id,
      @required this.email,
      @required this.token,
      this.gender,
      this.dob,
      this.phone,
      this.name,
      this.info});
}
