import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mesrecettes/models/recipe.dart';

class FireStoreHelper {
  final Firestore _firestore = Firestore.instance;

  FireStoreHelper() {
    _firestore.settings(persistenceEnabled: false);
  }

  Future<DocumentSnapshot> loadUserData(String uid) async {
    return (await _firestore.collection('users').document(uid).get());
  }

  Future<bool> addRecipe(Recipe recipe, String uid, List<String> recipeIds,
      {List<Map<String, dynamic>> categories}) async {
    DocumentReference recipeRef =
        _firestore.collection('recipes').document(recipe.id);

    WriteBatch batch = _firestore.batch();

    batch.setData(recipeRef, recipe.toMap(sqlFormat: false), merge: true);

    _updateUserData(batch, uid, recipeIds: recipeIds, categories: categories);

    return batch.commit().then((value) => true).catchError((error) => false);
  }

  Future<bool> updateRecipe(
      String oldRecipeId, Recipe newRecipe, String uid, List<String> recipeIds,
      {List<Map<String, dynamic>> categories}) async {
    DocumentReference oldRecipeRef =
        _firestore.collection('recipes').document(oldRecipeId);
    DocumentReference newRecipeRef =
        _firestore.collection('recipes').document(newRecipe.id);

    WriteBatch batch = _firestore.batch();

    batch.delete(oldRecipeRef);
    batch.setData(newRecipeRef, newRecipe.toMap(sqlFormat: false), merge: true);
    _updateUserData(batch, uid, recipeIds: recipeIds, categories: categories);

    return batch.commit().then((value) => true).catchError((error) => false);
  }

  Future<bool> deleteRecipe(String recipeId, String uid, List<String> recipeIds,
      {List<Map<String, dynamic>> categories}) async {
    DocumentReference recipeRef =
        _firestore.collection('recipes').document(recipeId);

    WriteBatch batch = _firestore.batch();

    batch.delete(recipeRef);

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
}

final FireStoreHelper fireStoreHelper = FireStoreHelper();
