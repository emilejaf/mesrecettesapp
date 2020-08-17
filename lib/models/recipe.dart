import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mesrecettes/constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Recipe {
  String id;
  String name;
  String path;
  bool hasImage;
  List<String> ingredients;
  List<String> steps;
  String notes;
  String cookTime, prepTime, people;

  Recipe(
      {this.name = '',
      this.path = '',
      this.hasImage = false,
      this.ingredients,
      this.steps,
      this.notes = '',
      this.cookTime = '',
      this.prepTime = '',
      this.people = '',
      this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hasImage': hasImage ? 1 : 0,
      'cookTime': cookTime,
      'prepTime': prepTime,
      'people': people,
      'ingredients': jsonEncode(ingredients).toString(),
      'steps': jsonEncode(steps).toString(),
      'notes': notes
    };
  }
}

class Recipes extends ChangeNotifier {
  Recipes() {
    init();
  }

  void addRecipe(Recipe recipe) async {
    items.add(recipe);
    notifyListeners();

    final Database db = await getDatabase();
    db.insert('recipes', recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void editRecipe(Recipe newRecipe) async {
    items.removeWhere((recipe) => recipe.id == newRecipe.id);
    items.add(newRecipe);
    notifyListeners();

    final Database db = await getDatabase();
    db.update('recipes', newRecipe.toMap(),
        where: 'id = ?', whereArgs: [newRecipe.id]);
  }

  void removeRecipe(Recipe recipe) async {
    items.removeWhere((element) => element.id == recipe.id);
    notifyListeners();

    final Database db = await getDatabase();
    db.delete('recipes', where: 'id = ?', whereArgs: [recipe.id]);
  }

  void init() async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('recipes');
    final String appPath = (await getApplicationDocumentsDirectory()).path;

    items = List.generate(maps.length, (index) {
      final bool hasImage = maps[index]['hasImage'] == 1 ? true : false;
      final String id = maps[index]['id'];
      final String path = join(appPath, '$id.jpg');
      return Recipe(
          id: id,
          name: maps[index]['name'],
          path: hasImage ? path : '',
          hasImage: hasImage,
          cookTime: maps[index]['cookTime'],
          prepTime: maps[index]['prepTime'],
          people: maps[index]['people'],
          ingredients: jsonDecode(maps[index]['ingredients']).cast<String>(),
          steps: jsonDecode(maps[index]['steps']).cast<String>(),
          notes: maps[index]['notes']);
    });
    notifyListeners();
  }

  List<Recipe> items = [];
}
