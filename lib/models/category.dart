import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mesrecettes/constants.dart';
import 'package:sqflite/sqflite.dart';

class Category {
  String name;
  List<String> recipeIds;

  Category({this.name, this.recipeIds});

  Map<String, dynamic> toMap() {
    return {'name': name, 'recipeIds': jsonEncode(recipeIds)};
  }
}

class Categories extends ChangeNotifier {
  Categories() {
    init();
  }

  void addCategory(Category category) async {
    items.add(category);
    notifyListeners();

    final Database db = await getDatabase();
    db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void editName(Category category, String name) async {
    final String oldName = category.name;
    category.name = name;
    notifyListeners();

    final Database db = await getDatabase();
    _update(db, oldName, category);
  }

  List<Category> getCategoriesByRecipeId(String id) {
    return items
        .where((Category category) => category.recipeIds.contains(id))
        .toList();
  }

  void addRecipeId(List<Category> categories, String id) async {
    items
        .where((category) => categories.contains(category))
        .forEach((category) {
      category.recipeIds.add(id);
    });
    notifyListeners();

    final Database db = await getDatabase();

    categories.forEach((category) {
      _update(db, category.name, category);
    });
  }

  Future<void> removeRecipeId(String id) async {
    final Database db = await getDatabase();
    items.forEach((Category category) {
      if (category.recipeIds.contains(id)) {
        category.recipeIds.remove(id);
        _update(db, category.name, category);
      }
    });
  }

  void removeCategory(String name) async {
    items.removeWhere((element) => element.name == name);
    notifyListeners();

    final Database db = await getDatabase();
    db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  void init() async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('categories');

    items = List.generate(
        maps.length,
        (index) => Category(
            name: maps[index]['name'],
            recipeIds: jsonDecode(maps[index]['recipeIds']).cast<String>()));
    notifyListeners();
  }

  List<Category> items = [];

  void _update(Database db, String key, Category category) {
    db.update('categories', category.toMap(),
        where: 'name = ?', whereArgs: [key]);
  }
}
