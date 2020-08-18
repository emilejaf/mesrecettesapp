import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:admob_consent/admob_consent.dart';

const kPrimaryColor = Colors.lightGreen;
const kTextColor = Colors.black;
const kTextSecondaryColor = Colors.white;

Database _database;

Future<Database> getDatabase() async {
  if (_database == null) {
    _database = await _initDatabase();
  }
  return _database;
}

_initDatabase() async {
  return openDatabase(join(await getDatabasesPath(), 'mesrecettes.db'),
      onCreate: (db, version) async {
    await db.execute(
        'CREATE TABLE recipes(id TEXT PRIMARY KEY, name TEXT, cookTime TEXT, hasImage INTEGER, prepTime TEXT, people TEXT, ingredients TEXT, steps TEXT, notes TEXT)');
    return db.execute('CREATE TABLE categories(name TEXT, recipeIds TEXT)');
  }, version: 1);
}

final AdmobConsent _admobConsent = AdmobConsent();

void showConsentForm() {
  _admobConsent.show(
      publisherId: 'pub-8850562463084333',
      privacyURL: "https://mesrecettes.web.app/#privacypolicy");
  _admobConsent.onConsentFormLoaded.listen((event) {
    print(event);
  });
  _admobConsent.onConsentFormClosed.listen((bool status) {
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-8850562463084333~3958573142');
    print(status);
  });
}
