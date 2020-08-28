import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mesrecettes/helpers/firestore_helper.dart';
import 'package:connectivity/connectivity.dart';

showSnackBar(BuildContext context, String text) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(text),
  ));
}

class User extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseUser user;
  bool _userDataLoaded = false;
  // ignore: close_sinks
  StreamController<List<String>> _recipeIdsController;
  // ignore: close_sinks
  StreamController<List<Map<String, dynamic>>> _categoriesController;
  // ignore: close_sinks
  StreamController<FirebaseUser> _userController;
  Stream recipeIdsStream;
  Stream categoriesStream;
  Stream userStream;

  StreamSubscription<ConnectivityResult> _subscription;

  User() {
    _recipeIdsController = StreamController();
    _categoriesController = StreamController();
    _userController = StreamController.broadcast();
    recipeIdsStream = _recipeIdsController.stream;
    categoriesStream = _categoriesController.stream;
    userStream = _userController.stream;
    _auth.onAuthStateChanged.listen((FirebaseUser user) async {
      this.user = user;

      _userController.add(user);

      // if user was offline then online we have to fetch the user data

      if (isAuthenticated()) {
        _subscription = Connectivity()
            .onConnectivityChanged
            .listen((ConnectivityResult connectivityResult) async {
          if (connectivityResult != ConnectivityResult.none) {
            final bool result = await _initUserData();
            if (result) {
              //notifyListeners();
              if (_subscription != null) {
                _subscription.cancel();
              }
            }
          }
        });
      } else {
        if (_subscription != null) {
          _subscription.cancel();
        }
      }
    });
  }

  bool isAuthenticated() {
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, BuildContext context) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      switch (e.code) {
        case 'ERROR_INVALID_EMAIL':
          showSnackBar(context, "L'email est malformé");
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          showSnackBar(context, 'Cet email est déjà utilisé');
          break;
        case 'ERROR_NETWORK_REQUEST_FAILED':
          showSnackBar(context, 'Vous êtes hors ligne');
          break;
        default:
          showSnackBar(context, e.message);
          break;
      }
      return false;
    }
  }

  Future<bool> signInWithEmail(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      switch (e.code) {
        case 'ERROR_INVALID_EMAIL':
          showSnackBar(context, "L'email est malformé");
          break;
        case 'ERROR_WRONG_PASSWORD':
          showSnackBar(context, 'Le mot de passe est incorrect');
          break;
        case 'ERROR_USER_NOT_FOUND':
          showSnackBar(context, "L'email ne correspond à aucun compte");
          break;
        case 'ERROR_USER_DISABLED':
          showSnackBar(context, 'Ce compte a été désactivé');
          break;
        case 'ERROR_TOO_MANY_REQUESTS':
          showSnackBar(
              context, 'Il y a eu trop de tentative de connexion à ce compte');
          break;
        case 'ERROR_NETWORK_REQUEST_FAILED':
          showSnackBar(context, 'Vous êtes hors ligne');
          break;
        default:
          showSnackBar(context, e.message);
          break;
      }
      return false;
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential crediental = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      try {
        await _auth.signInWithCredential(crediental);
        return true;
      } catch (e) {
        switch (e.code) {
          case 'ERROR_USER_DISABLED':
            showSnackBar(context, 'Ce compte a été désactivé');
            break;
          case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
            showSnackBar(context, 'Il existe déjà un compte avec cet email');
            break;
          case 'ERROR_NETWORK_REQUEST_FAILED':
            showSnackBar(context, 'Vous êtes hors ligne');
            break;
          default:
            showSnackBar(context, e.message);
            break;
        }
      }
    }
    return false;
  }

  signOut() async {
    await _auth.signOut();
  }

  Future<bool> _initUserData() async {
    bool _result = false;
    List<String> recipeIds;
    List<Map<String, dynamic>> categories;
    // this code execute only once
    if (isAuthenticated() && _userDataLoaded == false) {
      // user logged in

      final document = await fireStoreHelper.loadUserData(user.uid);

      if (document != null) {
        // if user is offline / network error
        final data = document.data;

        if (data != null) {
          // user have already stored data
          if (data['recipeIds'] != null) {
            recipeIds = data['recipeIds'].cast<String>();
          } else {
            recipeIds = [];
          }
          if (data['categories'] != null) {
            categories = data['categories'].cast<Map<String, dynamic>>();
          } else {
            categories = [];
          }
        } else {
          // new user
          recipeIds = [];
          categories = [];
        }
        _result = true;
        _userDataLoaded = true;
      }
    }
    _recipeIdsController.add(recipeIds);
    _categoriesController.add(categories);
    return _result;
  }
}
