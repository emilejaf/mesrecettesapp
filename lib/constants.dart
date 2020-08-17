import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const kPrimaryColor = Colors.lightGreen;
const kTextColor = Colors.black;
const kTextSecondaryColor = Colors.white;

Future<Database> getDatabase() async {
  return openDatabase(join(await getDatabasesPath(), 'mesrecettes.db'),
      onCreate: (db, version) async {
    await db.execute(
        'CREATE TABLE recipes(id TEXT PRIMARY KEY, name TEXT, cookTime TEXT, hasImage INTEGER, prepTime TEXT, people TEXT, ingredients TEXT, steps TEXT, notes TEXT)');
    return db.execute('CREATE TABLE categories(name TEXT, recipeIds TEXT)');
  }, version: 1);
}
