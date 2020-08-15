import 'package:flutter/foundation.dart';

class Recipe {
  String id;
  String name;
  String picturePath;
  List<String> ingredients;
  List<String> steps;
  String notes;
  String cookTime, prepTime, people;

  Recipe(
      {this.name,
      this.ingredients,
      this.steps,
      this.notes,
      this.cookTime,
      this.prepTime,
      this.people,
      this.id});
}

class Recipes extends ChangeNotifier {
  void addRecipe(Recipe recipe) {
    items.add(recipe);
    notifyListeners();
  }

  void editRecipe(Recipe oldRecipe, Recipe newRecipe) {
    items.remove(oldRecipe);
    items.add(newRecipe);
    notifyListeners();
  }

  void removeRecipe(Recipe recipe) {
    items.remove(recipe);
    notifyListeners();
  }

  List<Recipe> items = [];
}
