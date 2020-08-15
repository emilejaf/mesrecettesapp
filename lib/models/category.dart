import 'package:flutter/cupertino.dart';

class Category {
  String name;
  List<String> recipeIds;

  Category({this.name, this.recipeIds});
}

class Categories extends ChangeNotifier {
  void addCategory(Category category) {
    items.add(category);
    notifyListeners();
  }

  void editName(Category category, String name) {
    category.name = name;
    notifyListeners();
  }

  List<Category> getCategoriesByRecipeId(String id) {
    return items
        .where((Category category) => category.recipeIds.contains(id))
        .toList();
  }

  void addRecipeId(List<Category> categories, String id) {
    items
        .where((category) => categories.contains(category))
        .forEach((category) {
      category.recipeIds.add(id);
    });
    notifyListeners();
  }

  void removeRecipeId(String id) {
    items.forEach((Category category) {
      if (category.recipeIds.contains(id)) {
        category.recipeIds.remove(id);
      }
    });
  }

  void removeCategoryAt(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  List<Category> items = [];
}
