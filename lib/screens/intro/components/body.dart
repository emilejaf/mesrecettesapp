import 'package:flutter/material.dart';
import 'package:mesrecettes/screens/account/login/login_screen.dart';
import 'package:mesrecettes/screens/account/register/register_screen.dart';
import 'package:mesrecettes/screens/home/home_screen.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 16),
              margin: EdgeInsets.only(bottom: 40),
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/app.png',
                    width: 50,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'MesRecettes',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Avez-vous déjà un compte ?"),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RaisedButton(
                          child: Text(
                            "Se connecter",
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                              }),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                indent: 40,
                endIndent: 40,
              ),
            ),
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Nouvel utilisateur ?"),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RaisedButton(
                          child: Text(
                            "S'inscrire",
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterScreen()))
                              }),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 32),
              child: FlatButton(
                  child: Text(
                    "Passer cette étape",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () => {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()))
                      }),
            )
          ],
        ),
      ),
    );
  }
}
