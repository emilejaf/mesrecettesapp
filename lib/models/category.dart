import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mesrecettes/constants.dart';
import 'package:mesrecettes/helpers/firestore_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class Category {
  String id;
  String name;
  bool sync;
  List<String> recipeIds;

  Category({this.name, this.recipeIds, this.id, this.sync = false});

  Map<String, dynamic> toMap({sqlFormat = true}) {
    final Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'recipeIds': sqlFormat ? jsonEncode(recipeIds) : recipeIds
    };
    if (sqlFormat) {
      map['sync'] = sync ? 1 : 0;
    }
    return map;
  }
}

bool listening = false;

class Categories extends ChangeNotifier {
  FirebaseUser _user;
  Set<Map<String, dynamic>> serverCategories;

  Categories({Stream categoriesStream, Stream userStream}) {
    _init(categoriesStream, listening);

    if (listening == false) {
      userStream.listen((event) {
        _user = event;
      });
      listening = true;
    }
  }

  void addCategory(Category category) async {
    items.insert(0, category);
    notifyListeners();

    final Database db = await getDatabase();
    db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // category will be unsync

    // we try to sync the category
    if (_canUpdate()) {
      _syncCategory(db, category);
      // notifyListeners();
    }
  }

  void editCategory(String oldCategoryId, Category newCategory) async {
    notifyListeners();
    deletedCategories.add(oldCategoryId);

    final Database db = await getDatabase();
    Batch batch = db.batch();
    batch.update('categories', newCategory.toMap(),
        where: 'id = ?', whereArgs: [oldCategoryId]);
    batch.insert('deletedCategories', {'id': oldCategoryId});
    batch.commit(noResult: true);

    if (_canUpdate()) {
      serverCategories.removeWhere((map) => map['id'] == oldCategoryId);
      serverCategories.add(newCategory.toMap(sqlFormat: false));
      bool result = await fireStoreHelper.updateCategories(
          _user.uid, serverCategories.toList());
      if (result) {
        newCategory.sync = true;
        Batch resultBatch = db.batch();
        resultBatch.update('categories', newCategory.toMap(),
            where: 'id = ?', whereArgs: [newCategory.id]);
        resultBatch.delete('deletedCategories',
            where: 'id = ?', whereArgs: [oldCategoryId]);
        resultBatch.commit(noResult: true);
      }
    }
  }

  List<Category> getCategoriesByRecipeId(String id) {
    return items
        .where((Category category) => category.recipeIds.contains(id))
        .toList();
  }

  Future<void> addRecipeId(List<Category> categories, String id) async {
    final Database db = await getDatabase();
    items
        .where((category) => categories.contains(category))
        .forEach((category) {
      String oldId = category.id;
      if (category.sync) {
        db.insert('deletedCategories', {'id': oldId});
      }
      category.recipeIds.add(id);
      category.sync = false;
      category.id = Uuid().v4();

      _updateCategoryState(db, category, oldId);
      if (_canUpdate()) {
        serverCategories.removeWhere((map) => map['id'] == oldId);
        serverCategories.add(category.toMap(sqlFormat: false));
      }
    });
    notifyListeners();
  }

  Future<void> removeRecipeId(String recipeId) async {
    final Database db = await getDatabase();
    items.forEach((Category category) {
      if (category.recipeIds.contains(recipeId)) {
        // we have to create a new category
        String oldId = category.id;
        if (category.sync) {
          // add oldCategory to deletedCategories
          db.insert('deletedCategories', {'id': oldId});
        }
        category.recipeIds.remove(recipeId);
        category.sync = false;
        category.id = Uuid().v4(); // generate new id
        _updateCategoryState(db, category, oldId);
        if (_canUpdate()) {
          serverCategories.removeWhere((map) => map['id'] == oldId);
          serverCategories.add(category.toMap(sqlFormat: false));
        }
      }
    });
    notifyListeners();
  }

  void deleteCategory(String id, bool sync) async {
    items.removeWhere((element) => element.id == id);
    notifyListeners();
    deletedCategories.add(id);
    final Database db = await getDatabase();
    Batch batch = db.batch();
    batch.delete('categories', where: 'id = ?', whereArgs: [id]);
    if (sync) {
      batch.insert('deletedCategories', {'id': id});
    }
    batch.commit(noResult: true);

    if (_canUpdate() && sync) {
      _deleteCategoryFromFirestore(db, id);
    }
  }

  Future<void> syncCategories(List<Category> categories) async {
    final Database db = await getDatabase();

    Batch batch = db.batch();

    categories.forEach((Category category) {
      category.sync = true;
      batch.update('categories', category.toMap(),
          where: 'id = ?', whereArgs: [category.id]);
    });

    batch.commit(noResult: true);
  }

  void unsyncAllCategories() async {
    items.forEach((Category category) {
      category.sync = false;
    });

    final Database db = await getDatabase();
    db.rawUpdate('UPDATE categories SET sync=0');
    db.delete('deletedCategories');
  }

  Future<void> _syncCategory(Database db, Category category) async {
    serverCategories.add(category.toMap(sqlFormat: false));
    bool result = await fireStoreHelper.updateCategories(
        _user.uid, serverCategories.toList());
    if (result) {
      category.sync = true;
      _updateCategoryState(db, category, category.id);
    }
  }

  Future<void> _deleteCategoryFromFirestore(
      Database db, String categoryId) async {
    serverCategories.removeWhere((map) => map['id'] == categoryId);
    bool result = await FireStoreHelper()
        .updateCategories(_user.uid, serverCategories.toList());
    if (result) {
      deletedCategories.remove(categoryId);
      db.delete('deletedCategories', where: 'id = ?', whereArgs: [categoryId]);
    }
  }

  bool _canUpdate() {
    return _user != null && serverCategories != null;
  }

  void _init(Stream categoriesStream, bool listening) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('categories');

    items = List.generate(maps.length, (index) => _fromMap(maps[index]))
        .reversed
        .toList();
    notifyListeners();

    final List<Map<String, dynamic>> deletedCategoriesMaps =
        await db.query('deletedCategories');

    deletedCategories = List.generate(deletedCategoriesMaps.length,
        (index) => deletedCategoriesMaps[index]['id']);

    if (listening == false) {
      categoriesStream.listen((event) {
        // categories list from firestore
        if (event != null) {
          serverCategories = event.toSet();

          if (items.isNotEmpty) {
            // we may have categories to upload or to delete
            Set<String> serverCategoriesIds =
                serverCategories.map((map) => map['id']).cast<String>().toSet();
            items
                .where((Category category) =>
                    !category.sync &&
                    !serverCategoriesIds.contains(category.id))
                .forEach((Category category) {
              // recipe to sync
              _syncCategory(db, category);
            });

            // check for categories to delete locally
            final Set<String> serverCategoiesId =
                serverCategories.map((e) => e['id']).cast<String>().toSet();

            final Set<String> firestoreDeletedCategoriesIds = items
                .where((Category category) =>
                    category.sync && !serverCategoiesId.contains(category.id))
                .map((Category category) => category.id)
                .toSet();

            items.removeWhere((Category category) =>
                firestoreDeletedCategoriesIds.contains(category.id));
            notifyListeners();

            if (firestoreDeletedCategoriesIds.isNotEmpty) {
              Batch batch = db.batch();

              firestoreDeletedCategoriesIds.forEach((String id) {
                batch.delete('categories', where: 'id = ?', whereArgs: [id]);
              });

              batch.commit(noResult: true);
            }
          }

          // check for recipe to delete from firestore
          deletedCategories.forEach((String categoryId) {
            // delete category to firestore
            _deleteCategoryFromFirestore(db, categoryId);
          });

          //check for category to download
          if (serverCategories.isNotEmpty) {
            Set<String> localCategoryId =
                items.map((Category category) => category.id).toSet();

            serverCategories
                .where((map) => !localCategoryId.contains(map['id']))
                .forEach((map) {
              Category category = _fromMap(map, sqlFormat: false);
              items.insert(0, category);
              notifyListeners();

              db.insert('categories', category.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace);
            });
          }
        }
      });
    }
  }

  List<Category> items = [];
  List<String> deletedCategories = [];

  Future<void> _updateCategoryState(
      Database db, Category category, String categoryId) async {
    await db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [categoryId]);
  }
}

Category _fromMap(Map<String, dynamic> data, {bool sqlFormat = true}) {
  return Category(
      id: data['id'],
      name: data['name'],
      sync: sqlFormat ? data['sync'] == 1 ? true : false : true,
      recipeIds: sqlFormat
          ? jsonDecode(data['recipeIds']).cast<String>()
          : data['recipeIds'].cast<String>());
}
