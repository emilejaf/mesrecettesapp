import 'package:flutter/material.dart';
import 'package:mesrecettes/components/my_drawer.dart';
import 'package:mesrecettes/screens/settings/components/body.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      body: Body(),
    );
  }
}
