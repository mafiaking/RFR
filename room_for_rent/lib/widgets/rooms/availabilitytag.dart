import 'package:flutter/material.dart';

class AvailabilityTag extends StatelessWidget {
  final bool _isBooked;

  AvailabilityTag(this._isBooked);

  Widget _buildAvailableTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        'A',
        style: TextStyle(color: Colors.white),
      )
    );
  }

  Widget _buildNATag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        'NA',
        style: TextStyle(color: Colors.white),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isBooked ?_buildNATag() : _buildAvailableTag();
  }
}
