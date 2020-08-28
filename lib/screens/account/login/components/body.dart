import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mesrecettes/models/user.dart';
import 'package:mesrecettes/screens/account/register/register_screen.dart';
import 'package:mesrecettes/size_config.dart';
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connexion',
                        style: TextStyle(fontSize: 25),
                      ),
                      TextFormField(
                        controller: _emailController,
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
                          } else {
                            return null;
                          }
                        },
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(top: 18, right: 6),
                        child: RichText(
                          text: TextSpan(
                              text: 'Mot de passe oublié ?',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => print('mot de passe oublié')),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 25, top: 10),
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Se connecter',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      final String email = _emailController.text;
                      final String password = _passwordController.text;
                      User user = Provider.of<User>(context, listen: false);
                      user
                          .signInWithEmail(email, password, context)
                          .then((result) {
                        if (result) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.defaultSize * 6),
                child: Divider(
                  height: 50,
                  color: Colors.black,
                ),
              ),
              Center(
                child: OutlineButton(
                  onPressed: () {
                    User user = Provider.of<User>(context, listen: false);
                    user.signInWithGoogle(context).then((result) {
                      if (result) {
                        Navigator.pop(context);
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/google_logo.png',
                        width: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Se connecter avec Google')
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 25),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Pas encore de compte ? ',
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: "S'inscrire",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()))),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
