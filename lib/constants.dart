import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        'CREATE TABLE recipes(id TEXT PRIMARY KEY, name TEXT, cookTime TEXT, hasImage INTEGER, sync INTEGER, prepTime TEXT, people TEXT, ingredients TEXT, steps TEXT, notes TEXT)');
    await db.execute('CREATE TABLE deletedRecipes(id TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE deletedCategories(id TEXT PRIMARY KEY)');
    return db.execute(
        'CREATE TABLE categories(id TEXT PRIMARY KEY, name TEXT, sync INTEGER, recipeIds TEXT)');
  }, version: 1);
}

final AdmobConsent _admobConsent = AdmobConsent();

bool _consent;

void initConsent() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _consent = prefs.getBool('consent') ?? null;
  if (_consent == null) {
    showConsentForm(initSDK: true);
  }
}

void showConsentForm({bool initSDK = false}) {
  _admobConsent.show(
      publisherId: 'pub-8850562463084333',
      privacyURL: "https://mesrecettes.web.app/#privacypolicy");
  _admobConsent.onConsentFormClosed.listen((bool status) async {
    if (initSDK) {
      FirebaseAdMob.instance
          .initialize(appId: 'ca-app-pub-8850562463084333~3958573142');
    }
    _consent = status;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('consent', _consent);
  });
}

MobileAdTargetingInfo getTargetingInfo() {
  return MobileAdTargetingInfo(
      nonPersonalizedAds: !_consent,
      childDirected: false,
      testDevices: ['DE4000BBEFBE907EB50B17AB2B9C6A33']);
}
