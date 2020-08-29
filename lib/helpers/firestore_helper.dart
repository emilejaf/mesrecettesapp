import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:http/http.dart' as http;

class FireStoreHelper {
  final Firestore _firestore = Firestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://mesrecettes-2b213.appspot.com');

  FireStoreHelper() {
    _firestore.settings(persistenceEnabled: false);
  }

  Future<DocumentSnapshot> loadUserData(String uid) async {
    try {
      return (await _firestore.collection('users').document(uid).get());
    } catch (e) {
      return null;
    }
  }

  Future<bool> addRecipe(Recipe recipe, String uid, List<String> recipeIds,
      {List<Map<String, dynamic>> categories}) async {
    DocumentReference recipeRef =
        _firestore.collection('recipes').document(recipe.id);

    WriteBatch batch = _firestore.batch();

    batch.setData(recipeRef, recipe.toMap(sqlFormat: false), merge: true);

    _updateUserData(batch, uid, recipeIds: recipeIds, categories: categories);

    if (recipe.hasImage) {
      _uploadFile(File(recipe.path), recipe.id + '.jpg');
    }

    return batch.commit().then((value) => true).catchError((error) => false);
  }

  Future<bool> updateRecipe(String oldRecipeId, bool oldRecipeSync,
      bool oldHasImage, Recipe newRecipe, String uid, List<String> recipeIds,
      {List<Map<String, dynamic>> categories}) async {
    DocumentReference oldRecipeRef =
        _firestore.collection('recipes').document(oldRecipeId);
    DocumentReference newRecipeRef =
        _firestore.collection('recipes').document(newRecipe.id);

    WriteBatch batch = _firestore.batch();

    if (oldRecipeSync) {
      batch.delete(oldRecipeRef);
      if (oldHasImage) {
        _deleteFile(oldRecipeId + '.jpg');
      }
    }
    batch.setData(newRecipeRef, newRecipe.toMap(sqlFormat: false), merge: true);
    if (newRecipe.hasImage) {
      _uploadFile(File(newRecipe.path), newRecipe.id + '.jpg');
    }
    _updateUserData(batch, uid, recipeIds: recipeIds, categories: categories);

    return batch.commit().then((value) => true).catchError((error) => false);
  }

  Future<bool> deleteRecipe(
      String recipeId, bool hasImage, String uid, List<String> recipeIds,
      {List<Map<String, dynamic>> categories}) async {
    DocumentReference recipeRef =
        _firestore.collection('recipes').document(recipeId);

    WriteBatch batch = _firestore.batch();

    batch.delete(recipeRef);

    if (hasImage) {
      _deleteFile(recipeId + '.jpg');
    }

    _updateUserData(batch, uid, recipeIds: recipeIds, categories: categories);

    return batch.commit().then((value) => true).catchError((error) => false);
  }

  Future<Map<String, dynamic>> getRecipe(String recipeId) async {
    DocumentReference recipeRef =
        _firestore.collection('recipes').document(recipeId);

    DocumentSnapshot documentSnapshot = await recipeRef.get();

    if (documentSnapshot != null && documentSnapshot.exists) {
      return documentSnapshot.data;
    } else {
      return null;
    }
  }

  Future<bool> updateCategories(
      String uid, List<Map<String, dynamic>> categories) {
    WriteBatch batch = _firestore.batch();

    _updateUserData(batch, uid, categories: categories);

    return batch.commit().then((value) => true).catchError((error) => false);
  }

  void _updateUserData(WriteBatch batch, String uid,
      {List<String> recipeIds, List<Map<String, dynamic>> categories}) {
    DocumentReference userRef = _firestore.collection('users').document(uid);

    Map<String, dynamic> userData = {'uid': uid};

    if (recipeIds != null) {
      userData['recipeIds'] = recipeIds;
    }

    if (categories != null) {
      userData['categories'] = categories;
    }

    userData.removeWhere((key, value) => value == null);

    batch.setData(userRef, userData, merge: true);
  }

  void _uploadFile(File file, String fileName) {
    _storage.ref().child(fileName).putFile(file);
  }

  void _deleteFile(String fileName) {
    _storage.ref().child(fileName).delete();
  }

  Future<void> downloadFile(String fileName, String newFilePath) async {
    final String url = await _storage.ref().child(fileName).getDownloadURL();

    final http.Response downloadedData = await http.get(url);
    final File file = File(newFilePath);
    await file.writeAsBytes(downloadedData.bodyBytes);
  }
}

final FireStoreHelper fireStoreHelper = FireStoreHelper();
