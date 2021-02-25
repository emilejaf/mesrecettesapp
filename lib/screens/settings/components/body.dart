import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mesrecettes/constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        Card(
          child: ListTile(
            title: Text('Modifier mon consentement'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => showConsentForm(),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Plus d'informations"),
            onTap: () => _showDialog(context),
          ),
        )
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showAboutDialog(
        context: context,
        applicationIcon: Image.asset(
          'assets/icons/app.png',
          scale: 10,
        ),
        children: [
          ListTile(
            title: Text('Politique de confidentialité'),
            onTap: () => launch('https://mesrecettes.web.app/#privacypolicy'),
          ),
          ListTile(
            title: Text("Conditions d'utilisation"),
            onTap: () => launch('https://mesrecettes.web.app/#termofuse'),
          )
        ]);
  }
}
