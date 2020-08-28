import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mesrecettes/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mesrecettes/helpers/firestore_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class Recipe {
  String id;
  String name;
  String path;
  bool hasImage;
  bool sync;
  List<String> ingredients;
  List<String> steps;
  String notes;
  String cookTime, prepTime, people;

  Recipe(
      {this.name = '',
      this.path = '',
      this.hasImage = false,
      this.sync = false,
      this.ingredients,
      this.steps,
      this.notes = '',
      this.cookTime = '',
      this.prepTime = '',
      this.people = '',
      this.id});

  Map<String, dynamic> toMap({bool sqlFormat = true}) {
    final map = {
      'id': id,
      'name': name,
      'hasImage': sqlFormat ? hasImage ? 1 : 0 : hasImage,
      'cookTime': cookTime,
      'prepTime': prepTime,
      'people': people,
      'ingredients':
          sqlFormat ? jsonEncode(ingredients).toString() : ingredients,
      'steps': sqlFormat ? jsonEncode(steps).toString() : steps,
      'notes': notes
    };
    if (sqlFormat) {
      map['sync'] = sync ? 1 : 0;
    }
    return map;
  }
}

class Recipes extends ChangeNotifier {
  FirebaseUser _user;
  Set<String> recipeIds;

  Recipes({Stream recipeIdsStream, Stream userStream}) {
    _init(recipeIdsStream);

    userStream.listen((event) {
      _user = event;
    });
  }

  void addRecipe(Recipe recipe, {List<Map<String, dynamic>> categories}) async {
    items.insert(0, recipe);
    notifyListeners();

    final Database db = await getDatabase();
    db.insert('recipes', recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // recipe will be unsync

    // we try to sync the recipe
    if (_canUpdate()) {
      _syncRecipe(db, recipe, categories: categories);
      //notifyListeners();
    }
  }

  void editRecipe(String oldRecipeId, Recipe newRecipe,
      {List<Map<String, dynamic>> categories}) async {
    items.removeWhere((recipe) => recipe.id == oldRecipeId);
    items.add(newRecipe);
    notifyListeners();

    final Database db = await getDatabase();
    deletedRecipes.add(oldRecipeId);
    Batch batch = db.batch();
    batch.update('recipes', newRecipe.toMap(),
        where: 'id = ?', whereArgs: [oldRecipeId]);
    batch.insert('deletedRecipes', {'id': oldRecipeId});
    batch.commit(noResult: true);

    if (_canUpdate()) {
      recipeIds.remove(oldRecipeId);
      recipeIds.add(newRecipe.id);
      bool result = await fireStoreHelper.updateRecipe(
          oldRecipeId, newRecipe, _user.uid, recipeIds.toList(),
          categories: categories);
      if (result) {
        newRecipe.sync = true;
        Batch resultBatch = db.batch();
        resultBatch.update('recipes', newRecipe.toMap(),
            where: 'id = ?', whereArgs: [newRecipe.id]);
        resultBatch.delete('deletedRecipes',
            where: 'id = ?', whereArgs: [oldRecipeId]);
        resultBatch.commit(noResult: true);
      }
    }
  }

  void deleteRecipe(Recipe recipe,
      {List<Map<String, dynamic>> categories}) async {
    items.removeWhere(
        (element) => element.id == recipe.id); // remove recipe from recipe list
    notifyListeners(); // update ui
    deletedRecipes.add(recipe.id); // add recipe to deleted list
    final Database db = await getDatabase();

    Batch batch = db.batch();
    batch.insert('deletedRecipes', {'id': recipe.id});
    batch.delete('recipes', where: 'id = ?', whereArgs: [recipe.id]);
    batch.commit(noResult: true);
    if (recipe.hasImage) {
      File(recipe.path).delete();
    }

    if (_canUpdate()) {
      _deleteRecipeFromFirestore(db, recipe.id, categories: categories);
    }
  }

  void unsyncAllRecipes() async {
    items.forEach((Recipe recipe) {
      recipe.sync = false;
    });

    final Database db = await getDatabase();
    db.rawUpdate('UPDATE recipes SET sync=0');
  }

  void _updateRecipeState(Database db, Recipe recipe) async {
    await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }

  bool _canUpdate() {
    return _user != null && recipeIds != null;
  }

  Future<void> _syncRecipe(Database db, Recipe recipe,
      {List<Map<String, dynamic>> categories}) async {
    recipeIds.add(recipe.id);
    bool result = await fireStoreHelper.addRecipe(
        recipe, _user.uid, recipeIds.toList(),
        categories: categories);
    if (result) {
      recipe.sync = true;
      _updateRecipeState(db, recipe);
    }
  }

  Future<void> _deleteRecipeFromFirestore(Database db, String recipeId,
      {List<Map<String, dynamic>> categories}) async {
    recipeIds.remove(recipeId);
    bool result = await fireStoreHelper.deleteRecipe(
        recipeId, _user.uid, recipeIds.toList(),
        categories: categories);
    if (result) {
      deletedRecipes.remove(recipeId);
      db.delete('deletedRecipes', where: 'id = ?', whereArgs: [recipeId]);
    }
  }

  void _init(Stream recipeIdsStream) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('recipes');
    final String appPath = (await getApplicationDocumentsDirectory()).path;

    items = List.generate(maps.length, (index) {
      return _fromMap(maps[index], appPath: appPath);
    });
    notifyListeners();

    final List<Map<String, dynamic>> deletedRecipesMaps =
        await db.query('deletedRecipes');

    deletedRecipes = List.generate(
        deletedRecipesMaps.length, (index) => deletedRecipesMaps[index]['id']);

    recipeIdsStream.listen((event) async {
      // recipeIds list from firestore
      if (event != null) {
        recipeIds = event.cast<String>().toSet();
        if (items.isNotEmpty) {
          // we may recipe to delete or to upload
          items.where((Recipe recipe) => !recipe.sync).forEach((Recipe recipe) {
            // recipe to sync
            // recipe have to be added to firestore
            _syncRecipe(db, recipe);
          });

          // check for recipe to delete locally
          final Set<String> firestoreDeletedRecipesIds = items
              .where((Recipe recipe) =>
                  recipe.sync && !recipeIds.contains(recipe.id))
              .map((Recipe recipe) => recipe.id)
              .toSet();
          items.removeWhere((Recipe recipe) =>
              firestoreDeletedRecipesIds.contains(recipe.id));
          notifyListeners();

          if (firestoreDeletedRecipesIds.isNotEmpty) {
            Batch batch = db.batch();

            firestoreDeletedRecipesIds.forEach((String id) {
              batch.delete('recipes', where: 'id = ?', whereArgs: [id]);
            });

            batch.commit(noResult: true);
          }
        }

        deletedRecipes.forEach((String recipeId) {
          // recipe to delete from firestore
          _deleteRecipeFromFirestore(db, recipeId);
          // recipeIds.remove(recipeId); // update with new value
        });
        // check for recipe to download
        if (recipeIds.isNotEmpty) {
          // we may have recipe to download
          Set<String> localRecipeIds =
              items.map((Recipe recipe) => recipe.id).toSet();
          recipeIds
              .where((id) => !localRecipeIds.contains(id))
              .forEach((String recipeId) {
            // recipe id of the recipe to download
            fireStoreHelper.getRecipe(recipeId).then((recipeMap) {
              Recipe recipe =
                  _fromMap(recipeMap, sqlFormat: false, appPath: appPath);
              items.insert(0, recipe);
              notifyListeners();
              db.insert('recipes', recipe.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace);
            });
          });
        }
      }
    });
  }

  List<Recipe> items = [];
  List<String> deletedRecipes = [];

  Recipe _fromMap(Map<String, dynamic> data,
      {bool sqlFormat = true, String appPath}) {
    final bool hasImage =
        sqlFormat ? data['hasImage'] == 1 ? true : false : data['hasImage'];
    final String id = data['id'];
    final String path = join(appPath, '$id.jpg');
    return Recipe(
        id: id,
        name: data['name'],
        path: hasImage ? path : '',
        hasImage: hasImage,
        sync: sqlFormat ? data['sync'] == 1 ? true : false : true,
        cookTime: data['cookTime'],
        prepTime: data['prepTime'],
        people: data['people'],
        ingredients: sqlFormat
            ? jsonDecode(data['ingredients']).cast<String>()
            : data['ingredients'].cast<String>(),
        steps: sqlFormat
            ? jsonDecode(data['steps']).cast<String>()
            : data['steps'].cast<String>(),
        notes: data['notes']);
  }
}
