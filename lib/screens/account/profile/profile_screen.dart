import 'package:flutter/material.dart';
import 'package:mesrecettes/screens/account/profile/components/body.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd7ffd9),
      ),
      body: Body(),
    );
  }
}
