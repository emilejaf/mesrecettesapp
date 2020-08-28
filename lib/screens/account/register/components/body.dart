import 'package:flutter/material.dart';
import 'package:mesrecettes/models/user.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;

  TextEditingController _emailController;
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Form(
        key: _formKey,
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
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inscription',
                        style: TextStyle(fontSize: 25),
                      ),
                      TextFormField(
                        controller: _emailController,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Adresse email'),
                        validator: (String value) {
                          if (value.trim().isEmpty) {
                            return 'Adresse email requis';
                          } else if (!value.trim().contains('@')) {
                            return 'Adresse email invalide';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            )),
                        validator: (String value) {
                          if (value.trim().isEmpty) {
                            return 'Mot de passe requis';
                          } else if (value.trim().length < 6) {
                            return 'Mot de passe trop court';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 25, top: 10),
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      final String email = _emailController.text;
                      final String password = _passwordController.text;
                      User user = Provider.of<User>(context, listen: false);
                      user
                          .signUpWithEmail(email, password, context)
                          .then((result) {
                        if (result) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
